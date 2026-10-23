import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EstoqueRepository {
  final Box _cacheBox = Hive.box('estoque_cache');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- LEITURA (OFFLINE-FIRST) ---
  List<Map<String, dynamic>> obterEstoqueLocal() {
    final List<dynamic> dadosDoCache = _cacheBox.get('lista_produtos', defaultValue: []);
    return dadosDoCache.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> sincronizarSrvParaLocal(String unidadeId) async {
    try {
      var conexao = await Connectivity().checkConnectivity();
      // Verificação de segurança caso esteja usando a versão mais recente do connectivity_plus (que retorna lista)
      bool semConexao = conexao is List ? conexao.contains(ConnectivityResult.none) : conexao == ConnectivityResult.none;
      if (semConexao) return; 

      final query = await _firestore
          .collection('unidades')
          .doc(unidadeId)
          .collection('produtos')
          .get();

      final List<Map<String, dynamic>> produtosAtualizados = query.docs.map((doc) {
        final dados = doc.data();
        dados['id'] = doc.id; 
        return dados;
      }).toList();

      await _cacheBox.put('lista_produtos', produtosAtualizados);
    } catch (e) {
      print("Erro ao sincronizar nuvem para o cache local: $e");
    }
  }

  // --- ESCRITA PADRÃO (Atualização Simples de Quantidade) ---
  Future<void> atualizarQuantidadeEstoque({
    required String unidadeId,
    required String produtoId,
    required double novaQuantidade,
  }) async {
    try {
      // 1. Atualização Instantânea no Cache Local
      final List<Map<String, dynamic>> estoqueAtual = obterEstoqueLocal();
      for (var produto in estoqueAtual) {
        if (produto['id'] == produtoId) {
          produto['qtd'] = novaQuantidade; // Mantendo a nomenclatura 'qtd' da interface
          break;
        }
      }
      await _cacheBox.put('lista_produtos', estoqueAtual);

      // 2. Tenta Nuvem, senão Fila Offline
      var conexao = await Connectivity().checkConnectivity();
      bool semConexao = conexao is List ? conexao.contains(ConnectivityResult.none) : conexao == ConnectivityResult.none;

      if (!semConexao) {
        await _firestore
            .collection('unidades')
            .doc(unidadeId)
            .collection('produtos')
            .doc(produtoId)
            .update({'qtd': novaQuantidade});
      } else {
        await _registrarMutacaoPendente({
          'tipo': 'UPDATE_SIMPLES',
          'unidadeId': unidadeId,
          'produtoId': produtoId,
          'qtd': novaQuantidade,
        });
      }
    } catch (e) {
      print("Erro ao atualizar estoque: $e");
    }
  }

  // --- ESCRITA CRÍTICA (Baixa Inteligente + Relatório de Desperdício) ---
  Future<void> registrarBaixaDesperdicio({
    required String unidadeId,
    required String produtoId,
    required String produtoNome,
    required double qtdReduzida,
    required double novoEstoqueAtual,
    required String motivo,
    required double custoPrejuizo,
    required String categoria,
    required String responsavel,
  }) async {
    try {
      // 1. Atualiza cache local instantaneamente para a UI não travar
      final List<Map<String, dynamic>> estoqueAtual = obterEstoqueLocal();
      for (var produto in estoqueAtual) {
        if (produto['id'] == produtoId) {
          produto['qtd'] = novoEstoqueAtual;
          break;
        }
      }
      await _cacheBox.put('lista_produtos', estoqueAtual);

      // Formata a data e o mês para o relatório
      final dataAtual = DateTime.now();
      final dataFormatada = "${dataAtual.day.toString().padLeft(2, '0')}/${dataAtual.month.toString().padLeft(2, '0')}";
      final mesTexto = _obterNomeMes(dataAtual.month);

      // Pacote de dados do Relatório
      final mapDesperdicio = {
        'produtoId': produtoId,
        'item': produtoNome,
        'qtd': "${qtdReduzida.toStringAsFixed(1)} un/kg",
        'motivo': motivo,
        'custo': custoPrejuizo,
        'categoria': categoria,
        'responsavel': responsavel,
        'data': dataFormatada,
        'mes': mesTexto,
        'timestamp': FieldValue.serverTimestamp(),
      };

      var conexao = await Connectivity().checkConnectivity();
      bool semConexao = conexao is List ? conexao.contains(ConnectivityResult.none) : conexao == ConnectivityResult.none;

      if (!semConexao) {
        // Gravação em Lote (Batch): Só confirma se ambos derem certo
        final batch = _firestore.batch();
        
        final docRefProduto = _firestore.collection('unidades').doc(unidadeId).collection('produtos').doc(produtoId);
        final docRefDesperdicio = _firestore.collection('unidades').doc(unidadeId).collection('desperdicios').doc();

        batch.update(docRefProduto, {'qtd': novoEstoqueAtual});
        // Removemos o FieldValue para resolver no servidor de fato, substituindo por DateTime pro batch local caso precise
        mapDesperdicio['timestamp'] = DateTime.now().millisecondsSinceEpoch; 
        batch.set(docRefDesperdicio, mapDesperdicio);

        await batch.commit();
      } else {
        // Envia as duas requisições combinadas para a fila offline
        await _registrarMutacaoPendente({
          'tipo': 'BAIXA_DESPERDICIO',
          'unidadeId': unidadeId,
          'produtoId': produtoId,
          'novoEstoqueAtual': novoEstoqueAtual,
          'dadosDesperdicio': mapDesperdicio,
        });
      }
    } catch (e) {
      print("Erro ao registrar baixa por desperdício: $e");
    }
  }

  // --- FILA DE CONTINGÊNCIA UNIFICADA (OFFLINE TO ONLINE) ---
  Future<void> _registrarMutacaoPendente(Map<String, dynamic> operacao) async {
    final List<dynamic> filaAtual = _cacheBox.get('fila_sincronizacao', defaultValue: []);
    final List<Map<String, dynamic>> novaFila = filaAtual.map((e) => Map<String, dynamic>.from(e)).toList();

    operacao['timestampFila'] = DateTime.now().millisecondsSinceEpoch;
    novaFila.add(operacao);

    await _cacheBox.put('fila_sincronizacao', novaFila);
  }

  // Processa a fila resolvendo se é uma atualização simples ou uma baixa complexa (com relatório)
  Future<void> processarFilaOffline() async {
    var conexao = await Connectivity().checkConnectivity();
    bool semConexao = conexao is List ? conexao.contains(ConnectivityResult.none) : conexao == ConnectivityResult.none;
    if (semConexao) return;

    final List<dynamic> filaRaw = _cacheBox.get('fila_sincronizacao', defaultValue: []);
    if (filaRaw.isEmpty) return;

    final List<Map<String, dynamic>> fila = filaRaw.map((e) => Map<String, dynamic>.from(e)).toList();
    print("Conexão reestabelecida! Sincronizando ${fila.length} alterações pendentes...");

    final batch = _firestore.batch();

    for (var mutacao in fila) {
      final unidadeId = mutacao['unidadeId'];
      final produtoId = mutacao['produtoId'];

      if (mutacao['tipo'] == 'UPDATE_SIMPLES') {
        final docRef = _firestore.collection('unidades').doc(unidadeId).collection('produtos').doc(produtoId);
        batch.update(docRef, {'qtd': mutacao['qtd']});
      } 
      else if (mutacao['tipo'] == 'BAIXA_DESPERDICIO') {
        final docRefProduto = _firestore.collection('unidades').doc(unidadeId).collection('produtos').doc(produtoId);
        final docRefDesperdicio = _firestore.collection('unidades').doc(unidadeId).collection('desperdicios').doc();
        
        batch.update(docRefProduto, {'qtd': mutacao['novoEstoqueAtual']});
        batch.set(docRefDesperdicio, mutacao['dadosDesperdicio']);
      }
    }

    await batch.commit();
    await _cacheBox.put('fila_sincronizacao', []);
    print("Fila offline sincronizada com sucesso!");
  }

  // Utilitário simples para não depender de pacotes externos como intl
  String _obterNomeMes(int mes) {
    const meses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
    return meses[mes - 1];
  }
}
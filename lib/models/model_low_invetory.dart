import 'package:flutter/material.dart';

class ModalBaixaEstoque extends StatefulWidget {
  final String produtoNome;
  final double precoCusto;
  final String categoria;
  final double estoqueAtual;
  final bool podeVerCustos; // 🛡️ Trava de segurança para esconder o preço

  const ModalBaixaEstoque({
    super.key,
    required this.produtoNome,
    required this.precoCusto,
    required this.categoria,
    required this.estoqueAtual,
    this.podeVerCustos = false, // Por padrão, ninguém vê o custo até que se prove o contrário (Gerente/Patrão)
  });

  @override
  State<ModalBaixaEstoque> createState() => _ModalBaixaEstoqueState();
}

class _ModalBaixaEstoqueState extends State<ModalBaixaEstoque> {
  final TextEditingController _qtdController = TextEditingController();
  String _motivoSelecionado = "Quebra / Preparo";
  
  // Simulando as configurações de Governança Premium do Patrão
  final bool _isPlanoPremium = true;
  final bool _alertaAtivadoPeloPatrao = true;
  final double _reguaCorteCritica = 100.00; // Limite configurado pelo patrão

  final List<String> _motivos = [
    "Quebra / Preparo",
    "Produto Vencido",
    "Avaria / Estragado",
    "Uso Interno / Teste"
  ];

  double _quantidadeInserida = 0.0;

  @override
  void initState() {
    super.initState();
    _qtdController.addListener(() {
      setState(() {
        _quantidadeInserida = double.tryParse(_qtdController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _qtdController.dispose();
    super.dispose();
  }

  // Cálculo do prejuízo em tempo real (Roda invisível para o funcionário)
  double get _prejuizoCalculado => _quantidadeInserida * widget.precoCusto;

  // Define se a quebra é considerada de gravidade CRÍTICA
  bool get _isGravidadeCritica => _prejuizoCalculado >= _reguaCorteCritica;

  // 🛡️ Lógica Visual: Se não puder ver os custos, a cor será sempre o Azul Neutro.
  Color get _corInterfaceAtiva {
    if (widget.podeVerCustos && _isGravidadeCritica) {
      return Colors.redAccent.shade400; 
    }
    return const Color(0xFF2979FF); 
  }

  void _processarBaixa() async {
    if (_quantidadeInserida <= 0 || _quantidadeInserida > widget.estoqueAtual) {
      _mostrarAviso("Quantidade inválida ou superior ao estoque atual.");
      return;
    }

    // Se for Premium e atingir a régua de corte, simula o disparo do push (Invisível para o funcionário)
    if (_isPlanoPremium && _alertaAtivadoPeloPatrao && _isGravidadeCritica) {
      // 🛰️ INTEGRADO COM O SERVIÇO DE PUSH (Firebase Cloud Messaging)
      // _fcmService.enviarAlertaGerente(widget.produtoNome, _prejuizoCalculado, _motivoSelecionado);
      
      // Simulação visual de que o alerta foi disparado (Em produção, o funcionário não veria isso)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🚨 ALERTA: Notificação enviada à Gestão!"),
          backgroundColor: Colors.redAccent.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Estoque atualizado com sucesso."),
        backgroundColor: Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("REGISTRAR BAIXA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
              // 🛡️ Só renderiza o selo de gravidade se puder ver os custos
              if (widget.podeVerCustos) _buildBadgeGravidade(isEscuro),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.produtoNome.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor)),
          const SizedBox(height: 24),

          // Campo de Quantidade
          TextField(
            controller: _qtdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w700),
            decoration: _inputDecorationStyle("Quantidade a ser reduzida (Estoque: ${widget.estoqueAtual})"),
          ),
          const SizedBox(height: 16),

          // Dropdown de Motivos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _motivoSelecionado,
                dropdownColor: cardColor,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: baseTextColor),
                style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w700, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _motivoSelecionado = newValue);
                },
                items: _motivos.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
              ),
            ),
          ),
          
          // 🛡️ Painel de Prejuízo oculto para funcionários
          if (widget.podeVerCustos) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isGravidadeCritica ? Colors.redAccent.shade400.withOpacity(0.05) : const Color(0xFF2979FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isGravidadeCritica ? Colors.redAccent.shade400.withOpacity(0.2) : const Color(0xFF2979FF).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PREJUÍZO ESTIMADO", style: TextStyle(fontSize: 10, color: hintColor, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text("R\$ ${_prejuizoCalculado.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _isGravidadeCritica ? Colors.redAccent.shade400 : baseTextColor)),
                    ],
                  ),
                  Icon(
                    _isGravidadeCritica ? Icons.gavel_rounded : Icons.trending_down_rounded, 
                    color: _isGravidadeCritica ? Colors.redAccent.shade400 : const Color(0xFF2979FF), 
                    size: 28
                  )
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16), // Espaçamento menor caso o card não exista
          ],

          const SizedBox(height: 32),
          
          // Botão de Confirmação Final (Usa a cor baseada na permissão)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _corInterfaceAtiva,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _processarBaixa,
              child: const Text("CONFIRMAR CONTA DE BAIXA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGravidade(bool isEscuro) {
    final Color corBadge = _isGravidadeCritica ? Colors.redAccent.shade400 : const Color(0xFF00E676);
    final String textoBadge = _isGravidadeCritica ? "GRAVIDADE: CRÍTICA" : "GRAVIDADE: NORMAL";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: corBadge.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: corBadge.withOpacity(0.3))
      ),
      child: Text(
        textoBadge,
        style: TextStyle(color: corBadge, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
      ),
    );
  }

  InputDecoration _inputDecorationStyle(String label) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _corInterfaceAtiva, width: 1.0)),
    );
  }

  void _mostrarAviso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.orangeAccent.shade700, behavior: SnackBarBehavior.floating));
  }
}
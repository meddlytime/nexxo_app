import 'package:flutter/material.dart';

// 1. O ENUM SUPORTA OS 3 NÍVEIS COMERCIAIS
enum TipoPlano { basico, medio, premium }

class RegrasPlano {
  final TipoPlano tipo;

  RegrasPlano(this.tipo);

  // 🚧 CONTROLE DE AMBIENTE DE TESTES 🚧
  // Mude para 'false' para puxar as regras reais do Firestore imediatamente
  static const bool _emModoTeste = true;

  // 🛰️ CONSTRUTOR FACTORY ATUALIZADO PARA O FIRESTORE
  factory RegrasPlano.fromFirestore(String? planoString) {
    if (_emModoTeste) {
      return RegrasPlano(TipoPlano.premium); // Força Premium global para testes rápidos
    }

    switch (planoString?.trim().toLowerCase()) {
      case 'premium':
        return RegrasPlano(TipoPlano.premium);
      case 'medio':
      case 'intermediario':
        return RegrasPlano(TipoPlano.medio);
      case 'basico':
      default:
        return RegrasPlano(TipoPlano.basico); // Fallback seguro
    }
  }

  // --- 🧠 FEATURE FLAGS: REGRAS DE INTERFACE ---
  
  // Multi-loja: Apenas as grandes redes do Premium visualizam e alternam filiais
  bool get possuiMultiLoja => tipo == TipoPlano.premium;
  
  // Relatório Reduzido (A isca): O Básico ganha o direito de ver o Top 3 de desperdício em texto
  bool get possuiRelatorioReduzido => tipo == TipoPlano.basico || tipo == TipoPlano.medio || tipo == TipoPlano.premium;

  // Relatórios Avançados: Gráficos de pizza, faturamento mensal e painéis robustos (Médio e Premium)
  bool get possuiRelatoriosAvancados => tipo == TipoPlano.medio || tipo == TipoPlano.premium;

  // Top 3 Campeões de Saídas: Recurso estratégico unificado para o plano Premium
  bool get possuiTopSaidasConsolidado => tipo == TipoPlano.premium;

  // Fluxo de Gerência Remota: Notificações e solicitações à distância na Dashboard (Premium)
  bool get exigeFluxoGerenteRemoto => tipo == TipoPlano.premium;

  // 🚀 NOVO: Exportação de Dados Corporativos (PDF/Excel de relatórios e listas de compras)
  bool get possuiExportacaoPlanilhas => tipo == TipoPlano.medio || tipo == TipoPlano.premium;


  // --- 📊 LIMITES OPERACIONAIS SINTONIZADOS ---
  
  int get maxCategorias => tipo == TipoPlano.basico ? 5 : 999; // Ilimitado do Médio para cima
  int get maxColaboradores => tipo == TipoPlano.premium ? 999 : (tipo == TipoPlano.medio ? 10 : 2);
  
  // 🚀 NOVO: Limite físico de itens distintos cadastrados no inventário
  int get maxItensInventario => tipo == TipoPlano.premium ? 9999 : (tipo == TipoPlano.medio ? 250 : 50);

  // 🚀 NOVO: Janela retroativa de dias no histórico de auditoria (Auditar o passado da empresa)
  int get diasHistoricoDisponiveis => tipo == TipoPlano.premium ? 90 : (tipo == TipoPlano.medio ? 30 : 7);


  // --- 🎨 DESIGNERS E LABELS ADAPTATIVOS ---
  String get tagPlano {
    switch (tipo) {
      case TipoPlano.premium: return "PREMIUM CORPORATIVO";
      case TipoPlano.medio: return "MÉDIO GESTOR";
      case TipoPlano.basico: return "BÁSICO OPERACIONAL";
    }
  }

  Color get corPlano {
    switch (tipo) {
      case TipoPlano.premium: return Colors.amber;
      case TipoPlano.medio: return Colors.purpleAccent; // Cor intermediária elegante
      case TipoPlano.basico: return Colors.blueAccent;
    }
  }
}

// 🧠 EXTENSION FACILITADORA PARA O STREAM DO FIRESTORE
extension FirestoreDataToRegrasExtension on Map<String, dynamic> {
  RegrasPlano get regras {
    return RegrasPlano.fromFirestore(this['plano'] as String?);
  }
}
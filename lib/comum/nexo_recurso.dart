import 'package:flutter/material.dart';

enum NexoRecurso {
  previsaoDemanda,
  moduloFinanceiro,
  colaboradoresIlimitados;

  String get titulo {
    switch (this) {
      case NexoRecurso.previsaoDemanda:
        return "PREVISÃO DE DEMANDA";
      case NexoRecurso.moduloFinanceiro:
        return "MÓDULO FINANCEIRO AVANÇADO";
      case NexoRecurso.colaboradoresIlimitados:
        return "EQUIPE ILIMITADA";
    }
  }

  String get descricao {
    switch (this) {
      case NexoRecurso.previsaoDemanda:
        return "Ative o motor preditivo e saiba exatamente quando os insumos da cozinha vão acabar antes do fim de semana chegar.";
      case NexoRecurso.moduloFinanceiro:
        return "Visualize gráficos de desperdício, custo de mercadoria vendida (CMV) e valor imobilizado em tempo real.";
      case NexoRecurso.colaboradoresIlimitados:
        return "Cadastre quantos funcionários, caixas e cozinheiros precisar para operar a unidade sem travas de limite.";
    }
  }

  IconData get icone {
    switch (this) {
      case NexoRecurso.previsaoDemanda:
        return Icons.auto_graph_rounded;
      case NexoRecurso.moduloFinanceiro:
        return Icons.account_balance_wallet_rounded;
      case NexoRecurso.colaboradoresIlimitados:
        return Icons.people_alt_rounded;
    }
  }
}
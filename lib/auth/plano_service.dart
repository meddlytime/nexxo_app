import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'controle_plano.dart';

class PlanoService extends ChangeNotifier {
  RegrasPlano _regras = RegrasPlano(TipoPlano.basico);
  RegrasPlano get regras => _regras;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// ⏳ Verifica se o cache expirou (mais de 24h)
  Future<bool> _isCacheExpirado() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaSinc = prefs.getInt('ultima_sinc') ?? 0;
    final agora = DateTime.now().millisecondsSinceEpoch;
    // 24 horas em milissegundos
    return (agora - ultimaSinc) > (24 * 60 * 60 * 1000);
  }

  Future<void> carregarPlanoLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planoSalvo = prefs.getString('plano_usuario') ?? 'basico';
      _regras = RegrasPlano.fromFirestore(planoSalvo);
      
      // Se estiver expirado, ele marca para sincronizar (a UI pode tratar isso)
      if (await _isCacheExpirado()) {
        debugPrint("Cache de plano expirado. Necessário sincronizar com Firestore.");
      }
    } catch (e) {
      _regras = RegrasPlano(TipoPlano.basico);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🛰️ Atualiza e registra a data da sincronização
  Future<void> atualizarPlanoDoUsuario(String? stringDoFirestore) async {
    if (stringDoFirestore == null || stringDoFirestore.isEmpty) return;

    _regras = RegrasPlano.fromFirestore(stringDoFirestore);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plano_usuario', stringDoFirestore.toLowerCase());
    // Grava o momento exato da sincronização
    await prefs.setInt('ultima_sinc', DateTime.now().millisecondsSinceEpoch);
    
    notifyListeners();
  }

  Future<void> resetarPlanoAoDeslogar() async {
    _regras = RegrasPlano(TipoPlano.basico);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('plano_usuario');
    await prefs.remove('ultima_sinc');
    notifyListeners();
  }
}

final planoService = PlanoService();
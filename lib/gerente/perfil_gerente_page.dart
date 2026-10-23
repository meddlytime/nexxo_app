import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app_estoque/auth/login_page.dart';
import 'package:app_estoque/auth/plano_service.dart';
import 'package:app_estoque/auth/controle_plano.dart';

// Novos imports do Paywall Centralizado
import 'package:app_estoque/comum/nexo_recurso.dart';
import 'package:app_estoque/comum/nexo_paywall_page.dart';

class PerfilGerentePage extends StatefulWidget {
  final int nivelFinanceiro;

  const PerfilGerentePage({
    super.key, 
    this.nivelFinanceiro = 1,
  });

  @override
  State<PerfilGerentePage> createState() => _PerfilGerentePageState();
}

class _PerfilGerentePageState extends State<PerfilGerentePage> {
  // Diretriz estética Nexo Obsidian
  static const Color accentColor = Color(0xFF00E676);

  // Dados do perfil (Simulando leitura/escrita do Firebase)
  String _nomeGerente = "Gerente Carlos";
  String _emailGerente = "carlos.gerente@vilagourmet.com";
  String _telefoneGerente = "(11) 99999-8888";

  // Configurações de Notificação (Simulando persistência local/Firebase)
  bool _notificarMovimentacao = true;
  bool _notificarNovaEquipe = false;
  bool _notificarEstoqueCritico = true;

  final List<Map<String, String>> _funcionarios = [
    {"nome": "Ronaldo Cozinha", "cargo": "Chef de Turno", "pin": "4812"},
    {"nome": "Amanda Silva", "cargo": "Operadora de Caixa", "pin": "9182"},
    {"nome": "Marcos Souza", "cargo": "Auxiliar de Estoque", "pin": "3341"},
  ];

  // --- RETORNA O NOME DO CARGO CONECTADO AO COORDENADOR DE PLANOS ---
  String _obterCargoPorPlano() {
    final tipo = planoService.regras.tipo;
    if (tipo == TipoPlano.premium) return "GERENTE PREMIUM (ACESSO TOTAL)";
    if (tipo == TipoPlano.medio) return "GERENTE SUPERVISOR (PLANO MÉDIO)";
    return "ACESSO NÃO AUTORIZADO (PLANO BÁSICO)";
  }

  // --- MODAL DE EDIÇÃO DE DADOS (NEXO OBSIDIAN) ---
  void _abrirModalEditarDados(ThemeData theme, Color baseTextColor, Color cardColor, Color hintColor, bool isEscuro) {
    final nomeController = TextEditingController(text: _nomeGerente);
    final emailController = TextEditingController(text: _emailGerente);
    final telefoneController = TextEditingController(text: _telefoneGerente);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final double paddingBottom = MediaQuery.of(context).padding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset > 0 ? bottomInset + 24 : paddingBottom + 24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EDITAR INFORMAÇÕES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text("Essas alterações serão sincronizadas com seu cadastro principal.", style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: nomeController,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Nome Completo", isEscuro: isEscuro, hintColor: hintColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "E-mail Corporativo", isEscuro: isEscuro, hintColor: hintColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Telefone", isEscuro: isEscuro, hintColor: hintColor),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, 
                        elevation: 0, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                      onPressed: () {
                        setState(() {
                          _nomeGerente = nomeController.text.trim();
                          _emailGerente = emailController.text.trim();
                          _telefoneGerente = telefoneController.text.trim();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dados sincronizados com o Cloud Firestore!"), backgroundColor: accentColor, behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: const Text("SALVAR ALTERAÇÕES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- MODAL DE CONFIGURAÇÕES DE NOTIFICAÇÃO (NEXO OBSIDIAN) ---
  void _abrirModalNotificacoes(ThemeData theme, Color baseTextColor, Color cardColor, Color hintColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CONFIGURAÇÃO DE ALERTAS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text("Gerencie quais eventos disparam push notifications na sua central.", style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                _buildSwitchTile("Movimentações de Histórico", "Notificar entradas ou baixas de equipe.", _notificarMovimentacao, (v) {
                  setModalState(() => _notificarMovimentacao = v);
                  setState(() {});
                }, baseTextColor, hintColor, theme),
                Divider(color: theme.dividerColor.withOpacity(0.05), height: 1),
                _buildSwitchTile("Alertas de Equipe Local", "Avisar quando novos pins forem ativados.", _notificarNovaEquipe, (v) {
                  setModalState(() => _notificarNovaEquipe = v);
                  setState(() {});
                }, baseTextColor, hintColor, theme),
                Divider(color: theme.dividerColor.withOpacity(0.05), height: 1),
                _buildSwitchTile("Quebras Críticas de Estoque", "Aviso imediato se um insumo atingir a régua mínima.", _notificarEstoqueCritico, (v) {
                  setModalState(() => _notificarEstoqueCritico = v);
                  setState(() {});
                }, baseTextColor, hintColor, theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, ValueChanged<bool> onChanged, Color baseTextColor, Color hintColor, ThemeData theme) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: baseTextColor)),
      subtitle: Text(sub, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
      activeColor: accentColor,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);
    final borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("MEU PERFIL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: baseTextColor, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // CABEÇALHO DO PERFIL
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: accentColor.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, size: 45, color: accentColor),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2)
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 14, color: baseTextColor),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(_nomeGerente.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(_obterCargoPorPlano(), style: const TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text("UNIDADE CENTRO - VILA GOURMET", style: TextStyle(color: hintColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: planoService.regras.corPlano.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: planoService.regras.corPlano.withOpacity(0.3))
                  ),
                  child: Text(
                    planoService.regras.tagPlano.toUpperCase(),
                    style: TextStyle(color: planoService.regras.corPlano, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          _buildTituloSecao("CONTA"),
          _buildOptionTile(Icons.person_outline_rounded, "EDITAR DADOS", "Nome, e-mail e telefone", cardColor, borderColor, hintColor, baseTextColor, 
            onTap: () => _abrirModalEditarDados(theme, baseTextColor, cardColor, hintColor, isEscuro)),
          _buildOptionTile(Icons.lock_outline_rounded, "ALTERAR SENHA", "Mantenha sua credencial segura", cardColor, borderColor, hintColor, baseTextColor, onTap: () {}),
          
          const SizedBox(height: 24),
          _buildTituloSecao("PERMISSÕES DA UNIDADE"),
          _buildOptionTile(Icons.notifications_none_rounded, "NOTIFICAÇÕES", "Alertas de estoque, equipe e fluxo", cardColor, borderColor, hintColor, baseTextColor, 
            onTap: () => _abrirModalNotificacoes(theme, baseTextColor, cardColor, hintColor)),
          
          _buildOptionTile(
            Icons.people_alt_outlined, 
            "GERENCIAR EQUIPE", 
            "${_funcionarios.length} operadores sob sua gerência", 
            cardColor, borderColor, hintColor, baseTextColor,
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, color: accentColor, size: 16),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => _buildSubTelaFuncionarios(theme, baseTextColor, cardColor, bgColor, borderColor, hintColor, isEscuro)));
            }
          ),

          _buildOptionTile(
            Icons.account_balance_wallet_outlined, 
            "MÓDULO FINANCEIRO", 
            widget.nivelFinanceiro == 2 
                ? "Acesso Total (Custos e Estoque)" 
                : widget.nivelFinanceiro == 1 
                    ? "Acesso Limitado (Apenas Estoque)" 
                    : "Acesso Bloqueado",
            cardColor, borderColor, hintColor, baseTextColor,
            trailing: Icon(
              widget.nivelFinanceiro == 2 
                  ? Icons.verified_user_rounded 
                  : widget.nivelFinanceiro == 1 
                      ? Icons.visibility_rounded 
                      : Icons.lock_outline_rounded, 
              color: widget.nivelFinanceiro > 0 ? accentColor : hintColor,
              size: 20
            ),
            onTap: () {}
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.power_settings_new_rounded, color: Colors.redAccent.shade400, size: 20),
              label: Text("ENCERRAR SESSÃO", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.shade400.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.redAccent.shade400.withOpacity(0.2))),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubTelaFuncionarios(ThemeData theme, Color baseTextColor, Color cardColor, Color bgColor, Color borderColor, Color hintColor, bool isEscuro) {
    return StatefulBuilder(
      builder: (context, setSubState) {
        final regras = planoService.regras;

        void dispararAdicao() {
          if (_funcionarios.length >= regras.maxColaboradores) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("LIMITE ATINGIDO! Plano atual permite ${regras.maxColaboradores} membros.", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                backgroundColor: Colors.orangeAccent.shade700,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: "UPGRADE",
                  textColor: Colors.black,
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      // 🚀 CHAMA O PAYWALL CENTRALIZADO
                      builder: (context) => const NexoPaywallPage(recurso: NexoRecurso.colaboradoresIlimitados)
                    )
                  ),
                ),
              ),
            );
            return;
          }

          String nome = "";
          String cargo = "Cozinha";

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text("CADASTRAR OPERADOR", style: TextStyle(color: baseTextColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Nome Completo", isEscuro: isEscuro, hintColor: hintColor),
                    onChanged: (v) => nome = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: cargo,
                    dropdownColor: cardColor,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Setor", isEscuro: isEscuro, hintColor: hintColor),
                    items: ["Cozinha", "Caixa", "Estoque", "Atendimento"].map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                    onChanged: (v) => cargo = v ?? "Cozinha",
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: Text("CANCELAR", style: TextStyle(color: hintColor, fontWeight: FontWeight.w900, fontSize: 11))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    if (nome.trim().isNotEmpty) {
                      setState(() => _funcionarios.add({"nome": nome, "cargo": cargo, "pin": (1000 + _funcionarios.length * 9).toString()}));
                      setSubState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("SALVAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text("EQUIPE LOCAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
            backgroundColor: Colors.transparent, 
            elevation: 0,
            iconTheme: IconThemeData(color: baseTextColor),
            actions: [
              IconButton(icon: const Icon(Icons.person_add_alt_1_rounded, color: accentColor), onPressed: dispararAdicao),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: _funcionarios.length,
            itemBuilder: (ctx, index) {
              final func = _funcionarios[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor)
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: accentColor.withOpacity(0.1), child: const Icon(Icons.badge_outlined, color: accentColor, size: 20)),
                  title: Text(func["nome"]!.toUpperCase(), style: TextStyle(color: baseTextColor, fontSize: 13, fontWeight: FontWeight.w900)),
                  subtitle: Text("${func["cargo"]} • PIN: ${func["pin"]}", style: TextStyle(color: hintColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade400, size: 22),
                    onPressed: () {
                      setState(() => _funcionarios.removeAt(index));
                      setSubState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTituloSecao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        titulo, 
        style: const TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon, 
    String title, 
    String sub, 
    Color cardColor, 
    Color borderColor,
    Color hintColor,
    Color baseTextColor, 
    {Widget? trailing, required VoidCallback onTap}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: hintColor, size: 22),
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 0.2)),
        subtitle: Text(sub, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: hintColor.withOpacity(0.5), size: 20),
        onTap: onTap,
      ),
    );
  }

  InputDecoration _inputStyleField({required String label, required bool isEscuro, required Color hintColor}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: hintColor, fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accentColor, width: 1.0)),
    );
  }
}
import 'package:flutter/material.dart';

class DetalhesFuncionarioPage extends StatefulWidget {
  final String idDocumento;
  final String nome;
  final String cargo;
  final String acesso;
  final String codigo;

  const DetalhesFuncionarioPage({
    super.key,
    required this.idDocumento,
    required this.nome,
    required this.cargo,
    required this.acesso,
    required this.codigo,
  });

  @override
  State<DetalhesFuncionarioPage> createState() => _DetalhesFuncionarioPageState();
}

class _DetalhesFuncionarioPageState extends State<DetalhesFuncionarioPage> {
  bool _isDeleting = false;
  static const Color accentColor = Color(0xFF00E676);

  void _confirmarExclusao(bool isEscuro, Color baseTextColor, Color hintColor, Color cardColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Excluir colaborador?", style: TextStyle(color: baseTextColor, fontSize: 16, fontWeight: FontWeight.w900)),
        content: Text(
          "Tem certeza que deseja remover ${widget.nome} do sistema? Esta ação apagará o PIN e o acesso imediatamente.",
          style: TextStyle(color: hintColor, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: hintColor, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isDeleting = true);
              await Future.delayed(const Duration(milliseconds: 1000));
              if (!mounted) return;
              setState(() => _isDeleting = false);
              
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${widget.nome} foi removido com sucesso."), behavior: SnackBarBehavior.floating)
              );
            }, 
            child: Text("EXCLUIR", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("PERFIL DO COLABORADOR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: baseTextColor, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: accentColor, size: 20),
            onPressed: _isDeleting ? null : () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
                child: const CircleAvatar(radius: 45, backgroundColor: accentColor, child: Icon(Icons.person_rounded, size: 45, color: Colors.black)),
              ),
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text("CÓDIGO DE ACESSO MASTER", style: TextStyle(fontSize: 10, color: hintColor, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text(widget.codigo, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8, color: accentColor)),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              _buildInfoRow("Nome Registrado", widget.nome, baseTextColor, hintColor),
              _buildInfoRow("Função", widget.cargo, baseTextColor, hintColor),
              _buildInfoRow("Nível de Permissão", widget.acesso, baseTextColor, hintColor),
              
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton.icon(
                  onPressed: _isDeleting ? null : () => _confirmarExclusao(isEscuro, baseTextColor, hintColor, cardColor),
                  icon: _isDeleting ? const SizedBox() : Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade400, size: 18),
                  label: _isDeleting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2))
                      : Text("EXCLUIR COLABORADOR", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color baseTextColor, Color hintColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: baseTextColor)),
        ],
      ),
    );
  }
}
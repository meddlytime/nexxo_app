import 'package:flutter/material.dart';

class ConfigTerminalPage extends StatefulWidget {
  const ConfigTerminalPage({super.key});

  @override
  State<ConfigTerminalPage> createState() => _ConfigTerminalPageState();
}

class _ConfigTerminalPageState extends State<ConfigTerminalPage> {
  bool _exigirPin = true;
  bool _exigirNome = true;
  bool _isSaving = false;

  final List<TextEditingController> _controllers = [
    TextEditingController(text: "Kitchen"),
    TextEditingController(text: "Bar"),
    TextEditingController(text: "Salon"),
  ];

  final List<IconData> _iconesSelecionados = [
    Icons.restaurant_menu,
    Icons.local_bar,
    Icons.assignment_turned_in_rounded, 
  ];

  final List<IconData> _iconesDisponiveis = [
    Icons.restaurant_menu,       
    Icons.local_bar,             
    Icons.local_cafe,            
    Icons.local_fire_department, 
    Icons.shopping_bag,          
  ];

  static const Color accentColor = Color(0xFF00E676);

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("CONFIGURE TERMINAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: baseTextColor, letterSpacing: 1.5)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: hintColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0),
            tabs: const [
              Tab(text: "BUTTON 01"),
              Tab(text: "BUTTON 02"),
              Tab(text: "BUTTON 03"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSwitchRow(Icons.lock_outline_rounded, "Require PIN for shift", _exigirPin, (v) => setState(() => _exigirPin = v), isEscuro, baseTextColor, hintColor),
                  const SizedBox(height: 16),
                  _buildSwitchRow(Icons.badge_outlined, "Require Name in logs", _exigirNome, (v) => setState(() => _exigirNome = v), isEscuro, baseTextColor, hintColor),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [0, 1, 2].map((i) => _buildPainelConfiguracaoBotao(i, isEscuro, baseTextColor, cardColor, hintColor)).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                await Future.delayed(const Duration(milliseconds: 800));
                if (!mounted) return;
                setState(() => _isSaving = false);
                Navigator.pop(context);
              },
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("SAVE CONFIGURATION", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPainelConfiguracaoBotao(int index, bool isEscuro, Color baseTextColor, Color cardColor, Color hintColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BUTTON NAME", style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          TextField(
            controller: _controllers[index],
            style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: _inputStyle(isEscuro),
          ),
          const SizedBox(height: 32),
          Text("VISUAL ICON", style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _iconesDisponiveis.map((iconData) {
              bool selecionado = _iconesSelecionados[index] == iconData;
              return InkWell(
                onTap: () => setState(() => _iconesSelecionados[index] = iconData),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selecionado ? accentColor.withOpacity(0.1) : cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selecionado ? accentColor : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
                  ),
                  child: Icon(iconData, color: selecionado ? accentColor : hintColor, size: 24),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(IconData icon, String title, bool value, Function(bool) onChanged, bool isEscuro, Color baseTextColor, Color hintColor) {
    return Row(
      children: [
        Icon(icon, color: hintColor, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accentColor,
          activeTrackColor: accentColor.withOpacity(0.2),
        ),
      ],
    );
  }

  InputDecoration _inputStyle(bool isEscuro) {
    return InputDecoration(
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: accentColor, width: 1.0)),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isScannerActive = true;

  void _processarCodigo(String codigo) async {
    setState(() => _isScannerActive = false); // Pausa o scanner para dialogar

    // Aqui você buscaria o produto no Firestore pelo código
    final quantidade = await _showDialogQuantidade(codigo);

    if (quantidade != null) {
      // Aqui você salvaria no Firestore: 
      // await FirebaseFirestore.instance.collection('estoque')...
      print("Salvando $quantidade unidades do produto $codigo");
    }

    setState(() => _isScannerActive = true); // Retoma o scanner
  }

  Future<int?> _showDialogQuantidade(String codigo) {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Produto: $codigo"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Quantidade"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner de Inventário")),
      body: _isScannerActive 
        ? MobileScanner(onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              _processarCodigo(barcodes.first.rawValue ?? "Desconhecido");
            }
          })
        : const Center(child: CircularProgressIndicator()),
    );
  }
}
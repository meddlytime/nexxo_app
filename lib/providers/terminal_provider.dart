import 'package:flutter_riverpod/flutter_riverpod.dart';

class TerminalInfo {
  final String storeId;
  final String storeName;
  final String sectorName;

  const TerminalInfo({
    required this.storeId,
    required this.storeName,
    required this.sectorName,
  });
}

class TerminalNotifier extends StateNotifier<TerminalInfo?> {
  TerminalNotifier()
      : super(const TerminalInfo(
          storeId: "store_01",
          storeName: "Downtown Unit",
          sectorName: "Main POS",
        ));

  void updateTerminal(String storeName, String sector) {
    state = TerminalInfo(
      storeId: state?.storeId ?? "store_01",
      storeName: storeName,
      sectorName: sector,
    );
  }

  void clearTerminal() {
    state = null;
  }
}

final terminalProvider =
    StateNotifierProvider<TerminalNotifier, TerminalInfo?>((ref) {
  return TerminalNotifier();
});
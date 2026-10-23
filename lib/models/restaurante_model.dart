class RestauranteModel {
  final String id;
  final String nome;
  final String plano; // Aqui vai vir "basico" ou "premium" do Firestore

  RestauranteModel({
    required this.id,
    required this.nome,
    required this.plano,
  });

  // Transforma o documento do Firestore em um Objeto do Flutter
  factory RestauranteModel.fromFirestore(Map<String, dynamic> doc, String id) {
    return RestauranteModel(
      id: id,
      nome: doc['nome'] ?? 'Sem nome',
      plano: doc['plano'] ?? 'basico', // Caso não exista, assume o básico por segurança
    );
  }
}
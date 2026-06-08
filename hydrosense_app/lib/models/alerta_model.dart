class AlertaModel {
  final int? id;
  final String timestamp;
  final String tipo;
  final String descricao;

  AlertaModel({
    this.id,
    required this.timestamp,
    required this.tipo,
    required this.descricao,
  });

  factory AlertaModel.fromMap(Map<String, dynamic> map) {
    return AlertaModel(
      id: map['id'],
      timestamp: map['timestamp'],
      tipo: map['tipo'],
      descricao: map['descricao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp,
      'tipo': tipo,
      'descricao': descricao,
    };
  }
}
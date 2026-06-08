class LeituraModel {
  final int? id;
  final String timestamp;
  final int umidadeSolo;
  final double pressaoHpa;
  final int nivelReservCm;
  final int chuvaDetectada;
  final int valvulaAtiva;   

  LeituraModel({
    this.id,
    required this.timestamp,
    required this.umidadeSolo,
    required this.pressaoHpa,
    required this.nivelReservCm,
    required this.chuvaDetectada,
    required this.valvulaAtiva,
  });

  factory LeituraModel.fromMap(Map<String, dynamic> map) {
    return LeituraModel(
      id: map['id'],
      timestamp: map['timestamp'],
      umidadeSolo: map['umidade_solo'],
      pressaoHpa: map['pressao_hpa'],
      nivelReservCm: map['nivel_reserv_cm'],
      chuvaDetectada: map['chuva_detectada'],
      valvulaAtiva: map['valvula_ativa'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp,
      'umidade_solo': umidadeSolo,
      'pressao_hpa': pressaoHpa,
      'nivel_reserv_cm': nivelReservCm,
      'chuva_detectada': chuvaDetectada,
      'valvula_ativa': valvulaAtiva,
    };
  }
}
import 'package:flutter/foundation.dart';

// Estados do sistema
enum Estado {
  chovendo,           // Se estiver chovendo e umidade não crítica ele não irriga
  esperandoAgua,      // Se precisar irrigar e não tiver água ele espera
  esperandoChuva,     // Falta água mas não muito, espera por chuva se a pressão tem baixado
  irrigando,          // Irrigando
  umidadeIdeal,       // Nada acontecendo
  irrigandoManual,    // Usuário ativou modo manual
  ociosoManual,       // Modo manual ativo mas não irrigando
}

// Contexto de chuva
enum ContextoChuva {
  paraChover,         // Pressão baixando - chuva em breve
  naoEstaPraChover,   // Sem previsão de chuva
  chovendo,           // Chovendo agora
}

class DatabaseRow {
  final Estado estado;
  final int leituraumidadeSolo;           // 0-100
  final int leituraPorcentagemCaixaAgua;  // 0-100
  final ContextoChuva estadoChuva;
  final int? pressaoBaixandoAQuantasHoras; // Apenas se ParaChover
  final int? intensidadeChuva;             // Apenas se Chovendo
  final int leituraPressao;                // 0-100 (não principal)
  final int leituraChuva;                  // 0-100 (não principal)

  DatabaseRow({
    required this.estado,
    required this.leituraumidadeSolo,
    required this.leituraPorcentagemCaixaAgua,
    required this.estadoChuva,
    this.pressaoBaixandoAQuantasHoras,
    this.intensidadeChuva,
    required this.leituraPressao,
    required this.leituraChuva,
  });
}

class IrrigacaoState extends ChangeNotifier {
  // Dados de leitura (simulados ou vindos do backend)
  DatabaseRow _currentData = DatabaseRow(
    estado: Estado.umidadeIdeal,
    leituraumidadeSolo: 32,
    leituraPorcentagemCaixaAgua: 65,
    estadoChuva: ContextoChuva.naoEstaPraChover,
    leituraPressao: 78,
    leituraChuva: 10,
  );

  // Configurações de limites (em 0..1, normalizado)
  double umidadeCritica = 0.15;      // Vermelho - Irrigação urgente
  double umidadeNaoCritica = 0.50;   // Amarelo - Irrigação com baixa prioridade
  double umidadeParar = 0.85;        // Verde - Parar irrigação

  // Flags de configuração
  bool esperarPorChuva = true;       // Esperar chuva quando não crítica
  bool desativarDuranteChuva = true; // Desativar sistema durante chuva

  // Nível de alerta do tanque (em 0..1)
  double nivelAlertaTanque = 0.65;

  // Modo manual
  bool isManualMode = false;
  bool isIrrigating = false;
  int? selectedTime;

  // Getters para dados atuais
  DatabaseRow get currentData => _currentData;
  Estado get systemState => _currentData.estado;
  int get waterTankLevel => _currentData.leituraPorcentagemCaixaAgua;
  int get soilMoisture => _currentData.leituraumidadeSolo;
  int get pressao => _currentData.leituraPressao;
  ContextoChuva get rainStatus => _currentData.estadoChuva;

  // Setters para dados (simulação)
  void updateData({
    Estado? estado,
    int? leituraumidadeSolo,
    int? leituraPorcentagemCaixaAgua,
    ContextoChuva? estadoChuva,
    int? pressaoBaixandoAQuantasHoras,
    int? intensidadeChuva,
    int? leituraPressao,
    int? leituraChuva,
  }) {
    _currentData = DatabaseRow(
      estado: estado ?? _currentData.estado,
      leituraumidadeSolo: leituraumidadeSolo ?? _currentData.leituraumidadeSolo,
      leituraPorcentagemCaixaAgua: leituraPorcentagemCaixaAgua ?? _currentData.leituraPorcentagemCaixaAgua,
      estadoChuva: estadoChuva ?? _currentData.estadoChuva,
      pressaoBaixandoAQuantasHoras: pressaoBaixandoAQuantasHoras ?? _currentData.pressaoBaixandoAQuantasHoras,
      intensidadeChuva: intensidadeChuva ?? _currentData.intensidadeChuva,
      leituraPressao: leituraPressao ?? _currentData.leituraPressao,
      leituraChuva: leituraChuva ?? _currentData.leituraChuva,
    );
    notifyListeners();
  }

  void setManualMode(bool value) {
    isManualMode = value;
    if (!value) isIrrigating = false;
    notifyListeners();
  }

  void toggleIrrigating() {
    if (!isManualMode) return;
    isIrrigating = !isIrrigating;
    notifyListeners();
  }

  void setSelectedTime(int? minutes) {
    selectedTime = minutes;
    notifyListeners();
  }

  void updateConfig({
    double? umidadeCritica,
    double? umidadeNaoCritica,
    double? umidadeParar,
    bool? esperarPorChuva,
    bool? desativarDuranteChuva,
    double? nivelAlertaTanque,
  }) {
    if (umidadeCritica != null) this.umidadeCritica = umidadeCritica;
    if (umidadeNaoCritica != null) this.umidadeNaoCritica = umidadeNaoCritica;
    if (umidadeParar != null) this.umidadeParar = umidadeParar;
    if (esperarPorChuva != null) this.esperarPorChuva = esperarPorChuva;
    if (desativarDuranteChuva != null) this.desativarDuranteChuva = desativarDuranteChuva;
    if (nivelAlertaTanque != null) this.nivelAlertaTanque = nivelAlertaTanque;
    notifyListeners();
  }

  // Timeline: durações reais em horas
  List<TimelineEntry> get timelineEntries => [
    TimelineEntry('08:00', Estado.esperandoChuva, 1),
    TimelineEntry('09:00', Estado.umidadeIdeal, 1),
    TimelineEntry('10:00', Estado.esperandoChuva, 1),
    TimelineEntry('11:00', Estado.esperandoAgua, 1),
    TimelineEntry('12:00', Estado.irrigando, 3),
    TimelineEntry('15:00', Estado.umidadeIdeal, 1),
    TimelineEntry('16:00', Estado.chovendo, 1),
    TimelineEntry('18:00', Estado.ociosoManual, 1),
  ];
}

class TimelineEntry {
  final String time;
  final Estado state;
  final double durationHours;

  TimelineEntry(this.time, this.state, this.durationHours);

  String get durationLabel {
    if (durationHours < 1) return '${(durationHours * 60).round()}min';
    if (durationHours == durationHours.roundToDouble()) return '${durationHours.round()}h';
    return '${durationHours}h';
  }
}

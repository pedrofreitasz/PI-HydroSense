import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../models/irrigacao_state.dart';
import '../theme.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late List<double> thumbValues;
  late bool waitForRain;
  late bool disableOnRain;
  late double tankLevel;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<IrrigacaoState>();
    thumbValues = [state.umidadeCritica, state.umidadeNaoCritica, state.umidadeParar];
    waitForRain = state.esperarPorChuva;
    disableOnRain = state.desativarDuranteChuva;
    tankLevel = state.nivelAlertaTanque;
  }

  void _save() {
    context.read<IrrigacaoState>().updateConfig(
      umidadeCritica: thumbValues[0],
      umidadeNaoCritica: thumbValues[1],
      umidadeParar: thumbValues[2],
      esperarPorChuva: waitForRain,
      desativarDuranteChuva: disableOnRain,
      nivelAlertaTanque: tankLevel,
    );

    setState(() => saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F5F2), Color(0xFFF5FFFE)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: const Color(0xFF5E9387),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Limites de Umidade do Solo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF123832),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Slider multi-thumb
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerticalMultiThumbSlider(
                      values: thumbValues,
                      zoneColors: const [
                        Color(0xFFE5484D), // Inferior: Crítica (Vermelho)
                        Color(0xFFE8B33D), // Médio: Não Crítica (Amarelo)
                        Color(0xFF34B27B), // Superior: Parar (Verde)
                      ],
                      zoneEnabled: [true, waitForRain, true],
                      labels: const ['Crítica', 'Não Crítica', 'Parar'],
                      onChanged: (v) => setState(() => thumbValues = v),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Níveis de Decisão',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF123832),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoBox(
                            color: const Color(0xFF34B27B),
                            title: '🟢 Parar Irrigação',
                            description: 'Interrompe toda a irrigação imediatamente',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoBox(
                            color: const Color(0xFFE8B33D),
                            title: '🟡 Irrigar Não Crítico',
                            description: 'Irrigação permitida, mas com baixa prioridade. Sistema verifica possibilidade de chuva nas próximas horas antes de irrigar.',
                            enabled: waitForRain,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoBox(
                            color: const Color(0xFFE5484D),
                            title: '🔴 Irrigação Crítica',
                            description: 'Irrigação urgente – inicia imediatamente',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAF9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE3EFEC),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: const Color(0xFF5E9387),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Arraste as tags para ajustar cada nível. O "Não Crítica" desaparece quando desativado.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6E8E87),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Checkboxes
                SettingCheckbox(
                  value: waitForRain,
                  onChanged: (v) {
                    setState(() {
                      waitForRain = v;
                      if (v) {
                        final cri = thumbValues[0];
                        final parar = thumbValues[2];
                        thumbValues[1] = (cri + parar) / 2;
                      }
                    });
                  },
                  icon: Icons.cloud_outlined,
                  label: 'Esperar por Chuva',
                  description: 'Adia a irrigação não crítica quando há previsão de chuva',
                ),
                const SizedBox(height: 10),
                SettingCheckbox(
                  value: disableOnRain,
                  onChanged: (v) => setState(() => disableOnRain = v),
                  icon: Icons.cloud_off_outlined,
                  label: 'Desativar Sistema na Presença de Chuva',
                  description: 'Suspende toda irrigação automática enquanto estiver chovendo',
                ),

                const SizedBox(height: 28),
                Container(height: 1, color: const Color(0xFFE3EFEC)),
                const SizedBox(height: 28),

                // Tank alert
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: const Color(0xFF5E9387),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Reservatório de Água',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF123832),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Arraste na barrinha para ajustar o nível de alerta',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C9994),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WaterTankWithSlider(
                      level: tankLevel,
                      onChanged: (v) => setState(() => tankLevel = v),
                      width: 100,
                      height: 200,
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nível de Alerta',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF123832),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(tankLevel * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7FB8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F7F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 16,
                                  color: Color(0xFF1E9E86),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Alerta quando o nível estiver abaixo deste valor',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1E6B5E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Save button
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E9E86),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.save_outlined, size: 17),
                      label: const Text('Salvar Configurações'),
                    ),
                    const SizedBox(width: 14),
                    AnimatedOpacity(
                      opacity: saved ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text(
                        'Configuração salva ✓',
                        style: TextStyle(
                          color: Color(0xFF34B27B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required Color color,
    required String title,
    required String description,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled ? color.withOpacity(0.3) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: enabled ? color : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? title : '$title (desativado)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? const Color(0xFF123832) : const Color(0xFF999999),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: enabled ? const Color(0xFF6E8E87) : const Color(0xFFCCCCCC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vertical multi-thumb slider (3 níveis independentes mas ordenados)
// ---------------------------------------------------------------------------
class VerticalMultiThumbSlider extends StatefulWidget {
  final List<double> values;
  final List<Color> zoneColors;
  final List<bool> zoneEnabled;
  final List<String> labels;
  final ValueChanged<List<double>> onChanged;
  final double height;
  final double width;

  const VerticalMultiThumbSlider({
    super.key,
    required this.values,
    required this.zoneColors,
    required this.zoneEnabled,
    required this.labels,
    required this.onChanged,
    this.height = 320,
    this.width = 60,
  });

  @override
  State<VerticalMultiThumbSlider> createState() => _VerticalMultiThumbSliderState();
}

class _VerticalMultiThumbSliderState extends State<VerticalMultiThumbSlider> {
  final GlobalKey _trackKey = GlobalKey();
  int? _activeThumb;

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  int _nearestThumb(Offset local, Size size) {
    final frac = _clamp(1 - (local.dy / size.height), 0, 1);
    int nearest = 0;
    double best = double.infinity;
    for (int i = 0; i < widget.values.length; i++) {
      if (!widget.zoneEnabled[i]) continue;
      final d = (widget.values[i] - frac).abs();
      if (d < best) {
        best = d;
        nearest = i;
      }
    }
    return nearest;
  }

  void _updateFromGlobal(Offset globalPosition) {
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _activeThumb == null) return;
    final local = box.globalToLocal(globalPosition);
    final frac = _clamp(1 - (local.dy / box.size.height), 0, 1);

    final values = [...widget.values];
    final i = _activeThumb!;

    double minLimit = 0.05;
    double maxLimit = 0.95;

    for (int j = i - 1; j >= 0; j--) {
      if (widget.zoneEnabled[j]) {
        minLimit = values[j] + 0.05;
        break;
      }
    }

    for (int j = i + 1; j < values.length; j++) {
      if (widget.zoneEnabled[j]) {
        maxLimit = values[j] - 0.05;
        break;
      }
    }

    values[i] = _clamp(frac, minLimit, maxLimit);
    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(details.globalPosition);
        setState(() => _activeThumb = _nearestThumb(local, box.size));
        _updateFromGlobal(details.globalPosition);
      },
      onPanUpdate: (details) => _updateFromGlobal(details.globalPosition),
      onPanEnd: (_) => setState(() => _activeThumb = null),
      child: SizedBox(
        width: widget.width + 130,
        height: widget.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Track
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                key: _trackKey,
                width: widget.width,
                height: widget.height,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F6),
                  borderRadius: BorderRadius.circular(widget.width / 2),
                  border: Border.all(color: const Color(0xFFCFE7E1), width: 2),
                ),
              ),
            ),

            // Linhas de nível
            ...List.generate(3, (i) {
              final value = widget.values[i];
              final isEnabled = widget.zoneEnabled[i];
              if (!isEnabled) return const SizedBox.shrink();
              return Positioned(
                bottom: value * widget.height,
                left: 0,
                right: widget.width,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.zoneColors[i],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),

            // Labels
            ...List.generate(widget.values.length, (i) {
              final v = widget.values[i];
              final isEnabled = widget.zoneEnabled[i];
              if (!isEnabled) return const SizedBox.shrink();

              final yPos = v * widget.height;
              final color = widget.zoneColors[i];
              final label = widget.labels[i];

              return Positioned(
                bottom: yPos - 8,
                left: widget.width + 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$label ${(v * 100).round()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Water tank with integrated slider
// ---------------------------------------------------------------------------
class WaterTankWithSlider extends StatefulWidget {
  final double level;
  final ValueChanged<double> onChanged;
  final double width;
  final double height;

  const WaterTankWithSlider({
    super.key,
    required this.level,
    required this.onChanged,
    this.width = 120,
    this.height = 200,
  });

  @override
  State<WaterTankWithSlider> createState() => _WaterTankWithSliderState();
}

class _WaterTankWithSliderState extends State<WaterTankWithSlider> {
  final GlobalKey _tankKey = GlobalKey();

  void _update(Offset globalPosition) {
    final box = _tankKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    double frac = 1 - (local.dy / box.size.height);
    frac = frac.clamp(0.0, 1.0);
    widget.onChanged(frac);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (d) => _update(d.globalPosition),
      onPanUpdate: (d) => _update(d.globalPosition),
      child: Container(
        key: _tankKey,
        width: widget.width,
        height: widget.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCFE7E1), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Água
            Container(
              width: widget.width,
              height: widget.height * widget.level.clamp(0.0, 1.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5FB6E0), Color(0xFF2E7FB8)],
                ),
              ),
            ),

            // Ícone de água
            Positioned(
              top: 10,
              child: Icon(
                Icons.water_drop_outlined,
                size: 20,
                color: Colors.white.withOpacity(0.4),
              ),
            ),

            // Indicador do nível
            Positioned(
              bottom: widget.level * widget.height,
              left: -8,
              right: -8,
              child: Container(
                height: 3,
                color: const Color(0xFFE5484D),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildIndicatorDot(), _buildIndicatorDot()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFE5484D),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom checkbox tile
// ---------------------------------------------------------------------------
class SettingCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String label;
  final String description;

  const SettingCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFE3F7F1) : const Color(0xFFF7FAF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? const Color(0xFF8FD9C9) : const Color(0xFFDCEAE6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF1E9E86) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? const Color(0xFF1E9E86)
                      : const Color(0xFFB7CFC9),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 15, color: const Color(0xFF5E9387)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF123832),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6E8E87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Sistema de Irrigação — App completo (tema claro)
// Dashboard · Histórico · Manual · Configurações
// =============================================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(const IrrigationApp());
}

// =============================================================================
// TEMA
// =============================================================================
class AppColors {
  // Base
  static const bg = Color(0xFFF4F8F7);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE3EEEC);
  static const dark = Color(0xFF12302B);
  static const slate600 = Color(0xFF4E6863);
  static const slate500 = Color(0xFF6E8E87);
  static const slate400 = Color(0xFF9AB3AE);

  // Marca
  static const primary = Color(0xFF1E9E86);
  static const primarySoft = Color(0xFFD7F2EC);

  // Estados / categorias (consistentes nas 4 telas)
  static const green = Color(0xFF34B27B); // Umidade ideal / Parar
  static const greenSoft = Color(0xFFE3F7F1);
  static const blue = Color(0xFF2F8FE0); // Irrigando / Caixa d'água
  static const blueSoft = Color(0xFFE6F1FC);
  static const yellow = Color(0xFFE8B33D); // Esperando chuva / Não crítica
  static const yellowSoft = Color(0xFFFCF3DE);
  static const indigo = Color(0xFF7C6CE0); // Chovendo
  static const indigoSoft = Color(0xFFECE9FB);
  static const red = Color(0xFFE5484D); // Irrigação manual / Crítica
  static const redSoft = Color(0xFFFCE7E8);
  static const grayState = Color(0xFF8C9C99); // Manual ocioso
  static const grayStateSoft = Color(0xFFEDF1F0);
  static const orange = Color(0xFFE07A3D); // Esperando água
  static const orangeSoft = Color(0xFFFBEADD);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}

class IrrigationApp extends StatelessWidget {
  const IrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irrigação',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootShell(),
    );
  }
}

// =============================================================================
// ESTADOS COMPARTILHADOS (mock de dados)
// =============================================================================
enum IrrigationState {
  idealHumidity,
  irrigating,
  waitingRain,
  raining,
  waitingWater,
  manualIrrigation,
  manualIdle,
}

extension IrrigationStateX on IrrigationState {
  Color get color {
    switch (this) {
      case IrrigationState.idealHumidity:
        return AppColors.green;
      case IrrigationState.irrigating:
        return AppColors.blue;
      case IrrigationState.waitingRain:
        return AppColors.yellow;
      case IrrigationState.raining:
        return AppColors.indigo;
      case IrrigationState.waitingWater:
        return AppColors.orange;
      case IrrigationState.manualIrrigation:
        return AppColors.red;
      case IrrigationState.manualIdle:
        return AppColors.grayState;
    }
  }

  Color get softColor {
    switch (this) {
      case IrrigationState.idealHumidity:
        return AppColors.greenSoft;
      case IrrigationState.irrigating:
        return AppColors.blueSoft;
      case IrrigationState.waitingRain:
        return AppColors.yellowSoft;
      case IrrigationState.raining:
        return AppColors.indigoSoft;
      case IrrigationState.waitingWater:
        return AppColors.orangeSoft;
      case IrrigationState.manualIrrigation:
        return AppColors.redSoft;
      case IrrigationState.manualIdle:
        return AppColors.grayStateSoft;
    }
  }

  IconData get icon {
    switch (this) {
      case IrrigationState.idealHumidity:
        return Icons.eco_outlined;
      case IrrigationState.irrigating:
        return Icons.water_drop;
      case IrrigationState.waitingRain:
        return Icons.cloud_outlined;
      case IrrigationState.raining:
        return Icons.grain;
      case IrrigationState.waitingWater:
        return Icons.water_drop_outlined;
      case IrrigationState.manualIrrigation:
        return Icons.back_hand;
      case IrrigationState.manualIdle:
        return Icons.back_hand_outlined;
    }
  }

  String get label {
    switch (this) {
      case IrrigationState.idealHumidity:
        return 'Umidade ideal';
      case IrrigationState.irrigating:
        return 'Irrigando';
      case IrrigationState.waitingRain:
        return 'Esperando chuva';
      case IrrigationState.raining:
        return 'Chovendo';
      case IrrigationState.waitingWater:
        return 'Esperando água';
      case IrrigationState.manualIrrigation:
        return 'Irrigação manual';
      case IrrigationState.manualIdle:
        return 'Manual (ocioso)';
    }
  }
}

/// Um segmento de estado dentro de uma linha do tempo
class StateSegment {
  final IrrigationState state;
  final double weight; // proporcional à duração
  const StateSegment(this.state, this.weight);
}

/// Dados mockados, gerados de forma determinística para parecer "real".
class MockData {
  static final List<StateSegment> timeline24h = [
    StateSegment(IrrigationState.idealHumidity, 3),
    StateSegment(IrrigationState.irrigating, 1.4),
    StateSegment(IrrigationState.waitingRain, 1.8),
    StateSegment(IrrigationState.raining, 1.2),
    StateSegment(IrrigationState.idealHumidity, 2.6),
    StateSegment(IrrigationState.manualIrrigation, 1.0),
    StateSegment(IrrigationState.manualIdle, 1.0),
    StateSegment(IrrigationState.idealHumidity, 1.5),
  ];

  static final List<StateSegment> timeline7d = [
    StateSegment(IrrigationState.idealHumidity, 6),
    StateSegment(IrrigationState.irrigating, 2),
    StateSegment(IrrigationState.waitingRain, 3),
    StateSegment(IrrigationState.raining, 2.5),
    StateSegment(IrrigationState.idealHumidity, 5),
    StateSegment(IrrigationState.waitingWater, 1.5),
    StateSegment(IrrigationState.irrigating, 1.8),
    StateSegment(IrrigationState.idealHumidity, 4.5),
    StateSegment(IrrigationState.manualIrrigation, 1.2),
    StateSegment(IrrigationState.idealHumidity, 3.5),
  ];

  static List<double> series(int n, double base, double amp, int seed,
      {double clampMin = 0, double clampMax = 100}) {
    final rnd = math.Random(seed);
    final values = <double>[];
    double v = base;
    for (int i = 0; i < n; i++) {
      v += (rnd.nextDouble() - 0.5) * amp;
      v = v.clamp(clampMin, clampMax);
      values.add(v);
    }
    return values;
  }

  static final soilHumidity24h = series(60, 55, 6, 1);
  static final waterTank24h = series(60, 70, 4, 2);
  static final List<double> pressure24h =
      series(60, 1012, 1.6, 3, clampMin: 1000, clampMax: 1020);
  static final List<double> rain24h = (() {
    final rnd = math.Random(7);
    return List<double>.generate(60, (i) {
      if (i > 30 && i < 42) {
        return (rnd.nextDouble() * 8).clamp(0.0, 10.0);
      }
      return 0.0;
    });
  })();
}

// =============================================================================
// ROOT SHELL — navegação entre as 4 telas
// =============================================================================
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    ManualScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(index: _index),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: _pages[_index],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(index: _index, onChanged: (i) => setState(() => _index = i)),
    );
  }
}

const _navItems = [
  (icon: Icons.home_rounded, label: 'Dashboard'),
  (icon: Icons.back_hand_rounded, label: 'Manual'),
  (icon: Icons.settings_rounded, label: 'Configurações'),
];

class _TopBar extends StatelessWidget {
  final int index;
  const _TopBar({required this.index});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWide ? 'Sistema de Irrigação' : _navItems[index].label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const Text(
                  'Monitoramento em tempo real',
                  style: TextStyle(fontSize: 12, color: AppColors.slate500),
                ),
              ],
            ),
          ),
          _OnlinePill(),
          const SizedBox(width: 10),
          _IconButtonCircle(icon: Icons.notifications_none_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _OnlinePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.green),
          SizedBox(width: 6),
          Text(
            'Online',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButtonCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 19, color: AppColors.slate600),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (i) {
          final selected = i == index;
          final item = _navItems[i];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: selected ? AppColors.primary : AppColors.slate400,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primary : AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// WIDGETS COMPARTILHADOS
// =============================================================================

/// Cartão branco padrão usado em toda a interface
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Legenda de estados (bolinha colorida + label), usada no histórico e overview
class StateLegend extends StatelessWidget {
  final List<IrrigationState> states;
  const StateLegend({super.key, required this.states});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: states.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: s.softColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(s.icon, size: 14, color: s.color),
            ),
            const SizedBox(width: 7),
            Text(
              s.label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.slate600, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Barra de linha do tempo de estados (segmentos coloridos arredondados)
class StateTimelineBar extends StatelessWidget {
  final List<StateSegment> segments;
  final double height;
  final String? centerLabel;

  const StateTimelineBar({
    super.key,
    required this.segments,
    this.height = 34,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (a, b) => a + b.weight);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Row(
          children: segments.map((seg) {
            final flex = (seg.weight / total * 1000).round().clamp(1, 100000);
            final showLabel = centerLabel != null &&
                seg.weight == segments
                    .reduce((a, b) => a.weight > b.weight ? a : b)
                    .weight;
            return Expanded(
              flex: flex,
              child: Container(
                color: seg.state.color,
                alignment: Alignment.center,
                child: showLabel
                    ? FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            centerLabel!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Linha de timestamps abaixo de uma timeline
class TimelineAxis extends StatelessWidget {
  final List<String> labels;
  const TimelineAxis({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((l) => Text(l, style: const TextStyle(fontSize: 11, color: AppColors.slate400)))
          .toList(),
    );
  }
}

/// Pequeno gráfico de linha (sparkline / multi-série) usado no dashboard e histórico
class LineChartPainter extends CustomPainter {
  final List<List<double>> series; // múltiplas séries normalizadas 0..1
  final List<Color> colors;
  final double strokeWidth;
  final bool filled;
  final int? markerIndex; // índice "Agora"

  LineChartPainter({
    required this.series,
    required this.colors,
    this.strokeWidth = 2.4,
    this.filled = false,
    this.markerIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid horizontal
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int s = 0; s < series.length; s++) {
      final data = series[s];
      if (data.isEmpty) continue;
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = size.width * i / (data.length - 1);
        final y = size.height * (1 - data[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      if (filled) {
        final fillPath = Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(
          fillPath,
          Paint()
            ..color = colors[s].withOpacity(0.08)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = colors[s]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Marker "Agora"
      if (markerIndex != null && markerIndex! < data.length) {
        final mx = size.width * markerIndex! / (data.length - 1);
        final my = size.height * (1 - data[markerIndex!]);
        canvas.drawLine(
          Offset(mx, 0),
          Offset(mx, size.height),
          Paint()
            ..color = AppColors.slate400.withOpacity(0.5)
            ..strokeWidth = 1,
        );
        canvas.drawCircle(Offset(mx, my), 5, Paint()..color = Colors.white);
        canvas.drawCircle(
          Offset(mx, my),
          5,
          Paint()
            ..color = colors[s]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => true;
}

List<double> normalize(List<double> values, {double min = 0, double max = 100}) {
  return values.map((v) => ((v - min) / (max - min)).clamp(0.0, 1.0)).toList();
}

// =============================================================================
// DASHBOARD
// =============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _chartTab = 'Umidade';

  @override
  Widget build(BuildContext context) {
    final currentState = IrrigationState.idealHumidity;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estado atual
        AppCard(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: currentState.softColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(currentState.icon, color: currentState.color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTADO ATUAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentState.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nada acontecendo — umidade dentro do ideal.',
                      style: TextStyle(fontSize: 13, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy_outlined, size: 15, color: AppColors.slate600),
                    SizedBox(width: 6),
                    Text('Automático',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.slate600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Métricas principais
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 520;
          final metrics = [
            _MetricCard(
              icon: Icons.water_drop_outlined,
              iconColor: AppColors.green,
              label: 'Umidade do solo',
              value: '62',
              unit: '%',
              progress: 0.62,
              progressColor: AppColors.green,
              footer: 'Ideal (40% – 70%)',
              footerColor: AppColors.green,
            ),
            _MetricCard(
              icon: Icons.water_outlined,
              iconColor: AppColors.blue,
              label: "Caixa d'água",
              value: '78',
              unit: '%',
              progress: 0.78,
              progressColor: AppColors.blue,
              footer: 'Nível bom',
              footerColor: AppColors.blue,
            ),
          ];
          if (isNarrow) {
            return Column(
              children: [
                metrics[0],
                const SizedBox(height: 12),
                metrics[1],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: metrics[0]),
              const SizedBox(width: 12),
              Expanded(child: metrics[1]),
            ],
          );
        }),
        const SizedBox(height: 12),

        // Chuva + Pressão
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 520;
          final boxes = [
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.indigoSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_outlined, color: AppColors.indigo, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contexto de chuva',
                            style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                        const SizedBox(height: 2),
                        const Text('Possível chuva',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark)),
                        const SizedBox(height: 2),
                        const Text('Pressão atmosférica baixando há 2h',
                            style: TextStyle(fontSize: 11.5, color: AppColors.slate400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.redSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.show_chart_rounded, color: AppColors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tendência de pressão',
                            style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Text('Em queda',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark)),
                            SizedBox(width: 4),
                            Icon(Icons.trending_down_rounded, size: 16, color: AppColors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.slate400),
                ],
              ),
            ),
          ];
          if (isNarrow) {
            return Column(children: [boxes[0], const SizedBox(height: 12), boxes[1]]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: boxes[0]),
              const SizedBox(width: 12),
              Expanded(child: boxes[1]),
            ],
          );
        }),
        const SizedBox(height: 12),

        // Gráfico de evolução
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Evolução das leituras (últimas 24h)',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                  ),
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.slate400),
                ],
              ),
              const SizedBox(height: 14),
              _SegmentedTabs(
                options: const ['Umidade', 'Pressão', 'Chuva'],
                selected: _chartTab,
                onChanged: (v) => setState(() => _chartTab = v),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _buildChartPainter(),
                  child: Container(),
                ),
              ),
              const SizedBox(height: 10),
              const TimelineAxis(labels: ['18:00', '00:00', '06:00', '12:00', '18:00']),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (_chartTab == 'Umidade') ...[
                    _legendDot(AppColors.green, 'Umidade do solo (%)'),
                    _legendDot(AppColors.blue, "Caixa d'água (%)"),
                  ] else if (_chartTab == 'Pressão') ...[
                    _legendDot(AppColors.blue, 'Pressão (hPa)'),
                  ] else ...[
                    _legendDot(AppColors.indigo, 'Chuva (mm)'),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Linha do tempo de estados
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Text('Linha do tempo de estados',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                  ),
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.slate400),
                ],
              ),
              const SizedBox(height: 16),
              StateTimelineBar(segments: MockData.timeline24h, height: 38),
              const SizedBox(height: 8),
              const TimelineAxis(
                labels: ['18:00', '21:00', '00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00'],
              ),
              const SizedBox(height: 16),
              StateLegend(states: IrrigationState.values),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cards inferiores
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 640;
          final cards = [
            _SmallStatCard(
              icon: Icons.speed_rounded,
              iconColor: AppColors.blue,
              label: 'Pressão atmosférica',
              value: '1007 hPa',
              footer: 'Em queda',
              footerIcon: Icons.trending_down_rounded,
              footerColor: AppColors.red,
            ),
            _SmallStatCard(
              icon: Icons.cloud_outlined,
              iconColor: AppColors.indigo,
              label: 'Chuva acumulada',
              value: '2,4 mm',
              footer: 'Últimas 24h',
              footerColor: AppColors.slate500,
            ),
            _SmallStatCard(
              icon: Icons.grain_rounded,
              iconColor: AppColors.indigo,
              label: 'Chuva atual',
              value: '0,0 mm/h',
              footer: 'Sem chuva',
              footerColor: AppColors.slate500,
            ),
            _SmallStatCard(
              icon: Icons.schedule_rounded,
              iconColor: AppColors.green,
              label: 'Última atualização',
              value: '18:23:45',
              footer: 'Agora',
              footerColor: AppColors.green,
            ),
          ];
          if (isNarrow) {
            return Column(
              children: [
                Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  CustomPainter _buildChartPainter() {
    final markerIndex = 45;
    if (_chartTab == 'Umidade') {
      return LineChartPainter(
        series: [
          normalize(MockData.soilHumidity24h),
          normalize(MockData.waterTank24h),
        ],
        colors: const [AppColors.green, AppColors.blue],
        filled: true,
        markerIndex: markerIndex,
      );
    } else if (_chartTab == 'Pressão') {
      return LineChartPainter(
        series: [normalize(MockData.pressure24h, min: 1000, max: 1020)],
        colors: const [AppColors.blue],
        filled: true,
        markerIndex: markerIndex,
      );
    } else {
      return LineChartPainter(
        series: [normalize(MockData.rain24h, min: 0, max: 10)],
        colors: const [AppColors.indigo],
        filled: true,
        markerIndex: markerIndex,
      );
    }
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  const _SegmentedTabs({required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: options.map((o) {
          final isSel = o == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSel
                      ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Center(
                  child: Text(
                    o,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSel ? AppColors.primary : AppColors.slate500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final double progress;
  final Color progressColor;
  final String footer;
  final Color footerColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    required this.progressColor,
    required this.footer,
    required this.footerColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: 7),
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.dark, height: 1)),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 2),
                child: Text(unit, style: const TextStyle(fontSize: 16, color: AppColors.slate400, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.bg,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(footer, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: footerColor)),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String footer;
  final Color footerColor;
  final IconData? footerIcon;

  const _SmallStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.footer,
    required this.footerColor,
    this.footerIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.slate500, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.dark)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(footer, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: footerColor)),
              if (footerIcon != null) ...[
                const SizedBox(width: 3),
                Icon(footerIcon, size: 12, color: footerColor),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MANUAL
// =============================================================================
class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  bool isManualMode = false;
  bool isIrrigating = false;
  int? selectedTime;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(isManual: isManualMode, isIrrigating: isIrrigating),
        const SizedBox(height: 12),
        _ControlsCard(
          isManual: isManualMode,
          onChanged: (v) => setState(() {
            isManualMode = v;
            if (!v) isIrrigating = false;
          }),
        ),
        const SizedBox(height: 12),
        _IrrigateButton(
          enabled: isManualMode,
          irrigating: isIrrigating,
          onTap: () => setState(() => isIrrigating = !isIrrigating),
        ),
        const SizedBox(height: 12),
        _TimeSelector(
          selected: selectedTime,
          onChanged: (v) => setState(() => selectedTime = v),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isManual;
  final bool isIrrigating;
  const _StatusCard({required this.isManual, required this.isIrrigating});

  @override
  Widget build(BuildContext context) {
    late IrrigationState state;
    late String subtitle;
    if (!isManual) {
      state = IrrigationState.idealHumidity;
      subtitle = 'Sistema operando automaticamente';
    } else if (isIrrigating) {
      state = IrrigationState.manualIrrigation;
      subtitle = 'Irrigação manual em andamento...';
    } else {
      state = IrrigationState.manualIdle;
      subtitle = 'Controle total pelo usuário';
    }
    final title = !isManual ? 'Modo Automático' : (isIrrigating ? 'Irrigando' : 'Modo Manual');

    return AppCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(state),
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: state.softColor, borderRadius: BorderRadius.circular(20)),
              child: Icon(state.icon, color: state.color, size: 34),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.dark)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
        ],
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  final bool isManual;
  final ValueChanged<bool> onChanged;
  const _ControlsCard({required this.isManual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Controles',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.dark)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Modo Manual', style: TextStyle(fontSize: 14, color: AppColors.slate600)),
              Switch.adaptive(
                value: isManual,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status', style: TextStyle(fontSize: 14, color: AppColors.slate600)),
              Text(
                isManual ? 'Ativado' : 'Desativado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isManual ? AppColors.green : AppColors.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IrrigateButton extends StatelessWidget {
  final bool enabled;
  final bool irrigating;
  final VoidCallback onTap;
  const _IrrigateButton({required this.enabled, required this.irrigating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: irrigating ? AppColors.red : AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: Icon(irrigating ? Icons.stop_rounded : Icons.water_drop, size: 20),
        label: Text(
          irrigating ? 'Parar Irrigação' : 'Iniciar Irrigação',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;
  const _TimeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final times = [5, 15, 30];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tempo de irrigação',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate500)),
          const SizedBox(height: 14),
          Row(
            children: times.map((t) {
              final isSel = selected == t;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: t == times.first ? 0 : 6,
                    right: t == times.last ? 0 : 6,
                  ),
                  child: GestureDetector(
                    onTap: () => onChanged(isSel ? null : t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : AppColors.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                        boxShadow: isSel
                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 15, color: isSel ? Colors.white : AppColors.slate500),
                            const SizedBox(width: 6),
                            Text(
                              '$t min',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isSel ? Colors.white : AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Irrigação será interrompida após $selected min',
                style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// CONFIGURAÇÕES
// =============================================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Ordem: [Crítica (baixo), Não Crítica (meio), Parar (alto)]
  List<double> thumbValues = [0.15, 0.50, 0.85];
  bool waitForRain = true;
  bool disableOnRain = true;
  double tankLevel = 0.65;
  bool saved = false;

  void _save() {
    setState(() => saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IRRIGAÇÃO · CONFIGURAÇÕES',
                            style: TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: AppColors.slate500)),
                        SizedBox(height: 2),
                        Text('Limites de Umidade do Solo',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.dark)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              LayoutBuilder(builder: (context, c) {
                final narrow = c.maxWidth < 560;
                final slider = VerticalMultiThumbSlider(
                  values: thumbValues,
                  zoneColors: const [AppColors.red, AppColors.yellow, AppColors.green],
                  zoneEnabled: [true, waitForRain, true],
                  labels: const ['Crítica', 'Não Crítica', 'Parar'],
                  onChanged: (v) => setState(() => thumbValues = v),
                );
                final infoColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Níveis de Decisão',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.dark)),
                    const SizedBox(height: 12),
                    _InfoBox(
                      color: AppColors.green,
                      icon: Icons.eco_outlined,
                      title: 'Parar Irrigação',
                      description: 'Interrompe toda a irrigação imediatamente',
                    ),
                    const SizedBox(height: 8),
                    _InfoBox(
                      color: AppColors.yellow,
                      icon: Icons.water_drop_outlined,
                      title: 'Irrigar Não Crítico',
                      description:
                          'Irrigação permitida, mas com baixa prioridade. Sistema verifica possibilidade de chuva antes de irrigar.',
                      enabled: waitForRain,
                    ),
                    const SizedBox(height: 8),
                    _InfoBox(
                      color: AppColors.red,
                      icon: Icons.priority_high_rounded,
                      title: 'Irrigação Crítica',
                      description: 'Irrigação urgente – inicia imediatamente',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.slate500),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Arraste as tags para ajustar cada nível. O "Não Crítica" desaparece quando desativado.',
                              style: TextStyle(fontSize: 12, color: AppColors.slate500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: slider),
                      const SizedBox(height: 24),
                      infoColumn,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    slider,
                    const SizedBox(width: 30),
                    Expanded(child: infoColumn),
                  ],
                );
              }),
              const SizedBox(height: 28),
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
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined, size: 16, color: AppColors.slate500),
                  const SizedBox(width: 6),
                  const Text('Reservatório de Água',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.dark)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Arraste na barrinha para ajustar o nível de alerta',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400)),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, c) {
                final narrow = c.maxWidth < 520;
                final tank = WaterTankWithSlider(
                  level: tankLevel,
                  onChanged: (v) => setState(() => tankLevel = v),
                  width: 100,
                  height: 200,
                );
                final info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nível de Alerta',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text('${(tankLevel * 100).round()}%',
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.blue)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alerta quando o nível estiver abaixo deste valor',
                              style: TextStyle(fontSize: 12, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                if (narrow) {
                  return Column(
                    children: [
                      Center(child: tank),
                      const SizedBox(height: 18),
                      info,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    tank,
                    const SizedBox(width: 30),
                    Expanded(child: info),
                  ],
                );
              }),
              const SizedBox(height: 28),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.save_outlined, size: 17),
                    label: const Text('Salvar Configurações', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  AnimatedOpacity(
                    opacity: saved ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppColors.green),
                        SizedBox(width: 5),
                        Text('Configuração salva', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;

  const _InfoBox({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enabled ? color.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled ? color.withOpacity(0.12) : AppColors.grayStateSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: enabled ? color : AppColors.slate400),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? title : '$title (desativado)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.dark : AppColors.slate400,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11.5, color: enabled ? AppColors.slate500 : AppColors.slate400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          color: value ? AppColors.greenSoft : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value ? const Color(0xFF8FD9C9) : AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: value ? AppColors.primary : const Color(0xFFB7CFC9), width: 1.5),
              ),
              child: value ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 15, color: AppColors.slate500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(label,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.dark, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(description, style: const TextStyle(fontSize: 12.5, color: AppColors.slate500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vertical multi-thumb slider (3 níveis independentes mas ordenados)
// ---------------------------------------------------------------------------
class VerticalMultiThumbSlider extends StatefulWidget {
  final List<double> values; // 3 valores 0..1, mantêm ordem
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

  double _clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);

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
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                key: _trackKey,
                width: widget.width,
                height: widget.height,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(widget.width / 2),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
            ),
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
                  decoration: BoxDecoration(color: widget.zoneColors[i], borderRadius: BorderRadius.circular(2)),
                ),
              );
            }),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Text(
                    '$label ${(v * 100).round()}%',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
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
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
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
            Positioned(
              top: 10,
              child: Icon(Icons.water_drop_outlined, size: 20, color: Colors.white.withOpacity(0.4)),
            ),
            Positioned(
              bottom: widget.level * widget.height,
              left: -8,
              right: -8,
              child: Container(
                height: 3,
                color: AppColors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_dot(), _dot()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
    );
  }
}

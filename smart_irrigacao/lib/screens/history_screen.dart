import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/irrigacao_state.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _zoomHours = 3;
  int? _hoveredPoint;
  int? _hoveredState;
  Estado? _activeFilter;
  bool _expandedChart = false;

  final List<_MoisturePoint> _points = const [
    _MoisturePoint('08:00', 63),
    _MoisturePoint('08:20', 56),
    _MoisturePoint('08:40', 44),
    _MoisturePoint('09:00', 34),
    _MoisturePoint('09:20', 25),
    _MoisturePoint('09:40', 38),
    _MoisturePoint('10:00', 56),
    _MoisturePoint('10:20', 54),
    _MoisturePoint('10:40', 51),
    _MoisturePoint('11:00', 45),
    _MoisturePoint('11:20', 48),
    _MoisturePoint('11:40', 50),
    _MoisturePoint('12:00', 42),
    _MoisturePoint('12:20', 38),
    _MoisturePoint('12:45', 37),
    _MoisturePoint('13:10', 34),
    _MoisturePoint('13:35', 31),
    _MoisturePoint('14:00', 55),
    _MoisturePoint('14:20', 57),
    _MoisturePoint('14:40', 76),
    _MoisturePoint('15:00', 75),
    _MoisturePoint('15:30', 74),
    _MoisturePoint('16:00', 73),
    _MoisturePoint('16:30', 62),
    _MoisturePoint('17:00', 59),
    _MoisturePoint('18:00', 54),
  ];

  final List<_StateEvent> _events = const [
    _StateEvent(
      '08:00',
      Estado.esperandoChuva,
      'Aguardando chuva antes de irrigar',
    ),
    _StateEvent('09:00', Estado.umidadeIdeal, 'Umidade em faixa segura'),
    _StateEvent('10:00', Estado.esperandoChuva, 'Previsao de chuva mantida'),
    _StateEvent('11:00', Estado.esperandoAgua, 'Tanque abaixo do ideal'),
    _StateEvent('12:00', Estado.irrigando, 'Irrigacao automatica ligada'),
    _StateEvent('13:00', Estado.irrigando, 'Solo recuperando umidade'),
    _StateEvent('14:00', Estado.irrigando, 'Ciclo automatico finalizando'),
    _StateEvent('15:00', Estado.umidadeIdeal, 'Sistema em espera'),
    _StateEvent('16:00', Estado.chovendo, 'Chuva detectada'),
    _StateEvent('17:00', Estado.irrigandoManual, 'Acionamento manual'),
    _StateEvent('18:00', Estado.ociosoManual, 'Modo manual sem irrigacao'),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final highlightedPoint = _hoveredPoint ?? 14;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PeriodSelector(
                      onTap: () => _showMessage(
                        'Periodo selecionado: 20/05/2024 08:00 - 18:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _IconAction(
                    icon: Icons.filter_alt_outlined,
                    tooltip: 'Limpar filtros',
                    onTap: () => setState(() => _activeFilter = null),
                    boxed: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ChartPanel(
                points: _points,
                events: _events,
                zoomHours: _zoomHours,
                highlightedPoint: highlightedPoint,
                hoveredState: _hoveredState,
                activeFilter: _activeFilter,
                expanded: _expandedChart,
                onZoomChanged: (value) => setState(() => _zoomHours = value),
                onPointHover: (index) => setState(() => _hoveredPoint = index),
                onPointExit: () => setState(() => _hoveredPoint = null),
                onStateHover: (index) => setState(() => _hoveredState = index),
                onStateExit: () => setState(() => _hoveredState = null),
                onStateTap: (event) => setState(() {
                  _activeFilter =
                      _activeFilter == event.state ? null : event.state;
                }),
                onExpand: () =>
                    setState(() => _expandedChart = !_expandedChart),
              ),
              const SizedBox(height: 18),
              _LegendCard(
                selected: _activeFilter,
                onSelected: (state) => setState(() {
                  _activeFilter = _activeFilter == state ? null : state;
                }),
              ),
              const SizedBox(height: 14),
              const _HintRow(),
              const SizedBox(height: 8),
              Consumer<IrrigacaoState>(
                builder: (context, state, _) => _LiveSummary(
                  moisture: state.soilMoisture,
                  tank: state.waterTankLevel,
                  pressure: state.pressao,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final VoidCallback onTap;

  const _PeriodSelector({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 22,
                color: AppColors.dark,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  '20/05/2024 08:00   -   20/05/2024 18:00',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.dark),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  final List<_MoisturePoint> points;
  final List<_StateEvent> events;
  final int zoomHours;
  final int highlightedPoint;
  final int? hoveredState;
  final Estado? activeFilter;
  final bool expanded;
  final ValueChanged<int> onZoomChanged;
  final ValueChanged<int> onPointHover;
  final VoidCallback onPointExit;
  final ValueChanged<int> onStateHover;
  final VoidCallback onStateExit;
  final ValueChanged<_StateEvent> onStateTap;
  final VoidCallback onExpand;

  const _ChartPanel({
    required this.points,
    required this.events,
    required this.zoomHours,
    required this.highlightedPoint,
    required this.hoveredState,
    required this.activeFilter,
    required this.expanded,
    required this.onZoomChanged,
    required this.onPointHover,
    required this.onPointExit,
    required this.onStateHover,
    required this.onStateExit,
    required this.onStateTap,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final point = points[highlightedPoint.clamp(0, points.length - 1)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 25, color: AppColors.dark),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Estados do sistema e umidade do solo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                  ),
                ),
              ),
              _IconAction(
                icon: expanded
                    ? Icons.close_fullscreen_rounded
                    : Icons.open_in_full_rounded,
                tooltip: expanded ? 'Reduzir grafico' : 'Expandir grafico',
                onTap: onExpand,
                boxed: true,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ZoomSelector(value: zoomHours, onChanged: onZoomChanged),
          const SizedBox(height: 26),
          const _TimeScale(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AxisLabel(text: 'Estado do\nsistema'),
              Expanded(
                child: _StateStrip(
                  events: events,
                  hovered: hoveredState,
                  activeFilter: activeFilter,
                  onHover: onStateHover,
                  onExit: onStateExit,
                  onTap: onStateTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AxisLabel(text: 'Umidade\ndo solo (%)'),
              Expanded(
                child: MouseRegion(
                  onHover: (event) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final width = box.size.width - 116;
                    final localX = event.localPosition.dx - 96;
                    final ratio = (localX / math.max(width, 1)).clamp(0.0, 1.0);
                    onPointHover((ratio * (points.length - 1)).round());
                  },
                  onExit: (_) => onPointExit(),
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) return;
                      final width = box.size.width - 116;
                      final ratio =
                          (details.localPosition.dx / math.max(width, 1))
                              .clamp(0.0, 1.0);
                      onPointHover((ratio * (points.length - 1)).round());
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: expanded ? 430 : 340,
                          constraints: const BoxConstraints(minHeight: 280),
                          child: CustomPaint(
                            painter: _MoistureChartPainter(
                              points: points,
                              selectedIndex: highlightedPoint,
                              filterColor: activeFilter == null
                                  ? null
                                  : _StateStyle.color(activeFilter!),
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        Positioned(
                          left: ((highlightedPoint / (points.length - 1)) *
                                  (MediaQuery.sizeOf(context).width - 154))
                              .clamp(0, MediaQuery.sizeOf(context).width),
                          top: -28,
                          child: _ChartTooltip(point: point),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoomSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _ZoomSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const values = [1, 3, 6, 12, 24];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Zoom',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Wrap(
            children: values.map((item) {
              final selected = item == value;
              return InkWell(
                onTap: () => onChanged(item),
                borderRadius: BorderRadius.circular(7),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 58,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.green500.withValues(alpha: 0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: selected
                          ? AppColors.green500
                          : AppColors.borderLighter,
                    ),
                  ),
                  child: Text(
                    '${item}h',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.green500 : AppColors.dark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TimeScale extends StatelessWidget {
  const _TimeScale();

  @override
  Widget build(BuildContext context) {
    const times = ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];
    return Padding(
      padding: const EdgeInsets.only(left: 98, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: times
            .map(
              (time) => Column(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(width: 1, height: 18, color: AppColors.borderLight),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StateStrip extends StatelessWidget {
  final List<_StateEvent> events;
  final int? hovered;
  final Estado? activeFilter;
  final ValueChanged<int> onHover;
  final VoidCallback onExit;
  final ValueChanged<_StateEvent> onTap;

  const _StateStrip({
    required this.events,
    required this.hovered,
    required this.activeFilter,
    required this.onHover,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Row(
        children: List.generate(events.length, (index) {
          final event = events[index];
          final active = activeFilter == null || activeFilter == event.state;
          final isHovered = hovered == index;

          return Expanded(
            child: Tooltip(
              message:
                  '${event.time} - ${_StateStyle.label(event.state)}\n${event.detail}',
              child: MouseRegion(
                onEnter: (_) => onHover(index),
                onExit: (_) => onExit(),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap(event),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: isHovered ? 88 : 78,
                    margin: EdgeInsets.only(
                      right: index == events.length - 1 ? 0 : 4,
                      top: isHovered ? 0 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: _StateStyle.color(event.state).withValues(
                        alpha: active ? 1 : 0.28,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: _StateStyle.color(
                                  event.state,
                                ).withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _StateStyle.icon(event.state),
                      color: Colors.white,
                      size: isHovered ? 29 : 25,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  final Estado? selected;
  final ValueChanged<Estado> onSelected;

  const _LegendCard({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const states = [
      Estado.esperandoChuva,
      Estado.irrigando,
      Estado.irrigandoManual,
      Estado.esperandoAgua,
      Estado.chovendo,
      Estado.ociosoManual,
      Estado.umidadeIdeal,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legenda dos estados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 18,
            children: states.map((state) {
              final active = selected == null || selected == state;
              return Tooltip(
                message: selected == state
                    ? 'Remover filtro'
                    : 'Filtrar por ${_StateStyle.label(state)}',
                child: InkWell(
                  onTap: () => onSelected(state),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: active ? 1 : 0.35,
                    child: SizedBox(
                      width: 190,
                      child: Row(
                        children: [
                          Icon(
                            _StateStyle.icon(state),
                            color: _StateStyle.color(state),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _StateStyle.label(state),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LiveSummary extends StatelessWidget {
  final int moisture;
  final int tank;
  final int pressure;

  const _LiveSummary({
    required this.moisture,
    required this.tank,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniMetric(
            label: 'Umidade agora',
            value: '$moisture%',
            color: AppColors.blue500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniMetric(
            label: 'Caixa d agua',
            value: '$tank%',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniMetric(
            label: 'Pressao',
            value: '$pressure%',
            color: AppColors.amber500,
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: AppColors.slate400),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Deslize o grafico para navegar no tempo. Passe o mouse nos pontos e toque nos estados para filtrar.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartTooltip extends StatelessWidget {
  final _MoisturePoint point;

  const _ChartTooltip({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        '${point.time}  |  ${point.value}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;

  const _AxisLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool boxed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: boxed ? 42 : 44,
          height: boxed ? 42 : 44,
          decoration: boxed
              ? BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                )
              : null,
          child: Icon(icon, color: AppColors.dark, size: boxed ? 20 : 28),
        ),
      ),
    );
  }
}

class _MoistureChartPainter extends CustomPainter {
  final List<_MoisturePoint> points;
  final int selectedIndex;
  final Color? filterColor;

  const _MoistureChartPainter({
    required this.points,
    required this.selectedIndex,
    this.filterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 46.0;
    const top = 16.0;
    const bottom = 34.0;
    final chartWidth = size.width - left - 8;
    final chartHeight = size.height - top - bottom;
    final color = filterColor ?? AppColors.blue500;

    final gridPaint = Paint()
      ..color = AppColors.borderLighter
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.2;

    for (final y in [0, 25, 50, 75, 100]) {
      final dy = top + chartHeight - (y / 100) * chartHeight;
      canvas.drawLine(Offset(left, dy), Offset(size.width, dy), gridPaint);
      _drawText(
        canvas,
        '$y',
        Offset(0, dy - 8),
        AppColors.slate500,
        14,
        FontWeight.w700,
      );
    }

    canvas.drawLine(
      const Offset(left, top),
      Offset(left, top + chartHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(left, top + chartHeight),
      Offset(size.width, top + chartHeight),
      axisPaint,
    );

    final path = Path();
    final fill = Path();
    for (var i = 0; i < points.length; i++) {
      final x = left + (i / (points.length - 1)) * chartWidth;
      final y = top + chartHeight - (points[i].value / 100) * chartHeight;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, top + chartHeight);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill
      ..lineTo(left + chartWidth, top + chartHeight)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.04),
          ],
        ).createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2.6,
    );

    final selected = selectedIndex.clamp(0, points.length - 1);
    final sx = left + (selected / (points.length - 1)) * chartWidth;
    final sy = top + chartHeight - (points[selected].value / 100) * chartHeight;
    final guide = Paint()
      ..color = AppColors.slate400
      ..strokeWidth = 1.4;
    _drawDashedLine(
        canvas, Offset(sx, top - 8), Offset(sx, top + chartHeight), guide);
    canvas.drawCircle(Offset(sx, sy), 10, Paint()..color = AppColors.white);
    canvas.drawCircle(Offset(sx, sy), 7, Paint()..color = color);

    const bottomTimes = ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];
    for (var i = 0; i < bottomTimes.length; i++) {
      final x = left + (i / (bottomTimes.length - 1)) * chartWidth;
      _drawText(
        canvas,
        bottomTimes[i],
        Offset(x - 22, size.height - 20),
        AppColors.slate500,
        14,
        FontWeight.w700,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 8.0;
    const gap = 8.0;
    var distance = 0.0;
    final total = (end - start).distance;
    final direction = (end - start) / total;
    while (distance < total) {
      final from = start + direction * distance;
      final to = start + direction * math.min(distance + dash, total);
      canvas.drawLine(from, to, paint);
      distance += dash + gap;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
    FontWeight weight,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MoistureChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.filterColor != filterColor;
  }
}

class _StateStyle {
  static String label(Estado state) => switch (state) {
        Estado.esperandoChuva => 'Esperando chuva',
        Estado.umidadeIdeal => 'Umidade boa',
        Estado.esperandoAgua => 'Esperando agua',
        Estado.irrigando => 'Irrigando',
        Estado.chovendo => 'Chovendo',
        Estado.irrigandoManual => 'Irrigacao manual',
        Estado.ociosoManual => 'Manual ocioso',
      };

  static IconData icon(Estado state) => switch (state) {
        Estado.esperandoChuva => Icons.cloud_outlined,
        Estado.umidadeIdeal => Icons.eco_outlined,
        Estado.esperandoAgua => Icons.water_drop_outlined,
        Estado.irrigando => Icons.shower_outlined,
        Estado.chovendo => Icons.thunderstorm_outlined,
        Estado.irrigandoManual => Icons.front_hand_outlined,
        Estado.ociosoManual => Icons.pan_tool_alt_outlined,
      };

  static Color color(Estado state) => switch (state) {
        Estado.esperandoChuva => const Color(0xFFF6C536),
        Estado.umidadeIdeal => AppColors.blue500,
        Estado.esperandoAgua => const Color(0xFFF28A24),
        Estado.irrigando => AppColors.green500,
        Estado.chovendo => const Color(0xFF0E4A86),
        Estado.irrigandoManual => const Color(0xFF6E45B8),
        Estado.ociosoManual => const Color(0xFFB9BEC7),
      };
}

class _MoisturePoint {
  final String time;
  final int value;

  const _MoisturePoint(this.time, this.value);
}

class _StateEvent {
  final String time;
  final Estado state;
  final String detail;

  const _StateEvent(this.time, this.state, this.detail);
}

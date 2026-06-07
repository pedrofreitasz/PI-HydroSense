import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoistureChartPainter extends CustomPainter {
  final List<double> data;

  MoistureChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E9F2)
      ..strokeWidth = 1;

    const double leftPad = 40;
    const double bottomPad = 0;
    final double chartW = size.width - leftPad;
    final double chartH = size.height - bottomPad;

    for (int i = 0; i <= 4; i++) {
      final y = chartH - (chartH * i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    final double xStep = chartW / (data.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = leftPad + i * xStep;
      final y = chartH - (data[i] / 100) * chartH;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartH);
        fillPath.lineTo(x, y);
      } else {
        final prevX = leftPad + (i - 1) * xStep;
        final prevY = chartH - (data[i - 1] / 100) * chartH;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppTheme.primary.withOpacity(0.18),
        AppTheme.primary.withOpacity(0.01),
      ],
    );
    fillPath.lineTo(leftPad + (data.length - 1) * xStep, chartH);
    fillPath.close();
    fillPaint.shader =
        gradient.createShader(Rect.fromLTWH(leftPad, 0, chartW, chartH));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = leftPad + i * xStep;
      final y = chartH - (data[i] / 100) * chartH;
      canvas.drawCircle(Offset(x, y), 5, dotBorder);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    final textStyle =
        const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10);
    for (int i = 0; i <= 4; i++) {
      final value = (i * 25).toString();
      final tp = TextPainter(
        text: TextSpan(text: value, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = chartH - (chartH * i / 4) - tp.height / 2;
      tp.paint(canvas, Offset(0, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MoistureChart extends StatelessWidget {
  const MoistureChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> data = [57, 70, 77, 70, 57, 62, 45, 55, 70, 62];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Histórico de Umidade',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textPrimary),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Text('Últimas 24h',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: const Text('Umidade (%)',
                  style: TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: SizedBox(
                height: 160,
                child: CustomPaint(
                  painter: MoistureChartPainter(data: data),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['06:30', '09:00', '12:00', '15:00', '06:30']
                .map((t) => Text(t,
                    style: const TextStyle(
                        fontSize: 8, color: AppTheme.textSecondary)))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text('Horário (Últimas 24 Horas)',
              style:
                  TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ),
      ],
    );
  }
}
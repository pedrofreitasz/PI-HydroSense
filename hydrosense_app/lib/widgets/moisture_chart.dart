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
    final gridPaint = Paint()..color = const Color(0xFFE5E9F2)..strokeWidth = 1;

    final dotPaint = Paint()..color = AppTheme.primary..style = PaintingStyle.fill;
    final dotBorder = Paint()..color = Colors.white..style = PaintingStyle.fill;

    const double leftPad = 40;
    const double bottomPad = 0;
    final double chartW = size.width - leftPad;
    final double chartH = size.height - bottomPad;

    // Desenha as linhas horizontais de grade
    for (int i = 0; i <= 4; i++) {
      final y = chartH - (chartH * i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // Se não houver dados reais, interrompe o desenho aqui
    if (data.isEmpty) return;

    final double xStep = chartW / (data.length == 1 ? 1 : data.length - 1);
    final path = Path();
    final fillPath = Path();

    // Caso especial: se o usuário inseriu apenas 1 registro
    if (data.length == 1) {
      final x = leftPad + chartW / 2; // Centraliza o ponto isolado
      final y = chartH - (data[0] / 100) * chartH;
      canvas.drawCircle(Offset(x, y), 6, dotBorder);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    } else {
      // Desenha as linhas curvas conectando os dados reais inseridos
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
      fillPaint.shader = gradient.createShader(Rect.fromLTWH(leftPad, 0, chartW, chartH));
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // Desenha as bolinhas nos vértices
      for (int i = 0; i < data.length; i++) {
        final x = leftPad + i * xStep;
        final y = chartH - (data[i] / 100) * chartH;
        canvas.drawCircle(Offset(x, y), 5, dotBorder);
        canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      }
    }

    // Desenha os rótulos do eixo Y (0 a 100)
    for (int i = 0; i <= 4; i++) {
      final value = (i * 25).toString();
      final tp = TextPainter(
        text: TextSpan(text: value, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
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
  final List<double> dadosDoBanco;
  
  const MoistureChart({super.key, required this.dadosDoBanco});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Histórico de Umidade',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Em tempo real', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: const Text('Umidade (%)', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: SizedBox(
                height: 160,
                child: dadosDoBanco.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum dado inserido ainda.\nClique em "Irrigar Agora" para começar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      )
                    : CustomPaint(
                        painter: MoistureChartPainter(data: dadosDoBanco),
                        size: Size.infinite,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/irrigacao_state.dart';
import '../theme.dart';

class SensorCardsGrid extends StatelessWidget {
  const SensorCardsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IrrigacaoState>(
      builder: (context, state, _) {
        return Column(
          children: [
            _InteractiveSensorCard(
              icon: Icons.opacity,
              label: 'Umidade do solo',
              value: '${state.currentData.leituraumidadeSolo}%',
              progress: state.currentData.leituraumidadeSolo / 100,
              color: AppColors.primary,
              onChanged: (v) => state.updateData(leituraumidadeSolo: (v * 100).round()),
            ),
            const SizedBox(height: 12),
            _InteractiveSensorCard(
              icon: Icons.waves,
              label: 'Caixa d\'água',
              value: '${state.currentData.leituraPorcentagemCaixaAgua}%',
              progress: state.currentData.leituraPorcentagemCaixaAgua / 100,
              color: AppColors.blue500,
              onChanged: (v) => state.updateData(leituraPorcentagemCaixaAgua: (v * 100).round()),
            ),
          ],
        );
      },
    );
  }
}

class _InteractiveSensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;
  final ValueChanged<double> onChanged;

  const _InteractiveSensorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  const SizedBox(width: 10),
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.slate600)),
                ],
              ),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: color.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: progress,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

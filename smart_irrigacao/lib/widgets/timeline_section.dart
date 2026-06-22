import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/irrigacao_state.dart';
import '../theme.dart';

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IrrigacaoState>(
      builder: (context, state, _) {
        final entries = state.timelineEntries;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isLast = index == entries.length - 1;

            return _TimelineItem(
              entry: entry,
              isLast: isLast,
            );
          },
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEntry entry;
  final bool isLast;

  const _TimelineItem({required this.entry, required this.isLast});

  String _label(Estado s) => switch (s) {
    Estado.esperandoChuva => 'Esperando chuva',
    Estado.umidadeIdeal => 'Umidade boa',
    Estado.esperandoAgua => 'Esperando água',
    Estado.irrigando => 'Irrigando',
    Estado.chovendo => 'Chovendo',
    Estado.irrigandoManual => 'Manual (irrigando)',
    Estado.ociosoManual => 'Manual (ocioso)',
  };

  IconData _icon(Estado s) => switch (s) {
    Estado.esperandoChuva => Icons.timer_outlined,
    Estado.umidadeIdeal => Icons.eco_outlined,
    Estado.esperandoAgua => Icons.water_drop_outlined,
    Estado.irrigando => Icons.opacity,
    Estado.chovendo => Icons.grain,
    Estado.irrigandoManual => Icons.front_hand_outlined,
    Estado.ociosoManual => Icons.front_hand_outlined,
  };

  Color _color(Estado s) => switch (s) {
    Estado.esperandoChuva => AppColors.amber500,
    Estado.umidadeIdeal => AppColors.primary,
    Estado.esperandoAgua => AppColors.orange500,
    Estado.irrigando => AppColors.blue500,
    Estado.chovendo => AppColors.purple500,
    Estado.irrigandoManual => AppColors.pink500,
    Estado.ociosoManual => AppColors.slate400,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna de Horário
        SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              entry.time,
              style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // Linha e Círculo
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _color(entry.state),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon(entry.state), color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.withOpacity(0.1),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Conteúdo
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _label(entry.state),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark),
                    ),
                    Text(
                      entry.durationLabel,
                      style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '10:50–${entry.time}',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Umidade 34% · Caixa 86% · Sem previsão de chuva',
                  style: TextStyle(fontSize: 12, color: AppColors.slate600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

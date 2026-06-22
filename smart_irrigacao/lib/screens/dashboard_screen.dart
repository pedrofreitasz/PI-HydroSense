import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/irrigacao_state.dart';
import '../theme.dart';
import '../widgets/estado_card.dart';
import '../widgets/sensor_cards.dart';
import '../widgets/timeline_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _buildStatusBadge(),
              ),
              const SizedBox(height: 16),
              const EstadoCard(),
              const SizedBox(height: 24),
              const Text(
                'Sensores Ativos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 16),
              const SensorCardsGrid(),
              const SizedBox(height: 24),
              const Text(
                'Ambiente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 16),
              const RainContextCard(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: AppColors.slate600,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Historico (ultimas 24h)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Ver tudo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const TimelineSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 8, height: 8),
          ),
          SizedBox(width: 8),
          Text(
            'ONLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class RainContextCard extends StatelessWidget {
  const RainContextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IrrigacaoState>(
      builder: (context, state, _) {
        final contexto = state.currentData.estadoChuva;
        String title;
        IconData icon;
        Color color;

        if (contexto == ContextoChuva.paraChover) {
          title = 'Chuva em breve';
          icon = Icons.cloud_queue_rounded;
          color = AppColors.blue500;
        } else if (contexto == ContextoChuva.chovendo) {
          title = 'Chovendo agora';
          icon = Icons.grain_rounded;
          color = AppColors.blue500;
        } else {
          title = 'Ceu limpo';
          icon = Icons.wb_sunny_rounded;
          color = AppColors.amber500;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contexto de chuva',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '18:00',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.slate400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

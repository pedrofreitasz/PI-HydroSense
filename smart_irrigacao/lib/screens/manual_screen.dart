import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/irrigacao_state.dart';
import '../theme.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<IrrigacaoState>(
        builder: (context, state, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de Status do Modo
                _buildStatusHeader(state),
                const SizedBox(height: 24),

                const Text(
                  'Configurações Manuais',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 16),

                // Card de Modo Manual
                _buildControlCard(
                  title: 'Modo Manual',
                  subtitle: 'Assuma o controle total do sistema',
                  icon: Icons.touch_app_rounded,
                  color: AppColors.primary,
                  trailing: Switch(
                    value: state.isManualMode,
                    onChanged: (v) => state.setManualMode(v),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Card de Irrigação
                AnimatedOpacity(
                  opacity: state.isManualMode ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !state.isManualMode,
                    child: _buildControlCard(
                      title: 'Irrigação',
                      subtitle: state.isIrrigating
                          ? 'Distribuindo água...'
                          : 'Sistema parado',
                      icon: Icons.water_drop_rounded,
                      color: state.isIrrigating
                          ? AppColors.primary
                          : AppColors.slate400,
                      trailing: ElevatedButton(
                        onPressed: () => state.toggleIrrigating(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isIrrigating
                              ? AppColors.red500
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(state.isIrrigating ? 'Parar' : 'Iniciar',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Tempo de Irrigação',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 16),

                // Seletor de tempo
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [5, 10, 15, 30, 60].map((min) {
                    final isSelected = state.selectedTime == min;
                    return GestureDetector(
                      onTap: state.isManualMode
                          ? () => state.setSelectedTime(isSelected ? null : min)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderLight),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]
                              : [],
                        ),
                        child: Text(
                          '$min min',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color:
                                isSelected ? Colors.white : AppColors.slate600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(IrrigacaoState state) {
    final isManual = state.isManualMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isManual
            ? AppColors.primary.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isManual
                ? AppColors.primary.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            isManual ? Icons.handyman_rounded : Icons.auto_mode_rounded,
            size: 48,
            color: isManual ? AppColors.primary : AppColors.slate400,
          ),
          const SizedBox(height: 12),
          Text(
            isManual ? 'Modo Manual Ativo' : 'Modo Automático',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isManual ? AppColors.primary : AppColors.slate500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isManual
                ? 'Você tem o controle total'
                : 'O sistema decide por você',
            style: TextStyle(
                fontSize: 13,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget trailing,
  }) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

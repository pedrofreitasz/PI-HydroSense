import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/moisture_chart.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.water,
                      iconBg: AppTheme.primarySurface,
                      iconColor: AppTheme.primary,
                      title: 'Última Irrigação',
                      value: 'Hoje, 06:30',
                      valueColor: AppTheme.primary,
                      trailing: const Icon(Icons.access_time_outlined,
                          color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.eco,
                      iconBg: AppTheme.greenSurface,
                      iconColor: AppTheme.greenAccent,
                      title: 'Status do Solo',
                      value: 'Ideal',
                      valueColor: AppTheme.greenAccent,
                      subtitle: '65% de umidade',
                      trailing: const Icon(Icons.water_drop_outlined,
                          color: AppTheme.greenAccent, size: 24),
                    ),
                    const SizedBox(height: 12),
                    _buildTankCard(),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.cloud,
                      iconBg: AppTheme.primarySurface,
                      iconColor: AppTheme.primary,
                      title: 'Chance de Chuva',
                      value: '15%',
                      valueColor: AppTheme.primary,
                      trailing: const Icon(Icons.umbrella_outlined,
                          color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.menu, color: AppTheme.textPrimary, size: 26),
          const SizedBox(width: 12),
          _buildLogo(),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_outlined,
                  color: AppTheme.textPrimary, size: 26),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        const Text(
          'HydroSense',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: -0.3),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: valueColor)),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildTankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.propane_tank_outlined,
                color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nível do Reservatório',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                const Text('82%',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 10,
                    backgroundColor: Color(0xFFE5E9F2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: const MoistureChart(),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.water_drop_outlined,
                  color: Colors.white, size: 22),
              label: const Text('Irrigar Agora',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined,
                  color: AppTheme.primary, size: 22),
              label: const Text('Configurações',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
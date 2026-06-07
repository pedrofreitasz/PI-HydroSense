import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _minMoisture = 0.4;
  bool _autoIrrigation = true;
  bool _lowWaterAlert = true;
  bool _irrigationStarted = true;

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
                    _buildIrrigationRulesCard(),
                    const SizedBox(height: 14),
                    _buildNotificationsCard(),
                    const SizedBox(height: 14),
                    _buildDeviceStatusCard(),
                    const SizedBox(height: 14),
                    _buildScheduleCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                color: AppTheme.textPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(9)),
            child:
                const Icon(Icons.water_drop, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 6),
          const Text('HydroSense',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
          const SizedBox(width: 12),
          const Text('Configurações',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE5E9F2),
        ),
      ],
    );
  }

  Widget _buildIrrigationRulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.water_drop, 'Regras de Irrigação'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Umidade Mínima do Solo',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('${(_minMoisture * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
              'Defina o nível mínimo de umidade antes de iniciar a irrigação.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('10%',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: const Color(0xFFE5E9F2),
                    thumbColor: AppTheme.primary,
                    overlayColor: AppTheme.primary.withOpacity(0.12),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _minMoisture,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) => setState(() => _minMoisture = v),
                  ),
                ),
              ),
              const Text('100%',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const Divider(color: AppTheme.divider, height: 24),
          _buildToggleRow(
            icon: Icons.eco,
            iconBg: AppTheme.greenSurface,
            iconColor: AppTheme.greenAccent,
            title: 'Irrigação Automática',
            subtitle:
                'Irrigar automaticamente quando as regras forem atendidas.',
            value: _autoIrrigation,
            onChanged: (v) => setState(() => _autoIrrigation = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              Icons.notifications_outlined, 'Notificações'),
          const SizedBox(height: 16),
          _buildToggleRow(
            icon: Icons.propane_tank_outlined,
            iconBg: AppTheme.primarySurface,
            iconColor: AppTheme.primary,
            title: 'Alerta de Reservatório Baixo',
            subtitle: 'Notificar quando o nível da água estiver baixo.',
            value: _lowWaterAlert,
            onChanged: (v) => setState(() => _lowWaterAlert = v),
          ),
          const Divider(color: AppTheme.divider, height: 24),
          _buildToggleRow(
            icon: Icons.water,
            iconBg: AppTheme.primarySurface,
            iconColor: AppTheme.primary,
            title: 'Irrigação Iniciada',
            subtitle: 'Notificar quando a irrigação for iniciada.',
            value: _irrigationStarted,
            onChanged: (v) => setState(() => _irrigationStarted = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.wifi, 'Status do Dispositivo'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(4, (i) {
                        return Container(
                          width: 5,
                          height: 6.0 + i * 4,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                              color: AppTheme.greenAccent,
                              borderRadius: BorderRadius.circular(2)),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Conectividade do Sensor',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                        Row(
                          children: [
                            Text('Forte',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.greenAccent)),
                            SizedBox(width: 4),
                            Icon(Icons.circle,
                                size: 8, color: AppTheme.greenAccent),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.divider),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nível da Bateria',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                        Text('95%',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 30,
                      height: 22,
                      child: CustomPaint(
                          painter: BatteryPainter(level: 0.95)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              Icons.calendar_today_outlined, 'Agendamento'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Horários de Irrigação',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  Text('Defina os horários em que a irrigação ocorrerá.',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline,
                    size: 16, color: AppTheme.primary),
                label: const Text('Adicionar',
                    style:
                        TextStyle(color: AppTheme.primary, fontSize: 13)),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeChip('06:30', 'Diário'),
                const SizedBox(width: 10),
                _buildTimeChip('18:30', 'Diário'),
                const SizedBox(width: 10),
                _buildTimeChip('08:00', 'Seg, Qua, Sex'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.info_outline,
                  size: 14, color: AppTheme.textSecondary),
              SizedBox(width: 6),
              Text('A irrigação dura 20 minutos por sessão.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time, String repeat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
              Text(repeat,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(width: 10),
          const Icon(Icons.more_vert,
              size: 16, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.water_drop_outlined,
              color: Colors.white, size: 22),
          label: const Text('Salvar Alterações',
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
    );
  }
}

class BatteryPainter extends CustomPainter {
  final double level;
  BatteryPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fillPaint = Paint()
      ..color = AppTheme.greenAccent
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 2, size.width - 4, size.height - 4),
          const Radius.circular(3)),
      bodyPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 4, size.height / 2 - 3, 4, 6),
      Paint()..color = const Color(0xFFD1D5DB),
    );
    final fillW = (size.width - 8) * level;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 4, fillW, size.height - 8),
          const Radius.circular(2)),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
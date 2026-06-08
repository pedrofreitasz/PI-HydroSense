import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/moisture_chart.dart';
import '../database/database_helper.dart';
import '../models/leitura_model.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<LeituraModel> _leituras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarLeituras();
    });
  }

  Future<void> _carregarLeituras() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final dados = await DatabaseHelper.instance.buscarTodasLeituras();
      if (!mounted) return;
      setState(() {
        _leituras = dados;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao acessar o banco de dados: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Abre o formulário para o usuário configurar totalmente o novo cadastro
  void _abrirFormularioNovaIrrigacao() {
    final TextEditingController umidadeController = TextEditingController(text: '60');
    final TextEditingController reservatorioController = TextEditingController(text: '80');
    bool valvulaAtiva = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nova Irrigação Manual',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Campo: Umidade do Solo
                    const Text('Umidade do Solo (%)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: umidadeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 65',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.water_drop, color: AppTheme.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Nível do Reservatório
                    const Text('Nível do Reservatório (%)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reservatorioController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 90',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.propane_tank_outlined, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Switch: Estado da Válvula
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ativar Válvula de Água?', style: TextStyle(fontWeight: FontWeight.w600)),
                        Switch(
                          value: valvulaAtiva,
                          activeColor: AppTheme.primary,
                          onChanged: (value) {
                            setModalState(() {
                              valvulaAtiva = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botão Salvar Cadastro
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final int umidade = int.tryParse(umidadeController.text) ?? 50;
                          final int reservatorio = int.tryParse(reservatorioController.text) ?? 100;

                          final novaLeitura = LeituraModel(
                            timestamp: DateTime.now().toIso8601String(),
                            umidadeSolo: umidade,
                            pressaoHpa: 1012.3,
                            nivelReservCm: reservatorio,
                            chuvaDetectada: 0,
                            valvulaAtiva: valvulaAtiva ? 1 : 0,
                          );

                          await DatabaseHelper.instance.inserirLeitura(novaLeitura);
                          
                          if (!context.mounted) return;
                          Navigator.pop(context); // Fecha o formulário
                          
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dados cadastrados com sucesso!')),
                          );

                          _carregarLeituras(); // Recarrega a tela principal e o gráfico
                        },
                        child: const Text('Salvar Registro', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _removerUltimaLeitura() async {
    if (_leituras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum dado para remover.')),
      );
      return;
    }

    final idParaRemover = _leituras.first.id; 
    if (idParaRemover != null) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('leituras', where: 'id = ?', whereArgs: [idParaRemover]);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro mais recente removido!')),
      );
      _carregarLeituras();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<double> dadosGrafico = _leituras.map((l) => l.umidadeSolo.toDouble()).toList().reversed.toList();
    final bool temDados = _leituras.isNotEmpty;
    
    final stringUmidade = temDados ? '${_leituras.first.umidadeSolo}%' : '--';
    final stringReservatorio = temDados ? '${_leituras.first.nivelReservCm}%' : '0%';
    final double valorProgressoReservatorio = temDados ? (_leituras.first.nivelReservCm / 100).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.water,
                          iconBg: AppTheme.primarySurface,
                          iconColor: AppTheme.primary,
                          title: 'Última Irrigação',
                          value: temDados ? (_leituras.first.valvulaAtiva == 1 ? 'Válvula Ligada' : 'Apenas Leitura') : 'Nenhuma registrada',
                          valueColor: AppTheme.primary,
                          trailing: const Icon(Icons.access_time_outlined, color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.eco,
                          iconBg: AppTheme.greenSurface,
                          iconColor: AppTheme.greenAccent,
                          title: 'Status do Solo',
                          value: temDados ? 'Monitorando' : 'Sem Dados',
                          valueColor: AppTheme.greenAccent,
                          subtitle: temDados ? '$stringUmidade de umidade' : 'Insira um dado abaixo',
                          trailing: const Icon(Icons.water_drop_outlined, color: AppTheme.greenAccent, size: 24),
                        ),
                        const SizedBox(height: 12),
                        _buildTankCard(stringReservatorio, valorProgressoReservatorio),
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration,
                          child: MoistureChart(dadosDoBanco: dadosGrafico),
                        ),
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
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 26),
            tooltip: 'Remover último dado',
            onPressed: _removerUltimaLeitura,
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
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        const Text(
          'HydroSense',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: -0.3),
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
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: valueColor)),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildTankCard(String nivel, double progresso) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.propane_tank_outlined, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nível do Reservatório', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(nivel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE5E9F2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              onPressed: _abrirFormularioNovaIrrigacao, // Modificado para abrir o modal
              icon: const Icon(Icons.water_drop_outlined, color: Colors.white, size: 22),
              label: const Text('Irrigar Agora', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                _carregarLeituras();
              },
              icon: const Icon(Icons.settings_outlined, color: AppTheme.primary, size: 22),
              label: const Text('Configurações', style: TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/irrigacao_state.dart';
import '../theme.dart';

class EstadoCard extends StatelessWidget {
  const EstadoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IrrigacaoState>(
      builder: (context, state, _) {
        final info = _getEstadoInfo(state.systemState);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [info.bgColor, info.bgColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: info.bgColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(info.icon, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTADO ATUAL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.descricao,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _EstadoInfo _getEstadoInfo(Estado state) {
    switch (state) {
      case Estado.irrigando:
      case Estado.irrigandoManual:
        return _EstadoInfo(
          Icons.water_drop_rounded,
          'Irrigando',
          'O sistema está distribuindo água agora.',
          AppColors.primary,
        );
      case Estado.chovendo:
        return _EstadoInfo(
          Icons.cloud_rounded,
          'Chovendo',
          'Sistema em pausa devido à chuva.',
          AppColors.blue500,
        );
      case Estado.esperandoChuva:
        return _EstadoInfo(
          Icons.cloud_queue_rounded,
          'Esperando Chuva',
          'Umidade baixa, aguardando chuva.',
          AppColors.amber500,
        );
      case Estado.esperandoAgua:
        return _EstadoInfo(
          Icons.hourglass_bottom_rounded,
          'Sem Água',
          'Reservatório baixo. Aguardando.',
          AppColors.red500,
        );
      case Estado.umidadeIdeal:
        return _EstadoInfo(
          Icons.eco_rounded,
          'Umidade Ideal',
          'Solo hidratado adequadamente.',
          AppColors.green500,
        );
      default:
        return _EstadoInfo(
          Icons.eco_rounded,
          'Umidade Ideal',
          'Solo hidratado adequadamente.',
          AppColors.primary,
        );
    }
  }
}

class _EstadoInfo {
  final IconData icon;
  final String nome;
  final String descricao;
  final Color bgColor;

  _EstadoInfo(this.icon, this.nome, this.descricao, this.bgColor);
}

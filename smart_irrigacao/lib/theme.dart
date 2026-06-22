import 'package:flutter/material.dart';

class AppColors {
  // Cores primárias - novo tema verde-água premium
  static const Color primary = Color(0xFF1E9E86);
  static const Color primaryLight = Color(0xFFE9F5F2);
  static const Color primaryDark = Color(0xFF123832);
  
  // Cores de status
  static const Color red500 = Color(0xFFE5484D);      // Crítica
  static const Color amber500 = Color(0xFFE8B33D);    // Não Crítica
  static const Color green500 = Color(0xFF34B27B);    // Parar/Sucesso
  
  // Cores de fundo
  static const Color bg = Color(0xFFF1F7F6);
  static const Color white = Color(0xFFFFFFFF);
  
  // Cores de texto
  static const Color dark = Color(0xFF123832);
  static const Color slate600 = Color(0xFF5E9387);
  static const Color slate500 = Color(0xFF6E8E87);
  static const Color slate400 = Color(0xFF7C9994);
  
  // Cores de componentes
  static const Color blue500 = Color(0xFF2E7FB8);
  static const Color orange500 = Color(0xFFE8B33D);
  static const Color purple500 = Color(0xFF8B5CF6);
  static const Color pink500 = Color(0xFFEC4899);
  
  // Cores de borda e sombra
  static const Color borderLight = Color(0xFFCFE7E1);
  static const Color borderLighter = Color(0xFFE3EFEC);
  
  // Estado cores (compatível com novo sistema)
  static const Color estadoIrrigando = Color(0xFF1E9E86);
  static const Color estadoChovendo = Color(0xFF1E3A5F);
  static const Color estadoEsperando = Color(0xFFE8B33D);
  static const Color estadoManual = Color(0xFF2E7FB8);
}

class AppTheme {
  static ThemeData get theme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.white,
      onSurface: AppColors.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      
      // Corrigindo o CardTheme para ser compatível com todas as versões do Material 3
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.dark),
        titleTextStyle: TextStyle(
          color: AppColors.dark,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

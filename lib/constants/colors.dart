import 'package:flutter/material.dart';

// Background utama (gelap elegan)
const Color kBackgroundColor = Color(0xFF121212);

// Warna aksen utama (pilih salah satu, atau gunakan keduanya sesuai kebutuhan)
const Color kPrimaryPurple = Color(0xFF7C4DFF);
const Color kPrimaryBlue = Color(0xFF42A5F5);

// Warna utama aplikasi (gunakan salah satu sebagai primary)
const MaterialColor kPrimaryMaterialColor =
    MaterialColor(0xFF7C4DFF, <int, Color>{
      50: Color(0xFFF3E8FF),
      100: Color(0xFFE1CFFF),
      200: Color(0xFFC7AFFF),
      300: Color(0xFFA98CFF),
      400: Color(0xFF916FFF),
      500: Color(0xFF7C4DFF),
      600: Color(0xFF6F3FE6),
      700: Color(0xFF5C32BF),
      800: Color(0xFF4A2699),
      900: Color(0xFF321A66),
    });

// Card putih terang atau abu terang
const Color kCardColor = Color(0xFFF5F5F5); // abu terang
const Color kCardWhite = Colors.white;

// Warna prioritas task
const Color kPriorityHighColor = Color(0xFFFF5252); // Merah
const Color kPriorityMediumColor = Color(0xFFFFA726); // Oranye
const Color kPriorityLowColor = Color(0xFF66BB6A); // Hijau

// Warna teks terang dan gelap
const Color kTextLightColor = Colors.white;
const Color kTextDarkColor = Color(0xFF212121);

// Warna border atau divider
const Color kDividerColor = Color(0xFFBDBDBD);

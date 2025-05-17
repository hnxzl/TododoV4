import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =====================
// LIGHT THEME (Pantai)
// =====================
const Color kLightBg = Color(0xFFFDFCF7); // Primary background
const Color kLightCard = Color(0xFFFFFFFF); // Card background
const Color kLightText = Color(0xFF1F1F1F); // Primary text
const Color kLightAccent = Color(0xFF00A8A8); // Accent (biru laut)
const Color kLightHighlight = Color(0xFFFDCB6E); // Highlight (kuning pasir)
const Color kLightBorder = Color(0xFFE0E0E0); // Border/subtle

// Priority
const Color kLightPriorityHigh = Color(0xFFFF5F57); // High (merah coral)
const Color kLightPriorityMedium = Color(0xFFFFA726); // Medium (oranye)
const Color kLightPriorityLow = Color(0xFF66BB6A); // Low (hijau lembut)

// =====================
// DARK THEME (Bulan)
// =====================
const Color kDarkBg = Color(0xFF0D0D0D); // Primary background
const Color kDarkCard = Color(0xFF1A1A1A); // Card background
const Color kDarkCardAlt = Color(0xFF222831); // Card alt
const Color kDarkText = Color(0xFFEDEDED); // Primary text
const Color kDarkAccent = Color(0xFF4DD0E1); // Accent (biru bulan)
const Color kDarkBorder = Color(0xFF2F2F2F); // Border/subtle

// Priority
const Color kDarkPriorityHigh = Color(0xFFFF6B6B); // High (merah terang)
const Color kDarkPriorityMedium = Color(0xFFFFB74D); // Medium (oranye terang)
const Color kDarkPriorityLow = Color(0xFF81C784); // Low (hijau cerah)

// =====================
// TYPOGRAPHY
// =====================
const String kFontFamily = 'Poppins'; // atau 'Inter'

const double kTitleFontSize = 22; // Judul besar
const double kSubtitleFontSize = 16; // Subjudul/label
const double kBodyFontSize = 14; // Isi
const double kCaptionFontSize = 12; // Deskripsi/info kecil

const FontWeight kTitleWeight = FontWeight.bold;
const FontWeight kSubtitleWeight = FontWeight.w600;
const FontWeight kBodyWeight = FontWeight.normal;
const FontWeight kCaptionWeight = FontWeight.w500;

// =====================
// THEME DATA
// =====================
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: kLightBg,
  cardColor: kLightCard,
  primaryColor: kLightAccent,
  colorScheme: ColorScheme.light(
    primary: kLightAccent,
    secondary: kLightHighlight,
    background: kLightBg,
    surface: kLightCard,
    onPrimary: Colors.white,
    onSecondary: kLightText,
    onBackground: kLightText,
    onSurface: kLightText,
    error: kLightPriorityHigh,
    onError: Colors.white,
  ),
  dividerColor: kLightBorder,
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    titleLarge: TextStyle(
      fontSize: kTitleFontSize,
      fontWeight: kTitleWeight,
      color: kLightText,
    ),
    titleMedium: TextStyle(
      fontSize: kSubtitleFontSize,
      fontWeight: kSubtitleWeight,
      color: kLightText,
    ),
    bodyMedium: TextStyle(
      fontSize: kBodyFontSize,
      fontWeight: kBodyWeight,
      color: kLightText,
    ),
    bodySmall: TextStyle(
      fontSize: kCaptionFontSize,
      fontWeight: kCaptionWeight,
      color: kLightText,
      fontStyle: FontStyle.italic,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kDarkBg,
  cardColor: kDarkCard,
  primaryColor: kDarkAccent,
  colorScheme: ColorScheme.dark(
    primary: kDarkAccent,
    secondary: kDarkPriorityMedium,
    background: kDarkBg,
    surface: kDarkCard,
    onPrimary: Colors.white,
    onSecondary: kDarkText,
    onBackground: kDarkText,
    onSurface: kDarkText,
    error: kDarkPriorityHigh,
    onError: Colors.white,
  ),
  dividerColor: kDarkBorder,
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    titleLarge: TextStyle(
      fontSize: kTitleFontSize,
      fontWeight: kTitleWeight,
      color: kDarkText,
    ),
    titleMedium: TextStyle(
      fontSize: kSubtitleFontSize,
      fontWeight: kSubtitleWeight,
      color: kDarkText,
    ),
    bodyMedium: TextStyle(
      fontSize: kBodyFontSize,
      fontWeight: kBodyWeight,
      color: kDarkText,
    ),
    bodySmall: TextStyle(
      fontSize: kCaptionFontSize,
      fontWeight: kCaptionWeight,
      color: kDarkText,
      fontStyle: FontStyle.italic,
    ),
  ),
);

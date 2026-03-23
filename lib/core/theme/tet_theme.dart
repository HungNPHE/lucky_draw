import 'package:flutter/material.dart';

/// Màu và style chủ đạo Tết: đỏ, vàng, nền ấm - Tông màu dịu hơn
class TetTheme {
  TetTheme._();

  // Màu đỏ dịu hơn
  static const Color redPrimary = Color(0xFFB83240);   // Đỏ đất dịu
  static const Color redDark = Color(0xFF6B1A1A);      // Đỏ đậm dịu
  static const Color redLight = Color(0xFFE85D5D);     // Đỏ nhạt
  
  // Màu vàng dịu hơn
  static const Color gold = Color(0xFFC9A227);         // Vàng đất
  static const Color goldLight = Color(0xFFE8D179);    // Vàng nhạt dịu
  static const Color goldDark = Color(0xFF9A7B1A);     // Vàng đậm
  
  // Màu phụ
  static const Color cream = Color(0xFFF5F0E6);        // Kem dịu
  static const Color bgGradientStart = Color(0xFF1a1212);
  static const Color bgGradientEnd = Color(0xFF2d1a1a);
  static const Color bgGradientMid = Color(0xFF231515);
  
  // Màu surface dịu
  static const Color surfaceLight = Color(0xFF2d2020);
  static const Color surfaceDark = Color(0xFF1a1515);
}

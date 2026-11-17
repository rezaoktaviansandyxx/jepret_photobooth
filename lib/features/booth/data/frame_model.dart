import 'package:material_ui/material_ui.dart';

class FrameModel {
  final String id;
  final String name;
  final String tag;
  final Color backgroundColor;
  final Color borderColor;
  final String assetPath;
  final String? placeholderText;
  final String? placeholderEmoji;

  const FrameModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.backgroundColor,
    required this.borderColor,
    required this.assetPath,
    this.placeholderText,
    this.placeholderEmoji,
  });
}

final List<FrameModel> sampleFrames = [
  const FrameModel(
    id: 'classic',
    name: 'Classic',
    tag: 'Putih Minimal',
    backgroundColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFFE0E0E0),
    assetPath: 'assets/frames/classic.png',
    placeholderEmoji: '✨',
    placeholderText: 'Classic Clean',
  ),
  const FrameModel(
    id: 'doodle_love',
    name: 'Doodle Love',
    tag: 'Pink Hati',
    backgroundColor: Color(0xFFFFE4EC),
    borderColor: Color(0xFFFF69B4),
    assetPath: 'assets/frames/doodle_love.png',
    placeholderEmoji: '💖',
    placeholderText: 'Sweet Love',
  ),
  const FrameModel(
    id: 'berry_sweet',
    name: 'Berry Sweet',
    tag: 'Stroberi',
    backgroundColor: Color(0xFFFFECEF),
    borderColor: Color(0xFFE63946),
    assetPath: 'assets/frames/berry_sweet.png',
    placeholderEmoji: '🍓',
    placeholderText: 'Berry Cute',
  ),
  const FrameModel(
    id: 'retro_pastel',
    name: 'Retro Pastel',
    tag: 'Ungu Pastel',
    backgroundColor: Color(0xFFE8DEF8),
    borderColor: Color(0xFF9C8EB9),
    assetPath: 'assets/frames/retro_pastel.png',
    placeholderEmoji: '💜',
    placeholderText: 'Retro Vibes',
  ),
  const FrameModel(
    id: 'malang_edition',
    name: 'Malang Edition',
    tag: 'Malang Pride',
    backgroundColor: Color(0xFFFFF7D6),
    borderColor: Color(0xFFD4A373),
    assetPath: 'assets/frames/malang_edition.png',
    placeholderEmoji: '🍎',
    placeholderText: 'Bakso Malang • Bromo',
  ),
];
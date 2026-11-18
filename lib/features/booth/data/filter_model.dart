import 'package:material_ui/material_ui.dart';

enum FilterType {
  original,
  bw,
  vintage,
  pinky,
}

class FilterModel {
  final FilterType type;
  final String name;
  final ColorFilter? colorFilter;

  const FilterModel({
    required this.type,
    required this.name,
    this.colorFilter,
  });

  /// Grayscale (Black & White)
  /// Luminance weights: 0.2126 R + 0.7152 G + 0.0722 B
  static const List<double> _bwMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  /// Vintage
  /// Warm yellowish sepia tone with slightly reduced contrast
  static const List<double> _vintageMatrix = <double>[
    0.9, 0.05, 0.05, 0, 20,
    0.05, 0.85, 0.05, 0, 15,
    0.02, 0.05, 0.7, 0, -10,
    0,    0,    0,   1, 0,
  ];

  /// Pinky
  /// Enhanced pink / soft magenta warmth
  static const List<double> _pinkyMatrix = <double>[
    1.1, 0.0, 0.0, 0, 25,
    0.0, 0.9, 0.0, 0, 5,
    0.1, 0.0, 1.05, 0, 20,
    0,   0,   0,   1, 0,
  ];

  static final List<FilterModel> filters = [
    const FilterModel(
      type: FilterType.original,
      name: 'Original',
      colorFilter: null,
    ),
    const FilterModel(
      type: FilterType.bw,
      name: 'B&W',
      colorFilter: ColorFilter.matrix(_bwMatrix),
    ),
    const FilterModel(
      type: FilterType.vintage,
      name: 'Vintage',
      colorFilter: ColorFilter.matrix(_vintageMatrix),
    ),
    const FilterModel(
      type: FilterType.pinky,
      name: 'Pinky',
      colorFilter: ColorFilter.matrix(_pinkyMatrix),
    ),
  ];
}

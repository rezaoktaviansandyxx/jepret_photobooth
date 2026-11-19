import 'package:material_ui/material_ui.dart';
import '../data/frame_model.dart';

class FrameCard extends StatelessWidget {
  final FrameModel frame;
  final bool isSelected;
  final VoidCallback onTap;

  const FrameCard({
    super.key,
    required this.frame,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amberAccent : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mini Preview Container
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: frame.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: frame.borderColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: frame.id == 'malang_edition'
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('🍜', style: TextStyle(fontSize: 20)),
                                      SizedBox(width: 4),
                                      Text('🍎', style: TextStyle(fontSize: 24)),
                                      SizedBox(width: 4),
                                      Text('🌋', style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '🏛️ Tugu Malang',
                                    style: TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4A373).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFFD4A373),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'MALANG PRIDE',
                                      style: TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    frame.placeholderEmoji ?? '🖼️',
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Text(
                                      frame.placeholderText ?? frame.name,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Name
                  Text(
                    frame.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Tag
                  Text(
                    frame.tag,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Centang Badge when selected
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amberAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

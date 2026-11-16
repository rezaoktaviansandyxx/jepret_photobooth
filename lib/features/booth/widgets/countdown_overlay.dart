import 'package:material_ui/material_ui.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;

  const CountdownOverlay({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Text(
          '$count',
          key: ValueKey<int>(count),
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 24,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

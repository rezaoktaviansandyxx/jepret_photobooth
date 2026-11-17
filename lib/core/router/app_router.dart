import 'package:go_router/go_router.dart';
import '../../features/booth/screens/camera_screen.dart';
import '../../features/booth/screens/frame_picker_screen.dart';
import '../../features/booth/screens/home_screen.dart';
import '../../features/booth/screens/result_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/frame-picker',
      name: 'frame_picker',
      builder: (context, state) => const FramePickerScreen(),
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) => const ResultScreen(),
    ),
  ],
);

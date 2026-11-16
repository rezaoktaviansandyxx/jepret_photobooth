import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'features/booth/provider/booth_provider.dart';
import 'features/booth/screens/camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const JepretApp());
}

class JepretApp extends StatelessWidget {
  const JepretApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoothProvider()),
      ],
      child: MaterialApp(
        title: 'Jepret Photobooth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.white70,
          ),
          useMaterial3: true,
        ),
        // Route langsung diarahkan ke CameraScreen untuk testing
        home: const CameraScreen(),
      ),
    );
  }
}

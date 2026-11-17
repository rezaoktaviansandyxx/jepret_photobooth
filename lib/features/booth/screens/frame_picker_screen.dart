import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/frame_model.dart';
import '../provider/booth_provider.dart';
import '../widgets/frame_card.dart';

class FramePickerScreen extends StatefulWidget {
  const FramePickerScreen({super.key});

  @override
  State<FramePickerScreen> createState() => _FramePickerScreenState();
}

class _FramePickerScreenState extends State<FramePickerScreen> {
  FrameModel? _selectedFrame;

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal dari provider jika sudah ada frame yang dipilih sebelumnya
    _selectedFrame = context.read<BoothProvider>().selectedFrame;
  }

  void _onFrameSelected(FrameModel frame) {
    setState(() {
      _selectedFrame = frame;
    });
    context.read<BoothProvider>().selectFrame(frame);
  }

  void _onContinuePressed() {
    if (_selectedFrame == null) return;
    context.read<BoothProvider>().selectFrame(_selectedFrame!);
    context.push('/camera');
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedFrame != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pilih Frame',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: sampleFrames.length,
                itemBuilder: (context, index) {
                  final frame = sampleFrames[index];
                  final isSelected = _selectedFrame?.id == frame.id;
                  return FrameCard(
                    frame: frame,
                    isSelected: isSelected,
                    onTap: () => _onFrameSelected(frame),
                  );
                },
              ),
            ),
            // Tombol [Lanjut] di bawah
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canContinue ? _onContinuePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white24,
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.white38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: canContinue ? 4 : 0,
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

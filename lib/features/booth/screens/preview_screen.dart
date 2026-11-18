import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/filter_model.dart';
import '../provider/booth_provider.dart';
import '../widgets/photo_strip.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  void _onRetakePhoto(BuildContext context, int index) {
    final booth = context.read<BoothProvider>();
    booth.setRetakeIndex(index);
    // Navigasi ke kamera dalam mode retake foto tunggal
    context.push('/camera?retake=$index');
  }

  @override
  Widget build(BuildContext context) {
    final booth = context.watch<BoothProvider>();
    final selectedFrame = booth.selectedFrame;
    final selectedFilter = booth.selectedFilter;
    final photos = booth.capturedPhotos;

    return Scaffold(
      backgroundColor: const Color(0xFF141416),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141416),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/camera');
            }
          },
        ),
        title: const Text(
          'Preview Foto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Strip Preview Gede di Tengah (Vertikal 3 foto, frame nempel)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: PhotoStrip(
                    photos: photos,
                    frame: selectedFrame,
                    filter: selectedFilter,
                    showRetakeButton: true,
                    onRetake: (index) => _onRetakePhoto(context, index),
                  ),
                ),
              ),
            ),

            // Pilihan Filter Horizontal (4 pilihan: Original, B&W, Vintage, Pinky)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                border: Border(
                  top: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'Pilih Filter',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: FilterModel.filters.length,
                      separatorBuilder: (context, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final filter = FilterModel.filters[index];
                        final isSelected = filter.type == selectedFilter.type;

                        return GestureDetector(
                          onTap: () {
                            booth.applyFilter(filter);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF4081).withValues(alpha: 0.15)
                                  : const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFF4081) // Border pink kalau aktif
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                filter.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFFFF4081)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tombol [Lanjut ke Hasil] di bawah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: const Color(0xFF1C1C1E),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/result');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjut ke Hasil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/manga_style.dart';
import '../widgets/manga_components.dart';
import 'game_page.dart';
import 'intro_page.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MangaColors.background,
      body: Stack(
        children: [
          // Background Dots Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotsPainter(),
            ),
          ),

          // Main Content
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1280,
                height: 720,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80, left: 128),
                  child: Row(
                    children: [
                      // Left: Character and Speech Bubble
                      Expanded(
                        flex: 5,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Character Image - Cropped to hide the black frame corners
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: 400,
                                height: 500,
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBwtaSs7WoO8lCZPVGpUVEAvbms_vY0SRI75unwhrcMvh4EwUtGTrEOuH9BbkPcw3qxIr564YezXnKoVNr_Beo3qRGLYiA4bSNA8U85gswvjqX94B_oZj2-b2NU1IThVMbQb5XO479WAZXmzPfFjoa4es7VO9F0Z8lAXTTYlui5v2gpy43mVBB2mUo2_HQkUqakYyoKkUVeFnTtu2zdWAw1uh4_Sk56y43kyD4fYrm4QLbyT6Gc-d_4RFV8jRyAtFC4kx1dGaThcS8',
                                  fit: BoxFit.cover,
                                  alignment: const Alignment(0, -0.5), // Center on face
                                ),
                              ),
                            ),
                            // Speech Bubble
                            Positioned(
                              bottom: 40,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: MangaStyle.mangaBoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: 12,
                                ),
                                child: Text(
                                  '「準備好大顯身手了嗎？」',
                                  style: GoogleFonts.notoSansTc(
                                    textStyle: MangaStyle.bodyStyle(fontSize: 18, isBold: true),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      
                      // Right: Buttons
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildModeButton(
                                context,
                                '1對1 對戰',
                                Icons.sports_kabaddi_rounded,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage())),
                              ),
                              const SizedBox(height: 32),
                              _buildModeButton(
                                context,
                                '遊戲介紹',
                                Icons.info_outline_rounded,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IntroPage())),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      
          // Shared Components
          const Positioned(
            top: 0,
            left: 96,
            right: 0,
            child: MangaTopbar(),
          ),
          const Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: MangaSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: MangaStyle.mangaBoxDecoration(
          color: MangaColors.yellow,
          borderRadius: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: MangaStyle.mangaBoxDecoration(
                color: Colors.white,
                borderRadius: 99,
                hasShadow: false,
              ),
              child: Icon(icon, color: MangaColors.purple, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.notoSansTc(
                  textStyle: MangaStyle.headlineStyle(fontSize: 28),
                  shadows: [
                    const Shadow(
                      offset: Offset(2, 2),
                      color: MangaColors.purple,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: MangaColors.purple, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: MangaStyle.mangaBoxDecoration(
        color: MangaColors.surfaceContainer,
        borderRadius: 12,
        hasShadow: true,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MangaColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: MangaColors.purple, width: 2),
            ),
            child: Icon(icon, color: MangaColors.purple, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: MangaStyle.bodyStyle(fontSize: 10, isBold: true)),
              Text(value, style: MangaStyle.bodyStyle(isBold: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MangaColors.purple.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

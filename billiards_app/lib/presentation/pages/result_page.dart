import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/manga_style.dart';
import '../widgets/manga_components.dart';
import '../../domain/entities/game_result.dart';

class ResultPage extends StatelessWidget {
  final GameResult result;

  const ResultPage({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MangaColors.background,
      body: Stack(
        children: [
          // Background Rays & Dots
          Positioned.fill(
            child: CustomPaint(
              painter: RaysAndDotsPainter(),
            ),
          ),

          // Main Content
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1280,
                height: 720,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Victory Header
                          _buildVictoryHeader(),
                          const SizedBox(height: 80),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(child: _buildActionButton('再來一局', Icons.refresh_rounded, MangaColors.yellow, () => Navigator.pop(context))),
                              const SizedBox(width: 24),
                              Expanded(child: _buildActionButton('回到首頁', Icons.home_rounded, MangaColors.secondary, () => Navigator.of(context).popUntil((route) => route.isFirst))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Side anchor ONLY - Topbar REMOVED
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

  Widget _buildVictoryHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              '${result.winnerName} Win!!',
              style: GoogleFonts.notoSansTc(
                fontSize: 100,
                fontWeight: FontWeight.w900,
                color: MangaColors.yellow,
                fontStyle: FontStyle.italic,
                shadows: [
                  const Shadow(offset: Offset(8, 8), color: MangaColors.purple),
                ],
              ),
            ),
            // Decorative Stars
            const Positioned(
              top: -30,
              right: -50,
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: MangaColors.yellow, size: 80),
                  Icon(Icons.star_rounded, color: MangaColors.secondary, size: 50),
                ],
              ),
            ),
            const Positioned(
              bottom: -20,
              left: -40,
              child: Icon(Icons.stars_rounded, color: MangaColors.secondary, size: 60),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSticker(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: MangaStyle.mangaBoxDecoration(
        color: color,
        borderRadius: 12,
      ),
      child: Text(
        text,
        style: MangaStyle.headlineStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: MangaStyle.mangaBoxDecoration(
        color: Colors.white,
        borderRadius: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: MangaColors.purple, width: 4),
            ),
            child: Icon(icon, color: MangaColors.purple, size: 40),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: MangaStyle.bodyStyle(fontSize: 14, isBold: true)),
              Text(value, style: MangaStyle.headlineStyle(fontSize: 32)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankProgress() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: MangaStyle.mangaBoxDecoration(
        color: Colors.white,
        borderRadius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RANK PROGRESS', style: MangaStyle.headlineStyle(fontSize: 24)),
              Text('LV. 42 → 43', style: MangaStyle.headlineStyle(fontSize: 28, color: MangaColors.secondary)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: MangaColors.surfaceContainer,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: MangaColors.purple, width: 4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: MangaColors.secondary,
                  borderRadius: BorderRadius.circular(99),
                  border: const Border(right: BorderSide(color: MangaColors.purple, width: 4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: MangaStyle.mangaBoxDecoration(
          color: color,
          borderRadius: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MangaColors.purple, size: 36),
            const SizedBox(width: 16),
            Text(label, style: MangaStyle.headlineStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }
}

class RaysAndDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final paint = Paint()
      ..color = MangaColors.yellow.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Rays
    const numRays = 16;
    const rayAngle = 360 / numRays;
    for (int i = 0; i < numRays; i++) {
      if (i % 2 == 0) {
        final path = Path();
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: size.width),
          (i * rayAngle) * (3.14159 / 180),
          (rayAngle / 2) * (3.14159 / 180),
          false,
        );
        path.lineTo(center.dx, center.dy);
        canvas.drawPath(path, paint);
      }
    }

    // Dots
    final dotPaint = Paint()
      ..color = MangaColors.purple.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

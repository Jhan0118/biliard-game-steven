import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/manga_style.dart';
import '../widgets/manga_components.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MangaColors.background,
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            right: -100,
            top: 100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: MangaColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section: Title and Character
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleSection(),
                              const SizedBox(height: 48),
                              _buildCharacterImage(),
                            ],
                          ),
                        ),

                        const SizedBox(width: 64),

                        // Right Section: Features Bento Grid
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('遊戲特色', MangaColors.yellow),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: _buildFeatureCard('極速連線對決', '挑戰全球好手，即時匹配不等待，展開激烈的撞球攻防戰！', Icons.bolt_rounded, MangaColors.secondary)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildFeatureCard('經典撞球規則', '8號球對決：將所屬的花球全數打入袋後，擊入8號黑球即可獲勝。', Icons.gavel_rounded, MangaColors.yellow)),
                                ],
                              ),
                              const SizedBox(height: 48),
                              _buildSectionHeader('操作核心', MangaColors.secondary),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: _buildControlCard('動力滑桿', 'POWER GAUGE CONTROL', Icons.speed_rounded, isPower: true)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildControlCard('精準瞄準線', 'PRECISION GUIDELINE', Icons.ads_click_rounded, isPower: false)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildTitleSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          '撞球之星',
          style: GoogleFonts.notoSansTc(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: MangaColors.yellow,
            letterSpacing: 4,
            shadows: [
              const Shadow(offset: Offset(4, 4), color: MangaColors.purple),
            ],
          ),
        ),
        Positioned(
          top: -20,
          right: -40,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: MangaStyle.mangaBoxDecoration(color: MangaColors.purple, borderRadius: 99, hasShadow: true),
              child: const Text('NEW SEASON!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterImage() {
    return Container(
      width: 350,
      height: 350,
      decoration: MangaStyle.mangaBoxDecoration(
        color: MangaColors.secondary.withOpacity(0.1),
        borderRadius: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD5eaZ73xdymld62MNAAQZXU0i7YlUwf5loIxBaNhQBSTPZMN-oyM5p6l3Bxl8qLkf25xb7McM82qLPm0ZlKKPTx4In8DRD2MU9J4sizLKZYg4O-0eFyPe0tAG-AuGmttawHaLsC-s8Y_M0rhqkXbteK8eJ3FPCpU9lQqq6EAczlvq0CL6TcCj-RAtyVOGRecx9cY9HyQciuVtRYd8ABTOxzLlQFM7AjgM5sn928p_DmqZsM5cqobcF3YVGZqufPVZ9YUzul-0lGOg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color barColor) {
    return Row(
      children: [
        Container(width: 8, height: 32, decoration: MangaStyle.mangaBoxDecoration(color: barColor, borderRadius: 4, hasShadow: false)),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: MangaColors.purple)),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String desc, IconData icon, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: MangaStyle.mangaBoxDecoration(color: Colors.white, borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: MangaStyle.mangaBoxDecoration(color: iconBg, borderRadius: 99, hasShadow: false),
            child: Icon(icon, color: MangaColors.purple, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: MangaStyle.headlineStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(desc, style: MangaStyle.bodyStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildControlCard(String title, String subtitle, IconData icon, {required bool isPower}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: MangaStyle.mangaBoxDecoration(color: MangaColors.surfaceContainer, borderRadius: 16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: MangaStyle.mangaBoxDecoration(color: Colors.white, borderRadius: 99, hasShadow: false),
            child: Icon(icon, color: MangaColors.purple, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: MangaStyle.headlineStyle(fontSize: 18)),
                Text(subtitle, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: MangaColors.purple)),
                const SizedBox(height: 8),
                if (isPower)
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(color: MangaColors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: MangaColors.purple, width: 2)),
                    child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.75, child: Container(color: MangaColors.yellow)),
                  )
                else
                  Row(
                    children: List.generate(4, (i) => Container(width: 16, height: 6, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: MangaColors.secondary.withOpacity(1.0 - (i * 0.2)), borderRadius: BorderRadius.circular(4)))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPromo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: MangaStyle.mangaBoxDecoration(color: Colors.white, borderRadius: 16),
      child: Row(
        children: [
          Container(width: 56, height: 56, color: MangaColors.purple.withOpacity(0.1), child: const Center(child: Icon(Icons.qr_code_2_rounded, color: MangaColors.purple, size: 40))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('即刻掃描預約', style: TextStyle(fontWeight: FontWeight.w900, color: MangaColors.purple)),
              Text('第一次中文化限定版本', style: MangaStyle.bodyStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

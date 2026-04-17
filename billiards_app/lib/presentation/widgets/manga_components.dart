import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manga_style.dart';

class MangaTopbar extends StatelessWidget implements PreferredSizeWidget {
  const MangaTopbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: MangaColors.background,
        border: Border(
          bottom: BorderSide(color: MangaColors.purple, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: MangaColors.purple,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BILLIARD BATTLE',
            style: GoogleFonts.plusJakartaSans(
              textStyle: MangaStyle.headlineStyle(fontSize: 24),
              shadows: [
                const Shadow(
                  offset: Offset(2, 2),
                  color: MangaColors.yellow,
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildIcon(Icons.star_rounded),
              _buildIcon(Icons.favorite_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Icon(icon, color: MangaColors.purple, size: 28),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class MangaSidebar extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onMatchTap;

  const MangaSidebar({
    Key? key,
    this.onHomeTap,
    this.onMatchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: const BoxDecoration(
        color: MangaColors.background,
        borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32)),
        border: Border(
          right: BorderSide(color: MangaColors.purple, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: MangaColors.purple,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            _buildProfile(),
            const SizedBox(height: 32),
            _buildNavItem(
              Icons.home_rounded,
              'Home',
              isActive: true,
              onTap: onHomeTap ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            _buildNavItem(Icons.sports_score_rounded, 'Match', onTap: onMatchTap),
            const SizedBox(height: 32),
            _buildGoButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MangaColors.purple, width: 4),
            color: Colors.white,
          ),
          child: const ClipOval(
            child: Icon(Icons.person, color: MangaColors.purple, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isActive
                  ? MangaStyle.mangaBoxDecoration(
                      color: MangaColors.yellow,
                      borderRadius: 999,
                      hasShadow: true,
                    )
                  : null,
              child: Icon(
                icon,
                color: MangaColors.purple,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: MangaStyle.bodyStyle(fontSize: 10, isBold: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoButton() { // Renamed conceptually but kept name for minimal diff if needed, better to rename:
    return Container(
      width: 64,
      height: 64,
      decoration: MangaStyle.mangaBoxDecoration(
        color: MangaColors.yellow,
        borderRadius: 999,
      ),
      child: const Center(
        child: Icon(
          Icons.settings_rounded,
          color: MangaColors.purple,
          size: 32,
        ),
      ),
    );
  }
}

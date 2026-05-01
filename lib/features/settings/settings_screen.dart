import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/widgets/max_width_view.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: MaxWidthView(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: 'APPEARANCE'),
            _SettingsTile(
              title: 'Dark Mode',
              subtitle: 'Dark background (recommended)',
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setDarkMode(v),
                activeColor: AppColors.correct,
              ),
            ),
            const SizedBox(height: 8),
            _SectionHeader(title: 'GAMEPLAY'),
            _SettingsTile(
              title: 'Default Word Length',
              subtitle: 'Starting length when opening a game',
              trailing: DropdownButton<int>(
                value: settings.defaultWordLength,
                dropdownColor: const Color(0xFF1A1A1B),
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700),
                underline: const SizedBox(),
                items: [3, 4, 5, 6]
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text('$l letters'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .setDefaultWordLength(v);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            _SectionHeader(title: 'ABOUT'),
            _SettingsTile(
              title: 'Version',
              subtitle: '1.0.0',
              trailing: const SizedBox(),
            ),
            _SettingsTile(
              title: 'Word Lists',
              subtitle:
                  '${_totalWords()} words across all lengths',
              trailing: const SizedBox(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.premium.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.premium.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WordMark Premium',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.premium,
                          ),
                        ),
                        Text(
                          'Unlimited puzzles · Full archive · More packs',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Learn More',
                      style: GoogleFonts.inter(
                        color: AppColors.premium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  int _totalWords() => 222 + 560 + 500 + 138; // rough counts
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

/// SettingsPage provides visual-only setup adjustments and version audit listings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p16),
        children: [
          _buildSectionHeader('Data Management'),
          _buildSettingsTile(
            context,
            icon: Icons.cloud_upload_rounded,
            title: 'Backup Data',
            subtitle: 'Backup saved locations to local device storage.',
            onTap: () => _showSnackbar(context, 'Mock backup file created successfully!'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.cloud_download_rounded,
            title: 'Restore Data',
            subtitle: 'Restore places from a previous backup file.',
            onTap: () => _showSnackbar(context, 'Mock restore complete. 15 items imported.'),
          ),
          const Divider(height: 32),

          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_rounded,
            title: 'Theme Color',
            subtitle: 'Customize brand highlights (Coming Soon).',
            trailing: const Text('Emerald', style: TextStyle(color: AppColors.textSecondary)),
            onTap: () => _showSnackbar(context, 'Custom theme options coming soon!'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
            title: Text('Dark Mode', style: AppTypography.bodyEmphasis),
            subtitle: Text('Switch to dark visual layout (Coming Soon).', style: AppTypography.caption),
            value: false,
            onChanged: (val) => _showSnackbar(context, 'Dark mode interface coming in the next release!'),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 32),

          _buildSectionHeader('App Info & Support'),
          _buildSettingsTile(
            context,
            icon: Icons.star_rounded,
            title: 'Rate GoNext',
            subtitle: 'Tell us how you like using the application.',
            onTap: () => _showSnackbar(context, 'Thank you for your rating!'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.email_rounded,
            title: 'Send Feedback',
            subtitle: 'Report a bug or request a feature directly.',
            onTap: () => _showSnackbar(context, 'Feedback logged! Thanks for your input.'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_rounded,
            title: 'Privacy Policy',
            subtitle: 'Read our strict offline data privacy details.',
            onTap: () => _showSnackbar(context, 'Showing privacy terms...'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_rounded,
            title: 'Terms & Conditions',
            subtitle: 'Review legal terms of application usage.',
            onTap: () => _showSnackbar(context, 'Showing usage terms...'),
          ),
          const Divider(height: 32),

          // About GoNext Card
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.surfaceFaint,
              borderRadius: BorderRadius.circular(AppSizes.r16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, color: AppColors.primary, size: 36),
                AppSizes.gapH8,
                Text(
                  'GoNext',
                  style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold),
                ),
                Text('Version 1.0.0 (Build 2407)', style: AppTypography.caption),
                AppSizes.gapH12,
                Text(
                  'GoNext is an offline-first travel companion designed to help you discover and organize places close to you.',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          AppSizes.gapH32,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.overline.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.bodyEmphasis),
      subtitle: Text(subtitle, style: AppTypography.caption),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  void _showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

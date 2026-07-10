import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Privacy Policy', style: AppTypography.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.p24),
        children: [
          Text('Privacy Policy for GoNext', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
          AppSizes.gapH12,
          Text(
            'Last Updated: July 2026',
            style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
          ),
          AppSizes.gapH24,
          const Text(
            'GoNext is designed as an offline-first private travel diary. We take your privacy extremely seriously and do not upload, share, sell, or transmit any data saved in this application to any external servers, third-party databases, or companies.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('1. Information Collection and Storage', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'All inputs, descriptions, budget preferences, cuisine options, ratings, and details of visited boutiques, restaurants, and landmarks are stored locally on your device. These details reside inside secure local Hive database boxes and never leave your hardware. No login account, email, name, or phone number registration is required to use this application.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('2. Image Selection & Permissions', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'When you attach cover pictures to travel, boutique, or restaurant records, the app accesses local directories to retrieve paths, or triggers the camera sensor to store a photo locally. Images are saved on your phone and referenced only via system filepath variables inside your local database. We never access, scan, or copy photos other than the specific ones you choose.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('3. Location Permissions & Maps', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'GoNext requests device location services access purely to identify coordinates when placing pins on Google Maps or resolving addresses using geocoding engines. These coordinate requests are processed directly via your phone\'s hardware GPS sensor and the Google Maps API. No location coordinates or geocoding data are shared with, tracked by, or stored on external servers by GoNext.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('4. Backup and Portability', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'You remain the sole owner of your data. The Backup Data feature enables you to manually generate a text-based JSON file containing all saved records and choose where to store it. GoNext has no automated cloud backups; if you delete this application or clear device storage, your locally saved travel diary entries will be permanently lost unless you have manually generated a backup.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('5. Children\'s Privacy', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'GoNext is completely safe for children. Since no personal data is collected or transmitted, we do not monitor or restrict usage based on age, and do not track users under any circumstances.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('6. Contact Us', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'For any questions, comments, or inquiries regarding our offline privacy policy, please contact support@gonext-app.local. Thank you for exploring with GoNext!',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

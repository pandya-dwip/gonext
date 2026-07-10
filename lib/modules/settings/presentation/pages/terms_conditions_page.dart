import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Terms & Conditions', style: AppTypography.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.p24),
        children: [
          Text('Terms of Service & Usage', style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
          AppSizes.gapH12,
          Text(
            'Effective Date: July 2026',
            style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
          ),
          AppSizes.gapH24,
          const Text(
            'Welcome to GoNext. By downloading, accessing, or using this mobile application, you agree to comply with and be bound by the following terms and conditions. Please read these terms carefully before utilizing our application.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('1. Use of the App & Offline Status', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'GoNext provides an offline-first diary tool for cataloging dining, shopping, and travel places. Since all data is stored entirely on your local device, you are solely responsible for keeping your phone secure and maintaining backups of your stored records. GoNext is not liable for data loss due to device malfunctions, hardware resets, app cache clearance, or uninstalls.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('2. GPS and External Map Utilities', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'This application interacts with standard Google Maps APIs and your device\'s built-in location sensors. Standard data rates may apply when downloading maps and resolving addresses via mobile network connections. The accuracy of GPS mapping and geocoding coordinates depends on third-party service availability and hardware reception.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('3. Data Portability and Backups', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'You are provided with local import and export tools to save database records into JSON files. You bear full responsibility for the safety, storage, and privacy of any exported backup files you save or transmit. Do not modify the structure of the JSON backup file manually, as this may corrupt the file structure and cause restore failures.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('4. Intellectual Property', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'All layouts, designs, component brands, assets, logos, and custom code inside GoNext are the intellectual property of GoNext. You may not copy, reverse-engineer, distribute, or create derivative products from our binary files, source code, or design system components.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('5. Disclaimer of Warranties', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'GoNext is provided on an "as-is" and "as-available" basis without warranties of any kind, either express or implied. We do not warrant that the application will be uninterrupted, error-free, or entirely secure from local file modifications by root-level device processes.',
            style: TextStyle(height: 1.6),
          ),
          AppSizes.gapH24,
          Text('6. Modification of Terms', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
          AppSizes.gapH8,
          const Text(
            'We reserve the right to modify these terms and conditions at any time. Your continued use of the GoNext application following any changes indicates your acceptance of the updated terms.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

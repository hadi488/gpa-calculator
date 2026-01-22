import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Privacy Policy'),
            _buildSectionText(
              context,
              'Last Updated: January 2026\n\n'
              'HR NextGen ("we", "our", or "us") operates the GPA Calculator mobile application (the "Service").\n\n'
              'This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
            ),
            const Divider(height: 32),
            _buildSectionTitle(context, '1. Information Collection'),
            _buildSectionText(
              context,
              'We do NOT collect any personally identifiable information.\n\n'
              'All data entered into the application (such as grades, subjects, and student names) is stored locally on your device using local database technologies (Hive). We do not have access to this data, and it is never transmitted to any external server.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '2. Usage Data'),
            _buildSectionText(
              context,
              'The application does not track your usage behavior or collect analytics data.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '3. Permissions'),
            _buildSectionText(
              context,
              'The app requires the following permissions to function correctly:\n'
              '• Storage: To save your GPA records locally on your device.\n'
              '• Internet: Required only for accessing external links you explicitly click (e.g., Share, Rate Us, Privacy Policy).',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '4. Security'),
            _buildSectionText(
              context,
              'The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. Since your data is stored locally, its security depends on your device\'s security settings.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '5. Contact Us'),
            _buildSectionText(
              context,
              'If you have any questions about this Privacy Policy, please contact us:\n\n'
              '• By email: haiderrehman509@gmail.com',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
    );
  }
}

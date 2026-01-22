import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Terms of Service'),
            _buildSectionText(
              context,
              'Last Updated: January 2026\n\n'
              'Please read these Terms of Service ("Terms", "Terms of Service") carefully before using the GPA Calculator mobile application (the "Service") operated by HR NextGen ("us", "we", or "our").\n\n'
              'Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the Service.',
            ),
            const Divider(height: 32),
            _buildSectionTitle(context, '1. Use License'),
            _buildSectionText(
              context,
              'Permission is granted to temporarily download one copy of the materials (information or software) on HR NextGen\'s application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '2. Usage Limitations'),
            _buildSectionText(
              context,
              'You agree not to use the Service for any unlawful purpose or in any way that interrupts, damages, impairs, or renders the Service less efficient.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '3. Disclaimer'),
            _buildSectionText(
              context,
              'The materials on the Service are provided on an "as is" basis. HR NextGen makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.\n\n'
              'Further, while we strive for accuracy, we do not warrant that the GPA calculations are free of errors. Students should always verify results with their official institute records.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '4. Limitations'),
            _buildSectionText(
              context,
              'In no event shall HR NextGen be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on the Service.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '5. Changes'),
            _buildSectionText(
              context,
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. What constitutes a material change will be determined at our sole discretion.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '6. Contact Us'),
            _buildSectionText(
              context,
              'If you have any questions about these Terms, please contact us:\n\n'
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

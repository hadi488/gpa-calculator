import 'package:flutter/material.dart';
import 'package:cgpacalculator/data/services/url_launcher_service.dart';
import 'package:cgpacalculator/features/settings/screens/settings_screen.dart';
import 'package:cgpacalculator/features/settings/screens/privacy_policy_screen.dart';
import 'package:cgpacalculator/features/settings/screens/terms_of_service_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: const Text(
              'GPA Calculator',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            accountEmail: const Text('Version 1.0.0'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.school,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share App'),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncherService.shareApp();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_rate),
                  title: const Text('Rate Us'),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncherService.openStore();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Suggestion'),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncherService.sendEmail(
                      to: 'haiderrehman509@gmail.com',
                      subject: 'Suggestion for GPA Calculator',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report Bug'),
                  onTap: () {
                    Navigator.pop(context);
                    UrlLauncherService.sendEmail(
                      to: 'haiderrehman509@gmail.com',
                      subject: 'Bug Report: GPA Calculator',
                      body:
                          '\n\nDevice Info: ${Theme.of(context).platform.name}',
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: 'GPA Calculator',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.school, size: 48),
                      applicationLegalese: '© 2026 HR NextGen',
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'A comprehensive GPA/CGPA calculator designed to help students track their academic progress with ease.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Developed by: Haider Rehman',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Contact: haiderrehman509@gmail.com'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Made with ❤️ by HR NextGen',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[800]
                    : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

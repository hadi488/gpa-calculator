import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Service for launching URLs and sharing content
class UrlLauncherService {
  /// Sends an email
  static Future<void> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeQueryParameters(<String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Fallback or error handling if needed
      // print('Could not launch email');
    }
  }

  /// Opens a web URL
  static Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Shares app content
  /// Shares app content
  static Future<void> shareApp() async {
    const String appId = 'com.hrnextgen.cgpacalculator';

    final String playStoreUrl =
        'https://play.google.com/store/apps/details?id=$appId';

    await Share.share(
      'Check out this GPA Calculator! 📘\n\n'
      'Easily calculate your GPA & CGPA.\n\n'
      'Download here:\n$playStoreUrl',
      subject: 'GPA Calculator App',
    );
  }

  /// Opens store page (stub for now, can be updated with real ID later)
  static Future<void> openStore() async {
    // Replace with actual package name when published
    const appId = 'com.hrnextgen.cgpacalculator';
    final url = 'market://details?id=$appId';
    final fallbackUrl = 'https://play.google.com/store/apps/details?id=$appId';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      await openUrl(fallbackUrl);
    }
  }

  /// Helper to encode query params for mailto
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}

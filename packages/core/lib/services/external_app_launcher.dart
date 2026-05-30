import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalAppLauncher {
  static const Map<String, String> appSchemes = {
    'deepseek': 'deepseek://',
    'doubao': 'doubao://',
  };

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<bool> launchExternalApp(String scheme) async {
    final url = appSchemes[scheme] ?? '$scheme://';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<void> copyAndLaunch({required String question, required String instruction, String scheme = 'deepseek'}) async {
    final text = '$instruction\n\n$question';
    await copyToClipboard(text);
    await launchExternalApp(scheme);
  }
}
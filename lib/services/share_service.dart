import 'package:share_plus/share_plus.dart';

class ShareService {
  // Share a link to other apps
  static Future<void> shareLink(String url, {String? title}) async {
    try {
      await Share.share(url, subject: title ?? 'Shared from Link Grab');
    } catch (e) {
      print('Error sharing link: $e');
    }
  }
}

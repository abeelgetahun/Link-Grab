import 'dart:async';
import 'package:share_handler/share_handler.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';

class SharingService {
  final ShareHandlerPlatform _shareHandler = ShareHandlerPlatform.instance;
  Function(String)? _onLinkReceived;

  void init() {
    // Listen to media shared on app startup
    _checkInitialSharedMedia();

    // Listen to media shared while app is running
    _shareHandler.sharedMediaStream.listen((SharedMedia media) {
      if (_onLinkReceived != null) {
        if (media.content != null) {
          _onLinkReceived!(media.content!);
        } else if (media.attachments != null && media.attachments!.isNotEmpty) {
          for (var attachment in media.attachments!) {
            final path = attachment?.path;
            if (path != null) {
              _onLinkReceived!(path);
            }
          }
        }
      }
    });
  }

  Future<void> _checkInitialSharedMedia() async {
    final SharedMedia? media = await _shareHandler.getInitialSharedMedia();
    if (media != null && _onLinkReceived != null) {
      if (media.content != null) {
        _onLinkReceived!(media.content!);
      } else if (media.attachments != null && media.attachments!.isNotEmpty) {
        for (var attachment in media.attachments!) {
          final path = attachment?.path;
          if (path != null) {
            _onLinkReceived!(path);
          }
        }
      }
    }
  }

  void setLinkReceivedCallback(Function(String) callback) {
    _onLinkReceived = callback;
  }

  void dispose() {
    // No need to dispose as ShareHandler doesn't expose a dispose method
  }
}

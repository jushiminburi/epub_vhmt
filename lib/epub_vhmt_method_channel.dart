import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'epub_vhmt_platform_interface.dart';

/// An implementation of [EpubVhmtPlatform] that uses method channels.
class MethodChannelEpubVhmt extends EpubVhmtPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('epub_vhmt');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'epub_vhmt_method_channel.dart';

abstract class EpubVhmtPlatform extends PlatformInterface {
  /// Constructs a EpubVhmtPlatform.
  EpubVhmtPlatform() : super(token: _token);

  static final Object _token = Object();

  static EpubVhmtPlatform _instance = MethodChannelEpubVhmt();

  static EpubVhmtPlatform get instance => _instance;

  static set instance(EpubVhmtPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
}

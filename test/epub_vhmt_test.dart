import 'package:flutter_test/flutter_test.dart';
import 'package:epub_vhmt/epub_vhmt.dart';
import 'package:epub_vhmt/epub_vhmt_platform_interface.dart';
import 'package:epub_vhmt/epub_vhmt_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEpubVhmtPlatform
    with MockPlatformInterfaceMixin
    implements EpubVhmtPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EpubVhmtPlatform initialPlatform = EpubVhmtPlatform.instance;

  test('$MethodChannelEpubVhmt is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEpubVhmt>());
  });

//   test('getPlatformVersion', () async {
//     EpubVhmt epubVhmtPlugin = EpubVhmt();
//     MockEpubVhmtPlatform fakePlatform = MockEpubVhmtPlatform();
//     EpubVhmtPlatform.instance = fakePlatform;

//     expect(await epubVhmtPlugin.getPlatformVersion(), '42');
//   });
// }
}

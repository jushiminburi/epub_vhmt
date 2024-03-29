
import 'package:epub_vhmt/src/core/media_type.dart';

class VHResource {
  String? id;
  String? properties;
  MediaType? mediaType;
  String? mediaOverlay;
  
  late String href;
  late String fullHref;

  String? basePath() {
    if (href.isEmpty) return null;
    var paths = fullHref.split('/');
    paths.removeLast();
    return paths.join('/');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VHResource && id == other.id && href == other.href;
  }

  @override
  int get hashCode => id.hashCode ^ href.hashCode;
}
// ignore_for_file: file_names

import 'package:epub_vhmt/src/core/VHResource.dart';

class VHTocReference {
  List<VHTocReference> children;
  String? title;
  VHResource? resource;
  String? fragmentID;

  VHTocReference(
      { this.title,
      this.resource,
      this.fragmentID = '',
      List<VHTocReference>? children})
      : children = children ?? [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VHTocReference &&
        title == other.title &&
        fragmentID == other.fragmentID;
  }

  @override
  int get hashCode {
    return title.hashCode ^ fragmentID.hashCode;
  }
}

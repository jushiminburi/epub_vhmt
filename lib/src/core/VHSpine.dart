// ignore_for_file: file_names

import 'package:epub_vhmt/src/core/VHResource.dart';

class Spine {
  bool linear;
  VHResource resource;

  Spine({required this.resource, this.linear = true});
}

class VHSpine {
  String? pageProgressionDirection;
  List<Spine> spineReferences = [];

  bool get isRtl {
    return pageProgressionDirection == "rtl";
  }

  VHResource? nextChapter(String href) {
    bool found = false;

    for (Spine item in spineReferences) {
      if (found) {
        return item.resource;
      }

      if (item.resource.href == href) {
        found = true;
      }
    }
    return null;
  }
}
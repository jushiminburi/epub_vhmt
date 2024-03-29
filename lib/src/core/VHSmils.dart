// ignore_for_file: file_names

import 'package:collection/collection.dart';
import 'package:epub_vhmt/src/core/VHResource.dart';
import 'package:epub_vhmt/src/core/VHSmilElement.dart';


class VHSmilFile {
  VHResource resource;
  List<VHSmilElement> data = [];

  VHSmilFile({required this.resource});

  // MARK: - Shortcuts

  String? ID() {
    return resource.id;
  }

  String href() {
    return resource.href;
  }

  /// Returns a smil <par> tag which contains info about parallel audio and text to be played

  VHSmilElement? parallelAudioForFragment(String fragment) {
    return _findParElement(fragment, data);
  }

  VHSmilElement? _findParElement(String src, List<VHSmilElement> data) {
    for (VHSmilElement el in data) {
      if (el.name == "par" &&
          (el.textElement()?.attributes?["src"]?.contains(src) ?? false)) {
        return el;
      } else if (el.name == "seq" && el.children.isNotEmpty) {
        VHSmilElement? parEl = _findParElement(src, el.children);
        if (parEl != null) {
          return parEl;
        }
      }
    }
    return null;
  }

  VHSmilElement? nextParallelAudioForFragment(String fragment) {
    return _findNextParElement(fragment,data);
  }

  VHSmilElement? _findNextParElement(String src, List<VHSmilElement> data) {
    bool foundPrev = false;
    for (VHSmilElement el in data) {
      if (foundPrev) return el;
      if (el.name == "par" &&
          (el.textElement()?.attributes?["src"]?.contains(src) ?? false)) {
        foundPrev = true;
      } else if (el.name == "seq" && el.children.isNotEmpty) {
        VHSmilElement? parEl = _findNextParElement(src, el.children);
        if (parEl != null) {
          return parEl;
        }
      }
    }
    return null;
  }

  VHSmilElement? childWithName(String name) {
    for (VHSmilElement el in data) {
      if (el.name == name) {
        return el;
      }
    }
    return null;
  }

  List<VHSmilElement>? childrenWithNames(List<String> name) {
    List<VHSmilElement> matched = [];
    for (VHSmilElement el in data) {
      if (name.contains(el.name)) {
        matched.add(el);
      }
    }
    return matched.isNotEmpty ? matched : null;
  }

  List<VHSmilElement>? childrenWithName(String name) {
    return childrenWithNames([name]);
  }
}

class VHSmils {
  String? basePath;
  Map<String, VHSmilFile> smils = {};

  void add(VHSmilFile smil) {
    smils[smil.resource.href] = smil;
  }

  VHSmilFile? findByHref(String href) {
    return smils.values.firstWhereOrNull((smil) => smil.resource.href == href);
  }

  VHSmilFile? findById(String ID) {
    return smils.values.firstWhereOrNull((smil) => smil.resource.id == ID);
  }
}

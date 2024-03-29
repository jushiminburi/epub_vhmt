// ignore_for_file: file_names

class VHSmilElement {
  late String name; // the name of the tag: <seq>, <par>, <text>, <audio>
  late Map<String, String>? attributes;
  late List<VHSmilElement> children;

  VHSmilElement(this.name, [this.attributes]) {
    children = [];
  }

  String? getId() {
    return getAttribute("id");
  }

  String? getSrc() {
    return getAttribute("src");
  }

  List<String>? getType() {
    String? type = getAttribute("epub:type", "");
    return type!.split(" ");
  }

  bool isType(String aType) {
    return getType()!.contains(aType);
  }

  String? getAttribute(String name, [String? defaultVal]) {
    return attributes?[name] ?? defaultVal;
  }

  // MARK: - Retrieving children elements

  VHSmilElement? textElement() {
    return childWithName("text");
  }

  VHSmilElement? audioElement() {
    return childWithName("audio");
  }

  VHSmilElement? videoElement() {
    return childWithName("video");
  }

  VHSmilElement? childWithName(String name) {
    return children.firstWhere((el) => el.name == name);
  }

  List<VHSmilElement>? childrenWithNames(List<String> name) {
    return children.where((el) => name.contains(el.name)).toList();
  }

  List<VHSmilElement>? childrenWithName(String name) {
    return childrenWithNames([name]);
  }

  // MARK: - Audio clip info

  double clipBegin() {
    String? val = audioElement()?.getAttribute("clipBegin", "");
    return val!.clockTimeToSeconds();
  }

  double clipEnd() {
    String? val = audioElement()?.getAttribute("clipEnd", "");
    return val!.clockTimeToSeconds();
  }
}

// MARK: - Extension Methods

extension StringExtension on String? {
  double clockTimeToSeconds() {
    ///Implement your clock time to seconds conversion logic here
    return 0.0;
  }
}

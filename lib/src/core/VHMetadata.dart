// ignore_for_file: file_names

import 'package:epub_vhmt/src/core/media_type.dart';

class Author {
  String name;
  String role;
  String fileAs;
  Author({required this.name, required this.role, required this.fileAs});
}

class Identifier {
  String? id;
  String? scheme;
  String? value;
  Identifier({this.id, this.scheme, this.value});
}

class EventDate {
  String date;
  String? event;
  EventDate({required this.date, this.event});
}

class Meta {
  String? name;
  String? content;
  String? id;
  String? property;
  String? value;
  String? refines;
  Meta({this.name, this.content, this.id, this.property, this.value, this.refines});
}

class VHMetadata {
  List<Author> creators = [];
  List<Author> contributors = [];
  List<EventDate> dates = [];
  String language = "en-US";
  List<String> titles = [];
  List<Identifier> identifiers = [];
  List<String> subjects = [];
  List<String> descriptions = [];
  List<String> publishers = [];
  String format = MediaType.epub.name;
  List<String> rights = [];
  List<Meta> metaAttributes = [];

  Identifier? findIdentifierById(String id) {
    return identifiers.firstWhere((identifier) => identifier.id == id);
  }

  Meta? findMetaByName(String name) {
    return metaAttributes.firstWhere((meta) => meta.name == name );
  }

  Meta? findMetaByProperty(String property, {String? refinedBy}) {
    return metaAttributes.firstWhere((meta) {
      if (refinedBy != null) {
        return meta.property == property && meta.refines == refinedBy;
      }
      return meta.property == property;
    });
  }
}
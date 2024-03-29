// ignore_for_file: file_names

import 'package:epub_vhmt/src/core/VHMetadata.dart';
import 'package:epub_vhmt/src/core/VHResource.dart';
import 'package:epub_vhmt/src/core/VHResources.dart';
import 'package:epub_vhmt/src/core/VHSmils.dart';
import 'package:epub_vhmt/src/core/VHSpine.dart';
import 'package:epub_vhmt/src/core/VHTocReference.dart';

class VHBook {
  VHMetadata metadata = VHMetadata();
  VHSpine spine = VHSpine();
  VHSmils smils = VHSmils();
  double? version;
  VHResource? opfResource;
  VHResource? tocResource;
  String? uniqueIdentifier;
  VHResource? coverImage;
  String? name;
  VHResources resources = VHResources();
  List<VHTocReference>? tableOfContents;
  List<VHTocReference>? flatTableOfContents;

  bool get hasAudio {
    return smils.smils.isNotEmpty;
  }

  String? get title {
    return metadata.titles.isNotEmpty ? metadata.titles.first : null;
  }

  String? get authorName {
    return metadata.creators.isNotEmpty ? metadata.creators.first.name : null;
  }

  String? get duration {
    return metadata.findMetaByProperty( "media:duration")?.value;
  }

  String get activeClass {
    return metadata.findMetaByProperty( "media:active-class")?.value ?? "epub-media-overlay-active";
  }

  String get playbackActiveClass {
    return metadata.findMetaByProperty("media:playback-active-class")?.value ?? "epub-media-overlay-playing";
  }

  VHSmilFile? smilFileForResource(VHResource? resource) {
    if (resource == null || resource.mediaOverlay == null) return null;

    VHResource? smilResource = resources.findById(resource.mediaOverlay);
    if (smilResource == null) return null;

    return smils.findByHref(smilResource.href);
  }

  VHSmilFile? smilFileForHref(String href) {
    return smilFileForResource(resources.findByHref(href));
  }

  VHSmilFile? smilFileForId(String id) {
    return smilFileForResource(resources.findById(id));
  }

  String? durationForId(String id) {
    return metadata.findMetaByProperty( "media:duration", refinedBy: id)?.value;
  }
}
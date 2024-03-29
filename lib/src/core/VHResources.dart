// ignore_for_file: file_names

import 'package:epub_vhmt/src/core/VHResource.dart';
import 'package:epub_vhmt/src/core/media_type.dart';

class VHResources {
  /// Dictionnary to store resources with href as key
  Map<String, VHResource> resources = {};

  /// Adds a resource to the resources.
  void add(VHResource resource) {
    resources[resource.href] = resource;
  }

  /// Gets the first resource (random order) with the given media type.
  /// Useful for looking up the table of contents as it's supposed to be the only resource with NCX media type.
  VHResource? findByMediaType(MediaType mediaType) {
    return resources.values.firstWhere((resource) =>
        resource.mediaType != null && resource.mediaType == mediaType);
  }

  /// Gets the first resource (random order) with the given extension.
  /// Useful for looking up the table of contents as it's supposed to be the only resource with NCX extension.
  VHResource? findByExtension(String ext) {
    return resources.values.firstWhere((resource) =>
        resource.mediaType != null &&
        resource.mediaType!.defaultExtension == ext);
  }

  /// Gets the first resource (random order) with the given properties.
  /// ePub 3 properties. e.g. `cover-image`, `nav`
  VHResource? findByProperty(String properties) {
    return resources.values
        .firstWhere((resource) => resource.properties == properties);
  }

  /// Gets the resource with the given href.
  VHResource? findByHref(String href) {
    final cleanHref = href.replaceAll('../', '');
    return resources[cleanHref];
  }

  /// Gets the resource with the given id.
  VHResource? findById(String? id) {
    if (id == null) return null;

    return resources.values.firstWhere((resource) => resource.id == id);
  }

  /// Whether there exists a resource with the given href.
  bool containsByHref(String href) {
    return resources.containsKey(href);
  }

  /// Whether there exists a resource with the given id.
  bool containsById(String? id) {
    if (id == null) return false;

    return resources.values.any((resource) => resource.id == id);
  }
}

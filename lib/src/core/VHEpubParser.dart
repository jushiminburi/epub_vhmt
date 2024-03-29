// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:epub_vhmt/src/core/VHBook.dart';
import 'package:epub_vhmt/src/core/VHMetadata.dart';
import 'package:epub_vhmt/src/core/VHResource.dart';
import 'package:epub_vhmt/src/core/VHSmilElement.dart';
import 'package:epub_vhmt/src/core/VHSmils.dart';
import 'package:epub_vhmt/src/core/VHSpine.dart';
import 'package:epub_vhmt/src/core/VHTocReference.dart';
import 'package:epub_vhmt/src/core/media_type.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path/path.dart' as path;

class VHEpubParser {
  final book = VHBook();
  String resourcesBasePath = '';
  bool shouldRemoveEpub = true;
  String? epubPathToRemove;

  /// Parse the Cover Image from an epub file.
  Future<Image> parseCoverImage(String epubPath, {String? unzipPath}) async {
    try {
      final book = await readEpub(epubPath, false, unzipPath: unzipPath);
      final coverImage = book.coverImage;
      if (coverImage == null) {
        throw "Cover image available";
      }
      final imageFile = File(coverImage.fullHref);
      if (!await imageFile.exists()) {
        throw "Invalid image for path ${coverImage.fullHref}";
      }

      final bytes = await imageFile.readAsBytes();
      final image = Image.memory(bytes);
      return image;
    } catch (e) {
      debugPrint('Error parsing cover image: $e');
      rethrow;
    }
  }

  /// Parse the book title from an epub file.
  Future<String> parseTitle(String epubPath, {String? unzipPath}) async {
    try {
      final book = await readEpub(epubPath, false, unzipPath: unzipPath);
      final title = book.title;
      if (title == null) {
        throw "Title Not Available";
      }
      return title;
    } catch (e) {
      debugPrint('Error parsing title: $e');
      rethrow;
    }
  }

  /// Parse the book Author name from an epub file.
  Future<String> parseAuthorName(String epubPath, {String? unzipPath}) async {
    try {
      final book = await readEpub(epubPath, false, unzipPath: unzipPath);
      final authorName = book.authorName;
      if (authorName == null) {
        throw "Author Name Not Available";
      }
      return authorName;
    } catch (e) {
      debugPrint('Error parsing author name: $e');
      rethrow;
    }
  }

  /// Unzip, delete and read an epub file.
  Future<VHBook> readEpub(String epubPath, bool removeEpub,
      {String? unzipPath}) async {
    epubPathToRemove = epubPath;
    shouldRemoveEpub = removeEpub;
    final fileManager = Directory.systemTemp;
    final bookName = path.basename(epubPath);
    var bookBasePath = unzipPath ?? fileManager.path;
    bookBasePath = path.join(bookBasePath, bookName);
    if (!await Directory(bookBasePath).exists()) {
      await _unzipFile(epubPath, bookBasePath);
    }

    book.name = bookName;
    await readContainer(bookBasePath);
    await readOpf(bookBasePath);
    return book;
  }

  Future<void> _unzipFile(String zipPath, String destinationPath) async {
    final zipFile = File(zipPath);
    final destinationDir = Directory(destinationPath);
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            return ZipFileOperation.includeItem;
          });
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  /// Read and parse container.xml file.

  Future<void> readContainer(String bookBasePath) async {
    const containerPath = 'META-INF/container.xml';
    final containerFile = File(path.join(bookBasePath, containerPath));

    if (!await containerFile.exists()) {
      throw Exception('Container file not found');
    }

    final containerData = await containerFile.readAsString();
    final xmlDoc = xml.XmlDocument.parse(containerData);
    final opfResource = VHResource();
    final opf = xmlDoc
        .findAllElements('rootfiles')
        .first
        .findAllElements('rootfile')
        .first
        .getAttribute('full-path')!;
    opfResource.href = opf;
    final fullPath = opfResource.href;
    opfResource.mediaType = MediaType.byFileName(fullPath);
    book.opfResource = opfResource;
    if (book.opfResource != null) {
      final pathOpfResource = path.dirname(book.opfResource!.href);
      resourcesBasePath = path.join(bookBasePath, pathOpfResource);
    } else {
      throw "ODF Resource null";
    }
  }

  /// Read and parse .opf file.
  Future<void> readOpf(String bookBasePath) async {
    String? identifier;
    String opfPath = '';
    if (book.opfResource != null) {
      opfPath = path.join(bookBasePath, book.opfResource!.href);
    } else {
      throw "ODF Resource null";
    }
    final opfFile = File(opfPath);
    final opfData = await opfFile.readAsBytes();
    final xmlDoc = xml.XmlDocument.parse(utf8.decode(opfData));

    // Base OPF info
    final package =
        xmlDoc.children.firstWhere((node) => node is xml.XmlElement);
    identifier = package.getAttribute('unique-identifier');
    final version = package.getAttribute('version');
    if (version != null) {
      book.version = double.tryParse(version);
    }

    // Parse and save each "manifest item"
    xml.XmlElement? manifest = xmlDoc.findAllElements('manifest').first;

    List<xml.XmlElement> items = manifest.findElements('item').toList();
    for (final item in items) {
      VHResource resource = VHResource();
      resource.id = item.getAttribute('id');
      resource.properties = item.getAttribute('properties');
      resource.href = item.getAttribute('href') ?? '';
      resource.fullHref = path.join(resourcesBasePath, resource.href);
      resource.mediaType = MediaType.by(
          name: item.getAttribute('media-type') ?? '',
          fileName: resource.href);
      resource.mediaOverlay = item.getAttribute('media-overplay');

      if (resource.mediaType != null &&
          resource.mediaType == MediaType.smil) {
        await readSmilFile(resource);
      }
      book.resources.add(resource);
    }
      book.smils.basePath = resourcesBasePath;

    // read metadata
    final metaData = xmlDoc.findAllElements('metadata').first;
    List<xml.XmlElement> metaDataList = [];

    for (var child in metaData.children) {
      if (child is xml.XmlElement) {
        metaDataList.add(child);
      }
    }
    book.metadata = readMetadata(metaDataList);
    if (identifier != null) {
      final uniqueIdentifier = book.metadata.findIdentifierById(identifier);
      if (uniqueIdentifier != null) {
        book.uniqueIdentifier = uniqueIdentifier.value;
      }
    }

    // Read the cover image
    final coverImageId = book.metadata.findMetaByName('cover')?.content;
    if (coverImageId != null) {
      if (book.resources.findById(coverImageId) != null) {
        book.coverImage = book.resources.findById(coverImageId);
      } else {
        if (book.resources.findByProperty("cover-image") != null) {
          book.coverImage = book.resources.findById(coverImageId);
        }
      }
    }

    // Specific TOC for ePub 2 and 3
    // Get the first resource with the NCX mediatype
    final tocResource =
        book.resources.findByExtension(MediaType.ncx.defaultExtension);
    if (tocResource != null) {
      book.tocResource = tocResource;
    } else {
      final tocResource = book.resources.findByProperty('nav');
      if (tocResource != null) {
        book.tocResource = tocResource;
      }
    }
    assert(book.tocResource != null,
        'ERROR: Could not find table of contents resource. The book don\'t have a TOC resource.');

    // The book TOC
    book.tableOfContents = findTableOfContents();
    book.flatTableOfContents = flatToc;

    // read spine
    final spine = xmlDoc.rootElement.findElements('spine').first;
    final childrenSpine = spine.children.whereType<xml.XmlElement>().toList();
    book.spine = readSpine(childrenSpine);

    final pageProgressionDirection =
        spine.getAttribute('page-progression-direction');
    if (pageProgressionDirection != null) {
      book.spine.pageProgressionDirection = pageProgressionDirection;
    }
  }

  /// Reads and parses a .smil file.

  Future<void> readSmilFile(VHResource resource) async {
    try {
      final smilData = await File(resource.fullHref).readAsBytes();
      final smilFile = VHSmilFile(resource: resource);
      final xmlDoc = xml.XmlDocument.parse(utf8.decode(smilData));
      final bodyChildren = xmlDoc.findAllElements('body').first;
      if (bodyChildren.children.isNotEmpty) {
        final children =
            bodyChildren.children.whereType<xml.XmlElement>().toList();
        smilFile.data.addAll(readSmilFileElement(children));
      }
      book.smils.add(smilFile);
    } catch (e) {
      debugPrint('Cannot read file .smil file: ${resource.href}');
    }
  }

  List<VHSmilElement> readSmilFileElement(List<xml.XmlElement> children) {
    List<VHSmilElement> data = [];

    for (var element in children) {
      VHSmilElement smil = VHSmilElement(
          element.name.toString(),
          Map.fromEntries(element.attributes
              .map((attr) => MapEntry(attr.name.toString(), attr.value))));

      if (element.children.isNotEmpty) {
        final childrenElement =
            element.children.whereType<xml.XmlElement>().toList();
        smil.children.addAll(readSmilFileElement(childrenElement));
      }
      data.add(smil);
    }

    return data;
  }

  /// Read and parse the Table of Contents.

  List<VHTocReference> findTableOfContents() {
    final tableOfContent = <VHTocReference>[];
    List<xml.XmlElement>? tocItems;

    if (book.tocResource == null) return tableOfContent;
    final tocPath = path.join(resourcesBasePath, book.tocResource!.href);

    try {
      if (book.tocResource!.mediaType == MediaType.ncx) {
        final ncxData = File(tocPath).readAsBytesSync();
        final xmlDoc = xml.XmlDocument.parse(utf8.decode(ncxData));
        final tocXml = xmlDoc
            .findAllElements('navMap')
            .first
            .findElements('navPoint')
            .toList();
        tocItems = tocXml;
      } else {
        final tocData = File(tocPath).readAsBytesSync();
        final xmlDoc = xml.XmlDocument.parse(utf8.decode(tocData));
        final nav =
            xmlDoc.root.findElements('body').first.findElements('nav').first;
        final itemsList =
            nav.findElements('ol').first.findElements('li').toList();
        tocItems = itemsList;
      }
    } catch (e) {
      debugPrint("Cannot find Table of Contents.");
    }

    if (tocItems == null) return tableOfContent;
    for (final item in tocItems) {
      final ref = readTOCReference(item);
      if (ref != null) {
        tableOfContent.add(ref);
      }
    }
    return tableOfContent;
  }

  VHTocReference? readTOCReference(xml.XmlElement navPointElement) {
    String label = '';

    if (book.tocResource?.mediaType == MediaType.ncx) {
      final labelText = navPointElement
          .findElements('navLabel')
          .first
          .findElements('text')
          .first
          .text;
      label = labelText;
    
      final reference =
          navPointElement.findElements('content').first.getAttribute('src');
      if (reference == null) return null;
      final hrefSplit = reference.split('#');
      final fragmentID = hrefSplit.length > 1 ? hrefSplit[1] : "";
      final href = hrefSplit[0];

      final resource = book.resources.findByHref(href);
      final toc = VHTocReference(
          title: label, resource: resource, fragmentID: fragmentID);
      final navPoints = navPointElement.findElements('navPoint');

      for (final navpoint in navPoints) {
        final item = readTOCReference(navpoint);
        if (item != null) {
          toc.children.add(item);
        }
      }
      return toc;
    } else {
      final labelText = navPointElement.findElements('a').first.value;
      if (labelText != null) {
        label = labelText;
      }

      final reference =
          navPointElement.findElements('a').first.getAttribute('href');
      if (reference == null) return null;
      final hrefSplit = reference.split('#');
      final fragmentID = hrefSplit.length > 1 ? hrefSplit[1] : "";
      final href = hrefSplit[0];

      final resource = book.resources.findByHref(href);
      final toc = VHTocReference(
          title: label, resource: resource, fragmentID: fragmentID);

      final navPoints =
          navPointElement.findElements('ol').first.findElements('li');
      for (final navPoint in navPoints) {
        final item = readTOCReference(navPoint);
        if (item != null) {
          toc.children.add(item);
        }
      }
      return toc;
    }
  }

  List<VHTocReference> get flatToc {
    List<VHTocReference> tocItems = [];
    for (final item in book.tableOfContents ?? []) {
      tocItems.add(item);
      tocItems.addAll(countTocChild(item));
    }
    return tocItems;
  }

  List<VHTocReference> countTocChild(VHTocReference item) {
    List<VHTocReference> tocItems = [];
    for (final child in item.children) {
      tocItems.add(child);
    }
    return tocItems;
  }

  /// Recursively finds a `<nav>` tag on html.
  xml.XmlElement? findNavTag(xml.XmlElement element) {
    final children = element.children.whereType<xml.XmlElement>().toList();
    for (var child in children) {
      if (child.name.local == 'nav') {
        return child;
      } else {
        final nav = findNavTag(child);
        if (nav != null) {
          return nav;
        }
      }
    }
    return null;
  }

  /// Read and parse <metadata>.

  VHMetadata readMetadata(List<xml.XmlElement> tags) {
    VHMetadata metadata = VHMetadata();

    for (final tag in tags) {
      switch (tag.name.toString()) {
        case 'dc:title':
          metadata.titles.add(tag.text);
          break;
        case 'dc:identifier':
          final identifier = Identifier(
              id: tag.getAttribute('id'),
              scheme: tag.getAttribute('opf:scheme'),
              value: tag.text);
          metadata.identifiers.add(identifier);
          break;
        case 'dc:language':
          final language = tag.text;
          metadata.language = language != 'en' ? language : metadata.language;
          break;
        case 'dc:creator':
          final author = Author(
            name: tag.text,
            role: tag.getAttribute('opf:role') ?? '',
            fileAs: tag.getAttribute('opf:file-as') ?? '',
          );
          metadata.creators.add(author);
          break;
        case 'dc:contributor':
          final author = Author(
            name: tag.text,
            role: tag.getAttribute('opf:role') ?? '',
            fileAs: tag.getAttribute('opf:file-as') ?? '',
          );
          metadata.creators.add(author);
          break;
        case 'dc:publisher':
          metadata.publishers.add(tag.text);
          break;
        case 'dc:description':
          metadata.descriptions.add(tag.text);
          break;
        case 'dc:subject':
          metadata.subjects.add(tag.text);
          break;
        case 'dc:rights':
          metadata.rights.add(tag.text);
          break;
        case 'dc:date':
          final eventDate = EventDate(
            date: tag.text,
            event: tag.getAttribute('opf:event') ?? '',
          );
          metadata.dates.add(eventDate);
          break;
        case 'meta':
          final name = tag.getAttribute('name');
          final property = tag.getAttribute('property');
          final content = tag.getAttribute('content');
          final id = tag.getAttribute('id');
          final value = tag.text;
          final refines = tag.getAttribute('refines');
          metadata.metaAttributes.add(Meta(
              name: name,
              content: content,
              id: id,
              property: property,
              refines: refines,
              value: value));

          break;
        default:
          break;
      }
    }
    return metadata;
  }

  /// Read and parse <spine>.

  VHSpine readSpine(List<xml.XmlElement> tags) {
    VHSpine spine = VHSpine();

    for (final tag in tags) {
      final idref = tag.getAttribute('idref');
      if (idref == null) {
        continue;
      }
      bool linear = true;
      if (tag.getAttribute('linear') != null) {
        linear = tag.getAttribute('linear') == "yes" ? true : false;
      }
      if (book.resources.containsById(idref)) {
        VHResource? resource = book.resources.findById(idref);
        if (resource != null) {
          spine.spineReferences.add(Spine(resource: resource, linear: linear));
        }
      }
    }
    return spine;
  }
}

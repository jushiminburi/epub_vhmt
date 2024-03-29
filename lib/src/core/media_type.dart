import 'package:path/path.dart' as path;

/// MediaType is used to tell the type of content a resource is.
///
/// Examples of mediatypes are image/gif, text/css and application/xhtml+xml
class MediaType {
  final String name;
  final String defaultExtension;
  final List<String> extensions;

  MediaType({
    required this.name,
    required this.defaultExtension,
    this.extensions = const [],
  });

  /// Equatable
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaType &&
        name == other.name &&
        defaultExtension == other.defaultExtension &&
        extensions == other.extensions;
  }

  @override
  int get hashCode =>
      name.hashCode ^ defaultExtension.hashCode ^ extensions.hashCode;

  /// Manages mediatypes that are used by epubs.
  static final MediaType xhtml = MediaType(
    name: 'application/xhtml+xml',
    defaultExtension: 'xhtml',
    extensions: ['htm', 'html', 'xhtml', 'xml'],
  );
  static final MediaType epub = MediaType(
    name: 'application/epub+zip',
    defaultExtension: 'epub',
  );
  static final MediaType ncx = MediaType(
    name: 'application/x-dtbncx+xml',
    defaultExtension: 'ncx',
  );
  static final MediaType opf = MediaType(
    name: 'application/oebps-package+xml',
    defaultExtension: 'opf',
  );
  static final MediaType javaScript = MediaType(
    name: 'text/javascript',
    defaultExtension: 'js',
  );
  static final MediaType css = MediaType(
    name: 'text/css',
    defaultExtension: 'css',
  );

  // images
  static final MediaType jpg = MediaType(
    name: 'image/jpeg',
    defaultExtension: 'jpg',
    extensions: ['jpg', 'jpeg'],
  );
  static final MediaType png = MediaType(
    name: 'image/png',
    defaultExtension: 'png',
  );
  static final MediaType gif = MediaType(
    name: 'image/gif',
    defaultExtension: 'gif',
  );
  static final MediaType svg = MediaType(
    name: 'image/svg+xml',
    defaultExtension: 'svg',
  );

  // fonts
  static final MediaType ttf = MediaType(
    name: 'application/x-font-ttf',
    defaultExtension: 'ttf',
  );
  static final MediaType ttf1 = MediaType(
    name: 'application/x-font-truetype',
    defaultExtension: 'ttf',
  );
  static final MediaType ttf2 = MediaType(
    name: 'application/x-truetype-font',
    defaultExtension: 'ttf',
  );
  static final MediaType openType = MediaType(
    name: 'application/vnd.ms-opentype',
    defaultExtension: 'otf',
  );
  static final MediaType woff = MediaType(
    name: 'application/font-woff',
    defaultExtension: 'woff',
  );

  // audio
  static final MediaType mp3 = MediaType(
    name: 'audio/mpeg',
    defaultExtension: 'mp3',
  );
  static final MediaType mp4 = MediaType(
    name: 'audio/mp4',
    defaultExtension: 'mp4',
  );
  static final MediaType ogg = MediaType(
    name: 'audio/ogg',
    defaultExtension: 'ogg',
  );

  static final MediaType smil = MediaType(
    name: 'application/smil+xml',
    defaultExtension: 'smil',
  );
  static final MediaType xpgt = MediaType(
    name: 'application/adobe-page-template+xml',
    defaultExtension: 'xpgt',
  );
  static final MediaType pls = MediaType(
    name: 'application/pls+xml',
    defaultExtension: 'pls',
  );

  static final mediatypes = [
    xhtml,
    epub,
    ncx,
    opf,
    jpg,
    png,
    gif,
    javaScript,
    css,
    svg,
    ttf,
    ttf1,
    ttf2,
    openType,
    woff,
    mp3,
    mp4,
    ogg,
    smil,
    xpgt,
    pls,
  ];

  /// Gets the MediaType based on the file mimetype.
  static MediaType by({required String name, String? fileName}) {
    for (MediaType mediatype in mediatypes) {
      if (mediatype.name == name) {
        return mediatype;
      }
    }
    final ext = path.extension(fileName ?? '');
    return MediaType(name: name, defaultExtension: ext);
  }

  /// Gets the MediaType based on the file extension.
  static MediaType? byFileName(String fileName) {
    final exts = path.extension(fileName);
    String ext = exts.replaceAll(".", "");

    return mediatypes.firstWhere(
      (mediatype) => mediatype.defaultExtension.contains(ext),
      orElse: () => MediaType(name: '', defaultExtension: ''),
    );
  }

  /// Compare if the resource is a image.
  static bool isBitmapImage(MediaType mediaType) {
    return mediaType == jpg || mediaType == png || mediaType == gif;
  }

  /// Gets the MediaType based on the file extension.
  static MediaType? determineMediaType(String fileName) {
    final ext = path.extension(fileName);

    for (MediaType mediatype in mediatypes) {
      if (mediatype.defaultExtension == ext) {
        return mediatype;
      }
      if (mediatype.extensions.contains(ext)) {
        return mediatype;
      }
    }
    return null;
  }
}

import 'package:uuid/uuid.dart';

class DocumentModel {
  final String uuid;
  final String name;
  final List<String> tags;
  final String? previewBase64; // Base64 JPEG of first page
  final String? localFilePath; // Path to cached PDF on device
  final String fileHash; // SHA-256 of original PDF
  final int fileSizeBytes;
  final DateTime creationDate;
  final DateTime updateDate;
  final bool isDeleted;
  final bool isPinned;

  DocumentModel({
    String? uuid,
    required this.name,
    this.tags = const [],
    this.previewBase64,
    this.localFilePath,
    required this.fileHash,
    required this.fileSizeBytes,
    DateTime? creationDate,
    DateTime? updateDate,
    this.isDeleted = false,
    this.isPinned = false,
  })  : uuid = uuid ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  DocumentModel copyWith({
    String? name,
    List<String>? tags,
    Object? previewBase64 = const _Undefined(),
    Object? localFilePath = const _Undefined(),
    String? fileHash,
    int? fileSizeBytes,
    DateTime? updateDate,
    bool? isDeleted,
    bool? isPinned,
  }) {
    return DocumentModel(
      uuid: uuid,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      previewBase64: previewBase64 is _Undefined ? this.previewBase64 : previewBase64 as String?,
      localFilePath: localFilePath is _Undefined ? this.localFilePath : localFilePath as String?,
      fileHash: fileHash ?? this.fileHash,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      creationDate: creationDate,
      updateDate: updateDate ?? DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'tags': tags.join(','),
      'previewBase64': previewBase64,
      'localFilePath': localFilePath,
      'fileHash': fileHash,
      'fileSizeBytes': fileSizeBytes,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'updateDate': updateDate.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      uuid: map['uuid'] ?? '',
      name: map['name'] ?? '',
      tags: map['tags'] != null ? (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList() : [],
      previewBase64: map['previewBase64'],
      localFilePath: map['localFilePath'],
      fileHash: map['fileHash'] ?? '',
      fileSizeBytes: map['fileSizeBytes'] ?? 0,
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate'] ?? 0),
      updateDate: DateTime.fromMillisecondsSinceEpoch(map['updateDate'] ?? 0),
      isDeleted: (map['isDeleted'] ?? 0) == 1,
      isPinned: (map['isPinned'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel.fromMap(json);

  @override
  String toString() {
    return 'DocumentModel{uuid: $uuid, name: $name, tags: $tags, fileHash: $fileHash, fileSizeBytes: $fileSizeBytes, isDeleted: $isDeleted, isPinned: $isPinned}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentModel && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}

class _Undefined {
  const _Undefined();
}

import 'package:uuid/uuid.dart';

class CardModel {
  final String uuid;
  final String name;
  final List<String> tags;
  final String? coverImagePath;
  final DateTime creationDate;
  final DateTime updateDate;
  final int usageCount;
  final String? barcodeData;
  final String? barcodeType;
  final bool isDeleted;
  final bool isPinned;

  CardModel({
    String? uuid,
    required this.name,
    this.tags = const [],
    this.coverImagePath,
    DateTime? creationDate,
    DateTime? updateDate,
    this.usageCount = 0,
    this.barcodeData,
    this.barcodeType,
    this.isDeleted = false,
    this.isPinned = false,
  })  : uuid = uuid ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  CardModel copyWith({
    String? name,
    List<String>? tags,
    String? coverImagePath,
    DateTime? updateDate,
    int? usageCount,
    String? barcodeData,
    String? barcodeType,
    bool? isDeleted,
    bool? isPinned,
  }) {
    return CardModel(
      uuid: uuid,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      creationDate: creationDate,
      updateDate: updateDate ?? DateTime.now(),
      usageCount: usageCount ?? this.usageCount,
      barcodeData: barcodeData ?? this.barcodeData,
      barcodeType: barcodeType ?? this.barcodeType,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'tags': tags.join(','),
      'coverImagePath': coverImagePath,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'updateDate': updateDate.millisecondsSinceEpoch,
      'usageCount': usageCount,
      'barcodeData': barcodeData,
      'barcodeType': barcodeType,
      'isDeleted': isDeleted ? 1 : 0, // Convert boolean to int for SQLite
      'isPinned': isPinned ? 1 : 0, // Convert boolean to int for SQLite
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      uuid: map['uuid'] ?? '',
      name: map['name'] ?? '',
      tags: map['tags'] != null ? (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList() : [],
      coverImagePath: map['coverImagePath'],
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate'] ?? 0),
      updateDate: DateTime.fromMillisecondsSinceEpoch(map['updateDate'] ?? 0),
      usageCount: map['usageCount'] ?? 0,
      barcodeData: map['barcodeData'],
      barcodeType: map['barcodeType'],
      isDeleted: (map['isDeleted'] ?? 0) == 1, // Convert int to boolean for SQLite
      isPinned: (map['isPinned'] ?? 0) == 1, // Convert int to boolean for SQLite
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel.fromMap(json);

  @override
  String toString() {
    return 'CardModel{uuid: $uuid, name: $name, tags: $tags, coverImagePath: $coverImagePath, creationDate: $creationDate, updateDate: $updateDate, usageCount: $usageCount, barcodeData: $barcodeData, barcodeType: $barcodeType, isDeleted: $isDeleted, isPinned: $isPinned}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardModel && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}


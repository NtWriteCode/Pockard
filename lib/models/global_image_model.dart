class GlobalImageModel {
  final String uuid;
  final String name;
  final String imagePath;
  final DateTime uploadDate;
  final String uploaderPseudoUser;

  GlobalImageModel({required this.uuid, required this.name, required this.imagePath, required this.uploadDate, required this.uploaderPseudoUser});

  Map<String, dynamic> toMap() {
    return {'uuid': uuid, 'name': name, 'imagePath': imagePath, 'uploadDate': uploadDate.millisecondsSinceEpoch, 'uploaderPseudoUser': uploaderPseudoUser};
  }

  factory GlobalImageModel.fromMap(Map<String, dynamic> map) {
    return GlobalImageModel(
      uuid: map['uuid'] ?? '',
      name: map['name'] ?? '',
      imagePath: map['imagePath'] ?? '',
      uploadDate: DateTime.fromMillisecondsSinceEpoch(map['uploadDate'] ?? 0),
      uploaderPseudoUser: map['uploaderPseudoUser'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory GlobalImageModel.fromJson(Map<String, dynamic> json) => GlobalImageModel.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalImageModel && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}

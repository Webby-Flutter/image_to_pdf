class ImageItem {
  final String path;
  final DateTime addedAt;

  ImageItem({required this.path, required this.addedAt});

  Map<String, dynamic> toJson() => {
        'path': path,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ImageItem.fromJson(Map<String, dynamic> json) => ImageItem(
        path: json['path'],
        addedAt: DateTime.parse(json['addedAt']),
      );
}
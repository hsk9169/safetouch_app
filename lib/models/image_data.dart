class MenuImageData {
  final String? fileName;
  final String? content;

  MenuImageData({this.fileName, this.content});

  factory MenuImageData.fromJson(Map<String, dynamic> json) {
    return MenuImageData(
      fileName: json['fileName'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'content': content,
      };
}

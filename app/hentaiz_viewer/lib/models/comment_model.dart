class CommentModel {
  final int id;
  final int? parentId;
  final String content;
  final String username;
  final DateTime createdAt;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    this.parentId,
    required this.content,
    required this.username,
    required this.createdAt,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      parentId: json['parentId'],
      content: json['content'],
      username: json['username'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

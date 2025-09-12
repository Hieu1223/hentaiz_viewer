import 'package:hentaiz_viewer/resource.dart';

class HentaiDisplayModel {
  final int id;
  final String title;
  final String thumbnail;

  HentaiDisplayModel({
    required this.id,
    required this.title,
    required this.thumbnail,
  });

  factory HentaiDisplayModel.fromJson(Map<String, dynamic> json) {
    return HentaiDisplayModel(
      id: json['id'],
      title: json['title'],
      thumbnail: "${Resource.baseUrl}/proxy?url=${json['image_url']}", // cột trong DB phải có
    );
  }
}
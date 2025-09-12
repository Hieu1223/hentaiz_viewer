import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:hentaiz_viewer/models/hentai_display_model.dart';
import 'package:hentaiz_viewer/resource.dart';
import 'package:http/http.dart' as http;

class MainPageViewModel extends ChangeNotifier {
  late Future<List<HentaiDisplayModel>> hentaiListFuture;
  List<HentaiDisplayModel> hentaiList = [];
  int currentPage = 1;
  String? currentQuery; // null if not searching

  MainPageViewModel() {
    hentaiListFuture = fetchPage(1);
  }

  /// Fetch regular page
  Future<List<HentaiDisplayModel>> fetchPage(int page) async {
    final url = currentQuery == null
        ? "${Resource.baseUrl}/page/$page"
        : "${Resource.baseUrl}/search?q=${Uri.encodeQueryComponent(currentQuery!)}&page=$page";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      hentaiList = data.map((e) => HentaiDisplayModel.fromJson(e)).toList();
      notifyListeners();
      return hentaiList;
    } else {
      throw Exception("Failed to load data");
    }
  }

  /// Search by query
  Future<List<HentaiDisplayModel>> search(String query, {int page = 1}) async {
    currentQuery = query.trim().isEmpty ? null : query.trim();
    currentPage = page;
    hentaiListFuture = fetchPage(page);
    return hentaiListFuture;
  }

  Future<String> fetchVideoUrl(int id) async {
    final response = await http.get(Uri.parse("${Resource.baseUrl}/video/$id"));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['url'];
    } else {
      throw Exception("Failed to load video");
    }
  }

  void changePage(int page) {
    currentPage = page;
    hentaiListFuture = fetchPage(page);
  }

  void clearSearch() {
    currentQuery = null;
    currentPage = 1;
    hentaiListFuture = fetchPage(1);
  }
}

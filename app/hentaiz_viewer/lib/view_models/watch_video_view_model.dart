import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hentaiz_viewer/models/comment_model.dart';
import 'package:hentaiz_viewer/resource.dart';
import 'package:hentaiz_viewer/view_models/application_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class VideoWatchViewModel extends ChangeNotifier {
  final int videoId;
  String? videoUrl;
  bool loading = true;

  List<CommentModel> comments = [];
  bool commentsLoading = false;

  VideoWatchViewModel(this.videoId) {
    fetchVideo();
    fetchComments();
  }

  // Fetch video URL
  Future<void> fetchVideo() async {
    try {
      final response =
          await http.get(Uri.parse("${Resource.baseUrl}/video/$videoId"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        videoUrl = jsonResponse['url'];
      } else {
        throw Exception("Failed to load video (code: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error fetching video: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Fetch comments
  Future<void> fetchComments() async {
    commentsLoading = true;
    notifyListeners();
    try {
      final response =
          await http.get(Uri.parse("${Resource.baseUrl}/comments/$videoId"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        comments = (data['comments'] as List<dynamic>)
            .map((e) => CommentModel.fromJson(e))
            .toList();
      } else {
        debugPrint("Failed to load comments: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
    } finally {
      commentsLoading = false;
      notifyListeners();
    }
  }

  // Post comment
  Future<bool> postComment(BuildContext context,
      {required String content, int? parentId}) async {
    final appVM = Provider.of<ApplicationViewModel>(context, listen: false);

    if (!appVM.isLoggedIn()) {
      debugPrint("User not logged in");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("${Resource.baseUrl}/comments"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": appVM.getAuthorizationKey()!,
        },
        body: jsonEncode({
          "videoId": videoId,
          "content": content,
          "parentId": parentId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchComments(); // reload comments after posting
        return true;
      } else {
        debugPrint("Failed to post comment: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error posting comment: $e");
    }
    return false;
  }
}
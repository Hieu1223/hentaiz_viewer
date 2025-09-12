import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hentaiz_viewer/view_models/watch_video_view_model.dart';
import 'package:hentaiz_viewer/view_models/application_view_model.dart';

class CommentsSection extends StatefulWidget {
  final VideoWatchViewModel videoWatchVM;

  const CommentsSection({super.key, required this.videoWatchVM});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final Map<int, TextEditingController> _replyControllers = {};
  final TextEditingController _newCommentController = TextEditingController();

  bool _showNewCommentBox = false;
  bool _newCommentLoading = false; // Loading state for new comment
  int? _activeReplyId; // Only this comment's reply box is open
  final Map<int, bool> _replyLoading = {}; // Loading state for each reply

  @override
  void dispose() {
    _newCommentController.dispose();
    _replyControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _toggleReplyBox(int commentId) {
    setState(() {
      if (_activeReplyId == commentId) {
        _activeReplyId = null;
      } else {
        _activeReplyId = commentId;
        _showNewCommentBox = false;
      }
    });
  }

  void _toggleNewCommentBox() {
    setState(() {
      _showNewCommentBox = !_showNewCommentBox;
      if (_showNewCommentBox) _activeReplyId = null;
    });
  }

  Future<void> _submitNewComment() async {
    final content = _newCommentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _newCommentLoading = true);
    final success =
        await widget.videoWatchVM.postComment(context, content: content);
    if (success) _newCommentController.clear();
    setState(() => _newCommentLoading = false);
  }

  Future<void> _submitReply(int commentId) async {
    final content = _replyControllers[commentId]!.text.trim();
    if (content.isEmpty) return;

    setState(() => _replyLoading[commentId] = true);
    final success = await widget.videoWatchVM
        .postComment(context, content: content, parentId: commentId);
    if (success) _replyControllers[commentId]!.clear();
    setState(() => _replyLoading[commentId] = false);
  }

  @override
  Widget build(BuildContext context) {
    final appVM = Provider.of<ApplicationViewModel>(context);

    if (widget.videoWatchVM.commentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appVM.isLoggedIn())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: _toggleNewCommentBox,
              child: Text(_showNewCommentBox ? "Cancel" : "Add Comment"),
            ),
          ),
        if (_showNewCommentBox && appVM.isLoggedIn())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCommentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: _newCommentLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _newCommentLoading ? null : _submitNewComment,
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (widget.videoWatchVM.comments.isEmpty)
          const Text("No comments yet")
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.videoWatchVM.comments
                .map(
                  (comment) => CommentWidget(
                    comment: comment,
                    videoWatchVM: widget.videoWatchVM,
                    replyControllers: _replyControllers,
                    activeReplyId: _activeReplyId,
                    toggleReplyBox: _toggleReplyBox,
                    replyLoading: _replyLoading,
                    submitReply: _submitReply,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class CommentWidget extends StatelessWidget {
  final dynamic comment;
  final VideoWatchViewModel videoWatchVM;
  final Map<int, TextEditingController> replyControllers;
  final int? activeReplyId;
  final void Function(int) toggleReplyBox;
  final Map<int, bool> replyLoading;
  final Future<void> Function(int) submitReply;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.videoWatchVM,
    required this.replyControllers,
    required this.activeReplyId,
    required this.toggleReplyBox,
    required this.replyLoading,
    required this.submitReply,
  });

  @override
  Widget build(BuildContext context) {
    final appVM = Provider.of<ApplicationViewModel>(context);
    replyControllers.putIfAbsent(comment.id, () => TextEditingController());

    final isReplyOpen = activeReplyId == comment.id;
    final isLoading = replyLoading[comment.id] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${comment.username} • ${comment.createdAt.toLocal()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(comment.content),
          const SizedBox(height: 4),
          if (appVM.isLoggedIn())
            TextButton(
              onPressed: () => toggleReplyBox(comment.id),
              child: Text(isReplyOpen ? "Cancel" : "Reply"),
            ),
          if (isReplyOpen)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyControllers[comment.id],
                    decoration: const InputDecoration(
                      hintText: "Write a reply...",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: isLoading ? null : () => submitReply(comment.id),
                ),
              ],
            ),
          if ((comment.replies as List).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: (comment.replies as List)
                    .map(
                      (reply) => CommentWidget(
                        comment: reply,
                        videoWatchVM: videoWatchVM,
                        replyControllers: replyControllers,
                        activeReplyId: activeReplyId,
                        toggleReplyBox: toggleReplyBox,
                        replyLoading: replyLoading,
                        submitReply: submitReply,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

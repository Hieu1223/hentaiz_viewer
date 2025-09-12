import 'package:flutter/material.dart';
import 'package:hentaiz_viewer/view_models/watch_video_view_model.dart';
import 'package:hentaiz_viewer/views/components/account_bar.dart';
import 'package:hentaiz_viewer/views/components/comment_section.dart';
import 'package:hentaiz_viewer/views/components/native_video.dart';
import 'package:provider/provider.dart';

class VideoWatchPage extends StatelessWidget {
  final int videoId;
  final String videoTitle;

  const VideoWatchPage({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoWatchViewModel(videoId),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Watching $videoTitle"),
          actions: [AccountAction()],
        ),
        body: Consumer<VideoWatchViewModel>(
          builder: (context, vm, _) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.videoUrl == null) {
              return const Center(child: Text("Failed to load video"));
            }

            return ListView(
              padding: const EdgeInsets.all(8),
              children: [
                VideoPlayerSection(videoUrl: vm.videoUrl!, videoId: videoId),
                const SizedBox(height: 12),
                VideoTitleSection(title: videoTitle),
                const SizedBox(height: 16),
                CommentsSection(videoWatchVM: vm),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ---------------------- COMPONENTS ----------------------

class VideoPlayerSection extends StatelessWidget {
  final String videoUrl;
  final int videoId;

  const VideoPlayerSection({
    super.key,
    required this.videoUrl,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return NativeVideo(
      embedUrl: videoUrl,
      height: 250,
      width: double.infinity,
      title: "Video #$videoId",
    );
  }
}

class VideoTitleSection extends StatelessWidget {
  final String title;

  const VideoTitleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
      overflow: TextOverflow.ellipsis,
    );
  }
}


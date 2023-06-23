import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.videoUrl);

    _videoController.initialize().then(
          (_) => setState(
            () => _chewieController = ChewieController(
              autoInitialize: true,
              videoPlayerController: _videoController,
              aspectRatio: _videoController.value.aspectRatio,
            ),
          ),
        );
  }

  @override
  void dispose() { 
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _videoController.value.isInitialized
         ? AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: Chewie(
            controller: _chewieController,
          ),
        )
        : const SizedBox.shrink()
      ],
    );
  }
}

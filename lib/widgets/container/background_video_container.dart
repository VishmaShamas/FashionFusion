import 'package:fashion_fusion/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideoContainer extends StatefulWidget {
  const BackgroundVideoContainer({super.key, required this.child});
  final Widget child;

  @override
  State<BackgroundVideoContainer> createState() =>
      _BackgroundVideoContainerState();
}

class _BackgroundVideoContainerState extends State<BackgroundVideoContainer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset(VideoAsset.authBg)
          ..initialize().then((_) {
            setState(() {}); // Refresh to show video once initialized
          })
          ..setLooping(true)
          ..setVolume(0.0)
          ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_controller.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        Container(
          color: Colors.black.withOpacity(0.3),
        ), // Optional dark overlay
        widget.child,
      ],
    );
  }
}

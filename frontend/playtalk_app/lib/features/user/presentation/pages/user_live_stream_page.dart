import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class UserLiveStreamPage extends StatefulWidget {
  final String hlsUrl;
  final String title;

  const UserLiveStreamPage({
    super.key,
    required this.hlsUrl,
    required this.title,
  });

  @override
  State<UserLiveStreamPage> createState() => _UserLiveStreamPageState();
}

class _UserLiveStreamPageState extends State<UserLiveStreamPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.hlsUrl),
      );

      await controller.initialize();
      await controller.play();
      controller.setLooping(true);

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Failed to load stream: $e";
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : controller == null
                    ? const Text(
                        "Stream unavailable",
                        style: TextStyle(color: Colors.white),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                          const SizedBox(height: 16),
                          IconButton(
                            iconSize: 42,
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (controller.value.isPlaying) {
                                  controller.pause();
                                } else {
                                  controller.play();
                                }
                              });
                            },
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
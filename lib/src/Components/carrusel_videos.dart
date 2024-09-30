import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CarruselVideos extends StatefulWidget {
  const CarruselVideos({super.key}); // Agrega `key` y `const` para mejorar el rendimiento.

  @override
  CarruselVideosState createState() => CarruselVideosState();
}

class CarruselVideosState extends State<CarruselVideos> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;

  @override
  void initState() {
    super.initState();

    // Video 1 - 720p (1280x720)
    _controller1 = VideoPlayerController.networkUrl(
      Uri.parse('https://www.youtube.com/watch?v=G6iafHqJVEU'),  // Usamos networkUrl con Uri.parse
    )..initialize().then((_) {
      setState(() {});
    });

    // Video 2 - 1080p (1920x1080)
    _controller2 = VideoPlayerController.networkUrl(
      Uri.parse('https://www.youtube.com/watch?v=y8cdm6Nu1PE'),
    )..initialize().then((_) {
      setState(() {});
    });

    // Video 3 - 720p
    _controller3 = VideoPlayerController.networkUrl(
      Uri.parse('https://www.youtube.com/watch?v=pj51uMKUmko'),
    )..initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        videoPlayerWidget(_controller1),
        videoPlayerWidget(_controller2),
        videoPlayerWidget(_controller3),
      ],
    );
  }

  Widget videoPlayerWidget(VideoPlayerController controller) {
    return controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    )
        : const Center(child: CircularProgressIndicator()); // Agregar const mejora el rendimiento
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yumpro/services/mixpanel_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late VideoPlayerController _controller;
  bool _playClicked = false; // Variable pour suivre si Play a été cliqué
  bool _isVideoEnded = false; // Variable pour suivre si la vidéo est terminée

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://yummap.s3.eu-north-1.amazonaws.com/yumpro/snapvid-yumpro-intro.mp4',
    )..initialize().then((_) {
        setState(
            () {}); // Met à jour l'interface utilisateur lorsque la vidéo est prête à être lue
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isVideoEnded = true;
        });
      }
    });

    // Suivi de l'événement lorsque l'utilisateur arrive sur la page
    AnalyticsManager().trackEvent('landing_page_view');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Invitation au restaurant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : const CircularProgressIndicator(),
                    if (_controller.value.isInitialized)
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              if (!_playClicked) {
                                // Suivi de l'événement lorsque l'utilisateur clique sur Play pour la première fois
                                AnalyticsManager().trackEvent('play_clicked');
                                _playClicked = true;
                              }
                              if (_isVideoEnded) {
                                _controller.seekTo(Duration.zero);
                                _controller.play();
                                _isVideoEnded = false;
                              } else if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          child: Icon(
                            _isVideoEnded
                                ? Icons.replay
                                : _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800, // couleur du bouton
                  foregroundColor: Colors.white, // couleur du texte
                ),
                onPressed: () {
                  // Suivi de l'événement lorsque l'utilisateur clique sur "Accéder au service"
                  AnalyticsManager().trackEvent('access_service_clicked');
                  // Action à effectuer lors de l'appui sur le bouton
                  Navigator.pushNamed(context, '/register');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Accéder au service'),
                    SizedBox(
                      width: 8,
                      height: 40,
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

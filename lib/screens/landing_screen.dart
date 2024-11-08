import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yumpro/services/mixpanel_service.dart';
import 'package:yumpro/utils/appcolors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late VideoPlayerController _controller;
  bool _playClicked = false; // Suivre si le bouton Play a été cliqué
  bool _isVideoEnded = false; // Suivre si la vidéo est terminée
  bool _isLoading = true; // Indiquer si la vidéo est en cours de chargement
  bool _hasError = false; // Indiquer si une erreur s'est produite

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    // Suivi de l'événement lorsque l'utilisateur arrive sur la page
    AnalyticsManager().trackEvent('landing_page_view');
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.network(
        'https://yummap.s3.eu-north-1.amazonaws.com/yumpro/snapvid-yumpro-intro.mp4',
      );

      await _controller.initialize();
      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          setState(() {
            _isVideoEnded = true;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Erreur lors du chargement de la vidéo: $e');
    }
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
              const SizedBox(height: 30),
              const Text(
                'Invitation au restaurant 🍽️',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.accent),
                        )
                      : _hasError
                          ? const Text(
                              'Erreur lors du chargement de la vidéo.',
                              style: TextStyle(color: Colors.red),
                            )
                          : AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                  if (!_isLoading && !_hasError)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (!_playClicked) {
                              // Suivi de l'événement lorsque l'utilisateur clique sur Play
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
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800, // couleur du bouton
                  foregroundColor: Colors.white, // couleur du texte
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ), // padding vertical
                ),
                onPressed: () {
                  // Suivi de l'événement lorsque l'utilisateur clique sur "Accéder au service"
                  AnalyticsManager().trackEvent('access_service_clicked');
                  Navigator.pushNamed(context, '/register');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Accéder au service',
                      style: TextStyle(
                        fontSize: 25, // taille du texte
                        fontWeight: FontWeight.bold, // poids de la police
                      ),
                    ),
                    SizedBox(width: 8),
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

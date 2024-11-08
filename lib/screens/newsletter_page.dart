import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:yumpro/models/invitation.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/mixpanel_service.dart';
import 'package:yumpro/utils/appcolors.dart';
import 'package:video_player/video_player.dart';
import 'package:yumpro/utils/constants.dart';

const String xanoBaseUrl = "https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX";

class NewsletterPage extends StatefulWidget {
  final int invitationId;
  final String? token;

  const NewsletterPage({super.key, required this.invitationId, this.token});

  @override
  _NewsletterPageState createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  late Future<Invitation> invitationFuture;
  late String token;
  List<VideoPlayerController> _videoControllers = [];
  bool valid = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    invitationFuture = fetchInvitation(widget.invitationId);
  }

  Future<Invitation> fetchInvitation(int id) async {
    final response =
        await http.get(Uri.parse('$xanoBaseUrl/newsletter/$id/invitation'));

    if (response.statusCode == 200) {
      final invitation =
          Invitation.fromJson(json.decode(response.body)['result1']);
      // Construire le token avec restaurant.id et invitation.id
      token = json.decode(response.body)['result1']['token'];

      // Vérification du token
      if (widget.token != token) {
        // Afficher un message d'erreur si le token ne correspond pas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Requête invalide, le token d'authentification n'est pas correct"),
            backgroundColor: Colors.red,
          ),
        );

        throw Exception("Token d'authentification incorrect");
      }
      setState(() {
        valid = true;
      });

      return invitation;
    } else {
      throw Exception('Erreur lors du chargement de l\'invitation');
    }
  }

  String formatExpirationDate(DateTime date) {
    // Assurer que la date est en UTC avant de manipuler
    DateTime utcDate = date.toUtc();

    // Utiliser la bibliothèque intl pour gérer le fuseau horaire de Paris
    var parisTimeZone = DateTime.now().timeZoneOffset;

    // Ajuster la date pour qu'elle soit en heure de Paris
    DateTime parisDate =
        utcDate.add(parisTimeZone); // Ajouter le décalage horaire de Paris

    // Vérification de la date de Paris pour s'assurer que la conversion est correcte
    print('Paris Date: ${parisDate.toString()}');

    // Formater la date dans le format 'dd MMM yyyy'
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(parisDate);
  }

  Future<Uint8List> generateQrCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      gapless: true,
      eyeStyle: QrEyeStyle(color: Color(0xFF000000)),
      dataModuleStyle: QrDataModuleStyle(color: Color(0xFF000000)),
    );
    final image = await painter.toImage(200);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> generateAndDownloadPDF(Invitation invitation) async {
    final doc = pw.Document();
    final qrCodeData =
        await generateQrCode('$yummapBaseURL/invitation/${invitation.id}');
    final qrCodeImage = pw.MemoryImage(qrCodeData);
    String formattedExpirationDate = formatExpirationDate(
        DateTime.fromMillisecondsSinceEpoch(invitation.dateExpiration!));

    doc.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Détails de l\'invitation',
                  style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Vous êtes invité à manger chez ${invitation.restaurant.name}',
                  textAlign: pw.TextAlign.center),
              pw.Text('Adresse: ${invitation.restaurant.address}'),
              pw.Text('Code: ${invitation.code}'),
              pw.SizedBox(height: 20),
              pw.Image(qrCodeImage, width: 200, height: 200),
              pw.SizedBox(height: 20),
              pw.Text('Instructions:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(invitation.restaurantDetails.instructions),
              pw.SizedBox(height: 20),
              pw.Text(
                'Date d\'expiration: ${formattedExpirationDate}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'invitation_details.pdf');
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void initializeVideoControllers(List<String> videoLinks) {
    _videoControllers = videoLinks.map((url) {
      final controller = VideoPlayerController.network(url);
      controller.initialize();
      return controller;
    }).toList();
  }

  void _showVideoDialog(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: VideoPlayerWidget(videoUrl: videoUrl),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Invitation Yummap pro'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: valid,
              child: ElevatedButton(
                onPressed: () async {
                  final invitation = await invitationFuture;
                  generateAndDownloadPDF(invitation);
                  var properties = {
                    'id_invitation': widget.invitationId,
                  };
                  AnalyticsManager()
                      .trackEvent("Download invitation", properties);
                },
                child: const Text("Télécharger"),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: FutureBuilder<Invitation>(
                future: invitationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    var properties = {
                      'id_invitation': widget.invitationId,
                    };
                    AnalyticsManager()
                        .trackEvent("ErrorReadInvitation", properties);
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 60),
                          SizedBox(height: 16),
                          Text(
                            'Requête erronnée',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Le token d\'authentification n\'est pas valide.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('Invitation non trouvée.'));
                  }

                  final invitation = snapshot.data!;
                  if (_videoControllers.isEmpty &&
                      invitation.restaurant.videoLinks.isNotEmpty) {
                    initializeVideoControllers(
                        invitation.restaurant.videoLinks);
                  }

                  var properties = {
                    'id': invitation.id,
                    'restaurant_name': invitation.restaurant.name,
                    'workspace_id': invitation.workspaceId,
                  };
                  AnalyticsManager().trackEvent("ReadInvitation", properties);
                  ApiService().markInvitationAsRead(invitation.id);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.accent, width: 4),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        invitation.restaurant.imageUrl),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Vous êtes invité à manger chez',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                invitation.restaurant.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: AppColors.accent),
                                  const SizedBox(width: 8),
                                  Text(
                                    invitation.restaurant.address,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Code d\'invitation : ${invitation.code}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (invitation.consumed)
                                Container(
                                  padding: const EdgeInsets.all(
                                      10), // Ajouter de l'espace autour du texte
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .background, // Une couleur de fond qui contraste
                                    borderRadius: BorderRadius.circular(
                                        8), // Bords arrondis pour un effet plus agréable
                                    border: Border.all(
                                      color: AppColors
                                          .primaryGold, // Une bordure colorée pour faire ressortir l'information
                                      width: 2, // Largeur de la bordure
                                    ),
                                  ),
                                  child: Text(
                                    'Invitation consommée le ${formatExpirationDate(DateTime.fromMillisecondsSinceEpoch(invitation.dateUsage!))}',
                                    style: const TextStyle(
                                      color: AppColors
                                          .secondaryGold, // Garder la couleur visible et claire
                                      fontSize:
                                          18, // Taille de police augmentée pour plus de lisibilité
                                      fontWeight:
                                          FontWeight.bold, // Texte en gras
                                    ),
                                  ),
                                ),
                              if (!invitation.consumed &&
                                  DateTime.now().isAfter(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          invitation.dateExpiration! * 1000)))
                                Text(
                                  'Invitation expirée le ${formatExpirationDate(DateTime.fromMillisecondsSinceEpoch(invitation.dateExpiration!))}',
                                  style: const TextStyle(
                                      color: AppColors.textHint),
                                ),
                              if (!invitation.consumed &&
                                  DateTime.now().isBefore(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          invitation.dateExpiration! * 1000)))
                                Text(
                                  'Expire le ${formatExpirationDate(DateTime.fromMillisecondsSinceEpoch(invitation.dateExpiration!))}',
                                  style: const TextStyle(
                                      color: AppColors.textHint),
                                ),
                            ],
                          ),
                          const SizedBox(width: 50),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              QrImageView(
                                data:
                                    '$yummapBaseURL/invitation/${invitation.id}',
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (invitation.restaurant.videoLinks.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: invitation.restaurant.videoLinks
                                .map((videoUrl) {
                              final thumbnailUrl =
                                  videoUrl.replaceAll('.mp4', '.jpg');
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: GestureDetector(
                                  onTap: () =>
                                      _showVideoDialog(context, videoUrl),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(
                                          thumbnailUrl,
                                          width: 150,
                                          height: 250,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 150,
                                              height: 250,
                                              color: Colors.black,
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                size: 50,
                                              ),
                                            );
                                          },
                                        ),
                                        const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Présentation et instructions
                      Container(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Présentation :',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              invitation.restaurantDetails.presentation,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'À noter :',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              invitation.restaurantDetails.instructions,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

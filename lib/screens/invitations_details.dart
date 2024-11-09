import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:yumpro/models/invitation.dart';
import 'package:yumpro/services/mixpanel_service.dart';
import 'package:yumpro/utils/appcolors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/widgets.dart' as pw;
import 'package:yumpro/utils/constants.dart';
import 'package:yumpro/utils/custom_widgets.dart';

class InvitationDetailsScreen extends StatelessWidget {
  final Invitation invitation;

  const InvitationDetailsScreen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    // Formate la date d'expiration au format dd MM yyyy
    String formatExpirationDate(DateTime date) {
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      return formatter.format(date);
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

    Future<void> generateAndDownloadPDF() async {
      var properties = {
        "name_restaurant": invitation.restaurant.name,
        "workspace_id": invitation.workspaceId
      };
      AnalyticsManager().trackEvent("Download", properties);
      DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
          invitation.dateExpiration ?? DateTime.now().millisecondsSinceEpoch);
      DateTime dateUsage = DateTime.fromMillisecondsSinceEpoch(
          invitation.dateUsage ?? DateTime.now().millisecondsSinceEpoch);
      if (kIsWeb) {
        final doc = pw.Document();
        final qrCodeData =
            await generateQrCode('${yummapBaseURL}invitation/${invitation.id}');
        final qrCodeImage = pw.MemoryImage(qrCodeData);
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day);

        doc.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Détails de l\'invitation',
                      style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 20),
                  pw.Text(
                      'Vous êtes invité à manger chez ${invitation.restaurant.name}',
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 10),
                  pw.Text('Adresse: ${invitation.restaurant.address}',
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 10),
                  pw.Text('Code : ${invitation.code}',
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 10),

                  if (invitation.consumed)
                    pw.Text(
                        'Invitation consommée le ${formatExpirationDate(dateUsage)}',
                        textAlign: pw.TextAlign.center),

                  if (!invitation.consumed &&
                      date.isAfter(DateTime.fromMillisecondsSinceEpoch(
                          invitation.dateExpiration! * 1000)))
                    pw.Text(
                        'Invitation expirée le ${formatExpirationDate(expirationDate)}',
                        textAlign: pw.TextAlign.center),

                  if (!invitation.consumed &&
                      date.isBefore(DateTime.fromMillisecondsSinceEpoch(
                          invitation.dateExpiration! * 1000)))
                    pw.Text(
                        'Expire le : ${formatExpirationDate(expirationDate)}',
                        textAlign: pw.TextAlign.center),

                  // pw.Text('Expire laaa : ${formatExpirationDate(expirationDate)}',
                  //     textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 20),
                  pw.Image(qrCodeImage, width: 200, height: 200),
                ],
              ),
            ),
          ),
        );

        await Printing.sharePdf(
            bytes: await doc.save(), filename: 'invitation_details.pdf');
      } else {
        final htmlContent = """
        <html>
          <head>
            <style>
              body {
                display: flex;
                flex-direction: column;
                align-items: center;
                text-align: center;
                padding: 20px;
                font-family: Arial, sans-serif;
              }
              .container {
                max-width: 800px;
                width: 100%;
                text-align: left;
              }
              .spacer {
                margin: 20px 0;
              }
              img {
                border-radius: 50%;
                border: 4px solid #ff4081;
                width: 200px;
                height: 200px;
              }
              .qr-code {
                margin-top: 20px;
              }
              h1 {
                text-align: center;
              }
              .bold {
                font-weight: bold;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Détails de l'invitation</h1>
              <p class="spacer">Vous êtes invité à manger chez ${invitation.restaurant.name}</p>
              <img src="${invitation.restaurant.imageUrl}" alt="Restaurant" class="spacer" />
              <p class="spacer">Adresse: ${invitation.restaurant.address}</p>
              <p class="spacer">CODE : ${invitation.code}</p>
              <p class="spacer">Expire le : ${formatExpirationDate(expirationDate)}</p>
              <p class="bold">Présentation :</p>
              <p class="spacer">${invitation.restaurantDetails.presentation}</p>
              <p class="bold">Instructions :</p>
              <p class="spacer">${invitation.restaurantDetails.instructions}</p>
              <p class="qr-code"><img src="https://api.qrserver.com/v1/create-qr-code/?data=${yummapBaseURL}invitation/${invitation.id}&size=200x200" alt="QR Code" /></p>
            </div>
          </body>
        </html>
        """;

        final output = await getTemporaryDirectory();
        final filePath = await FlutterHtmlToPdf.convertFromHtmlContent(
            htmlContent, output.path, "invitation_details");

        final file = io.File(filePath.toString());
        final bytes = await file.readAsBytes();
        await Printing.sharePdf(
            bytes: bytes, filename: 'invitation_details.pdf');
      }
    }

    DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
        invitation.dateExpiration ?? DateTime.now().millisecondsSinceEpoch);
    DateTime usageDate = DateTime.fromMillisecondsSinceEpoch(
        invitation.dateUsage ?? DateTime.now().millisecondsSinceEpoch);
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'invitation'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.outgoing_mail),
          //   onPressed: generateAndDownloadPDF,
          //   iconSize: 45,
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomWidgets.primaryButton(
                text: "Télécharger", onPressed: generateAndDownloadPDF),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Column(
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
                              border:
                                  Border.all(color: AppColors.accent, width: 4),
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
                          // Text(
                          //   'Expire le : ${formatExpirationDate(expirationDate)}',
                          //   style: const TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.black,
                          //   ),
                          // ),
                          if (invitation.consumed)
                            Text(
                              'Invitation consomée le ${formatExpirationDate(usageDate)}',
                              style: const TextStyle(color: AppColors.textHint),
                            ),
                          if (!invitation.consumed &&
                              date.isAfter(DateTime.fromMillisecondsSinceEpoch(
                                  invitation.dateExpiration! * 1000)))
                            Text(
                              'Invitation expirée le ${formatExpirationDate(expirationDate)}',
                              style: const TextStyle(color: AppColors.textHint),
                            ),
                          if (!invitation.consumed &&
                              date.isBefore(DateTime.fromMillisecondsSinceEpoch(
                                  invitation.dateExpiration! * 1000)))
                            Text(
                              'Expire le ${formatExpirationDate(expirationDate)}',
                              style: const TextStyle(color: AppColors.textHint),
                            ),
                        ],
                      ),
                      const SizedBox(width: 50),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(
                            data: '${yummapBaseURL}invitation/${invitation.id}',
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
                        children:
                            invitation.restaurant.videoLinks.map((videoUrl) {
                          // Crée l'URL de la miniature en remplaçant .mp4 par .jpg
                          final thumbnailUrl =
                              videoUrl.replaceAll('.mp4', '.jpg');

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () => _showVideoDialog(context, videoUrl),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Affiche la miniature de la vidéo
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
                                            color:
                                                Colors.white.withOpacity(0.7),
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
                          'A noter :',
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
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

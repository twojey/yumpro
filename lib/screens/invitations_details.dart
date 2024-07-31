import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yumpro/models/invitation.dart';
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
    Future<Uint8List> generateQrCode(String data) async {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        gapless: true,
      );
      final image = await painter.toImage(200);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    }

    Future<void> generateAndDownloadPDF() async {
      if (kIsWeb) {
        final doc = pw.Document();
        final qrCodeData =
            await generateQrCode('${yummapBaseURL}invitation/${invitation.id}');
        final qrCodeImage = pw.MemoryImage(qrCodeData);

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
                  pw.Text(
                      'Note: ${invitation.restaurant.rating} (${invitation.restaurant.numReviews} avis)',
                      textAlign: pw.TextAlign.center),
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
      .spacer {
        margin: 20px 0;
      }
      img {
        border-radius: 50%;
        border: 4px solid #ff4081; /* Utilisation de la couleur accent d'AppColors */
        width: 200px;
        height: 200px;
      }
      .qr-code {
        margin-top: 20px;
      }
      h1 {
        text-align: center;
      }
    </style>
  </head>
  <body>
    <h1>Détails de l'invitation</h1>
    <p class="spacer">Vous êtes invité à manger chez ${invitation.restaurant.name}</p>
    <img src="${invitation.restaurant.imageUrl}" alt="Restaurant" class="spacer" />
    <p class="spacer">Adresse: ${invitation.restaurant.address}</p>
    <p class="spacer">Note: ${invitation.restaurant.rating} (${invitation.restaurant.numReviews} avis)</p>
    <p class="qr-code"><img src="https://api.qrserver.com/v1/create-qr-code/?data=${yummapBaseURL}invitation/${invitation.id}&size=200x200" alt="QR Code" /></p>
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'invitation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.outgoing_mail),
            onPressed: generateAndDownloadPDF,
            iconSize: 45,
          ),
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
                              image:
                                  NetworkImage(invitation.restaurant.imageUrl),
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
                            const Icon(Icons.location_on, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(
                              invitation.restaurant.address,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(
                              '${invitation.restaurant.rating} (${invitation.restaurant.numReviews} avis)',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

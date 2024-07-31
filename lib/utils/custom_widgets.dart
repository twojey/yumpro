import 'package:flutter/material.dart';
import 'appcolors.dart'; // Importer le fichier des couleurs

class CustomWidgets {
  // Bouton primaire avec dégradé
  static Widget primaryButton(
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.transparent, // Needed to show the gradient
        shadowColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondaryBlack, AppColors.primaryBlack],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          constraints: const BoxConstraints(
              minHeight: 48,
              maxHeight: 58,
              minWidth: 150), // Définir une taille fixe
          alignment: Alignment.center,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: AppColors.primaryGold,
            ),
            onPressed: onPressed,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.secondaryGold, AppColors.lightGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                text,
                style: const TextStyle(
                  color:
                      Colors.white, // This color is overridden by the gradient
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Bouton secondaire avec contour et dégradé
  static Widget secondaryButton(
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppColors.accent, // Couleur accent
      ),
      onPressed: onPressed,
      child: Container(
        constraints: const BoxConstraints(
            minHeight: 38,
            maxHeight: 58,
            minWidth: 30), // Définir une taille fixe
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textWhite, // Texte blanc
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // TextButton
  static Widget textButton(
      {required String text, required VoidCallback onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor: AppColors.primaryGold,
      ),
      onPressed: onPressed,
      child: Container(
        constraints: const BoxConstraints(
            minHeight: 48,
            maxHeight: 58,
            minWidth: 150), // Définir une taille fixe
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

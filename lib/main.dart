import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:yumpro/models/invitation.dart';
import 'package:yumpro/screens/forgot_password_screen.dart';
import 'package:yumpro/screens/home_screen.dart';
import 'package:yumpro/screens/invitation_page.dart';
import 'package:yumpro/screens/invitations_details.dart';
import 'package:yumpro/screens/landing_screen.dart';
import 'package:yumpro/screens/login_screen.dart';
import 'package:yumpro/screens/onboarding_screen.dart';
import 'package:yumpro/screens/register_screen.dart';
import 'package:yumpro/screens/reset_password_screen.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/utils/appcolors.dart';

void main() async {
  setUrlStrategy(PathUrlStrategy()); // Configure URL strategy without #
  print("aaa");
  await dotenv.load(fileName: ".env");
  print("bbb");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yumpro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

        // Handle dynamic invitation routes
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'invitation') {
          final id = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => InvitationPage(invitationId: id),
          );
        }

        // Handle other routes
        switch (uri.path) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => FutureBuilder<Map<String, dynamic>>(
                future: _checkUserStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                          child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accent),
                      )),
                    );
                  } else if (snapshot.hasData) {
                    final userData = snapshot.data!;
                    final String? token = userData['token'];
                    final String? name = userData['name'];

                    if (token != null) {
                      if (name != "") {
                        return const HomeScreen();
                      } else {
                        return const OnboardingScreen();
                      }
                    } else {
                      return const LoginScreen();
                    }
                  } else {
                    return const LoginScreen();
                  }
                },
              ),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
            );
          case '/onboarding':
            return MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            );
          case '/landing':
            return MaterialPageRoute(
              builder: (context) => const LandingPage(),
            );
          case '/demo':
            return MaterialPageRoute(
              builder: (context) => const LandingPage(),
            );
          case '/invitation-details':
            final invitation = settings.arguments as Invitation?;
            return MaterialPageRoute(
              builder: (context) =>
                  InvitationDetailsScreen(invitation: invitation!),
            );
          case '/forgot_password':
            return MaterialPageRoute(
              builder: (context) => ForgotPasswordScreen(),
            );
          case '/reset_password':
            final email = uri.queryParameters['email'] ?? '';
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: email),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Page non trouvée'),
                ),
                body: const Center(
                  child: Text('La page demandée n\'existe pas.'),
                ),
              ),
            );
        }
      },
    );
  }
}

Future<Map<String, dynamic>> _checkUserStatus() async {
  final token = await AuthService().getToken();
  final userInfo = await AuthService().getUserInfo();
  userInfo['token'] = token;
  return userInfo;
}

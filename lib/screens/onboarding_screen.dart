import 'package:flutter/material.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/widgets/onboarding_steps/step1.dart';
import 'package:yumpro/widgets/onboarding_steps/step2_hotel.dart';
import 'package:yumpro/widgets/onboarding_steps/step_influ.dart';
import 'package:yumpro/widgets/onboarding_steps/step3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isHotelAccount = true;
  bool _showStep3 = true;
  final Map<String, dynamic> _userData =
      {}; // Stocker les données de l'utilisateur
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
  }

  Future<void> _fetchUserInformation() async {
    try {
      final String token = await _authService.getToken() as String;
      final userData = await _apiService.getUser(token);

      // Update _userData with relevant information from userData
      setState(() {
        _userData['user_id'] = userData['user_id'];
        _userData['name'] = userData['name'];
        _userData['first_name'] = userData['first_name'];
        _userData['email'] = userData['email'];
        _userData['workspace_id'] = userData['workspace_id'];
      });
    } catch (error) {
      // Handle potential errors during user data retrieval
      print('Failed to retrieve user information: $error');
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _finishOnboarding(BuildContext context) async {
    try {
      // Save user data using the API
      await _apiService.updateUser(_userData['id'], _userData);

      // Navigate to the home screen
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
    }
  }

  void _handleStep1Completion(bool isHotelAccount, Map<String, dynamic> data) {
    setState(() {
      _isHotelAccount = isHotelAccount;
      _showStep3 = !isHotelAccount;
    });
    _userData.addAll(data);
    _nextStep(); // Avance à l'étape suivante
  }

  void _handleStep2HotelCompletion(Map<String, dynamic> hotelData) {
    _userData.addAll(hotelData);
    _nextStep();
  }

  void _handleStep2InfluencerCompletion(Map<String, dynamic> influencerData) {
    _userData.addAll(influencerData);
    _nextStep();
  }

  void _handleStep3Completion(Map<String, dynamic> profileData) {
    _userData.addAll(profileData);
    _finishOnboarding(context);
  }

  List<Step> _buildSteps() {
    List<Step> steps = [
      Step(
        title: const Text('Choisir le type de compte'),
        content: Step1(onCompletion: _handleStep1Completion),
        isActive: _currentStep == 0,
      ),
    ];
    if (_isHotelAccount) {
      steps.add(Step(
        title: const Text('Créer ou rejoindre un établissement'),
        content: Step2Hotel(
          onNextPressed: _handleStep2HotelCompletion,
        ),
        isActive: _currentStep == 1,
      ));
      steps.add(Step(
        title: const Text('Créer votre profil'),
        content: Step3Hotel(
          isHotelAccount: true,
          onCompletion: _handleStep3Completion,
        ),
        isActive: _currentStep == 2,
      ));
    } else if (!_isHotelAccount && _showStep3) {
      steps.add(Step(
        title: const Text('Ajoutez un compte'),
        content: Step2Influencer(
          onNextPressed: _handleStep2InfluencerCompletion,
        ),
        isActive: _currentStep == 1,
      ));
      steps.add(Step(
        title: const Text('Créer son profil employé'),
        content: Step3Hotel(
          isHotelAccount: false,
          onCompletion: _handleStep3Completion,
        ),
        isActive: _currentStep == 2,
      ));
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        automaticallyImplyLeading: false,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        steps: _buildSteps(),
        controlsBuilder: (context, ControlsDetails controlsDetails) {
          if (_currentStep == _buildSteps().length - 1) {
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

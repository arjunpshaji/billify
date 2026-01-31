import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/design_tokens.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Quickly Capture Bills',
      description: 'Snap photos of your receipts or upload from your gallery.',
      imagePath: 'assets/images/onboarding_1.png',
      backgroundColor: const Color(0xFF1A1D26),
    ),
    OnboardingSlide(
      title: 'Track Your Spending',
      description:
          'Monitor your expenses across categories and stay on budget.',
      imagePath: 'assets/images/onboarding_2.png',
      backgroundColor: const Color(0xFF1A1D26),
    ),
    OnboardingSlide(
      title: 'Stay Organized',
      description:
          'Never miss a bill payment with smart reminders and organization.',
      imagePath: 'assets/images/onboarding_3.png',
      backgroundColor: const Color(0xFF1A1D26),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundDark,
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index]);
            },
          ),

          // Skip Button
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Pagination Dots
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildDot(index),
              ),
            ),
          ),

          // Next/Get Started Button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                ),
              ),
              child: Text(
                _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                style: DesignTokens.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Container(
      color: slide.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Image Container
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.primaryPurple.withOpacity(0.3),
                      DesignTokens.primaryPurpleDark.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForSlide(slide),
                    size: 120,
                    color: DesignTokens.primaryPurple,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slide.title,
                      style: DesignTokens.displayMedium.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.description,
                      style: DesignTokens.bodyMedium.copyWith(
                        fontSize: 16,
                        color: DesignTokens.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSlide(OnboardingSlide slide) {
    if (slide.title.contains('Capture')) {
      return Icons.camera_alt_rounded;
    } else if (slide.title.contains('Track')) {
      return Icons.analytics_rounded;
    } else {
      return Icons.folder_rounded;
    }
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? DesignTokens.primaryPurple
            : DesignTokens.textTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}

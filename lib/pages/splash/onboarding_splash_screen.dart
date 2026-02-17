import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../auth/signup_page.dart';
import 'onboarding_screens/onboarding_page_one.dart';

class OnboardingSplashScreen extends StatefulWidget {
  const OnboardingSplashScreen({super.key});

  @override
  State<OnboardingSplashScreen> createState() => _OnboardingSplashScreenState();
}

class _OnboardingSplashScreenState extends State<OnboardingSplashScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingPages = [
    {
      'title': 'Track Your Tags',
      'description': 'Easily manage and track all your vehicle tags in one place. Stay updated with real-time notifications.',
      'icon': 'assets/icons/main.png',
    },
    {
      'title': 'Smart Management',
      'description': 'Add multiple vehicles and manage their tags efficiently. Keep all your vehicle information organized.',
      'icon': 'assets/icons/main.png',
    },
    {
      'title': 'Quick Access',
      'description': 'Access your tag information anytime, anywhere. Get quick support and manage everything on the go.',
      'icon': 'assets/icons/main.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SignupPage(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SignupPage(),
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: Stack(
        children: [
          // Page View for Onboarding
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingPages.length,
            itemBuilder: (context, index) {
              return OnboardingPageOne(
                title: _onboardingPages[index]['title']!,
                description: _onboardingPages[index]['description']!,
                iconPath: _onboardingPages[index]['icon']!,
                pageNumber: index + 1,
                totalPages: _onboardingPages.length,
              );
            },
          ),

          // Skip button at top right
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black.withOpacity(0.7),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation - Arrows and Dots
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingPages.length,
                        (index) => Container(
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppColors.black
                                : AppColors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Navigation Arrows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Arrow
                        GestureDetector(
                          onTap: _currentPage > 0 ? _previousPage : null,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _currentPage > 0
                                  ? AppColors.white
                                  : AppColors.white.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: _currentPage > 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _currentPage > 0
                                  ? AppColors.black
                                  : AppColors.black.withOpacity(0.3),
                              size: 20,
                            ),
                          ),
                        ),

                        // Next Arrow
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _currentPage == _onboardingPages.length - 1
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: AppColors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

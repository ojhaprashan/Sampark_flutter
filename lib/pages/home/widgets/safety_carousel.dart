import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';


class SafetyCarousel extends StatefulWidget {
  const SafetyCarousel({super.key});


  @override
  State<SafetyCarousel> createState() => _SafetyCarouselState();
}


class _SafetyCarouselState extends State<SafetyCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;


  final List<String> bannerImages = [
    'assets/Banner/Home/1.png',
    'assets/Banner/Home/2.png',
    'assets/Banner/Home/3.png',
    'assets/Banner/Home/4.png',
    'assets/Banner/Home/5.png',
  ];


  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }


  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }


      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildBannerCard(bannerImages[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 2), // ✅ Minimum gap between image and indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => _buildIndicator(index == _currentPage),
          ),
        ),
      ],
    );
  }


  Widget _buildBannerCard(String imageAsset) {
    return Image.asset(
      imageAsset,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFFFF9E6),
          child: Center(
            child: Icon(
              Icons.image,
              size: 50,
              color: AppColors.activeYellow,
            ),
          ),
        );
      },
    );
  }


  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.black : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

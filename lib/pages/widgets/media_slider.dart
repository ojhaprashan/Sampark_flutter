import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../utils/colors.dart';


class MediaSlider extends StatefulWidget {
  final List<MediaSliderItem> items;
  final double height;
  final bool showIndicators;
  final bool autoScroll;
  final Duration autoScrollDuration;
  final double viewportFraction;
  final bool show3DEffect;


  const MediaSlider({
    super.key,
    required this.items,
    this.height = 400,
    this.showIndicators = true,
    this.autoScroll = true,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.viewportFraction = 0.9,
    this.show3DEffect = true,
  });


  @override
  State<MediaSlider> createState() => _MediaSliderState();
}


class _MediaSliderState extends State<MediaSlider> {
  int _currentIndex = 0;
  late PageController _pageController;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  
  final Map<int, VideoPlayerController?> _videoControllers = {};
  bool _isVideoPlaying = false;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
    );
    if (widget.autoScroll) {
      _startAutoScroll();
    }
  }


  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _videoControllers.forEach((key, controller) {
      controller?.dispose();
    });
    super.dispose();
  }


  void _startAutoScroll() {
    if (!widget.autoScroll) return;
    
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (!_isVideoPlaying && !_isUserInteracting && mounted) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= widget.items.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  void _stopAutoScroll() {
    setState(() {
      _isUserInteracting = true;
    });
    _autoScrollTimer?.cancel();
  }


  void _resumeAutoScroll() {
    setState(() {
      _isUserInteracting = false;
    });
    if (widget.autoScroll) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _startAutoScroll();
      });
    }
  }


  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    _videoControllers.forEach((key, controller) {
      if (key != index) {
        controller?.pause();
      }
    });

    if (widget.items[index].type == MediaSliderType.video) {
      _initializeAndPlayVideo(index);
    } else {
      setState(() {
        _isVideoPlaying = false;
      });
    }
  }


  Future<void> _initializeAndPlayVideo(int index) async {
    if (_videoControllers[index] == null) {
      final controller = VideoPlayerController.asset(widget.items[index].path);
      _videoControllers[index] = controller;

      try {
        await controller.initialize();
        if (mounted) {
          setState(() {});
          controller.play();
          setState(() {
            _isVideoPlaying = true;
          });

          controller.addListener(() {
            if (controller.value.position >= controller.value.duration) {
              setState(() {
                _isVideoPlaying = false;
              });
            }
          });
        }
      } catch (e) {
        debugPrint('Error initializing video: $e');
        setState(() {
          _isVideoPlaying = false;
        });
      }
    } else {
      _videoControllers[index]?.play();
      setState(() {
        _isVideoPlaying = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanCancel: () => _resumeAutoScroll(),
            onPanEnd: (_) => _resumeAutoScroll(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.items.length,
              padEnds: false,
              itemBuilder: (context, index) {
                return widget.show3DEffect
                    ? _build3DSlideItem(index)
                    : _buildSimpleSlideItem(index);
              },
            ),
          ),
        ),
        
        if (widget.showIndicators) ...[
          const SizedBox(height: 16),
          _buildIndicators(),
        ],
      ],
    );
  }


  Widget _build3DSlideItem(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * widget.height,
            child: child,
          ),
        );
      },
      child: _buildSlideContent(index),
    );
  }


  Widget _buildSimpleSlideItem(int index) {
    return _buildSlideContent(index);
  }


 Widget _buildSlideContent(int index) {
  final item = widget.items[index];

  // ✅ Only add horizontal padding when 3D effect is enabled
  return widget.show3DEffect
      ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              child: item.type == MediaSliderType.image
                  ? _buildImageSlide(item)
                  : _buildVideoSlide(index, item),
            ),
          ),
        )
      : Container(
          color: Colors.white, // ✅ White background
          child: item.type == MediaSliderType.image
              ? _buildImageSlide(item)
              : _buildVideoSlide(index, item),
        );
}



  // ✅ CORRECT - Shows FULL image, uses item's boxFit setting
  Widget _buildImageSlide(MediaSliderItem item) {
    return item.isNetworkImage
        ? Image.network(
            item.path,
            fit: item.boxFit, // ✅ Uses the boxFit from MediaSliderItem
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.activeYellow,
                  strokeWidth: 3,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              );
            },
          )
        : Image.asset(
            item.path,
            fit: item.boxFit, // ✅ Uses the boxFit from MediaSliderItem
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              );
            },
          );
  }


  Widget _buildVideoSlide(int index, MediaSliderItem item) {
    final controller = _videoControllers[index];

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (controller.value.isPlaying) {
            controller.pause();
            _isVideoPlaying = false;
          } else {
            controller.play();
            _isVideoPlaying = true;
          }
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),

          if (!controller.value.isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppColors.activeYellow
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}


enum MediaSliderType { image, video }


class MediaSliderItem {
  final MediaSliderType type;
  final String path;
  final String title;
  final bool isNetworkImage;
  final BoxFit boxFit;


  MediaSliderItem({
    required this.type,
    required this.path,
    this.title = '',
    this.isNetworkImage = false,
    this.boxFit = BoxFit.contain, // ✅ Default back to contain
  });


  factory MediaSliderItem.networkImage({
    required String url,
    String title = '',
    BoxFit boxFit = BoxFit.contain, // ✅ Default to contain
  }) {
    return MediaSliderItem(
      type: MediaSliderType.image,
      path: url,
      title: title,
      isNetworkImage: true,
      boxFit: boxFit,
    );
  }


  factory MediaSliderItem.assetImage({
    required String assetPath,
    String title = '',
    BoxFit boxFit = BoxFit.contain, // ✅ Default to contain
  }) {
    return MediaSliderItem(
      type: MediaSliderType.image,
      path: assetPath,
      title: title,
      isNetworkImage: false,
      boxFit: boxFit,
    );
  }


  factory MediaSliderItem.video({
    required String assetPath,
    String title = '',
  }) {
    return MediaSliderItem(
      type: MediaSliderType.video,
      path: assetPath,
      title: title,
      isNetworkImage: false,
    );
  }
}

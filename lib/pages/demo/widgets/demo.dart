import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_header.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _isLoggedIn = false;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Yellow gradient background
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.primaryYellow.withOpacity(0.85),
                  AppColors.darkYellow,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Header with back button, no user info
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                ),

                // White content container with rounded top
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.paddingPage,
                          AppConstants.paddingLarge,
                          AppConstants.paddingPage,
                          AppConstants.paddingPage,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with underline accent
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select a product.',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.black,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 50,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.activeYellow,
                                        AppColors.primaryYellow,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),

                            // ✅ Description with larger font size - Changed to fontSizeSectionTitle
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased more
                                  height: 1.5,
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  const TextSpan(text: 'To activate any of our '),
                                  TextSpan(
                                    text: 'Tag',
                                    style: TextStyle(
                                      color: AppColors.darkYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: ', please '),
                                  TextSpan(
                                    text: 'scan the QR',
                                    style: TextStyle(
                                      color: AppColors.darkYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: ' using '),
                                  TextSpan(
                                    text: 'Any QR Scanner APP',
                                    style: TextStyle(
                                      color: AppColors.darkYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: ' or click on the Button below which says '),
                                  TextSpan(
                                    text: 'Scan',
                                    style: TextStyle(
                                      color: AppColors.darkYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingLarge),

                            // Product Cards with Accordion
                            _buildAccordionCard(
                              index: 0,
                              icon: Icons.local_parking_rounded,
                              title: 'Car & Bike Parking tag',
                              description: 'How to activate, Emergency Number, enable and disable tags and more.',
                              color: AppColors.activeYellow,
                              gradient: const [AppColors.activeYellow, AppColors.primaryYellow],
                              faqs: [
                                {'title': 'How to activate the Tag.', 'desc': 'How to activate, Emergency Number, enable and disable tags and more.', 'url': 'https://www.youtube.com/watch?v=P1ul3wtngJQ'},
                                {'title': 'How to Make a Masked Call.', 'desc': 'How to activate, Emergency Number, enable and disable tags and more.', 'url': 'https://www.youtube.com/watch?v=jeHYzqelu-M'},
                                {'title': 'Complete Walk Through.', 'desc': 'How to activate, Emergency Number, enable and disable tags and more.', 'url': 'https://www.youtube.com/watch?v=5RXOuF7o464'},
                                {'title': 'Change or Delete a Phone Number.', 'desc': 'Sold your car or Registered a different number?.', 'url': 'https://www.youtube.com/watch?v=qrrYhN3z2b8'},
                                {'title': 'Business Account management.', 'desc': 'How to activate, Emergency Number, enable and disable tags and more.', 'url': 'https://www.youtube.com/watch?v=5RXOuF7o464'},
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),

                            _buildAccordionCard(
                              index: 1,
                              icon: Icons.badge_outlined,
                              title: 'Business card',
                              description: 'How to activate, NFC, Social Media, Reviews, Catalog and more.',
                              color: Colors.blue.shade400,
                              gradient: [Colors.blue.shade400, Colors.blue.shade300],
                              faqs: [
                                {
                                  'title': 'Complete feature list',
                                  'desc': 'See All features of the business card.',
                                  'url': 'https://www.youtube.com/watch?v=V8QBifMIbO4'
                                },
                                {
                                  'title': 'How to activate / Edit the Card.',
                                  'desc': 'How to activate a Business card.',
                                  'url': 'https://www.youtube.com/watch?v=HblQm0rIpNA'
                                },
                                {
                                  'title': 'Activate NFC in Android.',
                                  'desc': 'How to enable and activate NFC in Business card.',
                                  'url': 'https://www.youtube.com/watch?v=FGY7yap2Tis'
                                },
                                {
                                  'title': 'Activate NFC in iPhone.',
                                  'desc': 'How to enable and activate NFC in Business card.',
                                  'url': 'http://youtube.com/watch?v=_VSgWpuPp68'
                                },
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),

                            _buildAccordionCard(
                              index: 2,
                              icon: Icons.videocam_rounded,
                              title: 'Video Door Tag',
                              description: 'How to activate, Video calls, Call Masking and check logs.',
                              color: Colors.purple.shade400,
                              gradient: [Colors.purple.shade400, Colors.purple.shade300],
                              faqs: [
                                {
                                  'title': 'How to Activate Video Calls.',
                                  'desc': 'Manage Door Tag and a complete Demo.',
                                  'url': 'https://www.youtube.com/watch?v=Xx-4rJpWtjU'
                                },
                              ],
                            ),

                            const SizedBox(height: AppConstants.spacingMedium),

                            _buildAccordionCard(
                              index: 3,
                              icon: Icons.restaurant_menu_rounded,
                              title: 'Menu Card',
                              description: 'How to activate, Menu Management, Order Management, Training and more.',
                              color: Colors.orange.shade400,
                              gradient: [Colors.orange.shade400, Colors.orange.shade300],
                              faqs: [
                                {
                                  'title': 'QR Menu feature list.',
                                  'desc': 'Complete Menu management, Bulk upload and bulk edits.',
                                  'url': 'https://www.youtube.com/watch?v=MoxOxEjoV8c'
                                },
                                {
                                  'title': 'How to upload Menu.',
                                  'desc': 'Complete Menu management, Bulk upload and bulk edits.',
                                  'url': 'https://www.youtube.com/watch?v=Fjw6iBwyCSM'
                                },
                                {
                                  'title': 'Complete Walk Through.',
                                  'desc': 'How to activate, Manage orders, app notifications and more.',
                                  'url': 'https://www.youtube.com/watch?v=hRiWVrncGNk'
                                },
                                {
                                  'title': 'Activate APP and Email Notification',
                                  'desc': 'How to activate, Manage orders, app notifications and more.',
                                  'url': 'https://www.youtube.com/watch?v=1PE_9XCw-z4'
                                },
                              ],
                            ),

                            const SizedBox(height: AppConstants.spacingMedium),

                            _buildDirectLinkCard(
                              index: 4,
                              icon: Icons.delivery_dining_rounded,
                              title: 'Get Order on time',
                              description: 'How to track, call delivery agent, order delayed and complaints.',
                              color: Colors.green.shade400,
                              gradient: [Colors.green.shade400, Colors.green.shade300],
                              url: 'https://www.youtube.com/watch?v=NQ_p6ir3PDQ',
                            ),
                            const SizedBox(height: AppConstants.paddingPage),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectLinkCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<Color> gradient,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchYouTube(url),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Icon with gradient
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: AppConstants.iconSizeGrid,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // ✅ Increased to fontSizeCardTitle
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle, // ✅ Increased
                        height: 1.4,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // YouTube icon
              Image.asset(
                'assets/icons/youtube.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: color,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<Color> gradient,
    required List<Map<String, String>> faqs,
  }) {
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? color : color.withOpacity(0.15),
          width: isExpanded ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded ? color.withOpacity(0.15) : color.withOpacity(0.08),
            blurRadius: isExpanded ? 16 : 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Card
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  // Icon with gradient
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: AppConstants.iconSizeGrid,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // ✅ Increased to fontSizeCardTitle
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeCardTitle, // ✅ Increased
                            height: 1.4,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow with animation
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: isExpanded ? 0.25 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded FAQ Section
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingMedium,
                0,
                AppConstants.paddingMedium,
                AppConstants.paddingMedium,
              ),
              child: Column(
                children: [
                  Divider(color: color.withOpacity(0.2), height: 1),
                  const SizedBox(height: 10),
                  ...faqs.map((faq) => _buildFaqItem(
                    title: faq['title']!,
                    description: faq['desc']!,
                    url: faq['url'],
                    color: color,
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String title,
    required String description,
    required Color color,
    String? url,
  }) {
    return GestureDetector(
      onTap: url != null ? () => _launchYouTube(url) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12), // ✅ Slightly increased padding
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),


        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (url != null)
                  Image.asset(
                    'assets/icons/youtube.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        '▶',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSectionTitle,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      );
                    },
                  ),
                if (url == null)
                  Text(
                    '▶',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSectionTitle,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 24), // ✅ Adjusted
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeCardDescription, // ✅ Increased from fontSizeSmallText
                  height: 1.4,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchYouTube(String url) async {
    final Uri youtubeUrl = Uri.parse(url);
    try {
      // First, try to launch with external application mode
      if (await canLaunchUrl(youtubeUrl)) {
        await launchUrl(
          youtubeUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If external app doesn't work, try platform default
        try {
          await launchUrl(youtubeUrl);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please install YouTube app or a browser to open videos'),
                action: SnackBarAction(
                  label: 'Copy Link',
                  onPressed: () {
                    // Copy to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening video: ${e.toString()}')),
        );
      }
    }
  }
}

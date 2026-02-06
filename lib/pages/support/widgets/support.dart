import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';
import '../../../services/auth_service.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  bool _isLoggedIn = false;
  String? _selectedTopic;
  final TextEditingController _searchController = TextEditingController();
  List<SupportTopic> _filteredTopics = [];

  final List<SupportTopic> _supportTopics = [
    SupportTopic(
      title: 'How to Activate Car / Bike Tag',
      message: 'Hi, I need help with activating my Car/Bike Tag',
      videoUrl: 'https://youtu.be/your-video-id', // Replace with actual URL
    ),
    SupportTopic(
      title: 'How can we help you ?',
      message: 'Hi, I need support with',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'How to Activate Business Card',
      message: 'Hi, I need help with activating my Business Card',
      videoUrl: 'https://youtu.be/your-video-id',
    ),
    SupportTopic(
      title: 'How to Activate Door Tag',
      message: 'Hi, I need help with activating my Door Tag',
      videoUrl: 'https://youtu.be/your-video-id',
    ),
    SupportTopic(
      title: 'NFC Not found in Phone',
      message: 'Hi, My phone doesn\'t have NFC feature',
      videoUrl: 'https://youtu.be/your-video-id',
    ),
    SupportTopic(
      title: 'How does business card works',
      message: 'Hi, I want to know how business card works',
      videoUrl: 'https://youtu.be/your-video-id',
    ),
    SupportTopic(
      title: 'How does Car Tag works',
      message: 'Hi, I want to know how Car Tag works',
      videoUrl: 'https://youtu.be/your-video-id',
    ),
    SupportTopic(
      title: 'Track Order',
      message: 'Hi, I want to track my order',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'Resell or Business',
      message: 'Hi, I am interested in reselling or business opportunity',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'Order Delayed',
      message: 'Hi, My order is delayed',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'Payment issues',
      message: 'Hi, I am facing payment issues',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'Urgent Help',
      message: 'Hi, I need urgent help',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'Any complains',
      message: 'Hi, I want to register a complaint',
      videoUrl: null,
    ),
    SupportTopic(
      title: 'Talk to Akanksha (My Manager)',
      message: 'Hi, I want to talk to Akanksha',
      videoUrl: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _filteredTopics = _supportTopics;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  void _filterTopics(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTopics = _supportTopics;
      } else {
        _filteredTopics = _supportTopics
            .where((topic) =>
                topic.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _openWhatsApp(String message) async {
    final phoneNumber = '919876543210'; // Replace with your WhatsApp business number
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    
    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Unable to open WhatsApp');
    }
  }

  Future<void> _openVideo(String videoUrl) async {
    final Uri url = Uri.parse(videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Unable to open video');
    }
  }

  void _showSupportOptions(SupportTopic topic) {
    setState(() {
      _selectedTopic = topic.title;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              topic.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Watch Video Button (if available)
            if (topic.videoUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fast Solution (Watch Video)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This is fast and easy solution, in case the issue is still not resolved do write us on WhatsApp.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openVideo(topic.videoUrl!);
                        },
                        icon: Image.asset(
                          'assets/icons/youtube.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.play_circle_outline, size: 20);
                          },
                        ),
                        label: Text('Watch Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.black, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // WhatsApp Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '15 Mins Waiting (WhatsApp us)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Incase of issue not resolved, do write us here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openWhatsApp(topic.message);
                      },
                      icon: Image.asset(
                        'assets/icons/whatsapp.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.chat, size: 20);
                        },
                      ),
                      label: Text('WhatsApp us'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.black, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Working Hours Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Working Hrs:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monday to Saturday, 10 AM to 6 PM.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please do note, We provide support over WhatsApp, Email and Phone. The call line is reserved for Active users and Resellers. For Pre-Sales Questions, we have Great videos and Chat Support.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                // App Header
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                ),

                // Content Area with curved top
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterTopics,
                        decoration: InputDecoration(
                          hintText: 'How can we help you ?',
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.lightGrey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.lightGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.activeYellow,
                              width: 2,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.textGrey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterTopics('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),

                    // Topics List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredTopics.length,
                        itemBuilder: (context, index) {
                          final topic = _filteredTopics[index];
                          final isSelected = _selectedTopic == topic.title;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showSupportOptions(topic),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.activeYellow.withOpacity(0.15)
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.activeYellow
                                          : AppColors.lightGrey,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          topic.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: AppColors.textGrey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Working Hours
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Working Hrs:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      Text(
                                        'Monday to Saturday, 10 AM to 6 PM.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // General Support Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _openWhatsApp('Hi, I need support');
                              },
                              icon: Image.asset(
                                'assets/icons/whatsapp.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.support_agent, size: 20);
                                },
                              ),
                              label: Text(
                                'Sampark us',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.activeYellow,
                                foregroundColor: AppColors.black,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
          )
      ],
      
      ),
    );
  }
}

class SupportTopic {
  final String title;
  final String message;
  final String? videoUrl;

  SupportTopic({
    required this.title,
    required this.message,
    this.videoUrl,
  });
}

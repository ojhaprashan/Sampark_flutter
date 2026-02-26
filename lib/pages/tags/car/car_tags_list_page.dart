import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../widgets/app_header.dart';
import 'car_tag_details_page.dart';

class CarTagsListPage extends StatefulWidget {
  const CarTagsListPage({super.key});

  @override
  State<CarTagsListPage> createState() => _CarTagsListPageState();
}

class _CarTagsListPageState extends State<CarTagsListPage> {
  bool _isLoggedIn = false;
  List<Tag> _carTags = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _countryCode = '+91'; // Default to India

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
      if (loggedIn) {
        // ✅ Load country code
        final userData = await AuthService.getUserData();
        final countryCode = userData['countryCode'] ?? '+91';
        if (mounted) {
          setState(() {
            _countryCode = countryCode;
          });
        }
        // ✅ Only fetch car tags for India users
        if (countryCode == '+91') {
          _fetchCarTags();
        }
      }
    }
  }

  Future<void> _fetchCarTags() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      
      // Remove + from country code and concatenate
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final tags = await TagsService.fetchTagsByCategory(
        type: 'c', // Car type
        phone: phoneWithCountryCode,
        smValue: '67s87s6yys66', // Use your actual sm value
        dgValue: 'testYU78dII8iiUIPSISJ', // Use your actual dg value
      );

      if (mounted) {
        setState(() {
          _carTags = tags.tags;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
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

          SafeArea(
            child: Column(
              children: [
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                  showCartIcon: false,
                ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingLarge),
                          child: Row(
                            children: [
                              Text(
                                'Manage All your Car tags! 🚗',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizePageTitle,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryYellow,
                                    ),
                                  ),
                                )
                              // ✅ Show message for non-India users
                              : _countryCode != '+91'
                                  ? Center(
                                      child: Text(
                                        'Car tags are available only for India',
                                        style: TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                              : _errorMessage.isNotEmpty
                                  ? Center(
                                      child: Text(
                                        _errorMessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : _carTags.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No car tags found',
                                            style: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                AppConstants.paddingLarge,
                                          ),
                                          itemCount: _carTags.length,
                                          itemBuilder: (context, index) {
                                            return _buildCarTagCard(
                                              _carTags[index],
                                            );
                                          },
                                        ),
                        ),
                      ],
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

  Widget _buildCarTagCard(Tag tag) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarTagDetailsPage(tag: tag),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.cardPaddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Main Row - Tag info on left, badges on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Tag ID and Full Tag ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.displayName,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSectionTitle,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tag id: ${tag.tagPublicId}',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardDescription,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // ✅ Right side - Status badges (vertical stack)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ✅ Calls active/disabled badge - Dynamic
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tag.callsEnabled ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag.callsEnabled ? 'Calls active' : 'Calls disabled',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w600,
                              color: tag.callsEnabled ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            tag.callsEnabled ? Icons.phone : Icons.phone_disabled,
                            size: 12,
                            color: tag.callsEnabled ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // ✅ Status badge - Dynamic
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tag.status.toLowerCase() == 'active' 
                            ? Colors.blue.shade50 
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag.status,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w600,
                              color: tag.status.toLowerCase() == 'active' 
                                  ? Colors.blue.shade700 
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            tag.status.toLowerCase() == 'active' ? Icons.play_arrow : Icons.pause,
                            size: 12,
                            color: tag.status.toLowerCase() == 'active' 
                                ? Colors.blue.shade700 
                                : Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

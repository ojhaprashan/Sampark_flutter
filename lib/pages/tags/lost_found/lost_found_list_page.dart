import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../widgets/app_header.dart';
import 'lost_found_details_page.dart';

class LostFoundItem {
  final String id;
  final String tagId;
  final String fullTagId;
  final String status; // 'Active' or 'Paused'
  final bool callsActive;
  final String type; // 'Bike', 'Car', 'Pet', 'Keys', 'Other'

  LostFoundItem({
    required this.id,
    required this.tagId,
    required this.fullTagId,
    required this.status,
    required this.callsActive,
    required this.type,
  });

  factory LostFoundItem.fromTag(Tag tag) {
    return LostFoundItem(
      id: tag.tagInternalId,
      tagId: tag.displayName,
      fullTagId: tag.tagPublicId,
      status: tag.status,
      callsActive: tag.callsEnabled,  // ✅ Use actual callsEnabled from tag
      type: 'Other',
    );
  }
}

class LostFoundListPage extends StatefulWidget {
  const LostFoundListPage({super.key});

  @override
  State<LostFoundListPage> createState() => _LostFoundListPageState();
}

class _LostFoundListPageState extends State<LostFoundListPage> {
  bool _isLoggedIn = false;
  List<LostFoundItem> _items = [];
  bool _isLoading = false;
  String _errorMessage = '';

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
        _fetchLostFoundItems();
      }
    }
  }

  Future<void> _fetchLostFoundItems() async {
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
        type: 'MT', // Lost and Found type
        phone: phoneWithCountryCode,
        smValue: '67s87s6yys66', // Use your actual sm value
        dgValue: 'testYU78dII8iiUIPSISJ', // Use your actual dg value
      );

      if (mounted) {
        setState(() {
          _items = tags.tags.map((tag) => LostFoundItem.fromTag(tag)).toList();
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
                                'Manage All your tags! 🤩',
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
                                  : _items.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No tags found',
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
                                          itemCount: _items.length,
                                          itemBuilder: (context, index) {
                                            return _buildTagCard(
                                              _items[index],
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

  Widget _buildTagCard(LostFoundItem item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LostFoundDetailsPage(item: item),
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
                        item.tagId,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSectionTitle,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tag id: ${item.fullTagId}',
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
                        color: item.callsActive ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.callsActive ? 'Calls active' : 'Calls disabled',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w600,
                              color: item.callsActive ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            item.callsActive ? Icons.phone : Icons.phone_disabled,
                            size: 12,
                            color: item.callsActive ? Colors.green.shade700 : Colors.red.shade700,
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
                        color: item.status.toLowerCase() == 'active' 
                            ? Colors.blue.shade50 
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.status,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w600,
                              color: item.status.toLowerCase() == 'active' 
                                  ? Colors.blue.shade700 
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            item.status.toLowerCase() == 'active' ? Icons.play_arrow : Icons.pause,
                            size: 12,
                            color: item.status.toLowerCase() == 'active' 
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

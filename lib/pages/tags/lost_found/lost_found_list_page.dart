import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../widgets/app_header.dart';
import '../widgets/tag_list_skeleton.dart';
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA), // Professional Off-White Background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingLarge),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.inventory_2, // Perfect icon for lost/found tags
                                  size: AppConstants.iconSizeGrid,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Expanded(
                                child: Text(
                                  'Manage All your tags! 🤩',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: _isLoading
                              ? const TagListSkeleton(itemCount: 5)
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
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                            left: AppConstants.paddingLarge,
                                            right: AppConstants.paddingLarge,
                                            bottom: 30,
                                          ),
                                          itemCount: _items.length,
                                          itemBuilder: (context, index) {
                                            return _buildTagCard(
                                              _items[index],
                                              index, // Pass the index here
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

  Widget _buildTagCard(LostFoundItem item, int index) {
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Index Counter Circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkYellow,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),

            // 2. Tag Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tagId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Ensure title stays on one line
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSectionTitle,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // FittedBox will automatically scale down long text 
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ID: ${item.fullTagId}',
                      maxLines: 1, // Forces it to stay on 1 line
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 3. Status Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Calls Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.callsActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.callsActive ? 'Calls active' : 'Calls disabled',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item.callsActive ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        item.callsActive ? Icons.phone : Icons.phone_disabled,
                        size: 10,
                        color: item.callsActive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.status.toLowerCase() == 'active' 
                        ? Colors.blue.shade50 
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: item.status.toLowerCase() == 'active' 
                              ? Colors.blue.shade700 
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        item.status.toLowerCase() == 'active' ? Icons.play_arrow : Icons.pause,
                        size: 10,
                        color: item.status.toLowerCase() == 'active' 
                            ? Colors.blue.shade700 
                            : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
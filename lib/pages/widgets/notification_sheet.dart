import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/notification_service.dart';

class NotificationSheet extends StatefulWidget {
  final String? tagInternalId;
  final String? phone;

  const NotificationSheet({
    super.key,
    this.tagInternalId,
    this.phone,
  });

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (widget.tagInternalId == null || widget.phone == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Missing tag information';
      });
      return;
    }

    try {
      final response = await NotificationService.fetchNotifications(
        tagInternalId: widget.tagInternalId!,
        phone: widget.phone!,
      );

      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => n.status == 'unread').length;

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      color: AppColors.activeYellow,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizePageTitle,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _unreadCount.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          if (_isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.activeYellow,
                  ),
                ),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Notifications',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSectionTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardDescription,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.activeYellow,
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_notifications.isEmpty)
            Expanded(
              child: _buildEmptyState(),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  color: AppColors.lightGrey.withOpacity(0.5),
                ),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationItem(notification);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final isUnread = notification.status == 'unread';
    
    // Map notification types to icons and colors
    IconData icon = Icons.notifications_active;
    Color iconColor = Colors.blue;

    if (notification.type != null) {
      switch (notification.type) {
        case '0': // Message
          icon = Icons.message_outlined;
          iconColor = const Color(0xFF2196F3);
          break;
        case '1': // Warning/Light
          icon = Icons.warning_outlined;
          iconColor = const Color(0xFFFF9800);
          break;
        case '2': // Info
          icon = Icons.info_outlined;
          iconColor = const Color(0xFF2196F3);
          break;
        case '3': // Call
          icon = Icons.phone_callback;
          iconColor = const Color(0xFF9C27B0);
          break;
        case 'offer':
          icon = Icons.local_offer_outlined;
          iconColor = const Color(0xFFFF9800);
          break;
        case 'activated':
          icon = Icons.verified_outlined;
          iconColor = const Color(0xFF4CAF50);
          break;
        case 'call':
          icon = Icons.phone_callback;
          iconColor = const Color(0xFF9C27B0);
          break;
        case 'order':
          icon = Icons.delivery_dining;
          iconColor = const Color(0xFF2196F3);
          break;
        default:
          icon = Icons.notifications_active;
          iconColor = Colors.blue;
      }
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // Handle notification tap - navigate to relevant screen
        },
        child: Container(
          color: isUnread
              ? AppColors.activeYellow.withOpacity(0.08)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardTitle,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardDescription,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.timestamp,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

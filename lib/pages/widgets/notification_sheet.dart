import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  // Sample notifications - Replace with actual data from API
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'icon': Icons.local_offer_outlined,
      'iconColor': const Color(0xFFFF9800),
      'title': 'Special Offer!',
      'message': 'Get 20% off on Premium Membership. Valid till tomorrow.',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'id': '2',
      'icon': Icons.verified_outlined,
      'iconColor': const Color(0xFF4CAF50),
      'title': 'Tag Activated',
      'message': 'Your parking tag #TAG123 has been successfully activated.',
      'time': '5 hours ago',
      'isRead': false,
    },
    {
      'id': '3',
      'icon': Icons.phone_callback,
      'iconColor': const Color(0xFF9C27B0),
      'title': 'Missed Call Alert',
      'message': 'Someone tried to reach you via your tag. Check details.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'id': '4',
      'icon': Icons.delivery_dining,
      'iconColor': const Color(0xFF2196F3),
      'title': 'Order Shipped',
      'message': 'Your order #ORD456 has been shipped and will arrive soon.',
      'time': '2 days ago',
      'isRead': true,
    },
    {
      'id': '5',
      'icon': Icons.celebration_outlined,
      'iconColor': const Color(0xFFE91E63),
      'title': 'Welcome to Sampark!',
      'message': 'Thank you for joining us. Explore all features now.',
      'time': '3 days ago',
      'isRead': true,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
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
                          '$_unreadCount',
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
                if (_unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.activeYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
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

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isUnread = !notification['isRead'];

    return Dismissible(
      key: Key(notification['id']),
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
        _deleteNotification(notification['id']);
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
          if (isUnread) {
            _markAsRead(notification['id']);
          }
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
                  color: notification['iconColor'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'],
                  size: 24,
                  color: notification['iconColor'],
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
                            notification['title'],
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
                      notification['message'],
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
                      notification['time'],
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

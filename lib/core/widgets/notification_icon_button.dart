import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/presentation/profile/notification_screen/view/notification_screen.dart';
import 'package:monaymanagment/repository/reminder/service/notification_manager.dart';

class NotificationIconButton extends StatefulWidget {
  final Color? iconColor;
  final double? iconSize;
  final bool showBadge;
  final int badgeCount;

  const NotificationIconButton({
    super.key,
    this.iconColor,
    this.iconSize,
    this.showBadge = true,
    this.badgeCount = 0,
  });

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  final NotificationManager _notificationManager = NotificationManager();

  @override
  void initState() {
    super.initState();
    _notificationManager.addListener(_onNotificationManagerChanged);
    if (widget.showBadge) {
      _notificationManager.initialize();
    }
  }

  @override
  void dispose() {
    _notificationManager.removeListener(_onNotificationManagerChanged);
    super.dispose();
  }

  void _onNotificationManagerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = widget.showBadge
        ? _notificationManager.unreadCount
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen()),
        ).then((_) {
          // Mark all notifications as read when returning from notification screen
          if (widget.showBadge) {
            _notificationManager.markAllAsRead();
          }
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            MyFlutterApp.vector__8_,
            color: widget.iconColor ?? Colors.white,
            size: widget.iconSize ?? SizeConstants.font(6),
          ),
          if (widget.showBadge && displayCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(SizeConstants.width(1)),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: BoxConstraints(
                  minWidth: SizeConstants.width(4),
                  minHeight: SizeConstants.width(4),
                ),
                child: Center(
                  child: _notificationManager.isLoading
                      ? SizedBox(
                          width: SizeConstants.width(2),
                          height: SizeConstants.width(2),
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          displayCount > 99 ? '99+' : displayCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConstants.font(2.2),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

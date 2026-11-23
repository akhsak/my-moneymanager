import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/notification_screen/controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return ChangeNotifierProvider(
      create: (context) => NotificationController()..loadNotifications(),
      child: Consumer<NotificationController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: ColorTheme.secondaryColor,
            body: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: ColorTheme.secondaryColor),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConstants.width(5),
                        vertical: SizeConstants.height(2),
                      ),
                      child: Row(
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: ColorTheme.mainColor2,
                              size: SizeConstants.font(4.5),
                            ),
                          ),

                          Spacer(),
                          // Title
                          Expanded(
                            child: Text(
                              'Notification',
                              textAlign: TextAlign.center,
                              style: TextStyles.bodyText(
                                color: ColorTheme.mainColor2,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Notification List with rounded top corners
                Expanded(
                  child: Container(
                    //margin: EdgeInsets.only(top: SizeConstants.height(1)),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF9F3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: RefreshIndicator(
                      onRefresh: () => controller.refreshNotifications(),
                      child:
                          controller.isLoading &&
                              controller.notificationGroups.isEmpty
                          ? _buildLoadingState()
                          : controller.errorMessage != null &&
                                controller.notificationGroups.isEmpty
                          ? _buildErrorState(
                              controller.errorMessage!,
                              controller,
                            )
                          : _buildNotificationList(controller),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationItem notification,
    int groupIndex,
    int notificationIndex,
    NotificationController controller,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Mark notification as read when tapped
            // Note: We need the reminder ID to mark it as read
            // For now, we'll mark all as read when returning from screen
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConstants.width(3),
              vertical: SizeConstants.height(1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: SizeConstants.width(7),
                  height: SizeConstants.width(7),
                  decoration: BoxDecoration(
                    color: notification.iconColor,
                    borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                  ),
                  child: Icon(
                    notification.icon,
                    color: Colors.white,
                    size: SizeConstants.font(3),
                  ),
                ),

                SizedBox(width: SizeConstants.width(2.5)),

                // Contenß
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.title,
                        style: TextStyles.bodyText(
                          color: const Color(0xFF082C2C),
                          size: SizeConstants.font(3),
                          weight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: SizeConstants.height(0.3)),

                      // Description
                      Text(
                        notification.description,
                        style: TextStyles.smallText(
                          color: const Color(0xFF082C2C),
                          size: SizeConstants.font(2.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (notification.timestamp.isNotEmpty) ...[
                        SizedBox(height: SizeConstants.height(1)),
                        // Timestamp
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            notification.timestamp,
                            style: TextStyles.smallText(
                              color: const Color(0xFF1E66FF),
                              size: SizeConstants.font(2.5),
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Separator line (except for the last item in each group)
        if (notificationIndex <
            controller.notificationGroups[groupIndex].notifications.length - 1)
          Container(
            margin: EdgeInsets.symmetric(horizontal: SizeConstants.width(4)),
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorTheme.secondaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: SizeConstants.height(2)),
          Text(
            'Loading notifications...',
            style: TextStyles.smallText(
              color: const Color(0xFF082C2C),
              size: SizeConstants.font(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, NotificationController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeConstants.width(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: SizeConstants.width(15),
              color: Colors.red,
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'Failed to load notifications',
              style: TextStyles.bodyText(
                color: const Color(0xFF082C2C),
                size: SizeConstants.font(4),
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              error,
              style: TextStyles.smallText(
                color: Colors.red,
                size: SizeConstants.font(3.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConstants.height(3)),
            ElevatedButton(
              onPressed: () => controller.loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyles.buttonText(
                  color: Colors.white,
                  size: SizeConstants.font(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(NotificationController controller) {
    if (controller.notificationGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MyFlutterApp.vector__8_,
              size: SizeConstants.width(20),
              color: Colors.grey,
            ),
            SizedBox(height: SizeConstants.height(2)),
            Text(
              'No notifications yet',
              style: TextStyles.smallText(
                color: const Color(0xFF082C2C),
                size: SizeConstants.font(3),
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConstants.height(1)),
            Text(
              'Your notifications will appear here',
              style: TextStyles.smallText(
                color: Colors.grey[600],
                size: SizeConstants.font(3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeConstants.width(4)),
      itemCount:
          controller.notificationGroups.length +
          (controller.hasMoreData ? 1 : 0),
      itemBuilder: (context, groupIndex) {
        // Show load more button if there's more data
        if (groupIndex == controller.notificationGroups.length) {
          return _buildLoadMoreButton(controller);
        }

        final group = controller.notificationGroups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Title
            Padding(
              padding: EdgeInsets.only(
                left: SizeConstants.width(2),
                //bottom: SizeConstants.height(1.5),
                top: groupIndex == 0
                    ? SizeConstants.height(2)
                    : SizeConstants.height(3),
              ),
              child: Text(
                group.title,
                style: TextStyles.bodyText(
                  color: const Color(0xFF082C2C),
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.bold,
                ),
              ),
            ),

            // Notifications in Group
            ...group.notifications.asMap().entries.map((entry) {
              final notificationIndex = entry.key;
              final notification = entry.value;
              return _buildNotificationItem(
                notification,
                groupIndex,
                notificationIndex,
                controller,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildLoadMoreButton(NotificationController controller) {
    return Container(
      padding: EdgeInsets.all(SizeConstants.width(4)),
      child: controller.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ColorTheme.secondaryColor,
                strokeWidth: 2,
              ),
            )
          : ElevatedButton(
              onPressed: () => controller.loadMoreNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConstants.width(2)),
                ),
                minimumSize: Size(double.infinity, SizeConstants.height(5)),
              ),
              child: Text(
                'Load More',
                style: TextStyles.buttonText(
                  color: Colors.white,
                  size: SizeConstants.font(3),
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';
import 'package:monaymanagment/repository/auth/services/auth_service.dart';
import 'package:monaymanagment/repository/auth/model/user_model.dart';
import 'package:monaymanagment/presentation/profile/profile_screen/view/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showProfileAvatar;
  final bool showBackButton;
  final bool showNotification;
  final String? profileImageUrl;
  final VoidCallback? onBackPressed;
  final List<Widget>? customActions;

  const CustomAppBar({
    super.key,
    this.title,
    this.showProfileAvatar = false,
    this.showBackButton = true,
    this.showNotification = true,
    this.profileImageUrl,
    this.onBackPressed,
    this.customActions,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorTheme.secondaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      centerTitle: title != null,
      title: title != null
          ? Text(
              title!,
              style: TextStyles.bodyText(
                color: Colors.white,
                size: SizeConstants.font(4.2),
                weight: FontWeight.bold,
              ),
            )
          : null,
      actions: _buildActions(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showProfileAvatar) {
      return Padding(
        padding: EdgeInsets.only(left: SizeConstants.width(3)),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Container(
            width: SizeConstants.width(10),
            height: SizeConstants.width(10),
            margin: EdgeInsets.symmetric(vertical: SizeConstants.height(1)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FutureBuilder<User?>(
              future: profileImageUrl != null
                  ? Future.value(null)
                  : AuthService().getStoredUser(),
              builder: (context, snapshot) {
                final fallbackUrl = snapshot.data?.profilePhoto;
                final urlToUse = profileImageUrl ?? fallbackUrl;
                return CircleAvatar(
                  radius: SizeConstants.width(5),
                  backgroundColor: Colors.white,
                  backgroundImage: (urlToUse != null && urlToUse.isNotEmpty)
                      ? NetworkImage(urlToUse)
                      : null,
                  child: (urlToUse == null || urlToUse.isEmpty)
                      ? Icon(
                          Icons.person,
                          color: ColorTheme.primaryColor,
                          size: SizeConstants.font(5),
                        )
                      : null,
                );
              },
            ),
          ),
        ),
      );
    } else if (showBackButton) {
      return IconButton(
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: SizeConstants.width(3.5),
        ),
      );
    }
    return null;
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> actions = [];

    if (showNotification) {
      actions.add(
        NotificationIconButton(
          iconColor: Colors.white,
          iconSize: SizeConstants.font(6),
          showBadge: true,
          badgeCount: 5,
        ),
      );
      actions.add(SizedBox(width: SizeConstants.width(2)));
    }

    if (customActions != null) {
      actions.addAll(customActions!);
    }

    return actions;
  }
}

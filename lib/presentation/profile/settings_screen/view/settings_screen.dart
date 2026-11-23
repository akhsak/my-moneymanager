import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:monaymanagment/presentation/profile/delete_account_screen/view/delete_account_screen.dart';
import 'package:monaymanagment/presentation/profile/notification_settings_screen/view/notification_settings_screen.dart';
import 'package:monaymanagment/presentation/profile/password_settings_screen/view/password_settings_screen.dart';
import 'package:monaymanagment/presentation/profile/Privacy_policy_screen/view/privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);

    return Scaffold(
      backgroundColor: ColorTheme.secondaryColor,
      appBar: CustomAppBar(
        title: 'Settings',
        showProfileAvatar: false,
        showBackButton: true,
        showNotification: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F8F0), // Light green background matching image
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConstants.width(5)),
          child: Column(
            children: [
              SizedBox(height: SizeConstants.height(1.5)),

              // Settings Options
              _buildSettingsOption(
                context: context,
                icon: MyFlutterApp.vector__8_,
                title: 'Notification Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: SizeConstants.height(1.5)),

              _buildSettingsOption(
                context: context,
                icon: Icons.lock_outline,
                title: 'Password Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordSettingsScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: SizeConstants.height(1.5)),

              _buildSettingsOption(
                context: context,
                icon: Icons.person_remove_outlined,
                title: 'Delete Account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteAccountScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: SizeConstants.height(1.5)),

              _buildSettingsOption(
                context: context,
                icon: Icons.person_remove_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              // Spacer to push content to top
              // Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConstants.width(4),
          vertical: SizeConstants.height(2),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConstants.width(3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: SizeConstants.width(10),
              height: SizeConstants.width(10),
              decoration: BoxDecoration(
                color: ColorTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: SizeConstants.font(4.5),
              ),
            ),

            SizedBox(width: SizeConstants.width(3.5)),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyles.bodyText(
                  color: ColorTheme.mainColor,
                  size: SizeConstants.font(3.5),
                  weight: FontWeight.w500,
                ),
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: ColorTheme.mainColor,
              size: SizeConstants.font(3),
            ),
          ],
        ),
      ),
    );
  }
}

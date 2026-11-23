import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/profile_screen/controller/profile_controller.dart';
import 'package:monaymanagment/core/widgets/notification_icon_button.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            NotificationIconButton(
              iconColor: Colors.white,
              iconSize: SizeConstants.font(6),
              showBadge: true,
              badgeCount: 5,
            ),
            SizedBox(width: SizeConstants.width(2)),
          ],
        ),
        body: Consumer<ProfileController>(
          builder: (context, controller, _) {
            return SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.refreshProfile,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorTheme.secondaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 15),

                              // Profile Picture
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: (controller.profileImageUrl.isNotEmpty)
                                      ? Image.network(
                                          controller.profileImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: SizeConstants.width(
                                                      12,
                                                    ),
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            size: 45,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // User Name
                              Text(
                                controller.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              // User Email
                              Text(
                                controller.userEmail.isNotEmpty
                                    ? controller.userEmail
                                    : 'Loading...',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 5),

                              if (controller.isGuestMode)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Text(
                                    'Guest mode – login for full access',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              if (controller.isGuestMode)
                                const SizedBox(height: 5),

                              // User Phone (if available)
                              if (controller.userPhone.isNotEmpty)
                                // Text(
                                //   controller.userPhone,
                                //   style: const TextStyle(
                                //     color: Colors.white70,
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.w400,
                                //   ),
                                // ),
                                const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),

                      // Menu Items Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: controller
                                .getMenuItems(context)
                                .map((item) => _buildMenuItem(item))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(ProfileMenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: item.onTap,
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: ColorTheme.secondaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: Colors.white, size: 22),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/edit_profile_screen/controller/edit_profle_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Widget _buildAvatarPlaceholder({Key? key}) {
    return SizedBox.expand(
      key: key,
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15)),
        alignment: Alignment.center,
        child: Icon(
          Icons.person,
          size: SizeConstants.width(12),
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(EditProfileController controller) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;

    final ok = await controller.uploadProfilePhoto(file.path);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile photo updated'),
          backgroundColor: ColorTheme.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (_) => EditProfileController(),
      child: Consumer<EditProfileController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: ColorTheme.secondaryColor,
            appBar: CustomAppBar(
              title: 'Edit My Profile',
              showBackButton: true,
              showNotification: true,
            ),
            body: controller.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: ColorTheme.mainColor2,
                    ),
                  )
                : RefreshIndicator(
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
                              padding: EdgeInsets.all(SizeConstants.width(5)),
                              child: Column(
                                children: [
                                  SizedBox(height: SizeConstants.height(2.5)),

                                  // Profile Picture with Camera Icon
                                  Stack(
                                    children: [
                                      Container(
                                        width: SizeConstants.width(25),
                                        height: SizeConstants.width(25),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: ColorTheme.mainColor2,
                                            width: 4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorTheme.mainColor
                                                  .withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            child:
                                                controller
                                                    .profileImageUrl
                                                    .isNotEmpty
                                                ? SizedBox.expand(
                                                    key: ValueKey(
                                                      controller
                                                          .profileImageUrl,
                                                    ),
                                                    child: Image.network(
                                                      controller
                                                          .profileImageUrl,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            progress,
                                                          ) {
                                                            if (progress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return _buildAvatarPlaceholder(
                                                              key: const ValueKey(
                                                                'profile-image-loading',
                                                              ),
                                                            );
                                                          },
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return _buildAvatarPlaceholder(
                                                              key: const ValueKey(
                                                                'profile-image-error',
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  )
                                                : _buildAvatarPlaceholder(
                                                    key: const ValueKey(
                                                      'profile-image-placeholder',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: controller.isUpdating
                                              ? null
                                              : () async {
                                                  await _pickAndUploadPhoto(
                                                    controller,
                                                  );
                                                },
                                          borderRadius: BorderRadius.circular(
                                            SizeConstants.width(4),
                                          ),
                                          child: Container(
                                            width: SizeConstants.width(8),
                                            height: SizeConstants.width(8),
                                            decoration: BoxDecoration(
                                              color: ColorTheme.secondaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: ColorTheme.mainColor2,
                                              size: SizeConstants.font(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: SizeConstants.height(2)),

                                  // User Name
                                  Text(
                                    controller.userName,
                                    style: TextStyles.bodyText(
                                      color: ColorTheme.mainColor2,
                                      size: SizeConstants.font(4),
                                      weight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: SizeConstants.height(0.5)),

                                  // User Email
                                  Text(
                                    controller.email.isNotEmpty
                                        ? controller.email
                                        : 'Loading...',
                                    style: TextStyles.smallText(
                                      color: ColorTheme.mainColor2,
                                      size: SizeConstants.font(3.5),
                                      weight: FontWeight.w500,
                                    ),
                                  ),

                                  SizedBox(height: SizeConstants.height(1.5)),

                                  // Remove Photo button (if photo exists)
                                  if (controller.profileImageUrl.isNotEmpty)
                                    TextButton(
                                      onPressed: controller.isUpdating
                                          ? null
                                          : () async {
                                              final ok = await controller
                                                  .deleteProfilePhoto();
                                              if (ok) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Profile photo removed',
                                                    ),
                                                    backgroundColor:
                                                        ColorTheme.green,
                                                  ),
                                                );
                                              }
                                            },
                                      child: Text(
                                        'Remove Photo',
                                        style: TextStyles.smallText(
                                          color: ColorTheme.mainColor,
                                          size: SizeConstants.font(3.2),
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Form Section
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(SizeConstants.width(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Account Settings Title
                                  Text(
                                    'Account Settings',
                                    style: TextStyles.bodyText(
                                      size: SizeConstants.font(4),
                                      weight: FontWeight.bold,
                                      color: ColorTheme.mainColor,
                                    ),
                                  ),

                                  SizedBox(height: SizeConstants.height(2.5)),

                                  // Username Field
                                  _buildInputField(
                                    label: 'Username',
                                    controller: controller.usernameController,
                                  ),

                                  SizedBox(height: SizeConstants.height(2)),

                                  // Phone Field
                                  _buildInputField(
                                    label: 'Phone',
                                    hintText: 'Enter your phone number',
                                    controller: controller.phoneController,
                                  ),

                                  SizedBox(height: SizeConstants.height(2)),

                                  // Email Field
                                  _buildInputField(
                                    label: 'Email Address',
                                    controller: controller.emailController,
                                  ),

                                  SizedBox(height: SizeConstants.height(3)),

                                  // Push Notifications Toggle
                                  // _buildToggleRow(
                                  //   label: 'Push Notifications',
                                  //   value: controller.pushNotifications,
                                  //   onChanged: controller.togglePushNotifications,
                                  // ),

                                  //SizedBox(height: SizeConstants.height(2)),

                                  // Dark Theme Toggle
                                  // _buildToggleRow(
                                  //   label: 'Turn Dark Theme',
                                  //   value: controller.darkTheme,
                                  //   onChanged: (value) => controller.toggleDarkTheme(),
                                  // ),
                                  SizedBox(height: SizeConstants.height(2)),

                                  // Error Message
                                  Builder(
                                    builder: (context) {
                                      final errorMessage =
                                          controller.errorMessage;
                                      if (errorMessage == null) {
                                        return const SizedBox.shrink();
                                      }
                                      debugPrint(
                                        'EditProfileScreen error: $errorMessage',
                                      );
                                      return Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(
                                          SizeConstants.width(3),
                                        ),
                                        margin: EdgeInsets.only(
                                          bottom: SizeConstants.height(2),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            SizeConstants.width(2),
                                          ),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: SizeConstants.font(3.5),
                                            ),
                                            SizedBox(
                                              width: SizeConstants.width(2),
                                            ),
                                            Expanded(
                                              child: Text(
                                                errorMessage,
                                                style: TextStyles.smallText(
                                                  color: Colors.red,
                                                  size: SizeConstants.font(3),
                                                  weight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  // Update Profile Button
                                  Center(
                                    child: SizedBox(
                                      width: SizeConstants.width(60),
                                      height: SizeConstants.height(5),
                                      child: ElevatedButton(
                                        onPressed: controller.isUpdating
                                            ? null
                                            : () async {
                                                final success = await controller
                                                    .updateProfile();
                                                if (success) {
                                                  // Show success message
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Profile updated successfully!',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                  Navigator.pop(
                                                    context,
                                                    true,
                                                  ); // Return true to indicate success
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ColorTheme.secondaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: controller.isUpdating
                                            ? SizedBox(
                                                width: SizeConstants.width(5),
                                                height: SizeConstants.width(5),
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'Update Profile',
                                                style: TextStyles.buttonText(
                                                  color: Colors.white,
                                                  size: SizeConstants.font(3.2),
                                                  weight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: SizeConstants.height(20)),
                                ],
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
    );
  }

  Widget _buildInputField({
    required String label,
    String? hintText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.smallText(
            size: SizeConstants.font(3.2),
            weight: FontWeight.w500,
            color: ColorTheme.mainColor,
          ),
        ),
        SizedBox(height: SizeConstants.height(1)),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: TextStyles.smallText(
              size: SizeConstants.font(3.5),
              color: ColorTheme.mainColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: SizeConstants.font(3.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConstants.width(4),
                vertical: SizeConstants.height(1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildToggleRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.smallText(
            size: SizeConstants.font(3.5),
            weight: FontWeight.w500,
            color: ColorTheme.mainColor,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ColorTheme.secondaryColor,
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[300],
        ),
      ],
    );
  }
}

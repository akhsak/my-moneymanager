import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/welcome/change_password_done_screen/view/change_password_done_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/welcome/change_password_screen/controller/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (context) => ChangePasswordController(),
      child: Consumer<ChangePasswordController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.arrow_back_ios, color: ColorTheme.mainColor2, size: SizeConstants.width(3.5))),
              backgroundColor: ColorTheme.secondaryColor,
            ),
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorTheme.secondaryColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConstants.height(8),
                      horizontal: SizeConstants.width(6),
                    ),
                    child: Text(
                      'New Password',
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyText(
                        color: ColorTheme.mainColor2,
                        size: SizeConstants.font(6),
                        weight: FontWeight.normal
                      ),
                    ),
                  ),
                  
                  // Main Content Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8F7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(SizeConstants.width(8)),
                          topRight: Radius.circular(SizeConstants.width(8)),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConstants.width(6),
                          vertical: SizeConstants.height(4),
                        ),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Change Password Title
                              Text(
                                'Change Password?',
                                style: TextStyles.bodyText(
                                  color: ColorTheme.mainColor,
                                  weight: FontWeight.bold,
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(2)),
                              
                              // Description Text
                              Text(
                                'Enter your new password and confirm it to update your account security.',
                                style: TextStyles.smallText(
                                  color: ColorTheme.mainColor,
                                  size: SizeConstants.font(3.5),
                                  weight: FontWeight.w400,
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(4)),
                              
                              // New Password Input Field
                              Text(
                                'New Password',
                                style: TextStyles.smallText(
                                  color: ColorTheme.mainColor,
                                  size: SizeConstants.font(3.5),
                                  weight: FontWeight.w500,
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(1)),
                              
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F8F7),
                                  borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                                  border: Border.all(
                                    color: ColorTheme.mainColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: controller.newPasswordController,
                                  obscureText: !controller.isNewPasswordVisible,
                                  validator: controller.validateNewPassword,
                                  decoration: InputDecoration(
                                    hintText: 'Enter new password',
                                    hintStyle: TextStyles.smallText(
                                      color: ColorTheme.mainColor.withOpacity(0.5),
                                      size: SizeConstants.font(3.5),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: SizeConstants.width(4),
                                      vertical: SizeConstants.height(2),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey[600],
                                        size: SizeConstants.font(5),
                                      ),
                                      onPressed: controller.toggleNewPasswordVisibility,
                                    ),
                                  ),
                                  style: TextStyles.smallText(
                                    color: ColorTheme.mainColor,
                                    size: SizeConstants.font(3.5),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(4)),
                              
                              // Confirm Password Input Field
                              Text(
                                'Confirm New Password',
                                style: TextStyles.smallText(
                                  color: ColorTheme.mainColor,
                                  size: SizeConstants.font(3.5),
                                  weight: FontWeight.w500,
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(1)),
                              
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F8F7),
                                  borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                                  border: Border.all(
                                    color: ColorTheme.mainColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: controller.confirmPasswordController,
                                  obscureText: !controller.isConfirmPasswordVisible,
                                  validator: controller.validateConfirmPassword,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm new password',
                                    hintStyle: TextStyles.smallText(
                                      color: ColorTheme.mainColor.withOpacity(0.5),
                                      size: SizeConstants.font(3.5),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: SizeConstants.width(4),
                                      vertical: SizeConstants.height(2),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey[600],
                                        size: SizeConstants.font(5),
                                      ),
                                      onPressed: controller.toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                  style: TextStyles.smallText(
                                    color: ColorTheme.mainColor,
                                    size: SizeConstants.font(3.5),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(4)),
                              
                              // Change Password Button
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorTheme.secondaryColor,
                                      foregroundColor: ColorTheme.mainColor2,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeConstants.height(2.5),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(SizeConstants.width(4)),
                                      ),
                                    ),
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordDoneScreen()));
                                    },
                                    child: controller.isLoading
                                        ? SizedBox(
                                            width: SizeConstants.width(5),
                                            height: SizeConstants.width(5),
                                            child: CircularProgressIndicator(
                                              color: ColorTheme.mainColor2,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Change Password',
                                            style: TextStyles.buttonText(
                                              color: ColorTheme.mainColor2,
                                              size: SizeConstants.font(4.5),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: SizeConstants.height(3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

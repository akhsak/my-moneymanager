import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:monaymanagment/presentation/guest_db/guest_mode_controller.dart';
import 'package:monaymanagment/repository/theme_service.dart';
import 'package:provider/provider.dart';

import 'package:monaymanagment/core/services/guest_storage_service.dart';
import 'package:monaymanagment/presentation/analysis/analysis_screen/controller/analysis_controller.dart';
import 'package:monaymanagment/presentation/analysis/calender_screen/controller/calender_controller.dart';
import 'package:monaymanagment/presentation/categories/category_screen/controller/category_controller.dart';
import 'package:monaymanagment/presentation/categories/category_wise_expense_list_screen/controller/category_wise_list_controller.dart';
import 'package:monaymanagment/presentation/welcome/change_password_done_screen/controller/change_password_done_controller.dart';
import 'package:monaymanagment/presentation/welcome/change_password_screen/controller/change_password_controller.dart';
import 'package:monaymanagment/presentation/profile/delete_account_screen/controller/delete_account_controller.dart';
import 'package:monaymanagment/presentation/profile/edit_profile_screen/controller/edit_profle_controller.dart';
import 'package:monaymanagment/presentation/add_transaction/expense_adding_screen/controller/expense_adding_controller.dart';
import 'package:monaymanagment/presentation/welcome/forgot_password/controller/forgot_password_controller.dart';
import 'package:monaymanagment/presentation/home/home_screen/controller/home_controller.dart';
import 'package:monaymanagment/presentation/profile/notification_screen/controller/notification_controller.dart';
import 'package:monaymanagment/presentation/profile/notification_settings_screen/controller/notification_settings_controller.dart';
import 'package:monaymanagment/presentation/profile/otp_screen/controller/otp_controller.dart';
import 'package:monaymanagment/presentation/profile/pin_chanage_screen/controller/pin_change_controller.dart';
import 'package:monaymanagment/presentation/home/quick_analysis_screen/controller/qucik_analysis_controller.dart';
import 'package:monaymanagment/presentation/categories/saving_category_screen/controller/savings_controller.dart';
import 'package:monaymanagment/presentation/categories/savings_category_list_screen/controller/savings_category_list_controller.dart';
import 'package:monaymanagment/presentation/analysis/search_screen/controller/search_controller.dart'
    as search_controller;
import 'package:monaymanagment/presentation/welcome/splash_screen/view/splash_screen.dart';
import 'package:monaymanagment/presentation/transaction/transaction_screen/controller/transaction_controller.dart';
import 'package:monaymanagment/presentation/welcome/login_screen/controller/login_screen_controller.dart';
import 'package:monaymanagment/presentation/welcome/sign_up_screen.dart/controller/sign_up_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await GuestStorageService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of  application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => LoginScreenController(),
              ),
              ChangeNotifierProvider(create: (context) => SignUpController()),
              ChangeNotifierProvider(
                create: (context) => ForgotPasswordController(),
              ),
              ChangeNotifierProvider(create: (context) => OtpController()),
              ChangeNotifierProvider(
                create: (context) => ChangePasswordController(),
              ),
              ChangeNotifierProvider(
                create: (context) => ChangePasswordDoneController(),
              ),
              ChangeNotifierProvider(create: (context) => HomeController()),
              ChangeNotifierProvider(
                create: (context) => NotificationController(),
              ),
              ChangeNotifierProvider(
                create: (context) => QuickAnalysisController(),
              ),
              ChangeNotifierProvider(
                create: (context) => TransactionController(),
              ),
              ChangeNotifierProvider(create: (context) => AnalysisController()),
              ChangeNotifierProvider(
                create: (context) => GuestModeController(),
              ),
              ChangeNotifierProvider(
                create: (context) => search_controller.SearchController(),
              ),
              ChangeNotifierProvider(create: (context) => CalenderController()),
              ChangeNotifierProvider(create: (context) => CategoryController()),
              ChangeNotifierProvider(
                create: (context) =>
                    CategoryWiseListController(category: 'Food'),
              ),
              ChangeNotifierProvider(
                create: (context) => ExpenseAddingController(),
              ),
              ChangeNotifierProvider(
                create: (context) => SavingsCategoryListController(),
              ),
              ChangeNotifierProvider(create: (context) => SavingsController()),
              ChangeNotifierProvider(
                create: (context) => EditProfileController(),
              ),
              //ChangeNotifierProvider(create: (context) => ProfileController()),
              ChangeNotifierProvider(
                create: (context) => NotificationSettingsController(),
              ),
              ChangeNotifierProvider(
                create: (context) => PinChangeController(),
              ),
              // ChangeNotifierProvider(create: (context) => PrivacyPolicyController()),
              ChangeNotifierProvider(
                create: (context) => DeleteAccountController(),
              ),

              // ChangeNotifierProvider(create: (context) => SecurityController()),
              // CategoryWiseListController is creat  ed per screen with selected category
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeService.lightTheme,
              darkTheme: themeService.darkTheme,
              themeMode: themeService.isDarkTheme
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: SplashScreen(),
              //home: BottomNavigationScreen(),
            ),
          );
        },
      ),
    );
  }
}

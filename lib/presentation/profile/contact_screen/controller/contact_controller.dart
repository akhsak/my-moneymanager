import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/profile/online_support_screen/view/online_support_screen.dart';

class ContactController extends ChangeNotifier {
  void navigateToCustomerService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnlineSupportScreen()),
    );
  }

  void openWebsite() {
    // Implement website opening logic
    print('Opening website...');
  }

  void openFacebook() {
    // Implement Facebook opening logic
    print('Opening Facebook...');
  }

  void openWhatsApp() {
    // Implement WhatsApp opening logic
    print('Opening WhatsApp...');
  }

  void openInstagram() {
    // Implement Instagram opening logic
    print('Opening Instagram...');
  }
}

import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/profile/pin_chanage_screen/view/pin_change_screen.dart';
import 'package:monaymanagment/presentation/profile/Privacy_policy_screen/view/privacy_policy_screen.dart';

class SecurityItem {
  final String title;
  final VoidCallback onTap;
  SecurityItem({required this.title, required this.onTap});
}

class SecurityController {
  List<SecurityItem> buildItems(BuildContext context) {
    return [
      SecurityItem(title: 'Change Pin', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PinChangeScreen()));
      }),
      SecurityItem(title: 'Terms And Conditions', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
      }),
    ];
  }
}

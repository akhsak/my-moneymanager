import 'package:flutter/material.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/icons.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';
import 'package:monaymanagment/core/constants/text_styles.dart';
import 'package:monaymanagment/presentation/profile/notification_screen/view/notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:monaymanagment/presentation/profile/Privacy_policy_screen/controller/Privacy_policy_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConstants.init(context);
    return ChangeNotifierProvider(
      create: (_) => PrivacyPolicyController(),
      child: Scaffold(
        backgroundColor: ColorTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.secondaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: SizeConstants.width(3.5),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Privacy Policy',
            style: TextStyles.bodyText(
              color: Colors.white,
              size: SizeConstants.font(4.5),
              weight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              icon: Icon(
                MyFlutterApp.vector__8_,
                color: Colors.white,
                size: SizeConstants.width(4.5),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F8F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(SizeConstants.width(5)),
            child: Consumer<PrivacyPolicyController>(
              builder: (context, controller, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConstants.height(2)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Info
                            Text(
                              'Last Updated: [01-11-2025]',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(2.8),
                                color: ColorTheme.mainColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(0.5)),
                            Text(
                              'App Name: Finuara',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(2.8),
                                color: ColorTheme.mainColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(0.5)),
                            Text(
                              'Email: support@finuara.com',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(2.8),
                                color: ColorTheme.mainColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Introduction
                            Text(
                              'This Privacy Policy describes how Finuara ("we," "our," or "us") collects, uses, and protects your information when you use our mobile and web applications. By creating an account or using Finuara, you agree to this Privacy Policy.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 1
                            Text(
                              '1. Information We Collect',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1.5)),

                            // Section 1a
                            Text(
                              'a. Personal Information',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.4),
                                weight: FontWeight.w600,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'When you register or log in to Finuara, we may collect:',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            _bulletedList([
                              'Name',
                              'Email address',
                              'Phone number (if applicable)',
                              'Login credentials (encrypted)',
                            ]),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'This information is used solely to create and manage your account and provide access to both web and mobile versions of Finuara.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(2)),

                            // Section 1b
                            Text(
                              'b. Financial & Transaction Data',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.4),
                                weight: FontWeight.w600,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'When using Finuara to record or manage your finances, we collect:',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            _bulletedList([
                              'Transaction details (amount, category, date, notes)',
                              'Budget and expense data',
                              'Wallet or account names (entered by you manually)',
                            ]),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'All such data is securely stored in our cloud database to ensure your information is available across devices (web and app).',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'We **do not** access or link to your real bank accounts unless explicitly integrated by you in the future, with your consent.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(2)),

                            // Section 1c
                            Text(
                              'c. Device & Usage Information',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.4),
                                weight: FontWeight.w600,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'We may collect non-personal data such as:',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            _bulletedList([
                              'Device type, operating system, and version',
                              'App version and crash logs',
                              'Browser type and IP address (for web users)',
                              'Time and frequency of app usage',
                            ]),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'This information helps us improve performance, troubleshoot issues, and enhance the user experience.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(2)),

                            // Section 1d
                            Text(
                              'd. Cookies & Web Data',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.4),
                                weight: FontWeight.w600,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'Our web platform may use cookies or similar technologies to:',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            _bulletedList([
                              'Maintain your login session',
                              'Remember your preferences',
                              'Improve overall service usability',
                            ]),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'You can manage cookie settings in your browser at any time.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 2
                            Text(
                              '2. How We Use the Information',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'We use collected data to:',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            _bulletedList([
                              'Provide secure login and synchronization across devices',
                              'Maintain accurate financial tracking and backups',
                              'Respond to customer inquiries or support requests',
                              'Improve app functionality and user experience',
                              'Communicate important updates or security notifications',
                            ]),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'We do **not** sell, rent, or share your personal information with third parties for marketing or advertising.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 3
                            Text(
                              '3. Data Storage & Security',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'Your data is encrypted and securely stored on our cloud servers. We use industry-standard encryption protocols (e.g., SSL/TLS) to protect data transmission.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'While we take all reasonable steps to secure your data, you are responsible for maintaining the confidentiality of your account credentials.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 4
                            Text(
                              '4. Data Retention & Deletion',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'You may request deletion of your account and associated data at any time by contacting us. Upon request, we will permanently delete your information from our servers in accordance with applicable data protection laws.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 5
                            Text(
                              '5. Third-Party Services',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'We may use third-party analytics and crash reporting tools (e.g., Google Firebase, Crashlytics) to help identify app performance issues. These tools may collect anonymized technical data but **never** include your personal or financial information.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 6
                            Text(
                              '6. Children\'s Privacy',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'Finuara is intended for use by individuals aged **18 and above**. We do not knowingly collect or store data from children under 18 years of age.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 7
                            Text(
                              '7. Policy Updates',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'We may update this Privacy Policy periodically. The updated version will be posted on this page with a new "Last Updated" date. Continued use of Finuara after updates means you accept the revised terms.',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Section 8
                            Text(
                              '8. Contact Us',
                              style: TextStyles.bodyText(
                                size: SizeConstants.font(3.6),
                                weight: FontWeight.w700,
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1)),
                            Text(
                              'If you have any questions or concerns about this Privacy Policy, please contact us at:',
                              style: TextStyles.smallText(
                                size: SizeConstants.font(3.2),
                                color: ColorTheme.mainColor,
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(2)),

                            // Contact info
                            InkWell(
                              onTap: () async {
                                final Uri emailUri = Uri(
                                  scheme: 'mailto',
                                  path: 'support@finuara.com',
                                );
                                if (await canLaunchUrl(emailUri)) {
                                  await launchUrl(emailUri);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot open email'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: SizeConstants.font(3.5),
                                    color: ColorTheme.secondaryColor,
                                  ),
                                  SizedBox(width: SizeConstants.width(2)),
                                  Text(
                                    'support@finuara.com',
                                    style:
                                        TextStyles.smallText(
                                          size: SizeConstants.font(3.2),
                                          color: ColorTheme.secondaryColor,
                                          weight: FontWeight.w600,
                                        ).copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(1.5)),
                            InkWell(
                              onTap: () async {
                                final Uri websiteUri = Uri.parse(
                                  'https://www.finuara.com',
                                );
                                if (await canLaunchUrl(websiteUri)) {
                                  await launchUrl(
                                    websiteUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot open website'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    size: SizeConstants.font(3.5),
                                    color: ColorTheme.secondaryColor,
                                  ),
                                  SizedBox(width: SizeConstants.width(2)),
                                  Text(
                                    'www.finuara.com',
                                    style:
                                        TextStyles.smallText(
                                          size: SizeConstants.font(3.2),
                                          color: ColorTheme.secondaryColor,
                                          weight: FontWeight.w600,
                                        ).copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: SizeConstants.height(3)),

                            // Acceptance checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: controller.accepted,
                                  onChanged: (v) =>
                                      controller.toggleAccepted(v ?? false),
                                  activeColor: ColorTheme.secondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'I have read and accept the Privacy Policy',
                                    style: TextStyles.smallText(
                                      size: SizeConstants.font(3.2),
                                      color: ColorTheme.mainColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeConstants.height(2)),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: SizeConstants.width(60),
                        height: SizeConstants.height(6.5),
                        child: ElevatedButton(
                          onPressed: controller.accepted
                              ? () {
                                  Navigator.pop(context, true);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.secondaryColor,
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Accept',
                            style: TextStyles.buttonText(
                              color: Colors.white,
                              size: SizeConstants.font(3.8),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConstants.height(2)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _bulletedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) {
        return Padding(
          padding: EdgeInsets.only(bottom: SizeConstants.height(0.8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: TextStyles.smallText(
                  size: SizeConstants.font(3.2),
                  color: ColorTheme.mainColor,
                ),
              ),
              Expanded(
                child: Text(
                  e,
                  style: TextStyles.smallText(
                    size: SizeConstants.font(3.2),
                    color: ColorTheme.mainColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/profile/help_screen/controller/faq_model.dart';
import 'package:monaymanagment/presentation/profile/online_support_screen/view/online_support_screen.dart';

class HelpController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<FAQ> _faqs = [];
  List<FAQ> _filteredFaqs = [];
  String _selectedTab = 'FAQ';

  List<FAQ> get faqs => _filteredFaqs;
  String get selectedTab => _selectedTab;

  HelpController() {
    _initializeFAQs();
    _filteredFaqs = _faqs;
    searchController.addListener(_onSearchChanged);
  }

  void _initializeFAQs() {
    _faqs = [
      FAQ(
        id: '1',
        question: 'How to use FINURA?',
        answer:
            'FINURA is your personal finance management app. Start by adding your income and expenses, create categories, set financial targets, and track your spending patterns. Use the analysis screen to view detailed insights about your financial habits.',
      ),
      FAQ(
        id: '2',
        question: 'How much does it cost to use FINURA?',
        answer:
            'FINURA is completely free to use! There are no subscription fees, hidden costs, or premium features. All functionality including expense tracking, analysis, and goal setting is available at no charge.',
      ),
      FAQ(
        id: '3',
        question: 'How to contact support?',
        answer:
            'For support and assistance with FINURA, you can reach out through the app\'s help section or contact our support team. We typically respond within 24 hours and are here to help with any questions or issues you may have.',
      ),
      FAQ(
        id: '4',
        question: 'How can I reset my password if I forget it?',
        answer:
            'If you forget your password, tap on the \'Forgot Password\' option on the login screen. Enter your email address and follow the instructions sent to your email to reset your password securely.',
      ),
      FAQ(
        id: '5',
        question: 'Are there any privacy or data security measures in place?',
        answer:
            'Yes, FINURA takes your privacy and security seriously. All data is encrypted during transmission and storage. We never share your personal financial information with third parties, and you can delete your account and all data at any time.',
      ),
      FAQ(
        id: '6',
        question: 'Can I customize settings within the application?',
        answer:
            'Absolutely! FINURA offers extensive customization options. You can create custom categories, set financial targets, configure notification preferences, change your profile information, and personalize the app according to your needs.',
      ),
      FAQ(
        id: '7',
        question: 'How can I delete my account?',
        answer:
            'To delete your account, go to Profile > Settings > Delete Account. This will permanently remove all your data including transactions, categories, and targets. This action cannot be undone, so please ensure you want to proceed.',
      ),
      FAQ(
        id: '8',
        question: 'How do I access my expense history?',
        answer:
            'You can view your expense history in several ways: Use the Transactions screen for a complete list, check the Analysis screen for insights and trends, or browse by categories in the Category screen. All transactions are organized by date and category for easy tracking.',
      ),
      FAQ(
        id: '9',
        question: 'Can I use the app offline?',
        answer:
            'FINURA requires an internet connection to sync your data across devices and provide real-time updates. However, you can view previously loaded data when offline. For full functionality including adding new transactions, an internet connection is needed.',
      ),
    ];
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void toggleFAQExpansion(String faqId) {
    final index = _filteredFaqs.indexWhere((faq) => faq.id == faqId);
    if (index != -1) {
      _filteredFaqs[index] = _filteredFaqs[index].copyWith(
        isExpanded: !_filteredFaqs[index].isExpanded,
      );
      notifyListeners();
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredFaqs = _faqs;
    } else {
      _filteredFaqs = _faqs
          .where(
            (faq) =>
                faq.question.toLowerCase().contains(query) ||
                faq.answer.toLowerCase().contains(query),
          )
          .toList();
    }
    notifyListeners();
  }

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

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}

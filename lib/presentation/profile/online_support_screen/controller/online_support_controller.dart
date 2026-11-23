import 'package:flutter/material.dart';
import 'package:monaymanagment/presentation/profile/help_screen/controller/faq_model.dart';

class OnlineSupportController extends ChangeNotifier {
  List<ChatMessage> _activeChats = [];
  List<ChatMessage> _endedChats = [];

  List<ChatMessage> get activeChats => _activeChats;
  List<ChatMessage> get endedChats => _endedChats;

  OnlineSupportController() {
    _initializeChats();
  }

  void _initializeChats() {
    _activeChats = [
      ChatMessage(
        id: '1',
        title: 'Support Assistant',
        message: 'Hello! I\'m here to assist you',
        time: '2 Min Ago',
        isActive: true,
      ),
    ];

    _endedChats = [
      ChatMessage(
        id: '2',
        title: 'Help Center',
        message: 'Your account is ready to use...',
        time: 'Feb 08 - 2024',
      ),
      ChatMessage(
        id: '3',
        title: 'Support Assistant',
        message: 'Hello! I\'m here to assist you',
        time: 'Dic 24 - 2023',
      ),
      ChatMessage(
        id: '4',
        title: 'Support Assistant',
        message: 'Hello! I\'m here to assist you',
        time: 'Sep 10 - 2023',
      ),
      ChatMessage(
        id: '5',
        title: 'Help Center',
        message: 'Hi, how are you today?',
        time: 'June 12 - 2023',
      ),
    ];
  }

  void startNewChat() {
    final newChat = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Support Assistant',
      message: 'Hello! How can I help you today?',
      time: 'Just now',
      isActive: true,
    );

    _activeChats.insert(0, newChat);
    notifyListeners();
  }

  void openChat(String chatId) {
    // Handle opening a specific chat
    print('Opening chat: $chatId');
  }
}

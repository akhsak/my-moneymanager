import 'package:flutter/material.dart';

class FAQ {
  final String id;
  final String question;
  final String answer;
  bool isExpanded;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    bool? isExpanded,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class ContactOption {
  final String title;
  final String icon;
  final VoidCallback onTap;

  ContactOption({required this.title, required this.icon, required this.onTap});
}

class ChatMessage {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isActive;

  ChatMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isActive = false,
  });
}

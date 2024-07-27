import 'package:flutter/material.dart';
import './screens/chat/chat_screen.dart';

void main() {
  runApp(const BoleToh());
}

class BoleToh extends StatelessWidget {
  const BoleToh({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoleToh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ChatScreen(
        userId: '12345',
        recipientId: '5678',
      ),
    );
  }
}

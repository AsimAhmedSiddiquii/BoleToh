import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:boletoh/utils/services/encrypt_decrypt.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String recipientId;

  const ChatScreen(
      {super.key, required this.userId, required this.recipientId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final WebSocketChannel channel;
  bool _isConnected = false;

  final List<String> messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8080/ws?user=${widget.userId}&recipient=5678'),
    );

    channel.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message);
          final senderId = data['senderId'];
          final encryptedMessage = data['content'];

          final decryptedMessage =
              EncryptDecrypt.decryptMessage(encryptedMessage);
          print(decryptedMessage);
          setState(() {
            messages.add('$senderId: $decryptedMessage');
          });
        } catch (error) {
          print('Error processing message: $error');
        }
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
        print('WebSocket connection closed');
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
        });
        print('WebSocket error: $error');
      },
    );

    channel.sink.done.then((_) {
      setState(() {
        _isConnected = false;
      });
    }).catchError((error) {
      setState(() {
        _isConnected = false;
      });
      print('WebSocket done error: $error');
    });

    // Mark as connected
    setState(() {
      _isConnected = true;
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }

    if (_isConnected) {
      final encryptedMessage = EncryptDecrypt.encryptMessage(message);

      final messagePayload = {
        'senderId': widget.userId,
        'receiverId': widget.recipientId,
        'content': encryptedMessage,
      };

      channel.sink.add(jsonEncode(messagePayload));
      setState(() {
        messages.add('You: $message');
      });
      _controller.clear();
    } else {
      print('WebSocket is not connected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientId}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Send a message...',
                    ),
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

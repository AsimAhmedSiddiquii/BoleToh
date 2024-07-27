import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageInput extends StatefulWidget {
  final WebSocketChannel channel;
  final Function(String) onMessageSent;

  const MessageInput(this.channel, this.onMessageSent, {super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final enteredMessage = _controller.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    widget.channel.sink.add(enteredMessage);
    widget.onMessageSent(enteredMessage);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

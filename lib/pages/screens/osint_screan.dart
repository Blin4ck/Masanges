import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OsintScrean extends StatefulWidget {
  const OsintScrean({Key? key}) : super(key: key);

  @override
  State<OsintScrean> createState() => _SimpleChatScreenState();
}

class _SimpleChatScreenState extends State<OsintScrean> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  void _submitMessage() {
    final text = _textController.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, text); // Добавляем сообщение в начало списка
    });

    _textController.clear(); // Очищаем поле ввода
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromARGB(255, 28, 27, 27),
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color.fromARGB(255, 28, 27, 27),
        middle: Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Начните общение 💙',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    reverse: true, // Новые сообщения появляются снизу
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
          ),
          _MessageBar(
            textController: _textController,
            onSubmit: _submitMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBar extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSubmit;

  const _MessageBar({
    Key? key,
    required this.textController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 28, 27, 27),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: textController,
                  placeholder: 'Type a message',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                onPressed: onSubmit,
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;

  const _ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Сообщения справа
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

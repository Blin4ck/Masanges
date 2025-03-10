import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageBar extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSubmit;

  const MessageBar({
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
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CupertinoTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: textController,
                    placeholder: 'Type a message',
                    padding: const EdgeInsets.all(12),
                    style: const TextStyle(color: Colors.white),
                    placeholderStyle: const TextStyle(color: Colors.grey),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 28, 27, 27),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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

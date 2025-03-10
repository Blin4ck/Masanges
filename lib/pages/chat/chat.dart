import 'dart:async';
import 'dart:convert';
import 'package:chat2/pages/chat/%20chat_bubble.dart';
import 'package:chat2/pages/chat/masenge_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({Key? key, required this.chatId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final Map<String, String> _decryptedMessageCache = {};

  late final Stream<List<Map<String, dynamic>>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _setupMessagesStream();
  }

  void _setupMessagesStream() {
    _messagesStream = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', widget.chatId)
        .order('created_at', ascending: true)
        .map((maps) => maps);
  }

  void _submitMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    final password = 'zxcdsaqwe';
    final encryptedMessage = _encryptMessage(text, password);

    try {
      await Supabase.instance.client.from('messages').insert({
        'content': encryptedMessage,
        'chat_id': widget.chatId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (error) {
      _showErrorDialog(error.message);
    } catch (_) {
      _showErrorDialog('Unexpected error occurred');
    }

    _textController.clear();
  }

  String _encryptMessage(String message, String password) {
    final key = encrypt.Key.fromBase64(_generateKey(password));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(message, iv: iv);
    return '${encrypted.base64}:${base64.encode(iv.bytes)}';
  }

  static String _generateKey(String password) {
    final key = utf8.encode(password);
    final hashedKey = sha256.convert(key).bytes;
    return base64.encode(hashedKey);
  }

  String _decryptMessage(String encryptedMessageWithIv) {
    if (_decryptedMessageCache.containsKey(encryptedMessageWithIv)) {
      return _decryptedMessageCache[encryptedMessageWithIv]!;
    }

    final parts = encryptedMessageWithIv.split(':');
    final encryptedMessage = parts[0];
    final iv = encrypt.IV.fromBase64(parts[1]);
    final key = encrypt.Key.fromBase64(_generateKey('zxcdsaqwe'));

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decryptedMessage = encrypter.decrypt64(encryptedMessage, iv: iv);
    _decryptedMessageCache[encryptedMessageWithIv] = decryptedMessage;
    return decryptedMessage;
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final decryptedMessage =
                          _decryptMessage(message['content']);
                      final createdAt = DateTime.parse(message['created_at']);
                      return ChatBubble(
                        message: decryptedMessage,
                        createdAt: createdAt,
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Нет сообщений'));
                }
              },
            ),
          ),
          MessageBar(
            textController: _textController,
            onSubmit: _submitMessage,
          ),
        ],
      ),
    );
  }
}

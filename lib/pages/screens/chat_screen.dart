import 'package:chat2/pages/chat/chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _chats = [];
  String? _currentUserId;
  Map<String, dynamic> _userProfiles = {};
  late final RealtimeChannel _channel;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadChats();
    _setupRealtimeListeners();
    _startPeriodicChatCheck();
  }

  void _loadCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        setState(() {
          _currentUserId = user.id;
        });
      }
    } catch (e) {
      _showErrorDialog('Ошибка загрузки текущего пользователя: $e');
    }
  }

  void _loadChats() async {
    if (_currentUserId == null) return;

    try {
      final chats = await Supabase.instance.client
          .from('chats')
          .select('id, user1_id, user2_id')
          .or('user1_id.eq.$_currentUserId,user2_id.eq.$_currentUserId');

      List<String> userIds = [];
      for (var chat in chats) {
        if (chat['user1_id'] != _currentUserId) {
          userIds.add(chat['user1_id']);
        }
        if (chat['user2_id'] != _currentUserId) {
          userIds.add(chat['user2_id']);
        }
      }
      userIds = userIds.toSet().toList();
      await _loadUserProfiles(userIds);

      setState(() {
        _chats = chats;
      });
    } catch (e) {
      _showErrorDialog('Ошибка загрузки чатов: $e');
    }
  }

  Future<void> _loadUserProfiles(List<String> userIds) async {
    try {
      final profiles = await Supabase.instance.client
          .from('profiles')
          .select('id, username, profile_image_url')
          .in_('id', userIds);

      for (var profile in profiles) {
        _userProfiles[profile['id']] = profile;
      }
    } catch (e) {
      _showErrorDialog('Ошибка загрузки профилей: $e');
    }
  }

  void _setupRealtimeListeners() {
    _channel = Supabase.instance.client.channel('public:chats');
    _channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'chats'),
      (payload, [ref]) {
        _loadChats();
      },
    ).subscribe();
  }

  void _startPeriodicChatCheck() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadChats();
    });
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      await Supabase.instance.client.from('chats').delete().eq('id', chatId);
      _loadChats();
    } catch (e) {
      _showErrorDialog('Ошибка удаления чата: $e');
    }
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Чаты',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      child: _chats.isEmpty
          ? const Center(
              child: Text('Чаты отсутствуют',
                  style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final otherUserId = chat['user1_id'] == _currentUserId
                    ? chat['user2_id']
                    : chat['user1_id'];

                final otherUser = _userProfiles[otherUserId] ??
                    {'username': 'Неизвестный', 'profile_image_url': null};

                return Dismissible(
                  key: Key(chat['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteChat(chat['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Чат удален'),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ChatPage(chatId: chat['id']),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.grey[850],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                otherUser['profile_image_url'] ??
                                    'https://via.placeholder.com/150',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              otherUser['username'] ?? 'Неизвестный',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    _timer?.cancel();
    super.dispose();
  }
}

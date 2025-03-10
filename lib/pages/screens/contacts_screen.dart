import 'package:chat2/pages/chat/chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ContactsScreen extends StatefulWidget {
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> _allUsers = [];
  String _searchQuery = '';
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();

  late final RealtimeChannel _channel;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUsers();
    _setupRealtimeListeners();
    _startPeriodicUserCheck();
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

  void _loadUsers() async {
    try {
      final users = await Supabase.instance.client.from('profiles').select();
      setState(() {
        _allUsers = users;
      });
    } catch (e) {
      _showErrorDialog('Ошибка загрузки пользователей: $e');
    }
  }

  void _setupRealtimeListeners() {
    _channel = Supabase.instance.client.channel('public:profiles');
    _channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'profiles'),
      (payload, [ref]) {
        _loadUsers();
      },
    ).subscribe();
  }

  void _startPeriodicUserCheck() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadUsers();
    });
  }

  Future<void> _createChat(String otherUserId) async {
    if (_currentUserId == null) return;

    try {
      final existingChat = await Supabase.instance.client
          .from('chats')
          .select()
          .or('user1_id.eq.$_currentUserId,user2_id.eq.$_currentUserId')
          .or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId')
          .maybeSingle();

      if (existingChat != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ChatPage(chatId: existingChat['id']),
          ),
        );
        return;
      }

      final newChat = await Supabase.instance.client
          .from('chats')
          .insert({
            'user1_id': _currentUserId,
            'user2_id': otherUserId,
          })
          .select()
          .single();

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ChatPage(chatId: newChat['id']),
        ),
      );
    } catch (e) {
      _showErrorDialog('Ошибка создания чата: $e');
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
    final filteredUsers = _allUsers
        .where((user) =>
            user['id'] != _currentUserId &&
            (_searchQuery.isEmpty ||
                user['username']
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Контакты',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 28, 27, 27),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoTextField(
              controller: _searchController,
              placeholder: 'Поиск по имени пользователя',
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(CupertinoIcons.search, color: Colors.white),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text('Контакты отсутствуют',
                        style: TextStyle(color: Colors.white)),
                  )
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(user[
                                              'profile_image_url'] ??
                                          'https://via.placeholder.com/150'),
                                      radius: 25,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      user['username'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _createChat(user['id']);
                                },
                                child: const Icon(
                                  CupertinoIcons.chat_bubble,
                                  size: 24,
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _channel.unsubscribe();
    _timer?.cancel();
    super.dispose();
  }
}

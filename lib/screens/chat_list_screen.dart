import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/chat.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final bool isAgent;

  const ChatListScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.isAgent = true,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> _chats = [];
  
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    setState(() {
      if (widget.isAgent) {
        _chats = ChatService.getAgentChats(widget.userId);
      } else {
        _chats = ChatService.getCustomerChats(widget.userId);
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Now';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: _chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isAgent
                        ? 'When customers message you, they will appear here'
                        : 'Start a conversation from a property page',
                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final otherName = widget.isAgent ? chat.customerName : chat.agentName;
                final initial = otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(initial, style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    otherName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  onTap: () async {
                    await ChatService.markAsRead(chat.id, widget.userId);
                    if (mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chat.id,
                            currentUserId: widget.userId,
                            currentUserName: widget.userName,
                            otherUserName: otherName,
                            propertyTitle: chat.propertyTitle,
                            isAgent: widget.isAgent,
                            agentId: widget.isAgent ? widget.userId : chat.agentId,
                          ),
                        ),
                      );
                      _loadChats();
                    }
                  },
                );
              },
            ),
    );
  }
}
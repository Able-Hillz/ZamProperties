import 'package:hive/hive.dart';
import '../models/chat.dart';
import '../models/property.dart';
import '../models/agent.dart';
import 'hive_service.dart';
import 'mock_data_service.dart';

class ChatService {
  static late Box _chatsBox;
  static late Box _messagesBox;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    _chatsBox = await Hive.openBox('chats');
    _messagesBox = await Hive.openBox('messages');
    
    _isInitialized = true;
    print('✅ ChatService initialized');
  }

  // Create a new chat
  static Future<String> createChat({
    required String propertyId,
    required String customerId,
    required String customerName,
    required String customerPhone,
  }) async {
    final property = MockDataService.getPropertyById(propertyId);
    if (property == null) throw Exception('Property not found');
    
    final agent = MockDataService.getAgentById(property.agentId);
    if (agent == null) throw Exception('Agent not found');
    
    final chatId = '${propertyId}_${customerId}_${DateTime.now().millisecondsSinceEpoch}';
    
    final chat = Chat(
      id: chatId,
      propertyId: propertyId,
      propertyTitle: property.title,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      agentId: agent.id,
      agentName: agent.name,
      lastMessageTime: DateTime.now(),
      lastMessage: 'Chat started',
    );
    
    await _chatsBox.put(chatId, chat.toMap());
    return chatId;
  }

  // Get all chats for a customer
  static List<Chat> getCustomerChats(String customerId) {
    final allChats = _chatsBox.values
        .map((map) => Chat.fromMap(map as Map<String, dynamic>))
        .where((chat) => chat.customerId == customerId && chat.isActive)
        .toList();
    
    allChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return allChats;
  }

  // Get all chats for an agent
  static List<Chat> getAgentChats(String agentId) {
    final allChats = _chatsBox.values
        .map((map) => Chat.fromMap(map as Map<String, dynamic>))
        .where((chat) => chat.agentId == agentId && chat.isActive)
        .toList();
    
    allChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return allChats;
  }

  // Get chat by ID
  static Chat? getChat(String chatId) {
    final map = _chatsBox.get(chatId);
    if (map == null) return null;
    return Chat.fromMap(map as Map<String, dynamic>);
  }

  // Send message
  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    final messageId = '${DateTime.now().millisecondsSinceEpoch}_${senderId}';
    
    final message = ChatMessage(
      id: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
    
    // Save message
    await _messagesBox.put(messageId, message.toMap());
    
    // Update chat last message
    final chatMap = _chatsBox.get(chatId);
    if (chatMap != null) {
      final chat = Chat.fromMap(chatMap as Map<String, dynamic>);
      final updatedChat = Chat(
        id: chat.id,
        propertyId: chat.propertyId,
        propertyTitle: chat.propertyTitle,
        customerId: chat.customerId,
        customerName: chat.customerName,
        customerPhone: chat.customerPhone,
        agentId: chat.agentId,
        agentName: chat.agentName,
        lastMessageTime: DateTime.now(),
        lastMessage: content,
        unreadCount: chat.unreadCount + (senderId != chat.customerId ? 0 : 1),
        isActive: chat.isActive,
      );
      await _chatsBox.put(chatId, updatedChat.toMap());
    }
  }

  // Get messages for a chat
  static List<ChatMessage> getMessages(String chatId) {
    final messages = _messagesBox.values
        .map((map) => ChatMessage.fromMap(map as Map<String, dynamic>))
        .where((msg) => msg.chatId == chatId)
        .toList();
    
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  // Mark messages as read
  static Future<void> markAsRead(String chatId, String readerId) async {
    final messages = getMessages(chatId);
    for (var msg in messages) {
      if (msg.senderId != readerId && !msg.isRead) {
        final updatedMsg = ChatMessage(
          id: msg.id,
          chatId: msg.chatId,
          senderId: msg.senderId,
          senderName: msg.senderName,
          content: msg.content,
          type: msg.type,
          timestamp: msg.timestamp,
          isRead: true,
          imageUrl: msg.imageUrl,
        );
        await _messagesBox.put(msg.id, updatedMsg.toMap());
      }
    }
    
    // Reset unread count
    final chatMap = _chatsBox.get(chatId);
    if (chatMap != null) {
      final chat = Chat.fromMap(chatMap as Map<String, dynamic>);
      final updatedChat = Chat(
        id: chat.id,
        propertyId: chat.propertyId,
        propertyTitle: chat.propertyTitle,
        customerId: chat.customerId,
        customerName: chat.customerName,
        customerPhone: chat.customerPhone,
        agentId: chat.agentId,
        agentName: chat.agentName,
        lastMessageTime: chat.lastMessageTime,
        lastMessage: chat.lastMessage,
        unreadCount: 0,
        isActive: chat.isActive,
      );
      await _chatsBox.put(chatId, updatedChat.toMap());
    }
  }

  // Get unread count for an agent
  static int getAgentUnreadCount(String agentId) {
    final chats = getAgentChats(agentId);
    return chats.fold(0, (sum, chat) => sum + chat.unreadCount);
  }
}

enum MessageType { text, image, property }

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? propertyId;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.propertyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'propertyId': propertyId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      chatId: map['chatId'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      content: map['content'],
      type: MessageType.values[map['type']],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'],
      imageUrl: map['imageUrl'],
      propertyId: map['propertyId'],
    );
  }
}

class Chat {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String agentId;
  final String agentName;
  final DateTime lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final bool isActive;

  Chat({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.agentId,
    required this.agentName,
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'agentId': agentId,
      'agentName': agentName,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      propertyId: map['propertyId'],
      propertyTitle: map['propertyTitle'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      agentId: map['agentId'],
      agentName: map['agentName'],
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
      lastMessage: map['lastMessage'],
      unreadCount: map['unreadCount'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }
}
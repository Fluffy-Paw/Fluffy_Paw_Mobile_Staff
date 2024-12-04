class MessageFile {
  final int id;
  final String file;
  final DateTime createDate;
  final bool status;

  MessageFile({
    required this.id,
    required this.file,
    required this.createDate,
    required this.status,
  });

  factory MessageFile.fromMap(Map<String, dynamic> map) {
    return MessageFile(
      id: map['id'] ?? 0,
      file: map['file'] ?? '',
      createDate: DateTime.parse(map['createDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? false,
    );
  }
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final DateTime createTime;
  final String content;
  final bool isSeen;
  final DateTime? deleteAt;
  final bool isDelete;
  final int replyMessageId;
  final List<MessageFile> files;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.createTime,
    required this.content,
    required this.isSeen,
    this.deleteAt,
    required this.isDelete,
    required this.replyMessageId,
    required this.files,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? 0,
      conversationId: map['conversationId'] ?? 0,
      senderId: map['senderId'] ?? 0,
      createTime: DateTime.parse(map['createTime'] ?? DateTime.now().toIso8601String()),
      content: map['content'] ?? '',
      isSeen: map['isSeen'] ?? false,
      deleteAt: map['deleteAt'] != null ? DateTime.parse(map['deleteAt']) : null,
      isDelete: map['isDelete'] ?? false,
      replyMessageId: map['replyMessageId'] ?? 0,
      files: List<MessageFile>.from(
        (map['files'] ?? []).map((x) => MessageFile.fromMap(x)),
      ),
    );
  }

  bool get hasFiles => files.isNotEmpty;
  bool get hasMultipleFiles => files.length > 1;
  String get firstFileUrl => files.isNotEmpty ? files.first.file : '';
}

class ChatPagination {
  final List<Message> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  ChatPagination({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ChatPagination.fromMap(Map<String, dynamic> map) {
    return ChatPagination(
      items: (map['items'] as List<dynamic>?)
          ?.map((x) => Message.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
      totalItems: map['totalItems'] as int? ?? 0,
      currentPage: map['currentPage'] as int? ?? 0,
      totalPages: map['totalPages'] as int? ?? 0,
      pageSize: map['pageSize'] as int? ?? 20,
      hasPreviousPage: map['hasPreviousPage'] as bool? ?? false,
      hasNextPage: map['hasNextPage'] as bool? ?? false,
    );
  }
}
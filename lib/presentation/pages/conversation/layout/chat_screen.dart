import 'dart:convert';
import 'dart:io';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/conversation/chat_controller.dart';
import 'package:fluffypawsm/data/models/conversation/message_model.dart';
import 'package:fluffypawsm/data/repositories/chat_service.dart';
import 'package:fluffypawsm/presentation/pages/conversation/layout/chat_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final String storeName;
  final String? storeAvatar;
  final int poAccountId;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.storeName,
    this.storeAvatar,
    required this.poAccountId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isAttachmentVisible = false;
  bool _isSending = false;
  int? _previousMessageCount;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // Scroll to 0 khi reverse: true
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedFiles.add(File(photo.path));
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedFiles.isEmpty)
      return;

    final content = _messageController.text.trim();
    final files = List<File>.from(_selectedFiles);

    // Clear input immediately
    _messageController.clear();
    setState(() {
      _selectedFiles.clear();
      _isAttachmentVisible = false;
      _isSending = true;
    });

    try {
      await ref
          .read(chatControllerProvider(widget.conversationId).notifier)
          .sendMessage(
            content: content,
            files: files,
          );
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(widget.conversationId));

    // Check for new messages and scroll
    if (chatState.hasValue) {
      final currentCount = chatState.value?.items.length ?? 0;
      if (_previousMessageCount != null &&
          currentCount > _previousMessageCount!) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
      _previousMessageCount = currentCount;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatState.when(
                data: (chat) => _buildMessageList(chat.items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
            if (_isAttachmentVisible) _buildAttachmentOptions(),
            if (_selectedFiles.isNotEmpty) _buildSelectedFiles(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _buildStoreAvatar(),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.storeName,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColor.blackColor,
                      ),
                ),
                Gap(2.h),
                Text(
                  'Usually responds within 1 hour',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.gray,
                        fontSize: 12.sp,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Show additional options
          },
        ),
      ],
    );
  }

  Widget _buildStoreAvatar() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.violetColor.withOpacity(0.1),
        image: widget.storeAvatar != null
            ? DecorationImage(
                image: NetworkImage(widget.storeAvatar!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.storeAvatar == null
          ? Center(
              child: Text(
                widget.storeName[0].toUpperCase(),
                style: AppTextStyle(context).title.copyWith(
                      color: AppColor.violetColor,
                      fontSize: 18.sp,
                    ),
              ),
            )
          : null,
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      reverse: true, // Set to true để tin nhắn mới nhất ở dưới
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final bool showDate = reversedIndex == 0 ||
            !_isSameDay(messages[reversedIndex].createTime,
                messages[reversedIndex - 1].createTime);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.createTime),
            MessageBubble(
              message: message,
              targetId: widget.poAccountId,
              conversationId: widget.conversationId,
              scrollController: _scrollController,
              isSending: _isSending && reversedIndex == 0,
              storeAvatar: widget.storeAvatar,
              storeName: widget.storeName,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Gap(8.w),
          Text(
            _formatDate(date),
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.gray,
                  fontSize: 12.sp,
                ),
          ),
          Gap(8.w),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttachmentOption(
            icon: Icons.image,
            label: 'Gallery',
            onTap: _pickImages,
          ),
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: _takePicture,
          ),
          _buildAttachmentOption(
            icon: Icons.insert_drive_file,
            label: 'Document',
            onTap: () {
              // Handle document selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColor.violetColor,
              size: 24.sp,
            ),
          ),
          Gap(8.h),
          Text(
            label,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  fontSize: 12.sp,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFiles() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 8.w),
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: DecorationImage(
                    image: FileImage(_selectedFiles[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFiles.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (isKeyboardVisible) {
          // When keyboard appears, scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: AppColor.violetColor,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _isAttachmentVisible = !_isAttachmentVisible;
                        });
                      },
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: TextStyle(fontSize: 14.sp),
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                color: AppColor.gray,
                                size: 24.sp,
                              ),
                              onPressed: () {
                                // Show emoji picker
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(8.w),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.violetColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isSending
                            ? SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return _getDayOfWeek(date);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  void _handleNewMessage(String content, int conversationId, int targetId,
      List<String> attachments) async {
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: conversationId,
      senderId: targetId,
      content: content,
      createTime: DateTime.now(),
      //createDate: DateTime.now(),
      isDelete: false,
      // status: true,
      replyMessageId: 0,
      isSeen: false,
      deleteAt: null,
      files: attachments
          .map((url) => MessageFile(
                id: DateTime.now().millisecondsSinceEpoch,
                file: url,
                createDate: DateTime.now(),
                status: true,
              ))
          .toList(),
    );

    ref
        .read(chatControllerProvider(widget.conversationId).notifier)
        .updateMessage(newMessage);
    _scrollToBottom();
  }
}

class MessageBubble extends ConsumerStatefulWidget {
  final Message message;
  final bool isSending;
  final int targetId;
  final int conversationId;
  final ScrollController scrollController;
  final String? storeAvatar;
  final String storeName;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.targetId,
    this.isSending = false,
    required this.scrollController,
    required this.conversationId,
    this.storeAvatar,
    required this.storeName,
  }) : super(key: key);

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    bool isStaffMessage = widget.message.senderId == widget.targetId;

    return Opacity(
      opacity: widget.isSending ? 0.7 : 1.0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment: isStaffMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isStaffMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isStaffMessage) ...[
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.violetColor.withOpacity(0.1),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: widget.storeAvatar != null &&
                            widget.storeAvatar!.isNotEmpty
                        ? Image.network(
                            widget.storeAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                widget.storeName[0],
                                style: TextStyle(
                                  color: AppColor.violetColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              widget.storeName[0],
                              style: TextStyle(
                                color: AppColor.violetColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  Gap(8.w),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isStaffMessage
                          ? AppColor.violetColor
                          : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft:
                            Radius.circular(isStaffMessage ? 16.r : 4.r),
                        bottomRight:
                            Radius.circular(isStaffMessage ? 4.r : 16.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.message.files.isNotEmpty) ...[
                          _buildMessageImages(),
                          if (widget.message.content.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                widget.message.content,
                                style: TextStyle(
                                  color: isStaffMessage
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                        ] else
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              widget.message.content,
                              style: TextStyle(
                                color: isStaffMessage
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!widget.isSending)
              Padding(
                padding: EdgeInsets.only(
                  top: 4.h,
                  left: !isStaffMessage ? 36.w : 0,
                  right: isStaffMessage ? 0 : 36.w,
                ),
                child: Row(
                  mainAxisAlignment: isStaffMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(widget.message.createTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10.sp,
                      ),
                    ),
                    if (isStaffMessage) ...[
                      Gap(4.w),
                      Icon(
                        widget.message.isSeen ? Icons.done_all : Icons.done,
                        size: 14.sp,
                        color: widget.message.isSeen
                            ? AppColor.violetColor
                            : Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageImages() {
    // Remove parameter here
    if (widget.message.files.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: widget.message.files.length == 1
          ? _buildSingleImage(widget.message.files.first)
          : GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.message.files
                  .map((file) => _buildImageTile(file))
                  .toList(),
            ),
    );
  }

  Widget _buildSingleImage(MessageFile file) => _buildImageTile(file);
  Widget _buildImageLoading() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.violetColor),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red[400],
        ),
      ),
    );
  }

// Widget _buildSingleImage(MessageFile file) {
//   return GestureDetector(
//     onTap: () => _showFullScreenImage(context, file.file),
//     child: Image.network(
//       file.file,
//       fit: BoxFit.cover,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return const ImageLoadingPlaceholder();
//       },
//       errorBuilder: (context, error, stackTrace) => const ImageErrorPlaceholder(),
//     ),
//   );
// }
  Widget _buildImageTile(MessageFile file) {
    bool isLocalFile = file.file.startsWith('/');
    return GestureDetector(
      onTap: () => _showFullScreenImage(file.file),
      child: isLocalFile
          ? Image.file(
              File(file.file),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImageError(),
            )
          : Image.network(
              file.file,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImageLoading();
              },
              errorBuilder: (_, __, ___) => _buildImageError(),
            ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isCurrentUser) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8.h,
        left: isCurrentUser ? 64.w : 8.w,
        right: isCurrentUser ? 8.w : 64.w,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.files.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: _buildMessageImages(),
            ),
          if (message.content.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: message.files.isNotEmpty ? 8.h : 0),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColor.violetColor : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imagePath) {
    bool isLocalFile = imagePath.startsWith('/');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: isLocalFile
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildImageError(),
                    )
                  : Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImageLoading();
                      },
                      errorBuilder: (_, __, ___) => _buildImageError(),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

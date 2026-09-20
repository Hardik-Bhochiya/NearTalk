import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showSenderName;
  final String currentUserId;
  final Function(String emoji)? onReact;
  final VoidCallback? onReply;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final Function(String newText)? onEdit;
  final Function(bool deleteForEveryone)? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    this.showSenderName = true,
    this.currentUserId = 'user-hardik',
    this.onReact,
    this.onReply,
    this.onLike,
    this.onDislike,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final List<String> _extraReactions = [];

  void _showContextMenu(BuildContext context) {
    if (widget.message.isDeleted) return;

    final isMine = widget.message.isMine;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF30363D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quick Emoji Reaction Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['👍', '👎', '❤️', '🔥', '😂', '🎉'].map((emoji) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        if (emoji == '👍') {
                          widget.onLike?.call();
                        } else if (emoji == '👎') {
                          widget.onDislike?.call();
                        } else {
                          setState(() {
                            if (!_extraReactions.contains(emoji)) {
                              _extraReactions.add(emoji);
                            }
                          });
                          widget.onReact?.call(emoji);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Copy message
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF58A6FF), size: 20),
                title: const Text('Copy Message', style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 14)),
                dense: true,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.message.content));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied to clipboard')),
                  );
                },
              ),

              // Edit option (only if sender is mine)
              if (isMine)
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Color(0xFF58A6FF), size: 20),
                  title: const Text('Edit Message', style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 14)),
                  dense: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditDialog(context);
                  },
                ),

              // Delete for everyone (only if sender is mine)
              if (isMine)
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFF85149), size: 20),
                  title: const Text('Delete for Everyone', style: TextStyle(color: Color(0xFFF85149), fontSize: 14, fontWeight: FontWeight.bold)),
                  dense: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(context, forEveryone: true);
                  },
                ),

              // Delete for me
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFF8B949E), size: 20),
                title: const Text('Delete for Me', style: TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
                dense: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, forEveryone: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final editController = TextEditingController(text: widget.message.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
        title: const Text('Edit Message', style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0D1117),
            hintText: 'Edit your message...',
            hintStyle: const TextStyle(color: Color(0xFF8B949E)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF58A6FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != widget.message.content) {
                widget.onEdit?.call(newText);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required bool forEveryone}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
        title: Text(
          forEveryone ? 'Delete for Everyone?' : 'Delete for Me?',
          style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          forEveryone
              ? 'This message will be deleted for all participants in this chat.'
              : 'This message will be removed from your view only.',
          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF85149),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call(forEveryone);
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeenIndicator() {
    // Seen indicator for sender
    if (widget.message.status == 'seen') {
      return const Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Color(0xFF58A6FF), // Blue ticks!
      );
    } else if (widget.message.status == 'delivered') {
      return const Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Color(0xFF8B949E), // Grey double tick
      );
    } else {
      return const Icon(
        Icons.done_rounded,
        size: 14,
        color: Color(0xFF8B949E), // Grey single tick
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMine = widget.message.isMine;
    final isDeleted = widget.message.isDeleted;
    final timeStr = DateFormat('hh:mm a').format(widget.message.timestamp);

    final isLikedByMe = widget.message.likes.contains(widget.currentUserId);
    final isDislikedByMe = widget.message.dislikes.contains(widget.currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF21262D),
              child: Text(
                widget.message.senderName.isNotEmpty ? widget.message.senderName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58A6FF),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showContextMenu(context),
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDeleted
                          ? const Color(0xFF161B22)
                          : (isMine ? const Color(0xFF1F6FEB) : const Color(0xFF21262D)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMine ? 16 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 16),
                      ),
                      border: Border.all(
                        color: isDeleted
                            ? const Color(0xFF30363D)
                            : (isMine ? const Color(0xFF388BFD) : const Color(0xFF30363D)),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Sender Name (in group chat)
                        if (!isMine && widget.showSenderName && !isDeleted) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.message.senderName,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF58A6FF),
                                ),
                              ),
                              if (widget.message.isAnonymous) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF30363D),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('🎭 Anon', style: TextStyle(fontSize: 8.5, color: Color(0xFF8B949E))),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                        ],

                        // Deleted Message View
                        if (isDeleted)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.block_rounded, size: 14, color: Color(0xFF8B949E)),
                              SizedBox(width: 6),
                              Text(
                                'This message was deleted',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF8B949E),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            widget.message.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFF0F6FC),
                              height: 1.35,
                            ),
                          ),

                        const SizedBox(height: 4),

                        // Timestamp, Edited tag, and Seen Indicator
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.message.isEdited && !isDeleted) ...[
                              const Text(
                                'edited • ',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF8B949E),
                                ),
                              ),
                            ],
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF8B949E),
                              ),
                            ),
                            if (isMine && !isDeleted) ...[
                              const SizedBox(width: 4),
                              _buildSeenIndicator(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reactions & Like / Dislike Pills
                  if (!isDeleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Like Pill
                          InkWell(
                            onTap: widget.onLike,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLikedByMe ? const Color(0xFF1F6FEB).withValues(alpha: 0.3) : const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLikedByMe ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('👍', style: TextStyle(fontSize: 12)),
                                  if (widget.message.likes.isNotEmpty) ...[
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.message.likes.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLikedByMe ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Dislike Pill
                          InkWell(
                            onTap: widget.onDislike,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDislikedByMe ? const Color(0xFFF85149).withValues(alpha: 0.2) : const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDislikedByMe ? const Color(0xFFF85149) : const Color(0xFF30363D),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('👎', style: TextStyle(fontSize: 12)),
                                  if (widget.message.dislikes.isNotEmpty) ...[
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.message.dislikes.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDislikedByMe ? const Color(0xFFF85149) : const Color(0xFF8B949E),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Extra reactions
                          if (_extraReactions.isNotEmpty)
                            ..._extraReactions.map((emoji) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161B22),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF30363D), width: 1),
                                  ),
                                  child: Text(emoji, style: const TextStyle(fontSize: 12)),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_config.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.rw),
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: (val) =>
                      setState(() => _isTyping = val.isNotEmpty),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  maxLines: null,
                ),
              ),
            ),
            SizedBox(width: 8.rw),
            GestureDetector(
              onTap: _handleSend,
              child: CircleAvatar(
                backgroundColor: _isTyping
                    ? AppColors.primary
                    : AppColors.divider,
                radius: 24.r,
                child: Icon(Icons.send, color: Colors.white, size: 20.rt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final VoidCallback onSendMessage;
  final ValueChanged<String> onChanged;
  final bool isBtActive;

  const ChatInputField({
    Key? key,
    required this.messageController,
    required this.messageFocusNode,
    required this.onSendMessage,
    required this.onChanged,
    required this.isBtActive,
  }) : super(key: key);

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: widget.messageController,
                        focusNode: widget.messageFocusNode,
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (_) => widget.onSendMessage(),
                        maxLines: 4,
                        minLines: 1,
                        onChanged: widget.onChanged,
                        decoration: const InputDecoration(
                          hintText: '메세지 보내기',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.isBtActive ? widget.onSendMessage : null,
                  child: Icon(
                    Icons.send,
                    color: widget.isBtActive
                        ? const Color.fromARGB(255, 26, 106, 6)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
import 'package:pillow_bud/theme/app_colors.dart';
import 'package:pillow_bud/models/chat_message.dart';


class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isFromBud: false,
      timestamp: DateTime.now(),
      sessionId: ref.read(currentChatIdProvider),
    );

    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      userMessage,
    ];

    _controller.clear();

    final responseText = await ref
        .read(budResponseProvider(text).future);

    final budMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: responseText,
      isFromBud: true,
      timestamp: DateTime.now(),
      sessionId: ref.read(currentChatIdProvider),
    );

    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      budMessage,
    ];
  }


  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                final isUser = !msg.isFromBud;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.06),

                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      msg.text,

                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tell Bud what you’re feeling…',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),

                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
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


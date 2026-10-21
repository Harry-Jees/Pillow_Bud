import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/chat_message.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/llm_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/crisis_detector.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/services/emotion_detector.dart';
import 'package:pillow_bud/services/voice/voice_input_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';
import 'package:pillow_bud/widgets/indicators/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasInput = false;
  bool _isPreparingSend = false;
  late Future<void> _historyLoadFuture;
  int _historyGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasInput && mounted) {
        setState(() => _hasInput = hasText);
      }
    });
    _historyLoadFuture = _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final generation = _historyGeneration;
    final sessionId = ref.read(currentChatIdProvider);
    try {
      final history = await DatabaseService.getAllChatMessages(
        sessionId: sessionId,
      );
      if (!mounted || generation != _historyGeneration) return;
      // Merge with messages sent while the database read was in flight.
      // IDs prevent duplicate bubbles; timestamps preserve conversation order.
      final currentMessages = ref.read(chatMessagesProvider);
      final mergedById = <String, ChatMessage>{
        for (final message in history) message.id: message,
        for (final message in currentMessages) message.id: message,
      };
      final mergedHistory = mergedById.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (!mounted || generation != _historyGeneration) return;
      ref.read(chatMessagesProvider.notifier).state = mergedHistory;
      ref.read(llmServiceProvider).restoreConversationHistory(
        mergedHistory.map((message) => {
          'role': message.isFromBud ? 'assistant' : 'user',
          'content': message.text,
        }),
      );
      if (mergedHistory.isNotEmpty) _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat history could not be loaded from this device.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    ref.read(isLoadingChatProvider.notifier).state = false;
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _send() async {
    if (_isPreparingSend || ref.read(isLoadingChatProvider)) return;
    _isPreparingSend = true;

    try {
      // Restore persisted context before constructing the next prompt. This
      // avoids a first message racing the async history read on screen startup.
      await _historyLoadFuture;
      if (!mounted) return;

      final text = _controller.text.trim();
      if (text.isEmpty) return;

      final sessionId = ref.read(currentChatIdProvider);
      final isCrisis = CrisisDetector.detect(text);
      final analysis = EmotionDetector.analyze(text);
      final detectedEmotion = analysis['emotion'] as String;
      final intensity = analysis['intensity'] as double;

      ref.read(currentChatEmotionProvider.notifier).state =
          detectedEmotion != 'neutral' ? detectedEmotion : '';

      final userMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isFromBud: false,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      ref.read(chatMessagesProvider.notifier).state = [
        ...ref.read(chatMessagesProvider),
        userMessage,
      ];

      _controller.clear();
      setState(() => _hasInput = false);
      _scrollToBottom();
      // Lock out repeat submissions before any persistence/inference await.
      ref.read(isLoadingChatProvider.notifier).state = true;

      try {
        await DatabaseService.saveChatMessage(
          userMessage,
          mood: detectedEmotion,
          intensity: intensity,
        );
      } catch (error) {
        debugPrint('ChatScreen: user message persistence failed: $error');
      }

      if (!mounted) return;

      if (isCrisis) _showCrisisDialog();
      _scrollToBottom();

      try {
        // Call the service directly: a FutureProvider.family is cached by
        // message text and can return a stale answer for repeated messages.
        final responseText = await ref
            .read(llmServiceProvider)
            .getEmotionalBudResponse(
              userMessage: text,
              userName: ref.read(userNameProvider),
              personalityMode: ref.read(buddyPersonalityProvider),
            );

        if (!mounted) return;

        final budMessage = ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: responseText,
          isFromBud: true,
          timestamp: DateTime.now(),
          sessionId: sessionId,
        );

        ref.read(chatMessagesProvider.notifier).state = [
          ...ref.read(chatMessagesProvider),
          budMessage,
        ];

        try {
          await DatabaseService.saveChatMessage(
            budMessage,
            mood: detectedEmotion,
          );
        } catch (error) {
          debugPrint('ChatScreen: Bud response persistence failed: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reply shown, but could not be saved to chat history.'),
              ),
            );
          }
        }
      } catch (error, stackTrace) {
        debugPrint('ChatScreen: response generation failed: $error\n$stackTrace');
        if (!mounted) return;

        final errorMessage = ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: 'I\'m here with you. Take a slow, steady breath. What feels heaviest right now?',
          isFromBud: true,
          timestamp: DateTime.now(),
          sessionId: sessionId,
        );
        ref.read(chatMessagesProvider.notifier).state = [
          ...ref.read(chatMessagesProvider),
          errorMessage,
        ];
        try {
          await DatabaseService.saveChatMessage(errorMessage);
        } catch (persistError) {
          debugPrint('ChatScreen: fallback response persistence failed: $persistError');
        }
      } finally {
        if (mounted) {
          ref.read(isLoadingChatProvider.notifier).state = false;
          _scrollToBottom();
        }
      }
    } finally {
      _isPreparingSend = false;
    }
  }

  void _showCrisisDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('💙 ', style: TextStyle(fontSize: 24)),
            Expanded(
              child: Text(
                'We Care About You',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are carrying a deep burden right now. Please know that you are not alone and free, confidential emergency support is ready 24/7:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ...CrisisDetector.getResources().map((resource) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(dialogContext).colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['name']!,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            resource['number']!,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: Theme.of(dialogContext).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.call, color: Theme.of(dialogContext).colorScheme.primary, size: 20),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Chatting'),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Start Fresh Conversation?',
          style: TextStyle(fontFamily: 'Lora', fontSize: 18),
        ),
        content: const Text(
          'This will clear the current chat history from your encrypted database.',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Invalidate any history read already in flight so it cannot
              // repopulate this conversation after the user starts fresh.
              _historyGeneration++;
              final sessionId = ref.read(currentChatIdProvider);
              ref.read(chatMessagesProvider.notifier).state = [];
              ref.read(currentChatEmotionProvider.notifier).state = '';
              ref.read(llmServiceProvider).clearConversationHistory();
              try {
                await DatabaseService.clearAllChatMessages(
                  sessionId: sessionId,
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not clear the saved chat history.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Chat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(isLoadingChatProvider);
    final activeEmotion = ref.watch(currentChatEmotionProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF212121) : const Color(0xFFF9F7FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bud',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Local AI',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
            if (activeEmotion.isNotEmpty)
              Text(
                'Sensing you\'re feeling $activeEmotion',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black54,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Start Fresh',
            onPressed: messages.isNotEmpty ? _clearChat : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(primary, isDarkMode)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == messages.length && isLoading) {
                        return _buildTypingIndicatorBubble(primary, isDarkMode);
                      }

                      final msg = messages[i];
                      return _buildMessageBubble(msg, primary, isDarkMode);
                    },
                  ),
          ),
          _buildInputBar(primary, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primary, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌸', style: TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Bud is ready to listen',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? const Color(0xFFECECF1)
                    : const Color(0xFF1A1225),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share anything on your mind. All conversations are encrypted and processed 100% locally on your device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, Color primary, bool isDarkMode) {
    final isUser = !msg.isFromBud;

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Bud Bubble
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 16)),
            ),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? primary.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: isDarkMode
                      ? primary.withValues(alpha: 0.22)
                      : const Color(0x18000000),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: isDarkMode
                      ? const Color(0xFFECECF1)
                      : const Color(0xFF2F2F2F),
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicatorBubble(Color primary, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 16)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? primary.withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primary.withValues(alpha: 0.22),
              ),
            ),
            child: const TypingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color primary, bool isDarkMode) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF171717) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? const Color(0x18FFFFFF)
                  : const Color(0x12000000),
            ),
          ),
        ),
        child: Row(
          children: [
            // Mic button
            ValueListenableBuilder<bool>(
              valueListenable: VoiceInputService.isListeningNotifier,
              builder: (context, isListening, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: VoiceInputService.soundLevelNotifier,
                  builder: (context, level, _) {
                    return GestureDetector(
                      onTap: () async {
                        if (isListening) {
                          await VoiceInputService.stop();
                        } else {
                          // Show partial text as user speaks
                          await VoiceInputService.start(
                            onResult: (text) {
                              _controller.text = text;
                              _controller.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: text.length),
                              );
                              setState(() => _hasInput = text.isNotEmpty);
                            },
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isListening
                              ? AppColors.danger.withValues(alpha: 0.15 + level * 0.25)
                              : primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isListening
                                ? AppColors.danger.withValues(alpha: 0.6)
                                : primary.withValues(alpha: 0.3),
                            width: isListening ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: isListening ? AppColors.danger : primary,
                          size: 20,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            // Text field (shows partial voice result while listening)
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: VoiceInputService.partialTextNotifier,
                builder: (context, partial, _) {
                  return TextField(
                    controller: _controller,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: partial.isNotEmpty
                          ? partial
                          : 'Share your thoughts with Bud...',
                      hintStyle: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: partial.isNotEmpty
                            ? (isDarkMode ? Colors.white60 : Colors.black54)
                            : (isDarkMode
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black38),
                        fontStyle: partial.isNotEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFECECF1).withValues(alpha: 0.45),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Container(
              decoration: BoxDecoration(
                color: _hasInput
                    ? primary
                    : primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _hasInput ? _send : null,
                icon: const Icon(Icons.arrow_upward_rounded, size: 22),
                color: Colors.white,
                tooltip: 'Send Message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

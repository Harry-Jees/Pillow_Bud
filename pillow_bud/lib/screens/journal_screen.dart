import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/journal_entry.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/services/date_utils.dart';
import 'package:pillow_bud/services/storage_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedMood = '😌';
  String _searchQuery = '';

  static const List<Map<String, String>> _moods = [
    {'emoji': '😤', 'label': 'Stressed'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😄', 'label': 'Joyful'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final entryId = DateTime.now().microsecondsSinceEpoch.toString();
    final now = DateTime.now();

    final entry = JournalEntry(
      id: entryId,
      text: text,
      mood: _selectedMood,
      dateCreated: now,
      dateModified: now,
    );

    final updated = [entry, ...ref.read(journalEntriesProvider)];
    ref.read(journalEntriesProvider.notifier).state = updated;
    await StorageService.saveJournalEntries(updated);

    // Save encrypted to SQLite3
    try {
      await DatabaseService.saveJournalEntry(entry);
    } catch (_) {}

    _controller.clear();
    setState(() => _selectedMood = '😌');

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final updated = ref
        .read(journalEntriesProvider)
        .where((e) => e.id != entry.id)
        .toList();
    ref.read(journalEntriesProvider.notifier).state = updated;
    await StorageService.saveJournalEntries(updated);

    try {
      await DatabaseService.deleteJournalEntry(entry.id);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showEntryDialog(JournalEntry entry) {
    final isDarkMode = ref.read(isDarkModeProvider);
    final themeColors = ref.read(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor:
            isDarkMode ? const Color(0xFF2F2F2F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        entry.mood,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateUtils.formatDateTime(entry.dateCreated),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Encrypted Reflection',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? const Color(0xFFECECF1)
                                : const Color(0xFF1A1225),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Text(
                    entry.text,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.88)
                          : Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger, size: 22),
                    tooltip: 'Delete Entry',
                    onPressed: () => _deleteEntry(entry),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewEntryDialog() {
    final isDarkMode = ref.read(isDarkModeProvider);
    final themeColors = ref.read(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor:
                isDarkMode ? const Color(0xFF2F2F2F) : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Journal Reflection',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? const Color(0xFFECECF1)
                            : const Color(0xFF1A1225),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      maxLines: 6,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind today? Write freely...',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black38,
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8F6FF),
                      ),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'How are you feeling?',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _moods.map((m) {
                        final isSelected = _selectedMood == m['emoji'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedMood = m['emoji']!);
                            setState(() => _selectedMood = m['emoji']!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primary.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primary
                                    : (isDarkMode
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0x12000000)),
                              ),
                            ),
                            child: Text(
                              m['emoji']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Save Reflection'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    final filteredEntries = _searchQuery.isEmpty
        ? entries
        : entries
            .where((e) =>
                e.text.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF212121) : const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          'My Journal',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? const Color(0xFFECECF1)
                : const Color(0xFF1A1225),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (entries.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search encrypted reflections...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            Expanded(
              child: filteredEntries.isEmpty
                  ? Center(
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
                                child: Text('📓', style: TextStyle(fontSize: 32)),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Your Private Journal'
                                  : 'No matching entries',
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
                              _searchQuery.isEmpty
                                  ? 'Write your first reflection. Everything is encrypted locally with AES-256.'
                                  : 'Try a different search term.',
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
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        return GestureDetector(
                          onTap: () => _showEntryDialog(entry),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.white,
                              border: Border.all(
                                color: isDarkMode
                                    ? const Color(0x18FFFFFF)
                                    : const Color(0x12000000),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateUtils.formatDateTime(entry.dateCreated),
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11,
                                        color: isDarkMode
                                            ? Colors.white.withValues(alpha: 0.45)
                                            : Colors.black45,
                                      ),
                                    ),
                                    Text(
                                      entry.mood,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewEntryDialog,
        backgroundColor: primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add, size: 22),
        label: const Text(
          'Write Reflection',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

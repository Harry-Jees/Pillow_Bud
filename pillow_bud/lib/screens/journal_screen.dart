import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/models/journal_entry.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final savedEntries = StorageService.getJournalEntries();
    ref.read(journalEntriesProvider.notifier).state = savedEntries;
  }

  Future<void> _saveEntry() async {
    if (_controller.text.trim().isEmpty) return;

    final entry = JournalEntry(
      id: DateTime.now().toIso8601String(),
      text: _controller.text.trim(),
      mood: _selectedMood,
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
    );

    final entries = [entry, ...ref.read(journalEntriesProvider)];
    ref.read(journalEntriesProvider.notifier).state = entries;
    await StorageService.saveJournalEntries(entries);

    _controller.clear();
    setState(() {
      _selectedMood = '😌';
    });
    Navigator.pop(context);
  }

  void _showEntryDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    entry.mood,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateUtils.formatDateTime(entry.dateCreated),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Journal Entry',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                entry.text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Text(
                  'No entries yet. Start writing!',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return GestureDetector(
                    onTap: () => _showEntryDialog(entry),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateUtils.formatTime(entry.dateCreated),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              Text(entry.mood,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewEntryDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Journal Entry',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                    hintText: 'Write your thoughts...',
                    hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                ),
                style: const TextStyle(color: AppColors.textPrimaryDark),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mood:', style: TextStyle(fontSize: 12)),
                  Row(
                    children: ['😤', '😢', '😌', '😊', '😄'].map((emoji) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = emoji),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedMood == emoji
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveEntry();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

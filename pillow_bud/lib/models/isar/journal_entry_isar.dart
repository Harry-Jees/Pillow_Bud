import 'package:isar/isar.dart';

part 'journal_entry_isar.g.dart';

@Collection()
class JournalEntryIsar {
  Id id = Isar.autoIncrement;

  late String entryId;

  late String text;

  late String mood;

  late DateTime dateCreated;

  late DateTime dateModified;
}

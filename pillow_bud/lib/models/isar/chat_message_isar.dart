import 'package:isar/isar.dart';

part 'chat_message_isar.g.dart';

@Collection()
class ChatMessageIsar {
  Id id = Isar.autoIncrement;

  late String messageId; // UUID or timestamp id

  late String sessionId;

  late String role; // user | bud

  late String content;

  late DateTime createdAt;

  String? mood;

  double? intensity;
}

import 'base_message.dart';
import 'user.dart';

class CustomMessage extends BaseMessage {
  final String receiverId;
  final String receiverType;
  final String customType;
  final Map<String, dynamic> customData;
  final User sender;

  CustomMessage(
    this.receiverId,
    this.receiverType,
    this.customType,
    this.customData, {
    this.sender,
  });

  factory CustomMessage.fromMap(dynamic map) {
    if (map == null) return null;

    return CustomMessage(
      map['receiverId'],
      map['receiverType'],
      map['customType'],
      Map<String, dynamic>.from(map['customData'] ?? {}),
      sender: User.fromMap(map['sender']),
    );
  }
}

class Notification {
  String id;
  String userId;
  String title;
  String body;
  DateTime timestamp;
  bool isRead;
  String type; // e.g., "ride_request", "ride_update", "message"
  Map<String, dynamic> data;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.data = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
      'data': data,
    };
  }
}

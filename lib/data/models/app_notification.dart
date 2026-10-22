/// One notification of the delivery app's inbox (sent from the admin panel).
class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? sentAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.sentAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'app').toString(),
      isRead: json['is_read'] == true,
      sentAt: DateTime.tryParse('${json['sent_at'] ?? ''}')?.toLocal(),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        sentAt: sentAt,
      );
}

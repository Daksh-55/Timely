import 'package:hive/hive.dart';

part 'date_model.g.dart';

@HiveType(typeId: 0)
class ImportantDate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? description;

  @HiveField(4)
  List<int> notificationIds;

  @HiveField(5)
  bool isNotificationEnabled;

  @HiveField(6)
  DateTime createdAt;

  ImportantDate({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    List<int>? notificationIds,
    this.isNotificationEnabled = true,
    DateTime? createdAt,
  }) : 
    notificationIds = notificationIds ?? [],
    createdAt = createdAt ?? DateTime.now();

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    return eventDate.difference(today).inDays;
  }

  bool get isPassed {
    return daysUntil < 0;
  }

  bool get isToday {
    return daysUntil == 0;
  }

  bool get isUpcoming {
    return daysUntil > 0;
  }

  String get timeUntilText {
    if (isPassed) {
      return '${-daysUntil} days ago';
    } else if (isToday) {
      return 'Today';
    } else if (daysUntil == 1) {
      return 'Tomorrow';
    } else {
      return 'In $daysUntil days';
    }
  }

  ImportantDate copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? description,
    List<int>? notificationIds,
    bool? isNotificationEnabled,
    DateTime? createdAt,
  }) {
    return ImportantDate(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      notificationIds: notificationIds ?? this.notificationIds,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ImportantDate(id: $id, title: $title, date: $date, daysUntil: $daysUntil)';
  }
}
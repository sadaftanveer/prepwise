import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionCategory {
  flutter,
  firebase,
  dsa,
  hr,
}

enum QuestionDifficulty {
  easy,
  medium,
  hard,
}

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    required this.isMastered,
    this.notes = '',
    this.attachments = const <String>[],
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  final String id;
  final String question;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final bool isMastered;
  final String notes;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  QuestionModel copyWith({
    String? id,
    String? question,
    QuestionCategory? category,
    QuestionDifficulty? difficulty,
    bool? isMastered,
    String? notes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isMastered: isMastered ?? this.isMastered,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'question': question,
      'category': category.name,
      'difficulty': difficulty.name,
      'isMastered': isMastered,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as String? ?? '',
      question: map['question'] as String? ?? '',
      category: _parseCategory(map['category'] as String?),
      difficulty: _parseDifficulty(map['difficulty'] as String?),
      isMastered: map['isMastered'] as bool? ?? false,
      notes: map['notes'] as String? ?? '',
      attachments: _parseAttachments(map['attachments']),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      userId: map['userId'] as String? ?? '',
    );
  }

  static QuestionCategory _parseCategory(String? value) {
    return QuestionCategory.values.firstWhere(
      (QuestionCategory item) => item.name == value,
      orElse: () => QuestionCategory.flutter,
    );
  }

  static QuestionDifficulty _parseDifficulty(String? value) {
    return QuestionDifficulty.values.firstWhere(
      (QuestionDifficulty item) => item.name == value,
      orElse: () => QuestionDifficulty.easy,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static List<String> _parseAttachments(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const <String>[];
  }
}

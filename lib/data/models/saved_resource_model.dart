import 'package:cloud_firestore/cloud_firestore.dart';

class SavedResource {
  const SavedResource({
    required this.id,
    required this.title,
    required this.url,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String url;
  final String category;
  final DateTime createdAt;

  factory SavedResource.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final dynamic ts = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else if (ts is DateTime) {
      createdAt = ts;
    }

    return SavedResource(
      id: doc.id,
      title: data['title'] as String? ?? '',
      url: data['url'] as String? ?? '',
      category: data['category'] as String? ?? 'general',
      createdAt: createdAt,
    );
  }

  factory SavedResource.fromMap(Map<String, dynamic> data) {
    return SavedResource(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      url: data['url'] as String? ?? '',
      category: data['category'] as String? ?? 'general',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'url': url,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

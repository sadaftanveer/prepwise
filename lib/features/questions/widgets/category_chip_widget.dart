import 'package:flutter/material.dart';

import '../../../data/models/question_model.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  factory CategoryChip.fromCategory({
    required QuestionCategory category,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return CategoryChip(
      label: category.name.toUpperCase(),
      selected: selected,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

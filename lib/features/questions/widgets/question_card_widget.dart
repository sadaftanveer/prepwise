import 'package:flutter/material.dart';

import '../../../data/models/question_model.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.onMasteredChanged,
  });

  final QuestionModel question;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onMasteredChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                question.question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                question.notes.isEmpty ? 'No notes yet' : question.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  _InfoChip(label: question.category.name.toUpperCase()),
                  const SizedBox(width: 8),
                  _InfoChip(label: question.difficulty.name.toUpperCase()),
                  if (question.attachments.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    _InfoChip(label: '${question.attachments.length} FILES'),
                  ],
                  const Spacer(),
                  Checkbox(
                    value: question.isMastered,
                    onChanged: onMasteredChanged == null
                        ? null
                        : (bool? value) {
                            if (value == null) {
                              return;
                            }
                            onMasteredChanged!(value);
                          },
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(31),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

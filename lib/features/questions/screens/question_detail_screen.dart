import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routes/route_names.dart';
import '../../../data/models/question_model.dart';
import '../providers/question_provider.dart';

class QuestionDetailScreen extends StatelessWidget {
  const QuestionDetailScreen({super.key, required this.question});

  final QuestionModel question;

  Future<void> _openAttachment(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestionProvider provider = context.read<QuestionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).pushNamed(
              RouteNames.addQuestion,
              arguments: question,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await provider.deleteQuestion(question.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                _InfoChip(label: question.category.name.toUpperCase()),
                const SizedBox(width: 8),
                _InfoChip(label: question.difficulty.name.toUpperCase()),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(question.notes.isEmpty ? 'No notes added.' : question.notes),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Text('Mastered'),
                const Spacer(),
                Switch(
                  value: question.isMastered,
                  onChanged: (bool value) =>
                      provider.toggleMastered(question, value),
                ),
              ],
            ),
            if (question.attachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Attachments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...question.attachments.map(
                (String url) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_file),
                  title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => _openAttachment(url),
                ),
              ),
            ],
          ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/interview_resources.dart';
import '../../../core/routes/route_names.dart';
import '../../../data/models/question_model.dart';
import '../providers/question_provider.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/question_card_widget.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuestionProvider provider = context.watch<QuestionProvider>();
    final QuestionCategory? selectedCategory = provider.selectedCategory;
    final List<ResourceLink> resources = selectedCategory == null
        ? InterviewResources.general
        : (InterviewResources.byCategory[selectedCategory] ??
            InterviewResources.general);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  CategoryChip(
                    label: 'ALL',
                    selected: provider.selectedCategory == null,
                    onTap: () => context.read<QuestionProvider>().setCategoryFilter(null),
                  ),
                  const SizedBox(width: 8),
                  ...QuestionCategory.values.map((QuestionCategory category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip.fromCategory(
                        category: category,
                        selected: provider.selectedCategory == category,
                        onTap: () =>
                            context.read<QuestionProvider>().setCategoryFilter(category),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ResourcesSection(resources: resources),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Text(provider.error!))
                      : ListView.separated(
                          itemCount: provider.questions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (BuildContext context, int index) {
                            final question = provider.questions[index];
                            return QuestionCard(
                              question: question,
                              onTap: () => Navigator.of(context).pushNamed(
                                RouteNames.questionDetail,
                                arguments: question,
                              ),
                              onMasteredChanged: (bool value) =>
                                  provider.toggleMastered(question, value),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourcesSection extends StatelessWidget {
  const _ResourcesSection({required this.resources});

  final List<ResourceLink> resources;

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Interview Resources',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...resources.map(
              (ResourceLink link) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link),
                title: Text(link.title),
                subtitle:
                    Text(link.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => _openUrl(link.url),
                trailing: const Icon(Icons.open_in_new, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

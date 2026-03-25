import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/route_names.dart';
import '../providers/question_provider.dart';
import '../widgets/question_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionProvider>().loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final QuestionProvider provider = context.watch<QuestionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('PrepWise')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.addQuestion),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Total: ${provider.totalCount} | Mastered: ${provider.masteredCount}'),
            const SizedBox(height: 12),
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

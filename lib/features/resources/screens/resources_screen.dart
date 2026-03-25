import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/interview_resources.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/saved_resource_model.dart';
import '../../../data/repositories/resources_repository.dart';
import '../../auth/providers/auth_provider.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ResourcesRepository _repository = ResourcesRepository();
  final List<SavedResource> _cachedSaved = <SavedResource>[];
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCached();
  }

  Future<void> _loadCached() async {
    final List<SavedResource> cached = await _repository.loadCachedSaved();
    if (!mounted) {
      return;
    }
    setState(() {
      _cachedSaved
        ..clear()
        ..addAll(cached);
    });
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _search() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    final String encoded = Uri.encodeComponent('interview $query');
    await _openUrl('https://www.google.com/search?q=$encoded');
  }

  @override
  Widget build(BuildContext context) {
    final bool authed = context.watch<AuthProvider>().isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<SavedResource>>(
          stream: authed ? _repository.watchSaved() : const Stream.empty(),
          builder: (BuildContext context, AsyncSnapshot<List<SavedResource>> snap) {
            final List<SavedResource> saved = snap.hasData
                ? snap.data!
                : (snap.hasError ? _cachedSaved : _cachedSaved);
            if (snap.hasData) {
              _repository.cacheSaved(saved);
            }
            return ListView(
              children: <Widget>[
                _SearchBar(
                  controller: _searchController,
                  onSearch: _search,
                ),
                const SizedBox(height: 16),
                _FilterBar(
                  selected: _filter,
                  onSelected: (String value) {
                    setState(() => _filter = value);
                  },
                ),
                const SizedBox(height: 12),
                if (!authed)
                  const _HintCard(
                    text: 'Sign in to save and sync resources.',
                  ),
                if (authed && saved.isNotEmpty) ...<Widget>[
                  _SectionHeader(title: 'Saved Resources'),
                  const SizedBox(height: 8),
                  ..._applyFilter(saved)
                      .map(
                    (SavedResource item) => _ResourceTile(
                      title: item.title,
                      url: item.url,
                      onTap: () => _openUrl(item.url),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_remove_outlined),
                        onPressed: () =>
                            _repository.removeResource(resourceId: item.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_filter == 'all' || _filter == 'general')
                  _SectionHeader(title: 'General Interview'),
                const SizedBox(height: 8),
                if (_filter == 'all' || _filter == 'general')
                  ...InterviewResources.general.map(
                    (ResourceLink link) => _SaveableResourceTile(
                      link: link,
                      category: 'general',
                      savedIds: saved.map((SavedResource r) => r.id).toSet(),
                      repo: _repository,
                      onTap: () => _openUrl(link.url),
                    ),
                  ),
                if (_filter == 'all' || _filter == 'general')
                  const SizedBox(height: 16),
                if (_filter == 'all' || _filter == 'flutter')
                  _SectionHeader(title: 'Flutter'),
                if (_filter == 'all' || _filter == 'flutter')
                  const SizedBox(height: 8),
                if (_filter == 'all' || _filter == 'flutter')
                  ...InterviewResources.byCategory[QuestionCategory.flutter]!
                      .map(
                    (ResourceLink link) => _SaveableResourceTile(
                      link: link,
                      category: 'flutter',
                      savedIds: saved.map((SavedResource r) => r.id).toSet(),
                      repo: _repository,
                      onTap: () => _openUrl(link.url),
                    ),
                  ),
                if (_filter == 'all' || _filter == 'flutter')
                  const SizedBox(height: 16),
                if (_filter == 'all' || _filter == 'firebase')
                  _SectionHeader(title: 'Firebase'),
                if (_filter == 'all' || _filter == 'firebase')
                  const SizedBox(height: 8),
                if (_filter == 'all' || _filter == 'firebase')
                  ...InterviewResources.byCategory[QuestionCategory.firebase]!
                      .map(
                    (ResourceLink link) => _SaveableResourceTile(
                      link: link,
                      category: 'firebase',
                      savedIds: saved.map((SavedResource r) => r.id).toSet(),
                      repo: _repository,
                      onTap: () => _openUrl(link.url),
                    ),
                  ),
                if (_filter == 'all' || _filter == 'firebase')
                  const SizedBox(height: 16),
                if (_filter == 'all' || _filter == 'dsa')
                  _SectionHeader(title: 'DSA'),
                if (_filter == 'all' || _filter == 'dsa')
                  const SizedBox(height: 8),
                if (_filter == 'all' || _filter == 'dsa')
                  ...InterviewResources.byCategory[QuestionCategory.dsa]!.map(
                    (ResourceLink link) => _SaveableResourceTile(
                      link: link,
                      category: 'dsa',
                      savedIds: saved.map((SavedResource r) => r.id).toSet(),
                      repo: _repository,
                      onTap: () => _openUrl(link.url),
                    ),
                  ),
                if (_filter == 'all' || _filter == 'dsa')
                  const SizedBox(height: 16),
                if (_filter == 'all' || _filter == 'hr')
                  _SectionHeader(title: 'HR'),
                if (_filter == 'all' || _filter == 'hr')
                  const SizedBox(height: 8),
                if (_filter == 'all' || _filter == 'hr')
                  ...InterviewResources.byCategory[QuestionCategory.hr]!.map(
                    (ResourceLink link) => _SaveableResourceTile(
                      link: link,
                      category: 'hr',
                      savedIds: saved.map((SavedResource r) => r.id).toSet(),
                      repo: _repository,
                      onTap: () => _openUrl(link.url),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<SavedResource> _applyFilter(List<SavedResource> items) {
    if (_filter == 'all') {
      return items;
    }
    return items.where((SavedResource r) => r.category == _filter).toList();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Search interview topics',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onSearch,
          child: const Text('Search'),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<String> values = <String>[
      'all',
      'general',
      'flutter',
      'firebase',
      'dsa',
      'hr',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values
            .map(
              (String value) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(value.toUpperCase()),
                  selected: selected == value,
                  onSelected: (_) => onSelected(value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SaveableResourceTile extends StatelessWidget {
  const _SaveableResourceTile({
    required this.link,
    required this.category,
    required this.savedIds,
    required this.repo,
    required this.onTap,
  });

  final ResourceLink link;
  final String category;
  final Set<String> savedIds;
  final ResourcesRepository repo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String id = repo.resourceIdFromUrl(link.url);
    final bool isSaved = savedIds.contains(id);

    return _ResourceTile(
      title: link.title,
      url: link.url,
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
        onPressed: () async {
          if (isSaved) {
            await repo.removeResource(resourceId: id);
          } else {
            await repo.saveResource(link: link, category: category);
          }
        },
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.title,
    required this.url,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String url;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: const Icon(Icons.link),
        trailing: trailing ?? const Icon(Icons.open_in_new, size: 18),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.info_outline),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}


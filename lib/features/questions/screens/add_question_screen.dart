import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/question_model.dart';
import '../../../data/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/question_provider.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key, this.initialQuestion});

  final QuestionModel? initialQuestion;

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  QuestionCategory _category = QuestionCategory.flutter;
  QuestionDifficulty _difficulty = QuestionDifficulty.easy;
  bool _isMastered = false;
  final List<PlatformFile> _attachments = <PlatformFile>[];
  late final List<String> _existingAttachments;
  bool _isUploading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final QuestionModel? question = widget.initialQuestion;
    _existingAttachments = question?.attachments ?? <String>[];
    if (question != null) {
      _questionController.text = question.question;
      _notesController.text = question.notes;
      _category = question.category;
      _difficulty = question.difficulty;
      _isMastered = question.isMastered;
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add questions')),
      );
      return;
    }

    final DateTime now = DateTime.now();
    final StorageService storageService = StorageService();
    final List<String> attachmentUrls = <String>[];

    if (_attachments.isNotEmpty) {
      setState(() => _isUploading = true);
      for (final PlatformFile file in _attachments) {
        if (file.path == null) {
          continue;
        }
        final String url = await storageService.uploadAttachment(
          userId: userId,
          file: File(file.path!),
          filename: file.name,
        );
        attachmentUrls.add(url);
      }
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }

    final QuestionModel question = QuestionModel(
      id: widget.initialQuestion?.id ?? now.microsecondsSinceEpoch.toString(),
      question: _questionController.text.trim(),
      category: _category,
      difficulty: _difficulty,
      isMastered: _isMastered,
      notes: _notesController.text.trim(),
      attachments: <String>[
        ..._existingAttachments,
        ...attachmentUrls,
      ],
      createdAt: widget.initialQuestion?.createdAt ?? now,
      updatedAt: now,
      userId: userId,
    );

    if (!mounted) {
      return;
    }

    final QuestionProvider provider = context.read<QuestionProvider>();
    if (widget.initialQuestion == null) {
      await provider.addQuestion(question);
    } else {
      await provider.updateQuestion(question);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialQuestion == null ? 'Add Question' : 'Edit Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (String? value) =>
                    Validators.requiredField(value, field: 'Question'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<QuestionCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: QuestionCategory.values
                    .map(
                      (QuestionCategory c) => DropdownMenuItem<QuestionCategory>(
                        value: c,
                        child: Text(c.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (QuestionCategory? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<QuestionDifficulty>(
                initialValue: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: QuestionDifficulty.values
                    .map(
                      (QuestionDifficulty d) => DropdownMenuItem<QuestionDifficulty>(
                        value: d,
                        child: Text(d.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (QuestionDifficulty? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _difficulty = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                              );
                              if (result == null) {
                                return;
                              }
                              setState(() {
                                _attachments
                                  ..clear()
                                  ..addAll(result.files);
                              });
                            },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add Attachments'),
                    ),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _attachments
                      .map((PlatformFile file) => Chip(label: Text(file.name)))
                      .toList(),
                ),
              ],
              if (_existingAttachments.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _existingAttachments
                      .map((String url) => Chip(
                            label: Text(
                              url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as Mastered'),
                value: _isMastered,
                onChanged: (bool value) => setState(() => _isMastered = value),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isUploading ? null : _saveQuestion,
                child: Text(
                  _isUploading
                      ? 'Uploading...'
                      : widget.initialQuestion == null
                          ? 'Save Question'
                          : 'Save Changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

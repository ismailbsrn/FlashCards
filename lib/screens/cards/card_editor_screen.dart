import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/collection_model.dart';
import '../../models/card_model.dart';
import '../../providers/card_provider.dart';
import '../../providers/auth_provider.dart';

class CardEditorScreen extends StatefulWidget {
  final CollectionModel collection;
  final CardModel? card;

  const CardEditorScreen({
    super.key,
    required this.collection,
    this.card,
  });

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _frontController;
  late TextEditingController _backController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.card != null;
    _frontController = TextEditingController(text: widget.card?.front ?? '');
    _backController = TextEditingController(text: widget.card?.back ?? '');
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_isEditing && widget.card != null) {
        await cardProvider.updateCard(
          widget.card!,
          _frontController.text.trim(),
          _backController.text.trim(),
          onSyncNeeded: () {
            authProvider.scheduleDebouncedSync();
          },
        );
      } else {
        await cardProvider.createCard(
          collectionId: widget.collection.id,
          front: _frontController.text.trim(),
          back: _backController.text.trim(),
          onSyncNeeded: () {
            authProvider.scheduleDebouncedSync();
          },
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'New Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Front',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _frontController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the question or prompt',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the front of the card';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Back',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _backController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the answer',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the back of the card';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isEditing ? 'Update Card' : 'Create Card'),
            ),
          ],
        ),
      ),
    );
  }
}

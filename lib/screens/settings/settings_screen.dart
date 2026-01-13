import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await settingsProvider.loadSettings(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsProvider.settings;
          if (settings == null) {
            return const Center(child: Text('Failed to load settings'));
          }

          return ListView(
            children: [
              // Language Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.language,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.language),
                leading: const Icon(Icons.language),
                trailing: DropdownButton<Locale>(
                  value: settingsProvider.locale ?? const Locale('en'),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      settingsProvider.setLocale(newLocale);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('tr'),
                      child: Text('Türkçe'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Study Settings Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.studySettings,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Maximum Reviews Per Day'),
                subtitle: Text('${settings.maxReviewsPerDay} cards'),
                leading: const Icon(Icons.repeat),
                onTap: () => _showNumberDialog(
                  context,
                  'Maximum Reviews Per Day',
                  settings.maxReviewsPerDay,
                  (value) {
                    final updated = settings.copyWith(maxReviewsPerDay: value);
                    settingsProvider.updateSettings(updated);
                  },
                ),
              ),
              ListTile(
                title: const Text('Maximum New Cards Per Day'),
                subtitle: Text('${settings.maxNewCardsPerDay} cards'),
                leading: const Icon(Icons.new_releases),
                onTap: () => _showNumberDialog(
                  context,
                  'Maximum New Cards Per Day',
                  settings.maxNewCardsPerDay,
                  (value) {
                    final updated = settings.copyWith(maxNewCardsPerDay: value);
                    settingsProvider.updateSettings(updated);
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Show Answer Timer'),
                subtitle: const Text('Display time taken to answer'),
                secondary: const Icon(Icons.timer),
                value: settings.showAnswerTimer,
                onChanged: (value) {
                  final updated = settings.copyWith(showAnswerTimer: value);
                  settingsProvider.updateSettings(updated);
                },
              ),
              SwitchListTile(
                title: const Text('Show Interval Buttons'),
                subtitle: const Text(
                  'Display next review intervals under buttons',
                ),
                secondary: const Icon(Icons.schedule),
                value: settings.showIntervalButtons,
                onChanged: (value) {
                  final updated = settings.copyWith(showIntervalButtons: value);
                  settingsProvider.updateSettings(updated);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.appearance,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkMode),
                subtitle: const Text('Use dark theme'),
                secondary: const Icon(Icons.dark_mode),
                value: settings.darkMode,
                onChanged: (value) {
                  final updated = settings.copyWith(darkMode: value);
                  settingsProvider.updateSettings(updated);
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  if (user == null) return const SizedBox.shrink();

                  return Column(
                    children: [
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                        leading: const Icon(Icons.email),
                      ),
                      if (user.displayName != null)
                        ListTile(
                          title: const Text('Display Name'),
                          subtitle: Text(user.displayName!),
                          leading: const Icon(Icons.person),
                        ),
                      ListTile(
                        title: const Text('Last Sync'),
                        subtitle: Text(
                          user.lastSyncAt != null
                              ? _formatDateTime(user.lastSyncAt!)
                              : 'Never',
                        ),
                        leading: const Icon(Icons.sync),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.about,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.version),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info),
              ),
              const ListTile(
                title: Text('Flashcards App'),
                subtitle: Text('An offline-first flashcard application'),
                leading: Icon(Icons.style),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showNumberDialog(
    BuildContext context,
    String title,
    int currentValue,
    Function(int) onSave,
  ) async {
    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Value',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final value = int.tryParse(controller.text);
      if (value != null && value > 0) {
        onSave(value);
      }
    }

    controller.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

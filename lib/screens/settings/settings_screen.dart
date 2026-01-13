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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsProvider.settings;
          if (settings == null) {
            return Center(child: Text(l10n.failedToLoadSettings));
          }

          return ListView(
            children: [
              // Language Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.language),
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
                  l10n.studySettings,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.maxReviewsPerDay),
                subtitle: Text(l10n.cardsCount(settings.maxReviewsPerDay)),
                leading: const Icon(Icons.repeat),
                onTap: () => _showNumberDialog(
                  context,
                  l10n.maxReviewsPerDay,
                  settings.maxReviewsPerDay,
                  (value) {
                    final updated = settings.copyWith(maxReviewsPerDay: value);
                    settingsProvider.updateSettings(updated);
                  },
                ),
              ),
              ListTile(
                title: Text(l10n.maxNewCardsPerDay),
                subtitle: Text(l10n.cardsCount(settings.maxNewCardsPerDay)),
                leading: const Icon(Icons.new_releases),
                onTap: () => _showNumberDialog(
                  context,
                  l10n.maxNewCardsPerDay,
                  settings.maxNewCardsPerDay,
                  (value) {
                    final updated = settings.copyWith(maxNewCardsPerDay: value);
                    settingsProvider.updateSettings(updated);
                  },
                ),
              ),
              SwitchListTile(
                title: Text(l10n.showAnswerTimer),
                subtitle: Text(l10n.displayTimeTakenToAnswer),
                secondary: const Icon(Icons.timer),
                value: settings.showAnswerTimer,
                onChanged: (value) {
                  final updated = settings.copyWith(showAnswerTimer: value);
                  settingsProvider.updateSettings(updated);
                },
              ),
              SwitchListTile(
                title: Text(l10n.showIntervalButtons),
                subtitle: Text(l10n.displayNextReviewIntervals),
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
                  l10n.appearance,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.useDarkTheme),
                secondary: const Icon(Icons.dark_mode),
                value: settings.darkMode,
                onChanged: (value) {
                  final updated = settings.copyWith(darkMode: value);
                  settingsProvider.updateSettings(updated);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.account,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  if (user == null) return const SizedBox.shrink();

                  return Column(
                    children: [
                      ListTile(
                        title: Text(l10n.email),
                        subtitle: Text(user.email),
                        leading: const Icon(Icons.email),
                      ),
                      if (user.displayName != null)
                        ListTile(
                          title: Text(l10n.displayName),
                          subtitle: Text(user.displayName!),
                          leading: const Icon(Icons.person),
                        ),
                      ListTile(
                        title: Text(l10n.lastSyncLabel),
                        subtitle: Text(
                          user.lastSyncAt != null
                              ? _formatDateTime(user.lastSyncAt!, l10n)
                              : l10n.never,
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
                  l10n.about,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.version),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info),
              ),
              ListTile(
                title: Text(l10n.flashcardsApp),
                subtitle: Text(l10n.offlineFirstFlashcardApp),
                leading: const Icon(Icons.style),
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.value,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
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

  String _formatDateTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

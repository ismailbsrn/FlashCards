import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sync_service.dart';
import '../../services/import_export_service.dart';
import 'dashboard.dart';
import '../collections/collections_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final SyncService _syncService = SyncService();
  final ImportExportService _importExportService = ImportExportService();
  bool _isSyncing = false;
  bool _collectionsInSelectionMode = false;
  final GlobalKey<DashboardTabState> _dashboardKey =
      GlobalKey<DashboardTabState>();
  final GlobalKey<ProfileTabState> _profileKey = GlobalKey<ProfileTabState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.onSyncCompleted = () {
        _profileKey.currentState?.refreshSyncCount();
        _dashboardKey.currentState?.loadData();
      };
    });
  }

  List<Widget> get _pages => [
    DashboardTab(
      key: _dashboardKey,
      onViewAllCollections: () {
        setState(() {
          _currentIndex = 1;
        });
      },
    ),
    CollectionsListScreen(
      onSelectionModeChanged: (inSelectionMode) {
        setState(() {
          _collectionsInSelectionMode = inSelectionMode;
        });
      },
    ),
    ProfileTab(key: _profileKey),
  ];

  Future<void> _performSync() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSyncing = true);

    final result = await _syncService.sync();

    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success']
                ? l10n.syncCompleted
                : l10n.syncFailed(result['error'] ?? ''),
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.reloadUser();

        final collectionProvider = Provider.of<CollectionProvider>(
          context,
          listen: false,
        );
        if (authProvider.currentUser != null) {
          await collectionProvider.loadCollections(
            authProvider.currentUser!.id,
          );
        }

        _dashboardKey.currentState?.loadData();
        _profileKey.currentState?.refreshSyncCount();
      }
    }
  }

  Future<void> _importCollections() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    final result = await _importExportService.importCollection(
      authProvider.currentUser!.id,
    );

    if (mounted) {
      if (result['success']) {
        final collectionProvider = Provider.of<CollectionProvider>(
          context,
          listen: false,
        );
        await collectionProvider.loadCollections(authProvider.currentUser!.id);

        _dashboardKey.currentState?.loadData();

        final failedFiles = result['failedFiles'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.importedCollections(
                result['collections'],
                result['cards'],
                failedFiles > 0 ? ' ($failedFiles file(s) failed)' : '',
              ),
            ),
            backgroundColor: failedFiles > 0 ? Colors.orange : Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importFailed(result['error'] ?? '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String title = l10n.home;
    if (_currentIndex == 1) {
      title = l10n.collections;
    } else if (_currentIndex == 2) {
      title = l10n.profile;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        centerTitle: true,
        actions: [
          if (_currentIndex == 0)
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                final isDarkMode = settingsProvider.settings?.darkMode ?? false;
                return IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () async {
                    final settings = settingsProvider.settings;
                    if (settings != null) {
                      final updated = settings.copyWith(darkMode: !isDarkMode);
                      await settingsProvider.updateSettings(updated);
                    }
                  },
                  tooltip: isDarkMode ? l10n.lightMode : l10n.darkMode,
                );
              },
            ),
          if (_currentIndex == 1 || _currentIndex == 2)
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              onPressed: _isSyncing ? null : _performSync,
              tooltip: l10n.syncTooltip,
            ),
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: _importCollections,
              tooltip: l10n.importCollections,
            ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _dashboardKey.currentState?.loadData();
          } else if (index == 2) {
            _profileKey.currentState?.refreshSyncCount();
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark_outlined),
            selectedIcon: const Icon(Icons.collections_bookmark),
            label: l10n.collections,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 && !_collectionsInSelectionMode
          ? FloatingActionButton(
              onPressed: () => _showCreateCollectionDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _showCreateCollectionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagController = TextEditingController();
    List<String> tags = [];
    Color selectedColor = Colors.blue;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createCollection),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                Text(
                  l10n.tags,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tagController,
                        decoration: InputDecoration(
                          labelText: l10n.addTag,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              tags.add(value.trim());
                              tagController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (tagController.text.trim().isNotEmpty) {
                          setState(() {
                            tags.add(tagController.text.trim());
                            tagController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                if (tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() {
                              tags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                Text(
                  l10n.color,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ColorPicker(
                  color: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() => selectedColor = color);
                  },
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  spacing: 5,
                  runSpacing: 5,
                  wheelDiameter: 155,
                  enableShadesSelection: false,
                  pickersEnabled: const {ColorPickerType.wheel: true},
                  heading: const SizedBox.shrink(),
                  subheading: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.of(context).pop({
                    'name': nameController.text.trim(),
                    'description': descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    'tags': tags,
                    'color':
                        '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  });
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    descriptionController.dispose();
    tagController.dispose();

    if (result != null && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final collectionProvider = Provider.of<CollectionProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        await collectionProvider.createCollection(
          userId: authProvider.currentUser!.id,
          name: result['name'],
          description: result['description'],
          tags: result['tags'],
          color: result['color'],
          onSyncNeeded: () {
            authProvider.scheduleDebouncedSync();
          },
        );
      }
    }
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => ProfileTabState();
}

class ProfileTabState extends State<ProfileTab>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  @override
  bool get wantKeepAlive => true;

  void refreshSyncCount() {
    _profileKey.currentState?.loadSyncCount();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProfileScreen(key: _profileKey);
  }
}

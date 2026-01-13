import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/sync_service.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  final SyncService _syncService = SyncService();
  int _pendingSyncCount = 0;
  bool _isLoadingSyncCount = false;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSyncCount();
    });
  }

  Future<void> loadSyncCount() async {
    if (_isLoadingSyncCount) return;
    
    setState(() => _isLoadingSyncCount = true);
    final count = await _syncService.getPendingSyncCount();
    if (mounted) {
      setState(() {
        _pendingSyncCount = count;
        _isLoadingSyncCount = false;
      });
    }
  }

  Future<void> _clearSyncQueue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Queue'),
        content: const Text(
          'Are you sure you want to clear all pending sync items? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _syncService.clearSyncQueue();
      await loadSyncCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync queue cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(
            child: Text('No user data available'),
          );
        }

        return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (user.displayName ?? user.email)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Display Name'),
                      subtitle: Text(user.displayName ?? 'Not set'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Member Since'),
                      subtitle: Text(
                        '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    if (user.lastSyncAt != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.sync),
                        title: const Text('Last Sync'),
                        subtitle: Text(
                          '${user.lastSyncAt!.year}-${user.lastSyncAt!.month.toString().padLeft(2, '0')}-${user.lastSyncAt!.day.toString().padLeft(2, '0')} '
                          '${user.lastSyncAt!.hour.toString().padLeft(2, '0')}:${user.lastSyncAt!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_queue),
                      title: const Text('Pending Sync Items'),
                      subtitle: _isLoadingSyncCount
                          ? const Text('Loading...')
                          : Text('$_pendingSyncCount items'),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: loadSyncCount,
                      ),
                    ),
                    if (_pendingSyncCount > 0) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_sweep, color: Colors.red),
                        title: const Text('Clear Sync Queue'),
                        subtitle: const Text('Remove all pending sync items'),
                        onTap: _clearSyncQueue,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.sync),
                      title: const Text('Sync Now'),
                      subtitle: _pendingSyncCount > 0
                          ? Text('$_pendingSyncCount pending items')
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await _syncService.sync();
                        await loadSyncCount();
                        if (mounted) {
                          if (result['unauthorized'] == true) {
                            // Force provider logout and navigate to login
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['success']
                                    ? 'Sync completed successfully'
                                    : 'Sync failed: ${result['error']}',
                              ),
                              backgroundColor: result['success'] ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          );
      },
    );
  }
}

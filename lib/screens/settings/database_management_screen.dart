
import 'package:flutter/material.dart';
import '../../services/sync_management_service.dart';
import '../../models/sync_analysis_model.dart';

class DatabaseManagementScreen extends StatefulWidget {
  const DatabaseManagementScreen({super.key});

  @override
  State<DatabaseManagementScreen> createState() => _DatabaseManagementScreenState();
}

class _DatabaseManagementScreenState extends State<DatabaseManagementScreen> {
  final _service = SyncManagementService();
  List<CardSyncStatus>? _analysis;
  bool _isLoading = true;
  bool _isExecuting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await _service.analyzeSyncState();
      if (!mounted) return;
      setState(() {
        _analysis = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _applyChanges() async {
    if (_analysis == null) return;
    
    // Count actions
    final pendingActions = _analysis!.where((i) => i.selectedAction != SyncAction.none).toList();
    if (pendingActions.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Changes?'),
        content: Text('This will perform ${pendingActions.length} operations on your database.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apply')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isExecuting = true);
    try {
      await _service.executeActions(pendingActions);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database updated successfully')),
      );
      Navigator.pop(context); // Close screen on success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Database'),
        actions: [
          if (!_isLoading)
            IconButton(onPressed: _analyze, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning server... This may take a moment.'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    }

    if (_analysis == null || _analysis!.isEmpty) {
      return const Center(child: Text('No database entries found.'));
    }

    // Group items
    final corrupt  = _analysis!.where((i) => i.status == SyncStatusType.corrupt).toList();
    final orphans  = _analysis!.where((i) => i.status == SyncStatusType.orphaned).toList();
    final pending  = _analysis!.where((i) => i.status == SyncStatusType.pendingDeletion).toList();
    final toSync   = _analysis!.where((i) => i.status == SyncStatusType.localOnly || i.status == SyncStatusType.serverOnly).toList();
    final deleted  = _analysis!.where((i) => i.status == SyncStatusType.remoteDeleted).toList();
    final synced   = _analysis!.where((i) => i.status == SyncStatusType.synced).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80), // Space for bottom bar
      children: [
        if (corrupt.isNotEmpty) _buildSection('Corrupt Files (Delete Recommended)', corrupt, Colors.red),
        if (orphans.isNotEmpty) _buildSection('Orphaned Files (Recover)', orphans, Colors.orange),
        if (pending.isNotEmpty) _buildSection('Pending Deletion (Sync)', pending, Colors.brown),
        if (toSync.isNotEmpty) _buildSection('Sync Needed', toSync, Colors.blue),
        if (deleted.isNotEmpty) _buildSection('Trash', deleted, Colors.grey),
        if (synced.isNotEmpty) _buildSection('Synced (OK)', synced, Colors.green, initiallyExpanded: false),
      ],
    );
  }

  Widget _buildSection(String title, List<CardSyncStatus> items, Color color, {bool initiallyExpanded = true}) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      textColor: color,
      iconColor: color,
      title: Text('$title (${items.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
      children: items.map((item) => _buildItemTile(item)).toList(),
    );
  }

  Widget _buildItemTile(CardSyncStatus item) {
    return ListTile(
      leading: _buildStatusIcon(item.status),
      title: Text(item.name, overflow: TextOverflow.ellipsis),
      subtitle: Text('ID: ${item.uuid.substring(0, 8)}...'),
      trailing: DropdownButton<SyncAction>(
        value: item.selectedAction,
        underline: Container(), // Remove underline for cleaner look
        onChanged: (SyncAction? newAction) {
          if (newAction != null) {
            setState(() {
              item.selectedAction = newAction;
            });
          }
        },
        items: _getAvailableActions(item.status).map((action) {
          return DropdownMenuItem(
            value: action,
            child: Text(_getActionLabel(action, item.status)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusIcon(SyncStatusType status) {
    switch (status) {
      case SyncStatusType.orphaned:
        return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
      case SyncStatusType.corrupt:
        return const Icon(Icons.broken_image_outlined, color: Colors.red);
      case SyncStatusType.pendingDeletion:
        return const Icon(Icons.auto_delete_outlined, color: Colors.brown);
      case SyncStatusType.remoteDeleted:
        return const Icon(Icons.delete_outline, color: Colors.grey);
      case SyncStatusType.localOnly:
        return const Icon(Icons.phonelink_ring, color: Colors.blue);
      case SyncStatusType.serverOnly:
        return const Icon(Icons.cloud_download_outlined, color: Colors.purple);
      default:
        return const Icon(Icons.check_circle_outline, color: Colors.green);
    }
  }

  List<SyncAction> _getAvailableActions(SyncStatusType status) {
    switch (status) {
      case SyncStatusType.orphaned:
        return [SyncAction.addToManifest, SyncAction.deletePermanently, SyncAction.none];
      case SyncStatusType.corrupt:
        return [SyncAction.deletePermanently, SyncAction.none];
      case SyncStatusType.pendingDeletion:
        // Push deletion to server, pull back from server (restore), or wipe local
        return [SyncAction.uploadLocal, SyncAction.downloadRemote, SyncAction.deletePermanently, SyncAction.none]; 
      case SyncStatusType.remoteDeleted:
        return [SyncAction.none, SyncAction.restore, SyncAction.deletePermanently];
      case SyncStatusType.localOnly:
        return [SyncAction.uploadLocal, SyncAction.deletePermanently, SyncAction.none];
      case SyncStatusType.serverOnly:
        return [SyncAction.downloadRemote, SyncAction.deletePermanently, SyncAction.none];
      default:
        return [SyncAction.none];
    }
  }

  String _getActionLabel(SyncAction action, SyncStatusType status) {
    switch (action) {
      case SyncAction.none: return 'Ignore';
      case SyncAction.addToManifest: return 'Recover';
      case SyncAction.restore: return 'Undelete';
      case SyncAction.uploadLocal: 
        return status == SyncStatusType.pendingDeletion ? 'Sync Deletion' : 'Upload';
      case SyncAction.downloadRemote: 
        return status == SyncStatusType.pendingDeletion ? 'Restore from Server' : 'Download';
      case SyncAction.deletePermanently: return 'Delete Forever';
    }
  }

  Widget _buildBottomBar() {
    // Only show if actions are pending
    final count = _analysis?.where((i) => i.selectedAction != SyncAction.none).length ?? 0;
    
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
      ),
      child: SafeArea(
        child: FilledButton.icon(
          onPressed: _isExecuting ? null : _applyChanges,
          icon: _isExecuting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Icon(Icons.save),
          label: Text(_isExecuting ? 'Applying...' : 'Apply $count Changes'),
        ),
      ),
    );
  }
}

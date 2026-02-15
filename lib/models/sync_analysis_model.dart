
import 'card_model.dart';

enum SyncStatusType {
  synced,        // Exists everywhere, matches.
  localOnly,     // Only on device (needs upload).
  serverOnly,    // Only on server (needs download).
  orphaned,      // On server, but missing from Manifest (The "Lost" cards).
  remoteDeleted, // Exists on server but marked isDeleted=true (Tombstone).
  pendingDeletion, // Local isDeleted=true, Remote is Active (needs sync).
  corrupt,       // Remote file exists but is invalid (0 bytes etc).
  conflict,      // Exists both places but different versions (rare if using timestamps).
}

class CardSyncStatus {
  final String uuid;
  final String name;
  final DateTime updateDate;
  
  final CardModel? localCard;
  final CardModel? remoteCard; // The actual content of the file on server
  final bool isInManifest;
  
  // What the user wants to do with this item
  SyncAction selectedAction;

  CardSyncStatus({
    required this.uuid,
    required this.name,
    required this.updateDate,
    this.localCard,
    this.remoteCard,
    this.isInManifest = false,
    this.selectedAction = SyncAction.none,
  });

  SyncStatusType get status {
    if (remoteCard != null && remoteCard!.name.startsWith('(Corrupt)')) return SyncStatusType.corrupt;
    if (localCard != null && localCard!.isDeleted && (remoteCard == null || !remoteCard!.isDeleted)) return SyncStatusType.pendingDeletion;
    if (remoteCard != null && remoteCard!.isDeleted) return SyncStatusType.remoteDeleted;
    if (remoteCard != null && !isInManifest) return SyncStatusType.orphaned;
    if (localCard != null && remoteCard == null) return SyncStatusType.localOnly;
    if (localCard == null && remoteCard != null) return SyncStatusType.serverOnly;
    return SyncStatusType.synced;
  }
}

enum SyncAction {
  none,             // Do nothing
  uploadLocal,      // Push local to server (fixes Local Only)
  downloadRemote,   // Pull remote to local (fixes Server Only)
  restore,          // Un-delete a remote tombstone
  addToManifest,    // Add orphan to manifest & database
  deletePermanently // Delete from both (cleanup)
}

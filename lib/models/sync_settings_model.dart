class SyncSettingsModel {
  final String? serverAddress;
  final String? username;
  final String? password;
  final bool isConnected;
  final DateTime? lastSyncDate;
  final bool globalFolderAvailable;
  final DateTime? lastSyncAttempt;
  final bool lastSyncSuccess;
  final String? lastSyncError;
  final bool useParallelSync;

  SyncSettingsModel({
    this.serverAddress,
    this.username,
    this.password,
    this.isConnected = false,
    this.lastSyncDate,
    this.globalFolderAvailable = false,
    this.lastSyncAttempt,
    this.lastSyncSuccess = true,
    this.lastSyncError,
    this.useParallelSync = true, // Default to parallel (faster)
  });

  SyncSettingsModel copyWith({
    String? serverAddress,
    String? username,
    String? password,
    bool? isConnected,
    DateTime? lastSyncDate,
    bool? globalFolderAvailable,
    DateTime? lastSyncAttempt,
    bool? lastSyncSuccess,
    String? lastSyncError,
    bool? useParallelSync,
  }) {
    return SyncSettingsModel(
      serverAddress: serverAddress ?? this.serverAddress,
      username: username ?? this.username,
      password: password ?? this.password,
      isConnected: isConnected ?? this.isConnected,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      globalFolderAvailable: globalFolderAvailable ?? this.globalFolderAvailable,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      lastSyncSuccess: lastSyncSuccess ?? this.lastSyncSuccess,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      useParallelSync: useParallelSync ?? this.useParallelSync,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serverAddress': serverAddress,
      'username': username,
      'password': password,
      'isConnected': isConnected,
      'lastSyncDate': lastSyncDate?.millisecondsSinceEpoch,
      'globalFolderAvailable': globalFolderAvailable,
      'lastSyncAttempt': lastSyncAttempt?.millisecondsSinceEpoch,
      'lastSyncSuccess': lastSyncSuccess,
      'lastSyncError': lastSyncError,
      'useParallelSync': useParallelSync,
    };
  }

  factory SyncSettingsModel.fromMap(Map<String, dynamic> map) {
    return SyncSettingsModel(
      serverAddress: map['serverAddress'],
      username: map['username'],
      password: map['password'],
      isConnected: map['isConnected'] ?? false,
      lastSyncDate: map['lastSyncDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncDate'])
          : null,
      globalFolderAvailable: map['globalFolderAvailable'] ?? false,
      lastSyncAttempt: map['lastSyncAttempt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncAttempt'])
          : null,
      lastSyncSuccess: map['lastSyncSuccess'] ?? true,
      lastSyncError: map['lastSyncError'],
      useParallelSync: map['useParallelSync'] ?? true, // Default to parallel
    );
  }

  bool get hasCredentials {
    return serverAddress != null &&
        username != null &&
        password != null;
  }

  bool get canSync {
    return hasCredentials && isConnected;
  }
}


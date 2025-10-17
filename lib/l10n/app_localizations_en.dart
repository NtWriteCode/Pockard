// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get addCard => 'Add Card';

  @override
  String get addCoverImageToCard => 'Add a cover image to this card';

  @override
  String get adjustLogo => 'Adjust Logo';

  @override
  String get allCards => 'All';

  @override
  String get appName => 'Pockard';

  @override
  String get autoOpenCamera => 'Auto-open camera';

  @override
  String get autoOpenCameraDescription => 'Automatically open camera when adding a new card';

  @override
  String get backgroundColor => 'Background Color';

  @override
  String get barcodeDataHint => 'Or enter barcode data manually';

  @override
  String barcodeError(Object error) {
    return 'Error scanning barcode: $error';
  }

  @override
  String get barcodeImageUploaded => 'Barcode image uploaded';

  @override
  String get barcodePreviewHint => 'Scan or enter barcode data to see preview';

  @override
  String get barcodeInformation => 'Barcode Information';

  @override
  String get barcodeLabel => 'Barcode/QR Code';

  @override
  String get barcodePreview => 'Barcode Preview';

  @override
  String get barcodeTypeLabel => 'Barcode Type';

  @override
  String get black => 'Black';

  @override
  String get camera => 'Camera';

  @override
  String get cameraDescription => 'Configure camera behavior';

  @override
  String get cameraPermissionRequired => 'Camera permission is required to scan barcodes';

  @override
  String get cancel => 'Cancel';

  @override
  String get cardAddedSuccess => 'Card added successfully!';

  @override
  String get cardDeletedSuccess => 'Card deleted successfully!';

  @override
  String cardDeleteError(Object error) {
    return 'Failed to delete card: $error';
  }

  @override
  String get cardExistsInGlobalPool => 'This card already exists in the global pool.';

  @override
  String get cardImportedSuccess => 'Card imported successfully!';

  @override
  String get cardName => 'Card Name';

  @override
  String get cardNameHint => 'Enter card name';

  @override
  String get cardNameRequired => 'Please enter a card name';

  @override
  String get cardPinned => 'Card pinned';

  @override
  String get cards => 'Cards';

  @override
  String cardSaveError(Object error) {
    return 'Error saving card: $error';
  }

  @override
  String get cardSharedGloballySuccess => 'Card shared globally successfully!';

  @override
  String get cardUnpinned => 'Card unpinned';

  @override
  String get cardUpdatedSuccess => 'Card updated successfully!';

  @override
  String get cardVisibleToAllUsers => 'This will make the card visible to all users in the global pool.';

  @override
  String get centerCodeInFrame => 'Center the code in the frame';

  @override
  String get changeImage => 'Change Image';

  @override
  String get chooseCustomColor => 'Choose Custom Color';

  @override
  String get chooseFromGlobalImages => 'Choose from Global Images';

  @override
  String get choosePhotoAndEdit => 'Choose photo and edit';

  @override
  String get close => 'Close';

  @override
  String get configureWebdavFirst => 'Please configure server connection in Sync tab first';

  @override
  String get connected => 'Connected';

  @override
  String get connectedCheck => 'Connected ✓';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String connectionFailed(Object error) {
    return 'Connection failed: $error';
  }

  @override
  String get connectionSuccessful => 'Connection successful!';

  @override
  String get coverImageLabel => 'Cover Image (Optional)';

  @override
  String get coverImageSuffix => '(Cover)';

  @override
  String get created => 'Created';

  @override
  String get createGlobalFolderHint => 'Create /pockard_global folder on your server to enable global features';

  @override
  String get createGlobalFolderManually => 'Please create this folder manually on your server to enable global sharing.';

  @override
  String get customColor => 'Custom Color';

  @override
  String get data => 'Data';

  @override
  String daysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String deleteCardMessage(Object cardName) {
    return 'Are you sure you want to delete \"$cardName\"? This action cannot be undone.';
  }

  @override
  String get deleteFromGlobalPool => 'Delete from Global Pool';

  @override
  String get deleteFromGlobalPoolDescription => 'Remove this card from the global pool';

  @override
  String get deleteGlobalCard => 'Delete Global Card';

  @override
  String deleteGlobalCardConfirm(Object cardName) {
    return 'Are you sure you want to delete \"$cardName\" from the global pool?';
  }

  @override
  String get deleteGlobalImage => 'Delete Global Image';

  @override
  String deleteGlobalImageConfirm(Object imageName) {
    return 'Are you sure you want to delete \"$imageName\" from the global pool?';
  }

  @override
  String get disabled => 'Disabled';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectAndChangeServer => 'Disconnect & Change Server';

  @override
  String get disconnectConfirmation => 'Are you sure you want to disconnect? You will need to re-enter your server credentials.';

  @override
  String get disconnectedSuccessfully => 'Disconnected successfully';

  @override
  String get disconnectFromServer => 'Disconnect from Server';

  @override
  String get display => 'Display';

  @override
  String get done => 'Done';

  @override
  String get dragToReorderTags => 'Drag to Reorder Tags';

  @override
  String get dragToReorderTagsDescription => 'The order here affects how tags appear on the main screen';

  @override
  String get editCard => 'Edit Card';

  @override
  String get emptyCardsMessage => 'Tap the + button to add your first loyalty card';

  @override
  String get emptyCardsTitle => 'No cards yet';

  @override
  String get enabled => 'Enabled';

  @override
  String get enterImageName => 'Enter a name for this image:';

  @override
  String get enterShopName => 'Enter a shop name to find their logo';

  @override
  String get enterTextHint => 'Enter text for your image\nPress Enter to break lines';

  @override
  String get error => 'Error';

  @override
  String errorDeletingGlobalCard(Object error) {
    return 'Error deleting global card: $error';
  }

  @override
  String errorDeletingGlobalImage(Object error) {
    return 'Error deleting global image: $error';
  }

  @override
  String errorDownloadingCard(Object error) {
    return 'Error downloading card: $error';
  }

  @override
  String errorDownloadingImage(Object error) {
    return 'Error downloading image: $error';
  }

  @override
  String errorEditingImage(Object error) {
    return 'Error editing image: $error';
  }

  @override
  String errorGeneratingImage(Object error) {
    return 'Error generating image: $error';
  }

  @override
  String errorImportingCards(Object error) {
    return 'Error importing cards: $error';
  }

  @override
  String errorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String errorProcessingLogo(Object error) {
    return 'Error processing logo: $error';
  }

  @override
  String errorScanningImage(Object error) {
    return 'Error scanning image: $error';
  }

  @override
  String errorUploadingImage(Object error) {
    return 'Error uploading image: $error';
  }

  @override
  String get exceptionConfigureWebdav => 'Please configure server connection in Sync tab first';

  @override
  String get exceptionFailedDownloadLogo => 'Failed to download logo';

  @override
  String get exceptionFailedFinalizeLogo => 'Failed to finalize logo';

  @override
  String get exceptionFailedProcessLogo => 'Failed to process logo';

  @override
  String get exceptionFailedSearchLogos => 'Failed to search logos';

  @override
  String get exceptionUserNotConfigured => 'Server user not configured';

  @override
  String get exceptionWebdavNotInitialized => 'WebDAV client not initialized';

  @override
  String get exceptionGlobalFolderNotAvailable => 'Global folder not available on server';

  @override
  String exceptionLocalFileNotFound(Object path) {
    return 'Local file does not exist: $path';
  }

  @override
  String get exceptionImageNotFound => 'Image not found';

  @override
  String get exceptionContextNotAvailable => 'Context not available for cropping';

  @override
  String get exceptionLogoSelectionCancelled => 'Logo selection cancelled';

  @override
  String get exportCards => 'Export All';

  @override
  String get exporting => 'Exporting...';

  @override
  String get fillAllConnectionFields => 'Please fill in all connection fields';

  @override
  String get filterAll => 'All';

  @override
  String get fourColumns => '4 columns';

  @override
  String get gallery => 'Gallery';

  @override
  String get generateImage => 'Generate Image';

  @override
  String globalCardsCount(Object count) {
    return 'Global Cards ($count)';
  }

  @override
  String get globalCardUpdatedSuccess => 'Global card updated successfully!';

  @override
  String get globalFeatures => 'Global Features';

  @override
  String get globalFolderAvailable => 'Global folder available';

  @override
  String get globalFolderDetected => 'Global folder detected - Global features enabled';

  @override
  String get globalFolderNotAvailable => 'Global Folder Not Available';

  @override
  String get globalFolderRequired => 'Global features require a \"/pockard_global\" folder on your server.';

  @override
  String get globalImages => 'Global Images';

  @override
  String globalImagesCount(Object count) {
    return 'Global Images ($count)';
  }

  @override
  String get globalPool => 'Global Pool';

  @override
  String get gridColumns => 'Grid Columns';

  @override
  String get gridColumnsDescription => 'Number of columns in grid view';

  @override
  String hoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String get imageDeletedSuccess => 'Image deleted successfully!';

  @override
  String get imageName => 'Image Name';

  @override
  String get imageNameHint => 'Image name';

  @override
  String get imageOnlyLabel => 'Image';

  @override
  String get textOnlyLabel => 'Text';

  @override
  String get images => 'Images';

  @override
  String get imageSharedGloballySuccess => 'Image shared globally successfully!';

  @override
  String get imageUploadedSuccess => 'Image uploaded successfully!';

  @override
  String get importCard => 'Import Card';

  @override
  String get importCardDescription => 'Add this card to your collection';

  @override
  String get importCards => 'Import All';

  @override
  String get importComplete => 'Import complete';

  @override
  String get importFailed => 'Import failed';

  @override
  String get importing => 'Importing...';

  @override
  String get invalidBarcodeData => 'Invalid data or unsupported format';

  @override
  String get invalidBarcodeDataPreview => 'Invalid barcode data';

  @override
  String get justNow => 'Just now';

  @override
  String get languageDescription => 'Choose your preferred language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get lastSync => 'Last Sync';

  @override
  String lastSyncLabel(Object date) {
    return 'Last sync: $date';
  }

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get layout => 'Layout';

  @override
  String get layoutDescription => 'Choose how cards are displayed';

  @override
  String get layoutGrid => 'Grid';

  @override
  String get layoutGridDesc => 'Display cards in a grid layout';

  @override
  String get layoutMinimal => 'Minimal';

  @override
  String get layoutMinimalDesc => 'Ultra-compact list showing only names and tiny previews';

  @override
  String get layoutRows => 'Rows';

  @override
  String get layoutRowsDesc => 'Display cards in a vertical list';

  @override
  String get loading => 'Loading...';

  @override
  String loadMore(Object count) {
    return 'Load More ($count remaining)';
  }

  @override
  String get logoAddedSuccess => 'Logo added successfully!';

  @override
  String get maxBrightness => 'Max Brightness';

  @override
  String get maxBrightnessDescription => 'Automatically set screen to maximum brightness when viewing barcodes';

  @override
  String minutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String get newCards => 'new cards';

  @override
  String get no => 'No';

  @override
  String get noBarcodeDataAvailable => 'No barcode data available';

  @override
  String get noBarcodeDataMessage => 'This card doesn\'t have any barcode or QR code data.';

  @override
  String get noBarcodeFoundInImage => 'No barcode found in image';

  @override
  String get noBarcodeOnly => 'No Barcode (Cover Image Only)';

  @override
  String get noCardsSharedYet => 'No cards have been shared globally yet';

  @override
  String get noCardsToImport => 'No cards found to import';

  @override
  String get noCardsToSync => 'No cards to sync';

  @override
  String get noCoverImage => 'No cover image';

  @override
  String get noGlobalCards => 'No global cards available yet';

  @override
  String get noGlobalImages => 'No global images available yet';

  @override
  String get noImagesSharedYet => 'No images have been shared globally yet';

  @override
  String get noLogosFound => 'No logos found. Try a different search term.';

  @override
  String get noTagsYet => 'No tags yet. Tags will appear here once you add them to your cards.';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get oneColumn => '1 column';

  @override
  String get overwriteGlobalCard => 'This will overwrite the existing global card with your current version.';

  @override
  String get parallelSync => 'Parallel Sync';

  @override
  String get parallelSyncDescription => 'Upload multiple cards at once for faster syncing.';

  @override
  String get parallelSyncWarningTitle => 'Potential Issue with Parallel Sync';

  @override
  String get parallelSyncWarningContent =>
      'Some WebDAV servers do not support parallel uploads, which can cause \'Locked\' errors during synchronization. If you experience issues, disabling this option and using sequential sync is recommended.';

  @override
  String get ok => 'OK';

  @override
  String get password => 'Password';

  @override
  String get pinCard => 'Pin card';

  @override
  String pinError(Object error) {
    return 'Error pinning card: $error';
  }

  @override
  String get position => 'Position';

  @override
  String get preview => 'Preview';

  @override
  String get processingLogo => 'Processing logo...';

  @override
  String get readyForSync => 'Ready for synchronization';

  @override
  String get refresh => 'Refresh';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get reset => 'Reset';

  @override
  String get resetStatistics => 'Reset All Statistics';

  @override
  String get resetStatisticsConfirmation => 'Are you sure you want to reset all card usage statistics? This action cannot be undone.';

  @override
  String get resetStatisticsDescription => 'Reset usage counts for all cards to zero';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get saveCard => 'Save Card';

  @override
  String get scanBarcode => 'Scan Code';

  @override
  String get scanFromImage => 'Scan from Image';

  @override
  String get search => 'Search';

  @override
  String get searchForLogos => 'Search for logos';

  @override
  String get searchingForLogos => 'Searching for logos...';

  @override
  String get searchLogo => 'Search Logo';

  @override
  String showingLogosCount(Object displayed, Object total) {
    return 'Showing $displayed of $total logos';
  }

  @override
  String get selectBarcodeImage => 'Select Barcode Image';

  @override
  String get server => 'Server';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get serverAddressHint => 'e.g. https://dav.example.com or https://192.168.0.200:8080\nor combine domain with port';

  @override
  String get serverConfiguration => 'Server Configuration';

  @override
  String get settings => 'Settings';

  @override
  String get share => 'Share';

  @override
  String get shareCardGlobally => 'Share Card Globally';

  @override
  String get shareCardGloballyConfirm => 'Are you sure you want to share';

  @override
  String get shareCardGloballyConfirm2 => 'globally?';

  @override
  String get shareCardGloballyError => 'Failed to share card globally';

  @override
  String get shareGlobally => 'Share Globally';

  @override
  String get shareImageGlobally => 'Share Image Globally';

  @override
  String get shareImageGloballyError => 'Failed to share image globally';

  @override
  String get shopNameHint => 'Enter shop name (e.g., tesco, lidl)';

  @override
  String get showBarcode => 'Show Barcode';

  @override
  String get showCoverImage => 'Show cover image';

  @override
  String get showGridNames => 'Show card names';

  @override
  String get showGridNamesDescription => 'Display card names below images in grid view';

  @override
  String get sortDateAdded => 'Date Added';

  @override
  String get sortName => 'Name (A-Z)';

  @override
  String get sortRecent => 'Recently Used';

  @override
  String get sortUsage => 'Most Used';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsResetSuccess => 'All statistics have been reset successfully';

  @override
  String get statisticsSection => 'Statistics';

  @override
  String get statisticsSectionDescription => 'Manage usage statistics for all cards';

  @override
  String get status => 'Status';

  @override
  String get success => 'Success';

  @override
  String get sync => 'Sync';

  @override
  String get syncActions => 'Sync Actions';

  @override
  String get syncCompletedSuccess => 'Sync completed successfully!';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNotConfigured => 'Sync is not configured.';

  @override
  String get syncNotConfiguredHint => 'Go to Settings → Sync to set up server sync.';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncStatusDialogTitle => 'Sync Status';

  @override
  String get syncStatusError => 'Error';

  @override
  String get syncStatusLastAttempt => 'Last Attempt';

  @override
  String get syncStatusLastSuccess => 'Last Success';

  @override
  String get syncStatusNever => 'Never';

  @override
  String syncSuccessExport(Object count) {
    return 'Successfully exported $count cards';
  }

  @override
  String syncSuccessWithCleanup(Object cardCount, Object deletedCount) {
    return 'Successfully synced $cardCount cards and cleaned up $deletedCount deleted cards';
  }

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'Add tags...';

  @override
  String get tagsLabel => 'Tags (Optional)';

  @override
  String get takePhotoAndEdit => 'Take photo and edit';

  @override
  String get tapToAddCoverImage => 'Tap to add cover image';

  @override
  String get tapToHideControls => 'Tap anywhere to hide controls';

  @override
  String get tapToShowControls => 'Tap anywhere to show controls';

  @override
  String get tapToUploadBarcodeImage => 'Tap to upload a barcode image';

  @override
  String get testConnection => 'Connect';

  @override
  String get text => 'Text';

  @override
  String get textColor => 'Text Color';

  @override
  String get theme => 'Theme';

  @override
  String get themeAmoled => 'Pure Black (AMOLED)';

  @override
  String get themeAmoledDesc => 'Pure black theme for AMOLED displays';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDesc => 'Dark theme for low-light environments';

  @override
  String get themeDescription => 'Choose your preferred app theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDesc => 'Light theme with bright colors';

  @override
  String get themeMaterialYou => 'Material You';

  @override
  String get themeMaterialYouDesc => 'Material You theme with dynamic colors';

  @override
  String get themeFlavor => 'Theme Flavor';

  @override
  String get themeFlavorDescription => 'Choose a color accent for the selected theme (not applicable for Material You).';

  @override
  String get flavorPockard => 'Pockard (Default)';

  @override
  String get flavorBlue => 'Blue';

  @override
  String get flavorGreen => 'Green';

  @override
  String get flavorPurple => 'Purple';

  @override
  String get flavorOrange => 'Orange';

  @override
  String get flavorTeal => 'Teal';

  @override
  String get timesUsed => 'Times used';

  @override
  String get tooltipRefresh => 'Refresh';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get type => 'Type';

  @override
  String get unableToGenerateBarcode => 'Unable to generate barcode';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get unpinCard => 'Unpin card';

  @override
  String get update => 'Update';

  @override
  String get updated => 'updated';

  @override
  String get updateGlobalCard => 'Update Global Card';

  @override
  String get updateGlobalCardConfirm => 'Are you sure you want to update the global version of';

  @override
  String get upload => 'Upload';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get uploadToGlobalImages => 'Upload to Global Images';

  @override
  String usageCount(Object count) {
    return '$count uses';
  }

  @override
  String get usageCountLabel => 'Usage Count';

  @override
  String get username => 'Username';

  @override
  String get uses => 'uses';

  @override
  String get webdavConnection => 'Server Connection';

  @override
  String get white => 'White';

  @override
  String get yes => 'Yes';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get advancedSettingsDescription => 'Configure custom folder paths for synchronization';

  @override
  String get pockardFolderPath => 'Pockard Folder Path';

  @override
  String get pockardFolderPathHint => 'Path where your cards will be synchronized.\nDefault: /pockard';

  @override
  String get globalFolderPath => 'Global Folder Path';

  @override
  String get globalFolderPathHint => 'Path for global shared cards.\nDefault: /pockard_global';

  @override
  String get showAdvancedSettings => 'Show Advanced Settings';

  @override
  String get hideAdvancedSettings => 'Hide Advanced Settings';
}

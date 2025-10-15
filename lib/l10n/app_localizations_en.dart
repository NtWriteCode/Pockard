// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pockard';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get done => 'Done';

  @override
  String get mainTitle => 'My Cards';

  @override
  String get searchCards => 'Search cards...';

  @override
  String get allCards => 'All';

  @override
  String get sortRecent => 'Recently Used';

  @override
  String get sortUsage => 'Most Used';

  @override
  String get sortName => 'Name (A-Z)';

  @override
  String get sortDateAdded => 'Date Added';

  @override
  String get emptyCardsTitle => 'No cards yet';

  @override
  String get emptyCardsMessage =>
      'Tap the + button to add your first loyalty card';

  @override
  String get emptySearchTitle => 'No cards found';

  @override
  String get emptySearchMessage => 'Try a different search term';

  @override
  String get connectionStatusConnected => 'Connected';

  @override
  String get connectionStatusDisconnected => 'Disconnected';

  @override
  String get syncStatusDialogTitle => 'Sync Status';

  @override
  String get syncStatusLastAttempt => 'Last Attempt';

  @override
  String get syncStatusLastSuccess => 'Last Success';

  @override
  String get syncStatusError => 'Error';

  @override
  String get syncStatusNever => 'Never';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNotConfigured => 'Sync is not configured.';

  @override
  String get syncNotConfiguredHint =>
      'Go to Settings → Sync to set up server sync.';

  @override
  String get syncCompletedSuccess => 'Sync completed successfully!';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String get editCard => 'Edit Card';

  @override
  String get cardNameLabel => 'Card Name';

  @override
  String get cardNameHint => 'Enter card name';

  @override
  String get cardNameRequired => 'Please enter a card name';

  @override
  String get barcodeTypeLabel => 'Barcode Type';

  @override
  String get barcodeDataLabel => 'Barcode Data';

  @override
  String get barcodeDataHint => 'Or enter barcode data manually';

  @override
  String get barcodePreview => 'Barcode Preview';

  @override
  String get barcodeDataHintNone => 'No barcode data needed';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get tagsLabel => 'Tags (Optional)';

  @override
  String get tagsHint => 'Add tags...';

  @override
  String get coverImageLabel => 'Cover Image (Optional)';

  @override
  String get selectCoverImage => 'Select Cover Image';

  @override
  String get searchLogo => 'Search Logo';

  @override
  String get generateImage => 'Generate Image';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get takePicture => 'Take Picture';

  @override
  String get useGlobalImage => 'Use Global Image';

  @override
  String get cardAddedSuccess => 'Card added successfully!';

  @override
  String get cardUpdatedSuccess => 'Card updated successfully!';

  @override
  String errorSavingCard(String error) {
    return 'Error saving card: $error';
  }

  @override
  String get shareGlobally => 'Share Globally';

  @override
  String get shareCardGloballyTitle => 'Share Card Globally?';

  @override
  String get shareCardGloballyMessage =>
      'This will upload the card (without usage data) to the global pool for other users.';

  @override
  String get cardSharedSuccess => 'Card shared globally!';

  @override
  String errorSharingCard(String error) {
    return 'Error sharing card: $error';
  }

  @override
  String get deleteCardTitle => 'Delete Card?';

  @override
  String deleteCardMessage(String cardName) {
    return 'Are you sure you want to delete \"$cardName\"? This action cannot be undone.';
  }

  @override
  String get cardDeletedSuccess => 'Card deleted successfully!';

  @override
  String errorDeletingCard(String error) {
    return 'Error deleting card: $error';
  }

  @override
  String usageCount(int count) {
    return '$count uses';
  }

  @override
  String get lastUsed => 'Last used';

  @override
  String get createdOn => 'Created';

  @override
  String get updatedOn => 'Updated';

  @override
  String get showBarcode => 'Show barcode';

  @override
  String get barcodeTypeNone => 'No Barcode';

  @override
  String get barcodeTypeQR => 'QR Code';

  @override
  String get barcodeTypeCode128 => 'Code 128';

  @override
  String get barcodeTypeCode39 => 'Code 39';

  @override
  String get barcodeTypeEAN13 => 'EAN-13';

  @override
  String get barcodeTypeEAN8 => 'EAN-8';

  @override
  String get barcodeTypeUPCA => 'UPC-A';

  @override
  String get barcodeTypeUPCE => 'UPC-E';

  @override
  String get barcodeTypeITF => 'ITF';

  @override
  String get barcodeTypeCodabar => 'Codabar';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get displayTabTitle => 'Display';

  @override
  String get syncTabTitle => 'Sync';

  @override
  String get tagsTabTitle => 'Tags';

  @override
  String get globalCardsTabTitle => 'Global Cards';

  @override
  String get globalImagesTabTitle => 'Global Images';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAmoled => 'Pure Black (AMOLED)';

  @override
  String get themeMaterialYou => 'Material You';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get languageSystem => 'System Default';

  @override
  String get cardViewLabel => 'Card View';

  @override
  String get cardViewList => 'List';

  @override
  String get cardViewGrid => 'Grid';

  @override
  String get syncSettingsTitle => 'Sync Settings';

  @override
  String get webdavServerLabel => 'Server Address';

  @override
  String get webdavServerHint => 'https://example.com/remote.php/dav';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'your-username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'your-password';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get testingConnection => 'Testing connection...';

  @override
  String get connectionSuccessful => 'Connection successful!';

  @override
  String connectionFailed(String error) {
    return 'Connection failed!';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnecting => 'Disconnecting...';

  @override
  String get disconnected => 'Disconnected successfully';

  @override
  String exportingCards(int count) {
    return 'Exporting $count cards...';
  }

  @override
  String cardsExportedSuccess(int count) {
    return 'Exported $count cards successfully!';
  }

  @override
  String errorExportingCards(String error) {
    return 'Error exporting cards: $error';
  }

  @override
  String get importCards => 'Import All';

  @override
  String get importingCards => 'Importing cards...';

  @override
  String cardsImportedSuccess(int imported, int updated) {
    return 'Imported $imported cards, Updated $updated';
  }

  @override
  String errorImportingCards(String error) {
    return 'Error importing cards: $error';
  }

  @override
  String get autoSyncLabel => 'Auto-sync on changes';

  @override
  String get parallelSyncLabel => 'Parallel Sync';

  @override
  String get parallelSyncDescription =>
      'Upload cards simultaneously (faster, but may overwhelm some servers)';

  @override
  String get fillAllFields => 'Please fill in all connection fields';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get lastSync => 'Last Sync';

  @override
  String get globalFolderAvailable => 'Global folder available';

  @override
  String get tagsSettingsTitle => 'Tag Order';

  @override
  String get tagsSettingsDescription =>
      'Drag to reorder tags. This affects the order they appear in filters.';

  @override
  String get noTagsYet => 'No Tags Yet';

  @override
  String get globalCardsTitle => 'Global Cards';

  @override
  String get globalCardsDescription => 'Cards shared by other users';

  @override
  String get downloadCard => 'Download';

  @override
  String get downloadingCard => 'Downloading card...';

  @override
  String get cardDownloadedSuccess => 'Card downloaded successfully!';

  @override
  String errorDownloadingCard(String error) {
    return 'Error downloading card: $error';
  }

  @override
  String get deleteGlobalCard => 'Delete Global Card';

  @override
  String get deleteGlobalCardTitle => 'Delete Global Card?';

  @override
  String get deleteGlobalCardMessage =>
      'Are you sure you want to delete this card from the global pool?';

  @override
  String get globalCardDeleted => 'Global card deleted';

  @override
  String errorDeletingGlobalCard(String error) {
    return 'Error deleting global card: $error';
  }

  @override
  String get noGlobalCards => 'No Global Cards';

  @override
  String uploadedBy(String uploader) {
    return 'Uploaded by $uploader';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get globalImagesTitle => 'Global Images';

  @override
  String get globalImagesDescription => 'Images shared by other users';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get downloadImage => 'Download';

  @override
  String get downloadingImage => 'Downloading image...';

  @override
  String get imageDownloadedSuccess => 'Image downloaded successfully!';

  @override
  String errorDownloadingImage(String error) {
    return 'Error downloading image: $error';
  }

  @override
  String get deleteGlobalImage => 'Delete Global Image';

  @override
  String get deleteGlobalImageTitle => 'Delete Global Image?';

  @override
  String get deleteGlobalImageMessage =>
      'Are you sure you want to delete this image from the global pool?';

  @override
  String get globalImageDeleted => 'Global image deleted';

  @override
  String errorDeletingGlobalImage(String error) {
    return 'Error deleting global image: $error';
  }

  @override
  String get noGlobalImages => 'No Global Images';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get fromGallery => 'From Gallery';

  @override
  String get fromCamera => 'From Camera';

  @override
  String get enterImageName => 'Enter a name for this image:';

  @override
  String get imageName => 'Image Name';

  @override
  String get imageNameRequired => 'Please enter an image name';

  @override
  String get uploadingImage => 'Uploading image...';

  @override
  String get imageUploadedSuccess => 'Image uploaded successfully!';

  @override
  String errorUploadingImage(String error) {
    return 'Error uploading image: $error';
  }

  @override
  String get logoSearchTitle => 'Search Logo';

  @override
  String get logoSearchHint => 'Enter brand name...';

  @override
  String get searchingLogos => 'Searching logos...';

  @override
  String get noLogosFound => 'No logos found';

  @override
  String errorSearchingLogos(String error) {
    return 'Error searching logos: $error';
  }

  @override
  String get selectLogo => 'Select';

  @override
  String get processingLogo => 'Processing logo...';

  @override
  String get logoSelectedSuccess => 'Logo selected successfully!';

  @override
  String errorProcessingLogo(String error) {
    return 'Error processing logo: $error';
  }

  @override
  String get imageGeneratorTitle => 'Generate Image';

  @override
  String get companyNameLabel => 'Company Name';

  @override
  String get companyNameHint => 'Enter company name';

  @override
  String get companyNameRequired => 'Please enter a company name';

  @override
  String get selectBackgroundColor => 'Background Color';

  @override
  String get selectTextColor => 'Text Color';

  @override
  String get generateImageButton => 'Generate Image';

  @override
  String get generatingImage => 'Generating image...';

  @override
  String get imageGeneratedSuccess => 'Image generated successfully!';

  @override
  String errorGeneratingImage(String error) {
    return 'Error generating image';
  }

  @override
  String get brightnessIncreasedNote =>
      'Brightness increased for better scanning';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidUrl => 'Please enter a valid URL';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get operationCancelled => 'Operation cancelled';

  @override
  String get globalPool => 'Global Pool';

  @override
  String get filterAll => 'All';

  @override
  String get addCard => 'Add Card';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get saveCard => 'Save Card';

  @override
  String get cardName => 'Card Name';

  @override
  String get barcodeLabel => 'Barcode/QR Code';

  @override
  String get noBarcodeNeeded => 'No barcode data needed';

  @override
  String get barcodeError => 'Error scanning barcode';

  @override
  String get cardSaveError => 'Error saving card';

  @override
  String get deleteCardConfirm => 'Are you sure you want to delete';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get barcodeInformation => 'Barcode Information';

  @override
  String get unknown => 'Unknown';

  @override
  String get data => 'Data';

  @override
  String get type => 'Type';

  @override
  String get statistics => 'Statistics';

  @override
  String get timesUsed => 'Times used';

  @override
  String get uses => 'uses';

  @override
  String get created => 'Created';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get cardDeletedSuccessfully => 'Card deleted successfully';

  @override
  String get failedToDeleteCard => 'Failed to delete card';

  @override
  String get tapToAddCoverImage => 'Tap to add cover image';

  @override
  String get cardDeleteError => 'Failed to delete card';

  @override
  String get updateGlobalCard => 'Update Global Card';

  @override
  String get shareCardGlobally => 'Share Card Globally';

  @override
  String get cardExistsInGlobalPool =>
      'This card already exists in the global pool.';

  @override
  String get updateGlobalCardConfirm =>
      'Are you sure you want to update the global version of';

  @override
  String get overwriteGlobalCard =>
      'This will overwrite the existing global card with your current version.';

  @override
  String get shareCardGloballyConfirm => 'Are you sure you want to share';

  @override
  String get shareCardGloballyConfirm2 => 'globally?';

  @override
  String get cardVisibleToAllUsers =>
      'This will make the card visible to all users in the global pool.';

  @override
  String get update => 'Update';

  @override
  String get share => 'Share';

  @override
  String get globalCardUpdatedSuccess => 'Global card updated successfully!';

  @override
  String get cardSharedGloballySuccess => 'Card shared globally successfully!';

  @override
  String get shareCardGloballyError => 'Failed to share card globally';

  @override
  String get imageSharedGloballySuccess =>
      'Image shared globally successfully!';

  @override
  String get shareImageGloballyError => 'Failed to share image globally';

  @override
  String get shareImageGlobally => 'Share Image Globally';

  @override
  String get imageNameHint => 'Image name';

  @override
  String get display => 'Display';

  @override
  String get tags => 'Tags';

  @override
  String get sync => 'Sync';

  @override
  String get theme => 'Theme';

  @override
  String get themeDescription => 'Choose your preferred app theme';

  @override
  String get languageDescription => 'Choose your preferred language';

  @override
  String get layout => 'Layout';

  @override
  String get layoutDescription => 'Choose how cards are displayed';

  @override
  String get gridColumns => 'Grid Columns';

  @override
  String get gridColumnsDescription => 'Number of columns in grid view';

  @override
  String get oneColumn => '1 column';

  @override
  String get fourColumns => '4 columns';

  @override
  String get camera => 'Camera';

  @override
  String get cameraDescription => 'Configure camera behavior';

  @override
  String get autoOpenCamera => 'Auto-open camera';

  @override
  String get autoOpenCameraDescription =>
      'Automatically open camera when adding a new card';

  @override
  String get statisticsSection => 'Statistics';

  @override
  String get statisticsSectionDescription =>
      'Manage usage statistics for all cards';

  @override
  String get resetStatistics => 'Reset All Statistics';

  @override
  String get resetStatisticsDescription =>
      'Reset usage counts for all cards to zero';

  @override
  String get resetStatisticsConfirmation =>
      'Are you sure you want to reset all card usage statistics? This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get statisticsResetSuccess =>
      'All statistics have been reset successfully';

  @override
  String get noTagsYetDescription =>
      'Tags will appear here once you add them to your cards';

  @override
  String get dragToReorderTags => 'Drag to Reorder Tags';

  @override
  String get dragToReorderTagsDescription =>
      'The order here affects how tags appear on the main screen';

  @override
  String get position => 'Position';

  @override
  String get cards => 'Cards';

  @override
  String get images => 'Images';

  @override
  String globalCardsCount(int count) {
    return 'Global Cards ($count)';
  }

  @override
  String globalImagesCount(int count) {
    return 'Global Images ($count)';
  }

  @override
  String get configureWebdavFirst =>
      'Please configure server connection in Sync tab first';

  @override
  String get failedToLoadGlobalCards => 'Failed to load global cards';

  @override
  String get cardImportedSuccess => 'Card imported successfully!';

  @override
  String get failedToImportCard => 'Failed to import card';

  @override
  String get globalCardDeletedSuccess => 'Global card deleted successfully!';

  @override
  String get failedToDeleteGlobalCard => 'Failed to delete global card';

  @override
  String get globalFolderNotAvailable => 'Global Folder Not Available';

  @override
  String get globalFolderRequired =>
      'Global features require a \"/pockard_global\" folder on your server.';

  @override
  String get createGlobalFolderManually =>
      'Please create this folder manually on your server to enable global image sharing.';

  @override
  String get tapToHideControls => 'Tap anywhere to hide controls';

  @override
  String get tapToShowControls => 'Tap anywhere to show controls';

  @override
  String get showCoverImage => 'Show cover image';

  @override
  String get unableToGenerateBarcode => 'Unable to generate barcode';

  @override
  String get invalidBarcodeData => 'Invalid data or unsupported format';

  @override
  String get noBarcodeDataAvailable => 'No barcode data available';

  @override
  String get noBarcodeDataMessage =>
      'This card doesn\'t have any barcode or QR code data.';

  @override
  String get usageCountLabel => 'Usage Count';

  @override
  String get fillAllConnectionFields => 'Please fill in all connection fields';

  @override
  String get globalFolderDetected =>
      'Global folder detected - Global features enabled';

  @override
  String get globalFolderNotFound =>
      'Global folder not found - Global features disabled';

  @override
  String get connectionError => 'Connection error';

  @override
  String get parallelSync => 'Parallel Sync';

  @override
  String get disconnectAndChangeServer => 'Disconnect & Change Server';

  @override
  String get disconnectFromServer => 'Disconnect from Server';

  @override
  String get disconnectConfirmation =>
      'Are you sure you want to disconnect? You will need to re-enter your server credentials.';

  @override
  String get disconnectedSuccessfully => 'Disconnected successfully';

  @override
  String get noCardsToSync => 'No cards to sync';

  @override
  String get noCardsToImport => 'No cards found to import';

  @override
  String get importComplete => 'Import complete';

  @override
  String get newCards => 'new cards';

  @override
  String get updated => 'updated';

  @override
  String get importFailed => 'Import failed';

  @override
  String deleteGlobalImageConfirm(String imageName) {
    return 'Are you sure you want to delete \"$imageName\" from the global pool?';
  }

  @override
  String get takePhotoAndEdit => 'Take photo and edit';

  @override
  String get gallery => 'Gallery';

  @override
  String get choosePhotoAndEdit => 'Choose photo and edit';

  @override
  String get errorPickingImage => 'Error picking image';

  @override
  String get uploadToGlobalImages => 'Upload to Global Images';

  @override
  String get upload => 'Upload';

  @override
  String get failedToUploadImage => 'Failed to upload image';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get logoAddedSuccess => 'Logo added successfully!';

  @override
  String get failedToProcessLogo => 'Failed to process logo';

  @override
  String get searchingForLogos => 'Searching for logos...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get customColor => 'Custom Color';

  @override
  String get chooseCustomColor => 'Choose Custom Color';

  @override
  String get changeImage => 'Change Image';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get generateImageOption => 'Generate Image';

  @override
  String get searchLogoOption => 'Search Logo';

  @override
  String get globalImages => 'Global Images';

  @override
  String get editCurrentImage => 'Edit Current Image';

  @override
  String get errorEditingImage => 'Error editing image';

  @override
  String get serverAddressHint =>
      'https://dav.example.com or https://192.168.0.200:8080';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get adjustLogo => 'Adjust Logo';

  @override
  String get shopNameHint => 'Enter shop name (e.g., tesco, lidl)';

  @override
  String get enterTextHint =>
      'Enter text for your image\nPress Enter to break lines';

  @override
  String get importCard => 'Import Card';

  @override
  String get importCardDescription => 'Add this card to your collection';

  @override
  String get deleteFromGlobalPool => 'Delete from Global Pool';

  @override
  String get deleteFromGlobalPoolDescription =>
      'Remove this card from the global pool';

  @override
  String deleteGlobalCardConfirm(String cardName) {
    return 'Are you sure you want to delete \"$cardName\" from the global pool?';
  }

  @override
  String get imageNameHint2 => 'Enter a name for this image';

  @override
  String get editCoverImage => 'Edit Cover Image';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to scan barcodes';

  @override
  String get scanFromImage => 'Scan from Image';

  @override
  String get noBarcodeFoundInImage => 'No barcode found in image';

  @override
  String get errorScanningImage => 'Error scanning image';

  @override
  String get failedToLoadGlobalImages2 => 'Failed to load global images';

  @override
  String get failedToDownloadImage => 'Failed to download image';

  @override
  String get failedToLoadGlobalImages => 'Failed to load global images';

  @override
  String get globalImageDeletedSuccess => 'Global image deleted successfully!';

  @override
  String get failedToDeleteGlobalImage => 'Failed to delete global image';

  @override
  String get centerCodeInFrame => 'Center the code in the frame';

  @override
  String get noImagesSharedYet => 'No images have been shared globally yet';

  @override
  String get readyForSync => 'Ready for synchronization';

  @override
  String get noCardsSharedYet => 'No cards have been shared globally yet';

  @override
  String get connectedCheck => 'Connected ✓';

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportCards => 'Export All';

  @override
  String get importing => 'Importing...';

  @override
  String get layoutRows => 'Rows';

  @override
  String get layoutGrid => 'Grid';

  @override
  String get themeLightDesc => 'Light theme with bright colors';

  @override
  String get themeDarkDesc => 'Dark theme for low-light environments';

  @override
  String get themeAmoledDesc => 'Pure black theme for AMOLED displays';

  @override
  String get themeMaterialYouDesc => 'Material You theme with dynamic colors';

  @override
  String get layoutRowsDesc => 'Display cards in a vertical list';

  @override
  String get layoutGridDesc => 'Display cards in a grid layout';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get searchForLogos => 'Search for logos';

  @override
  String get enterShopName => 'Enter a shop name to find their logo';

  @override
  String loadMore(int count) {
    return 'Load More ($count remaining)';
  }

  @override
  String get tooltipRefresh => 'Refresh';

  @override
  String get tooltipEditConfig => 'Edit Configuration';

  @override
  String syncSuccessWithCleanup(int cardCount, int deletedCount) {
    return 'Successfully synced $cardCount cards and cleaned up $deletedCount deleted cards';
  }

  @override
  String syncSuccessExport(int count) {
    return 'Successfully exported $count cards';
  }

  @override
  String get noCoverImage => 'No cover image';

  @override
  String get addCoverImageToCard => 'Add a cover image to this card';

  @override
  String get chooseFromGlobalImages => 'Choose from Global Images';

  @override
  String get addTagsHint => 'Add tags...';

  @override
  String get noBarcodeOnly => 'No Barcode (Cover Image Only)';

  @override
  String get exceptionConfigureWebdav =>
      'Please configure server connection in Sync tab first';

  @override
  String get exceptionFailedSearchLogos => 'Failed to search logos';

  @override
  String get exceptionFailedDownloadLogo => 'Failed to download logo';

  @override
  String get exceptionFailedProcessLogo => 'Failed to process logo';

  @override
  String get exceptionFailedFinalizeLogo => 'Failed to finalize logo';

  @override
  String get exceptionFailedInitWebdav => 'Failed to initialize server client';

  @override
  String get exceptionUserNotConfigured => 'Server user not configured';

  @override
  String get text => 'Text';

  @override
  String get textColor => 'Text Color';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get server => 'Server';

  @override
  String get globalFeatures => 'Global Features';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get createGlobalFolderHint =>
      'Create /pockard_global folder on your server to enable global features';

  @override
  String get webdavConnection => 'Server Connection';

  @override
  String get serverConfiguration => 'Server Configuration';

  @override
  String get syncActions => 'Sync Actions';

  @override
  String get connected => 'Connected';

  @override
  String get notConnected => 'Not Connected';

  @override
  String lastSyncLabel(String date) {
    return 'Last sync: $date';
  }

  @override
  String get coverImageSuffix => '(Cover)';

  @override
  String get status => 'Status';

  @override
  String get noBarcodeLabel => 'No Barcode';

  @override
  String get preview => 'Preview';

  @override
  String get backgroundColor => 'Background Color';

  @override
  String get pinCard => 'Pin card';

  @override
  String get unpinCard => 'Unpin card';

  @override
  String get cardPinned => 'Card pinned';

  @override
  String get cardUnpinned => 'Card unpinned';

  @override
  String get pinError => 'Error pinning card';

  @override
  String get showGridNames => 'Show card names';

  @override
  String get showGridNamesDescription =>
      'Display card names below images in grid view';

  @override
  String get layoutMinimal => 'Minimal';

  @override
  String get layoutMinimalDesc =>
      'Ultra-compact list showing only names and tiny previews';

  @override
  String get imageOnlyLabel => 'Image Only';

  @override
  String get imageOnlyMode => 'Image only mode - no barcode data needed';

  @override
  String get tapToUploadBarcodeImage => 'Tap to upload a barcode image';

  @override
  String get barcodeImageUploaded => 'Barcode image uploaded';

  @override
  String get selectBarcodeImage => 'Select Barcode Image';

  @override
  String get removeBarcodeImage => 'Remove barcode image';
}

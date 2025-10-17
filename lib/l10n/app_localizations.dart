import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('hu')];

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @addCoverImageToCard.
  ///
  /// In en, this message translates to:
  /// **'Add a cover image to this card'**
  String get addCoverImageToCard;

  /// No description provided for @adjustLogo.
  ///
  /// In en, this message translates to:
  /// **'Adjust Logo'**
  String get adjustLogo;

  /// No description provided for @allCards.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCards;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pockard'**
  String get appName;

  /// No description provided for @autoOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Auto-open camera'**
  String get autoOpenCamera;

  /// No description provided for @autoOpenCameraDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically open camera when adding a new card'**
  String get autoOpenCameraDescription;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @barcodeDataHint.
  ///
  /// In en, this message translates to:
  /// **'Or enter barcode data manually'**
  String get barcodeDataHint;

  /// No description provided for @barcodeError.
  ///
  /// In en, this message translates to:
  /// **'Error scanning barcode: {error}'**
  String barcodeError(Object error);

  /// No description provided for @barcodeImageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Barcode image uploaded'**
  String get barcodeImageUploaded;

  /// No description provided for @barcodePreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter barcode data to see preview'**
  String get barcodePreviewHint;

  /// No description provided for @barcodeInformation.
  ///
  /// In en, this message translates to:
  /// **'Barcode Information'**
  String get barcodeInformation;

  /// No description provided for @barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode/QR Code'**
  String get barcodeLabel;

  /// No description provided for @barcodePreview.
  ///
  /// In en, this message translates to:
  /// **'Barcode Preview'**
  String get barcodePreview;

  /// No description provided for @barcodeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode Type'**
  String get barcodeTypeLabel;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cameraDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure camera behavior'**
  String get cameraDescription;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan barcodes'**
  String get cameraPermissionRequired;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully!'**
  String get cardAddedSuccess;

  /// No description provided for @cardDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully!'**
  String get cardDeletedSuccess;

  /// No description provided for @cardDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete card: {error}'**
  String cardDeleteError(Object error);

  /// No description provided for @cardExistsInGlobalPool.
  ///
  /// In en, this message translates to:
  /// **'This card already exists in the global pool.'**
  String get cardExistsInGlobalPool;

  /// No description provided for @cardImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card imported successfully!'**
  String get cardImportedSuccess;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardName;

  /// No description provided for @cardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter card name'**
  String get cardNameHint;

  /// No description provided for @cardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a card name'**
  String get cardNameRequired;

  /// No description provided for @cardPinned.
  ///
  /// In en, this message translates to:
  /// **'Card pinned'**
  String get cardPinned;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @cardSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving card: {error}'**
  String cardSaveError(Object error);

  /// No description provided for @cardSharedGloballySuccess.
  ///
  /// In en, this message translates to:
  /// **'Card shared globally successfully!'**
  String get cardSharedGloballySuccess;

  /// No description provided for @cardUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Card unpinned'**
  String get cardUnpinned;

  /// No description provided for @cardUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully!'**
  String get cardUpdatedSuccess;

  /// No description provided for @cardVisibleToAllUsers.
  ///
  /// In en, this message translates to:
  /// **'This will make the card visible to all users in the global pool.'**
  String get cardVisibleToAllUsers;

  /// No description provided for @centerCodeInFrame.
  ///
  /// In en, this message translates to:
  /// **'Center the code in the frame'**
  String get centerCodeInFrame;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @chooseCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Custom Color'**
  String get chooseCustomColor;

  /// No description provided for @chooseFromGlobalImages.
  ///
  /// In en, this message translates to:
  /// **'Choose from Global Images'**
  String get chooseFromGlobalImages;

  /// No description provided for @choosePhotoAndEdit.
  ///
  /// In en, this message translates to:
  /// **'Choose photo and edit'**
  String get choosePhotoAndEdit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @configureWebdavFirst.
  ///
  /// In en, this message translates to:
  /// **'Please configure server connection in Sync tab first'**
  String get configureWebdavFirst;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connectedCheck.
  ///
  /// In en, this message translates to:
  /// **'Connected ✓'**
  String get connectedCheck;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String connectionFailed(Object error);

  /// No description provided for @connectionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Connection successful!'**
  String get connectionSuccessful;

  /// No description provided for @coverImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover Image (Optional)'**
  String get coverImageLabel;

  /// No description provided for @coverImageSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Cover)'**
  String get coverImageSuffix;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @createGlobalFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Create /pockard_global folder on your server to enable global features'**
  String get createGlobalFolderHint;

  /// No description provided for @createGlobalFolderManually.
  ///
  /// In en, this message translates to:
  /// **'Please create this folder manually on your server to enable global sharing.'**
  String get createGlobalFolderManually;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(Object days);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @deleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{cardName}\"? This action cannot be undone.'**
  String deleteCardMessage(Object cardName);

  /// No description provided for @deleteFromGlobalPool.
  ///
  /// In en, this message translates to:
  /// **'Delete from Global Pool'**
  String get deleteFromGlobalPool;

  /// No description provided for @deleteFromGlobalPoolDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove this card from the global pool'**
  String get deleteFromGlobalPoolDescription;

  /// No description provided for @deleteGlobalCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Global Card'**
  String get deleteGlobalCard;

  /// No description provided for @deleteGlobalCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{cardName}\" from the global pool?'**
  String deleteGlobalCardConfirm(Object cardName);

  /// No description provided for @deleteGlobalImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Global Image'**
  String get deleteGlobalImage;

  /// No description provided for @deleteGlobalImageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{imageName}\" from the global pool?'**
  String deleteGlobalImageConfirm(Object imageName);

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @disconnectAndChangeServer.
  ///
  /// In en, this message translates to:
  /// **'Disconnect & Change Server'**
  String get disconnectAndChangeServer;

  /// No description provided for @disconnectConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disconnect? You will need to re-enter your server credentials.'**
  String get disconnectConfirmation;

  /// No description provided for @disconnectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Disconnected successfully'**
  String get disconnectedSuccessfully;

  /// No description provided for @disconnectFromServer.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from Server'**
  String get disconnectFromServer;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @dragToReorderTags.
  ///
  /// In en, this message translates to:
  /// **'Drag to Reorder Tags'**
  String get dragToReorderTags;

  /// No description provided for @dragToReorderTagsDescription.
  ///
  /// In en, this message translates to:
  /// **'The order here affects how tags appear on the main screen'**
  String get dragToReorderTagsDescription;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @emptyCardsMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first loyalty card'**
  String get emptyCardsMessage;

  /// No description provided for @emptyCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get emptyCardsTitle;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @enterImageName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this image:'**
  String get enterImageName;

  /// No description provided for @enterShopName.
  ///
  /// In en, this message translates to:
  /// **'Enter a shop name to find their logo'**
  String get enterShopName;

  /// No description provided for @enterTextHint.
  ///
  /// In en, this message translates to:
  /// **'Enter text for your image\nPress Enter to break lines'**
  String get enterTextHint;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorDeletingGlobalCard.
  ///
  /// In en, this message translates to:
  /// **'Error deleting global card: {error}'**
  String errorDeletingGlobalCard(Object error);

  /// No description provided for @errorDeletingGlobalImage.
  ///
  /// In en, this message translates to:
  /// **'Error deleting global image: {error}'**
  String errorDeletingGlobalImage(Object error);

  /// No description provided for @errorDownloadingCard.
  ///
  /// In en, this message translates to:
  /// **'Error downloading card: {error}'**
  String errorDownloadingCard(Object error);

  /// No description provided for @errorDownloadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error downloading image: {error}'**
  String errorDownloadingImage(Object error);

  /// No description provided for @errorEditingImage.
  ///
  /// In en, this message translates to:
  /// **'Error editing image: {error}'**
  String errorEditingImage(Object error);

  /// No description provided for @errorGeneratingImage.
  ///
  /// In en, this message translates to:
  /// **'Error generating image: {error}'**
  String errorGeneratingImage(Object error);

  /// No description provided for @errorImportingCards.
  ///
  /// In en, this message translates to:
  /// **'Error importing cards: {error}'**
  String errorImportingCards(Object error);

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// No description provided for @errorProcessingLogo.
  ///
  /// In en, this message translates to:
  /// **'Error processing logo: {error}'**
  String errorProcessingLogo(Object error);

  /// No description provided for @errorScanningImage.
  ///
  /// In en, this message translates to:
  /// **'Error scanning image: {error}'**
  String errorScanningImage(Object error);

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String errorUploadingImage(Object error);

  /// No description provided for @exceptionConfigureWebdav.
  ///
  /// In en, this message translates to:
  /// **'Please configure server connection in Sync tab first'**
  String get exceptionConfigureWebdav;

  /// No description provided for @exceptionFailedDownloadLogo.
  ///
  /// In en, this message translates to:
  /// **'Failed to download logo'**
  String get exceptionFailedDownloadLogo;

  /// No description provided for @exceptionFailedFinalizeLogo.
  ///
  /// In en, this message translates to:
  /// **'Failed to finalize logo'**
  String get exceptionFailedFinalizeLogo;

  /// No description provided for @exceptionFailedProcessLogo.
  ///
  /// In en, this message translates to:
  /// **'Failed to process logo'**
  String get exceptionFailedProcessLogo;

  /// No description provided for @exceptionFailedSearchLogos.
  ///
  /// In en, this message translates to:
  /// **'Failed to search logos'**
  String get exceptionFailedSearchLogos;

  /// No description provided for @exceptionUserNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Server user not configured'**
  String get exceptionUserNotConfigured;

  /// No description provided for @exceptionWebdavNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'WebDAV client not initialized'**
  String get exceptionWebdavNotInitialized;

  /// No description provided for @exceptionGlobalFolderNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Global folder not available on server'**
  String get exceptionGlobalFolderNotAvailable;

  /// No description provided for @exceptionLocalFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Local file does not exist: {path}'**
  String exceptionLocalFileNotFound(Object path);

  /// No description provided for @exceptionImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get exceptionImageNotFound;

  /// No description provided for @exceptionContextNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Context not available for cropping'**
  String get exceptionContextNotAvailable;

  /// No description provided for @exceptionLogoSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Logo selection cancelled'**
  String get exceptionLogoSelectionCancelled;

  /// No description provided for @exportCards.
  ///
  /// In en, this message translates to:
  /// **'Export All'**
  String get exportCards;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @fillAllConnectionFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all connection fields'**
  String get fillAllConnectionFields;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @fourColumns.
  ///
  /// In en, this message translates to:
  /// **'4 columns'**
  String get fourColumns;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @generateImage.
  ///
  /// In en, this message translates to:
  /// **'Generate Image'**
  String get generateImage;

  /// No description provided for @globalCardsCount.
  ///
  /// In en, this message translates to:
  /// **'Global Cards ({count})'**
  String globalCardsCount(Object count);

  /// No description provided for @globalCardUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Global card updated successfully!'**
  String get globalCardUpdatedSuccess;

  /// No description provided for @globalFeatures.
  ///
  /// In en, this message translates to:
  /// **'Global Features'**
  String get globalFeatures;

  /// No description provided for @globalFolderAvailable.
  ///
  /// In en, this message translates to:
  /// **'Global folder available'**
  String get globalFolderAvailable;

  /// No description provided for @globalFolderDetected.
  ///
  /// In en, this message translates to:
  /// **'Global folder detected - Global features enabled'**
  String get globalFolderDetected;

  /// No description provided for @globalFolderNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Global Folder Not Available'**
  String get globalFolderNotAvailable;

  /// No description provided for @globalFolderRequired.
  ///
  /// In en, this message translates to:
  /// **'Global features require a \"/pockard_global\" folder on your server.'**
  String get globalFolderRequired;

  /// No description provided for @globalImages.
  ///
  /// In en, this message translates to:
  /// **'Global Images'**
  String get globalImages;

  /// No description provided for @globalImagesCount.
  ///
  /// In en, this message translates to:
  /// **'Global Images ({count})'**
  String globalImagesCount(Object count);

  /// No description provided for @globalPool.
  ///
  /// In en, this message translates to:
  /// **'Global Pool'**
  String get globalPool;

  /// No description provided for @gridColumns.
  ///
  /// In en, this message translates to:
  /// **'Grid Columns'**
  String get gridColumns;

  /// No description provided for @gridColumnsDescription.
  ///
  /// In en, this message translates to:
  /// **'Number of columns in grid view'**
  String get gridColumnsDescription;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @imageDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully!'**
  String get imageDeletedSuccess;

  /// No description provided for @imageName.
  ///
  /// In en, this message translates to:
  /// **'Image Name'**
  String get imageName;

  /// No description provided for @imageNameHint.
  ///
  /// In en, this message translates to:
  /// **'Image name'**
  String get imageNameHint;

  /// No description provided for @imageOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Image Only'**
  String get imageOnlyLabel;

  /// No description provided for @textOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Text Only'**
  String get textOnlyLabel;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @imageSharedGloballySuccess.
  ///
  /// In en, this message translates to:
  /// **'Image shared globally successfully!'**
  String get imageSharedGloballySuccess;

  /// No description provided for @imageUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully!'**
  String get imageUploadedSuccess;

  /// No description provided for @importCard.
  ///
  /// In en, this message translates to:
  /// **'Import Card'**
  String get importCard;

  /// No description provided for @importCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Add this card to your collection'**
  String get importCardDescription;

  /// No description provided for @importCards.
  ///
  /// In en, this message translates to:
  /// **'Import All'**
  String get importCards;

  /// No description provided for @importComplete.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get importComplete;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @invalidBarcodeData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data or unsupported format'**
  String get invalidBarcodeData;

  /// No description provided for @invalidBarcodeDataPreview.
  ///
  /// In en, this message translates to:
  /// **'Invalid barcode data'**
  String get invalidBarcodeDataPreview;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageDescription;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHungarian.
  ///
  /// In en, this message translates to:
  /// **'Magyar'**
  String get languageHungarian;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSync;

  /// No description provided for @lastSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {date}'**
  String lastSyncLabel(Object date);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @layoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how cards are displayed'**
  String get layoutDescription;

  /// No description provided for @layoutGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get layoutGrid;

  /// No description provided for @layoutGridDesc.
  ///
  /// In en, this message translates to:
  /// **'Display cards in a grid layout'**
  String get layoutGridDesc;

  /// No description provided for @layoutMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get layoutMinimal;

  /// No description provided for @layoutMinimalDesc.
  ///
  /// In en, this message translates to:
  /// **'Ultra-compact list showing only names and tiny previews'**
  String get layoutMinimalDesc;

  /// No description provided for @layoutRows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get layoutRows;

  /// No description provided for @layoutRowsDesc.
  ///
  /// In en, this message translates to:
  /// **'Display cards in a vertical list'**
  String get layoutRowsDesc;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More ({count} remaining)'**
  String loadMore(Object count);

  /// No description provided for @logoAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logo added successfully!'**
  String get logoAddedSuccess;

  /// No description provided for @maxBrightness.
  ///
  /// In en, this message translates to:
  /// **'Max Brightness'**
  String get maxBrightness;

  /// No description provided for @maxBrightnessDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically set screen to maximum brightness when viewing barcodes'**
  String get maxBrightnessDescription;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @newCards.
  ///
  /// In en, this message translates to:
  /// **'new cards'**
  String get newCards;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noBarcodeDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No barcode data available'**
  String get noBarcodeDataAvailable;

  /// No description provided for @noBarcodeDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This card doesn\'t have any barcode or QR code data.'**
  String get noBarcodeDataMessage;

  /// No description provided for @noBarcodeFoundInImage.
  ///
  /// In en, this message translates to:
  /// **'No barcode found in image'**
  String get noBarcodeFoundInImage;

  /// No description provided for @noBarcodeOnly.
  ///
  /// In en, this message translates to:
  /// **'No Barcode (Cover Image Only)'**
  String get noBarcodeOnly;

  /// No description provided for @noCardsSharedYet.
  ///
  /// In en, this message translates to:
  /// **'No cards have been shared globally yet'**
  String get noCardsSharedYet;

  /// No description provided for @noCardsToImport.
  ///
  /// In en, this message translates to:
  /// **'No cards found to import'**
  String get noCardsToImport;

  /// No description provided for @noCardsToSync.
  ///
  /// In en, this message translates to:
  /// **'No cards to sync'**
  String get noCardsToSync;

  /// No description provided for @noCoverImage.
  ///
  /// In en, this message translates to:
  /// **'No cover image'**
  String get noCoverImage;

  /// No description provided for @noGlobalCards.
  ///
  /// In en, this message translates to:
  /// **'No global cards available yet'**
  String get noGlobalCards;

  /// No description provided for @noGlobalImages.
  ///
  /// In en, this message translates to:
  /// **'No global images available yet'**
  String get noGlobalImages;

  /// No description provided for @noImagesSharedYet.
  ///
  /// In en, this message translates to:
  /// **'No images have been shared globally yet'**
  String get noImagesSharedYet;

  /// No description provided for @noLogosFound.
  ///
  /// In en, this message translates to:
  /// **'No logos found. Try a different search term.'**
  String get noLogosFound;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Tags will appear here once you add them to your cards.'**
  String get noTagsYet;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @oneColumn.
  ///
  /// In en, this message translates to:
  /// **'1 column'**
  String get oneColumn;

  /// No description provided for @overwriteGlobalCard.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite the existing global card with your current version.'**
  String get overwriteGlobalCard;

  /// No description provided for @parallelSync.
  ///
  /// In en, this message translates to:
  /// **'Parallel Sync'**
  String get parallelSync;

  /// No description provided for @parallelSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload cards simultaneously (faster, but may overwhelm some servers)'**
  String get parallelSyncDescription;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pinCard.
  ///
  /// In en, this message translates to:
  /// **'Pin card'**
  String get pinCard;

  /// No description provided for @pinError.
  ///
  /// In en, this message translates to:
  /// **'Error pinning card: {error}'**
  String pinError(Object error);

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @processingLogo.
  ///
  /// In en, this message translates to:
  /// **'Processing logo...'**
  String get processingLogo;

  /// No description provided for @readyForSync.
  ///
  /// In en, this message translates to:
  /// **'Ready for synchronization'**
  String get readyForSync;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reset All Statistics'**
  String get resetStatistics;

  /// No description provided for @resetStatisticsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all card usage statistics? This action cannot be undone.'**
  String get resetStatisticsConfirmation;

  /// No description provided for @resetStatisticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset usage counts for all cards to zero'**
  String get resetStatisticsDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode/QR Code'**
  String get scanBarcode;

  /// No description provided for @scanFromImage.
  ///
  /// In en, this message translates to:
  /// **'Scan from Image'**
  String get scanFromImage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchCards.
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get searchCards;

  /// No description provided for @searchForLogos.
  ///
  /// In en, this message translates to:
  /// **'Search for logos'**
  String get searchForLogos;

  /// No description provided for @searchingForLogos.
  ///
  /// In en, this message translates to:
  /// **'Searching for logos...'**
  String get searchingForLogos;

  /// No description provided for @searchLogo.
  ///
  /// In en, this message translates to:
  /// **'Search Logo'**
  String get searchLogo;

  /// No description provided for @showingLogosCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {displayed} of {total} logos'**
  String showingLogosCount(Object displayed, Object total);

  /// No description provided for @selectBarcodeImage.
  ///
  /// In en, this message translates to:
  /// **'Select Barcode Image'**
  String get selectBarcodeImage;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @serverAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. https://dav.example.com or https://192.168.0.200:8080\nor combine domain with port'**
  String get serverAddressHint;

  /// No description provided for @serverConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get serverConfiguration;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareCardGlobally.
  ///
  /// In en, this message translates to:
  /// **'Share Card Globally'**
  String get shareCardGlobally;

  /// No description provided for @shareCardGloballyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to share'**
  String get shareCardGloballyConfirm;

  /// No description provided for @shareCardGloballyConfirm2.
  ///
  /// In en, this message translates to:
  /// **'globally?'**
  String get shareCardGloballyConfirm2;

  /// No description provided for @shareCardGloballyError.
  ///
  /// In en, this message translates to:
  /// **'Failed to share card globally'**
  String get shareCardGloballyError;

  /// No description provided for @shareGlobally.
  ///
  /// In en, this message translates to:
  /// **'Share Globally'**
  String get shareGlobally;

  /// No description provided for @shareImageGlobally.
  ///
  /// In en, this message translates to:
  /// **'Share Image Globally'**
  String get shareImageGlobally;

  /// No description provided for @shareImageGloballyError.
  ///
  /// In en, this message translates to:
  /// **'Failed to share image globally'**
  String get shareImageGloballyError;

  /// No description provided for @shopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter shop name (e.g., tesco, lidl)'**
  String get shopNameHint;

  /// No description provided for @showBarcode.
  ///
  /// In en, this message translates to:
  /// **'Show Barcode'**
  String get showBarcode;

  /// No description provided for @showCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Show cover image'**
  String get showCoverImage;

  /// No description provided for @showGridNames.
  ///
  /// In en, this message translates to:
  /// **'Show card names'**
  String get showGridNames;

  /// No description provided for @showGridNamesDescription.
  ///
  /// In en, this message translates to:
  /// **'Display card names below images in grid view'**
  String get showGridNamesDescription;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get sortDateAdded;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortName;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently Used'**
  String get sortRecent;

  /// No description provided for @sortUsage.
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get sortUsage;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @statisticsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All statistics have been reset successfully'**
  String get statisticsResetSuccess;

  /// No description provided for @statisticsSection.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsSection;

  /// No description provided for @statisticsSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage usage statistics for all cards'**
  String get statisticsSectionDescription;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncActions.
  ///
  /// In en, this message translates to:
  /// **'Sync Actions'**
  String get syncActions;

  /// No description provided for @syncCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully!'**
  String get syncCompletedSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Sync is not configured.'**
  String get syncNotConfigured;

  /// No description provided for @syncNotConfiguredHint.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → Sync to set up server sync.'**
  String get syncNotConfiguredHint;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncStatusDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatusDialogTitle;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get syncStatusError;

  /// No description provided for @syncStatusLastAttempt.
  ///
  /// In en, this message translates to:
  /// **'Last Attempt'**
  String get syncStatusLastAttempt;

  /// No description provided for @syncStatusLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last Success'**
  String get syncStatusLastSuccess;

  /// No description provided for @syncStatusNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get syncStatusNever;

  /// No description provided for @syncSuccessExport.
  ///
  /// In en, this message translates to:
  /// **'Successfully exported {count} cards'**
  String syncSuccessExport(Object count);

  /// No description provided for @syncSuccessWithCleanup.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {cardCount} cards and cleaned up {deletedCount} deleted cards'**
  String syncSuccessWithCleanup(Object cardCount, Object deletedCount);

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Add tags...'**
  String get tagsHint;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (Optional)'**
  String get tagsLabel;

  /// No description provided for @takePhotoAndEdit.
  ///
  /// In en, this message translates to:
  /// **'Take photo and edit'**
  String get takePhotoAndEdit;

  /// No description provided for @tapToAddCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add cover image'**
  String get tapToAddCoverImage;

  /// No description provided for @tapToHideControls.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to hide controls'**
  String get tapToHideControls;

  /// No description provided for @tapToShowControls.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to show controls'**
  String get tapToShowControls;

  /// No description provided for @tapToUploadBarcodeImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload a barcode image'**
  String get tapToUploadBarcodeImage;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get testConnection;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeAmoled.
  ///
  /// In en, this message translates to:
  /// **'Pure Black (AMOLED)'**
  String get themeAmoled;

  /// No description provided for @themeAmoledDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure black theme for AMOLED displays'**
  String get themeAmoledDesc;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark theme for low-light environments'**
  String get themeDarkDesc;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred app theme'**
  String get themeDescription;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light theme with bright colors'**
  String get themeLightDesc;

  /// No description provided for @themeMaterialYou.
  ///
  /// In en, this message translates to:
  /// **'Material You'**
  String get themeMaterialYou;

  /// No description provided for @themeMaterialYouDesc.
  ///
  /// In en, this message translates to:
  /// **'Material You theme with dynamic colors'**
  String get themeMaterialYouDesc;

  /// No description provided for @timesUsed.
  ///
  /// In en, this message translates to:
  /// **'Times used'**
  String get timesUsed;

  /// No description provided for @tooltipRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get tooltipRefresh;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @unableToGenerateBarcode.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate barcode'**
  String get unableToGenerateBarcode;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @unpinCard.
  ///
  /// In en, this message translates to:
  /// **'Unpin card'**
  String get unpinCard;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get updated;

  /// No description provided for @updateGlobalCard.
  ///
  /// In en, this message translates to:
  /// **'Update Global Card'**
  String get updateGlobalCard;

  /// No description provided for @updateGlobalCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update the global version of'**
  String get updateGlobalCardConfirm;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @uploadToGlobalImages.
  ///
  /// In en, this message translates to:
  /// **'Upload to Global Images'**
  String get uploadToGlobalImages;

  /// No description provided for @usageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} uses'**
  String usageCount(Object count);

  /// No description provided for @usageCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage Count'**
  String get usageCountLabel;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @uses.
  ///
  /// In en, this message translates to:
  /// **'uses'**
  String get uses;

  /// No description provided for @webdavConnection.
  ///
  /// In en, this message translates to:
  /// **'Server Connection'**
  String get webdavConnection;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @advancedSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure custom folder paths for synchronization'**
  String get advancedSettingsDescription;

  /// No description provided for @pockardFolderPath.
  ///
  /// In en, this message translates to:
  /// **'Pockard Folder Path'**
  String get pockardFolderPath;

  /// No description provided for @pockardFolderPathHint.
  ///
  /// In en, this message translates to:
  /// **'Path where your cards will be synchronized.\nDefault: /pockard'**
  String get pockardFolderPathHint;

  /// No description provided for @globalFolderPath.
  ///
  /// In en, this message translates to:
  /// **'Global Folder Path'**
  String get globalFolderPath;

  /// No description provided for @globalFolderPathHint.
  ///
  /// In en, this message translates to:
  /// **'Path for global shared cards.\nDefault: /pockard_global'**
  String get globalFolderPathHint;

  /// No description provided for @showAdvancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Show Advanced Settings'**
  String get showAdvancedSettings;

  /// No description provided for @hideAdvancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Hide Advanced Settings'**
  String get hideAdvancedSettings;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

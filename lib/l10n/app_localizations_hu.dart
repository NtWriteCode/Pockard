// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'Pockard';

  @override
  String get save => 'Mentés';

  @override
  String get cancel => 'Mégse';

  @override
  String get delete => 'Törlés';

  @override
  String get close => 'Bezárás';

  @override
  String get confirm => 'Megerősítés';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get add => 'Hozzáadás';

  @override
  String get search => 'Keresés';

  @override
  String get settings => 'Beállítások';

  @override
  String get loading => 'Betöltés...';

  @override
  String get error => 'Hiba';

  @override
  String get success => 'Sikeres';

  @override
  String get yes => 'Igen';

  @override
  String get no => 'Nem';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Újra';

  @override
  String get done => 'Kész';

  @override
  String get mainTitle => 'Kártyáim';

  @override
  String get searchCards => 'Kártyák keresése...';

  @override
  String get allCards => 'Összes';

  @override
  String get sortRecent => 'Legutóbb használt';

  @override
  String get sortUsage => 'Legtöbbet használt';

  @override
  String get sortName => 'Név (A-Z)';

  @override
  String get sortDateAdded => 'Hozzáadás dátuma';

  @override
  String get emptyCardsTitle => 'Még nincsenek kártyák';

  @override
  String get emptyCardsMessage =>
      'Koppints a + gombra az első hűségkártyád hozzáadásához';

  @override
  String get emptySearchTitle => 'Nincs találat';

  @override
  String get emptySearchMessage => 'Próbálj más keresési kifejezést';

  @override
  String get connectionStatusConnected => 'Kapcsolódva';

  @override
  String get connectionStatusDisconnected => 'Nincs kapcsolat';

  @override
  String get syncStatusDialogTitle => 'Szinkronizálási státusz';

  @override
  String get syncStatusLastAttempt => 'Utolsó kísérlet';

  @override
  String get syncStatusLastSuccess => 'Utolsó sikeres';

  @override
  String get syncStatusError => 'Hiba';

  @override
  String get syncStatusNever => 'Soha';

  @override
  String get syncNow => 'Szinkronizálás most';

  @override
  String get syncing => 'Szinkronizálás...';

  @override
  String get syncNotConfigured => 'A szinkronizálás nincs beállítva.';

  @override
  String get syncNotConfiguredHint =>
      'Menj a Beállítások → Szinkronizálás menüpontba a szerver szinkronizálás beállításához.';

  @override
  String get syncCompletedSuccess => 'Szinkronizálás sikeresen befejezve!';

  @override
  String get syncFailed => 'Szinkronizálás sikertelen';

  @override
  String get addNewCard => 'Új Kártya Hozzáadása';

  @override
  String get editCard => 'Szerkesztés';

  @override
  String get cardNameLabel => 'Kártya neve';

  @override
  String get cardNameHint => 'Add meg a kártya nevét';

  @override
  String get cardNameRequired => 'Kérlek add meg a kártya nevét';

  @override
  String get barcodeTypeLabel => 'Vonalkód típusa';

  @override
  String get barcodeDataLabel => 'Vonalkód adatai';

  @override
  String get barcodeDataHint => 'Vagy add meg a vonalkódot manuálisan';

  @override
  String get barcodePreview => 'Vonalkód előnézet';

  @override
  String get barcodeDataHintNone => 'Nem szükséges vonalkód adat';

  @override
  String get scanBarcode => 'Vonalkód beolvasása';

  @override
  String get tagsLabel => 'Címkék (Opcionális)';

  @override
  String get tagsHint => 'Címkék hozzáadása...';

  @override
  String get coverImageLabel => 'Borítókép (opcionális)';

  @override
  String get selectCoverImage => 'Borítókép kiválasztása';

  @override
  String get searchLogo => 'Logó Keresése';

  @override
  String get generateImage => 'Kép Generálása';

  @override
  String get pickFromGallery => 'Kiválasztás galériából';

  @override
  String get takePicture => 'Fénykép készítése';

  @override
  String get useGlobalImage => 'Globális kép használata';

  @override
  String get cardAddedSuccess => 'Kártya sikeresen hozzáadva!';

  @override
  String get cardUpdatedSuccess => 'Kártya sikeresen frissítve!';

  @override
  String errorSavingCard(String error) {
    return 'Hiba a kártya mentésekor: $error';
  }

  @override
  String get shareGlobally => 'Globális megosztás';

  @override
  String get shareCardGloballyTitle => 'Kártya globális megosztása?';

  @override
  String get shareCardGloballyMessage =>
      'Ez feltölti a kártyát (használati adatok nélkül) a globális készletbe más felhasználók számára.';

  @override
  String get cardSharedSuccess => 'Kártya globálisan megosztva!';

  @override
  String errorSharingCard(String error) {
    return 'Hiba a kártya megosztásakor: $error';
  }

  @override
  String get deleteCardTitle => 'Kártya törlése?';

  @override
  String deleteCardMessage(String cardName) {
    return 'Biztosan törölni szeretnéd a(z) \"$cardName\" kártyát? Ez a művelet nem visszavonható.';
  }

  @override
  String get cardDeletedSuccess => 'Kártya sikeresen törölve!';

  @override
  String errorDeletingCard(String error) {
    return 'Hiba a kártya törlésekor: $error';
  }

  @override
  String usageCount(int count) {
    return '$count használat';
  }

  @override
  String get lastUsed => 'Utoljára használva';

  @override
  String get createdOn => 'Létrehozva';

  @override
  String get updatedOn => 'Frissítve';

  @override
  String get showBarcode => 'Vonalkód megjelenítése';

  @override
  String get barcodeTypeNone => 'Nincs vonalkód';

  @override
  String get barcodeTypeQR => 'QR kód';

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
  String get settingsTitle => 'Beállítások';

  @override
  String get displayTabTitle => 'Megjelenés';

  @override
  String get syncTabTitle => 'Szinkronizálás';

  @override
  String get tagsTabTitle => 'Címkék';

  @override
  String get globalCardsTabTitle => 'Globális kártyák';

  @override
  String get globalImagesTabTitle => 'Globális képek';

  @override
  String get themeLabel => 'Téma';

  @override
  String get themeLight => 'Világos';

  @override
  String get themeDark => 'Sötét';

  @override
  String get themeAmoled => 'Teljesen fekete (AMOLED)';

  @override
  String get themeMaterialYou => 'Material You';

  @override
  String get languageLabel => 'Nyelv';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get languageSystem => 'Rendszer alapértelmezett';

  @override
  String get cardViewLabel => 'Kártya nézet';

  @override
  String get cardViewList => 'Lista';

  @override
  String get cardViewGrid => 'Rács';

  @override
  String get syncSettingsTitle => 'Szinkronizálási beállítások';

  @override
  String get webdavServerLabel => 'Szerver cím';

  @override
  String get webdavServerHint => 'https://pelda.com/remote.php/dav';

  @override
  String get usernameLabel => 'Felhasználónév';

  @override
  String get usernameHint => 'felhasznalonev';

  @override
  String get passwordLabel => 'Jelszó';

  @override
  String get passwordHint => 'jelszo';

  @override
  String get testConnection => 'Kapcsolat tesztelése';

  @override
  String get testingConnection => 'Kapcsolat tesztelése...';

  @override
  String get connectionSuccessful => 'Sikeres kapcsolódás!';

  @override
  String connectionFailed(String error) {
    return 'Sikertelen kapcsolódás!';
  }

  @override
  String get disconnect => 'Kapcsolat bontása';

  @override
  String get disconnecting => 'Kapcsolat bontása...';

  @override
  String get disconnected => 'Kapcsolat sikeresen bontva';

  @override
  String exportingCards(int count) {
    return '$count kártya exportálása...';
  }

  @override
  String cardsExportedSuccess(int count) {
    return '$count kártya sikeresen exportálva!';
  }

  @override
  String errorExportingCards(String error) {
    return 'Hiba a kártyák exportálásakor: $error';
  }

  @override
  String get importCards => 'Összes importálása';

  @override
  String get importingCards => 'Kártyák importálása...';

  @override
  String cardsImportedSuccess(int imported, int updated) {
    return '$imported kártya importálva, $updated frissítve';
  }

  @override
  String errorImportingCards(String error) {
    return 'Hiba a kártyák importálásakor: $error';
  }

  @override
  String get autoSyncLabel => 'Automatikus szinkronizálás változáskor';

  @override
  String get parallelSyncLabel => 'Párhuzamos szinkronizálás';

  @override
  String get parallelSyncDescription =>
      'Kártyák egyidejű feltöltése (gyorsabb, de túlterhelheti egyes szervereket)';

  @override
  String get fillAllFields => 'Kérlek töltsd ki az összes kapcsolódási mezőt';

  @override
  String get serverAddress => 'Szerver cím';

  @override
  String get lastSync => 'Utolsó szinkronizálás';

  @override
  String get globalFolderAvailable => 'Globális mappa elérhető';

  @override
  String get tagsSettingsTitle => 'Címkék sorrendje';

  @override
  String get tagsSettingsDescription =>
      'Húzd az újrarendezéshez. Ez befolyásolja a szűrőkben való megjelenésüket.';

  @override
  String get noTagsYet => 'Még Nincsenek Címkék';

  @override
  String get globalCardsTitle => 'Globális kártyák';

  @override
  String get globalCardsDescription =>
      'Más felhasználók által megosztott kártyák';

  @override
  String get downloadCard => 'Letöltés';

  @override
  String get downloadingCard => 'Kártya letöltése...';

  @override
  String get cardDownloadedSuccess => 'Kártya sikeresen letöltve!';

  @override
  String errorDownloadingCard(String error) {
    return 'Hiba a kártya letöltésekor: $error';
  }

  @override
  String get deleteGlobalCard => 'Globális kártya törlése';

  @override
  String get deleteGlobalCardTitle => 'Globális kártya törlése?';

  @override
  String get deleteGlobalCardMessage =>
      'Biztosan törölni szeretnéd ezt a kártyát a globális készletből?';

  @override
  String get globalCardDeleted => 'Globális kártya törölve';

  @override
  String errorDeletingGlobalCard(String error) {
    return 'Hiba a globális kártya törlésekor: $error';
  }

  @override
  String get noGlobalCards => 'Nincsenek globális kártyák';

  @override
  String uploadedBy(String uploader) {
    return 'Feltöltötte: $uploader';
  }

  @override
  String get refresh => 'Frissítés';

  @override
  String get globalImagesTitle => 'Globális képek';

  @override
  String get globalImagesDescription =>
      'Más felhasználók által megosztott képek';

  @override
  String get uploadImage => 'Kép Feltöltése';

  @override
  String get downloadImage => 'Letöltés';

  @override
  String get downloadingImage => 'Kép letöltése...';

  @override
  String get imageDownloadedSuccess => 'Kép sikeresen letöltve!';

  @override
  String errorDownloadingImage(String error) {
    return 'Hiba a kép letöltésekor: $error';
  }

  @override
  String get deleteGlobalImage => 'Globális kép törlése';

  @override
  String get deleteGlobalImageTitle => 'Globális kép törlése?';

  @override
  String get deleteGlobalImageMessage =>
      'Biztosan törölni szeretnéd ezt a képet a globális készletből?';

  @override
  String get globalImageDeleted => 'Globális kép törölve';

  @override
  String errorDeletingGlobalImage(String error) {
    return 'Hiba a globális kép törlésekor: $error';
  }

  @override
  String get noGlobalImages => 'Nincsenek globális képek';

  @override
  String get selectImageSource => 'Kép forrás kiválasztása';

  @override
  String get fromGallery => 'Galériából';

  @override
  String get fromCamera => 'Kamerából';

  @override
  String get enterImageName => 'Add meg a kép nevét:';

  @override
  String get imageName => 'Kép neve';

  @override
  String get imageNameRequired => 'Kérlek add meg a kép nevét';

  @override
  String get uploadingImage => 'Kép feltöltése...';

  @override
  String get imageUploadedSuccess => 'Kép sikeresen feltöltve!';

  @override
  String errorUploadingImage(String error) {
    return 'Hiba a kép feltöltésekor: $error';
  }

  @override
  String get logoSearchTitle => 'Logó keresése';

  @override
  String get logoSearchHint => 'Add meg a márka nevét...';

  @override
  String get searchingLogos => 'Logók keresése...';

  @override
  String get noLogosFound => 'Nem találhatóak logók';

  @override
  String errorSearchingLogos(String error) {
    return 'Hiba a logók keresésekor: $error';
  }

  @override
  String get selectLogo => 'Kiválasztás';

  @override
  String get processingLogo => 'Logó feldolgozása...';

  @override
  String get logoSelectedSuccess => 'Logó sikeresen kiválasztva!';

  @override
  String errorProcessingLogo(String error) {
    return 'Hiba a logó feldolgozásakor: $error';
  }

  @override
  String get imageGeneratorTitle => 'Kép generálása';

  @override
  String get companyNameLabel => 'Cég neve';

  @override
  String get companyNameHint => 'Add meg a cég nevét';

  @override
  String get companyNameRequired => 'Kérlek add meg a cég nevét';

  @override
  String get selectBackgroundColor => 'Háttérszín';

  @override
  String get selectTextColor => 'Szövegszín';

  @override
  String get generateImageButton => 'Kép generálása';

  @override
  String get generatingImage => 'Kép generálása...';

  @override
  String get imageGeneratedSuccess => 'Kép sikeresen generálva!';

  @override
  String errorGeneratingImage(String error) {
    return 'Hiba a kép generálása során';
  }

  @override
  String get brightnessIncreasedNote => 'Fényerő növelve a jobb beolvasáshoz';

  @override
  String get fieldRequired => 'Ez a mező kötelező';

  @override
  String get invalidUrl => 'Kérlek adj meg érvényes URL-t';

  @override
  String get invalidEmail => 'Kérlek adj meg érvényes email címet';

  @override
  String get justNow => 'Most';

  @override
  String minutesAgo(int minutes) {
    return '$minutes perce';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours órája';
  }

  @override
  String daysAgo(int days) {
    return '$days napja';
  }

  @override
  String get today => 'Ma';

  @override
  String get yesterday => 'Tegnap';

  @override
  String get unknownError => 'Ismeretlen hiba történt';

  @override
  String get networkError => 'Hálózati hiba. Kérlek ellenőrizd a kapcsolatod.';

  @override
  String get permissionDenied => 'Engedély megtagadva';

  @override
  String get fileNotFound => 'Fájl nem található';

  @override
  String get operationCancelled => 'Művelet megszakítva';

  @override
  String get globalPool => 'Globális Készlet';

  @override
  String get filterAll => 'Összes';

  @override
  String get addCard => 'Kártya Hozzáadása';

  @override
  String get deleteCard => 'Kártya Törlése';

  @override
  String get saveCard => 'Kártya Mentése';

  @override
  String get cardName => 'Kártya Neve';

  @override
  String get barcodeLabel => 'Vonalkód/QR Kód';

  @override
  String get noBarcodeNeeded => 'Nincs szükség vonalkódra';

  @override
  String get barcodeError => 'Hiba a vonalkód beolvasása során';

  @override
  String get cardSaveError => 'Hiba a kártya mentése során';

  @override
  String get deleteCardConfirm => 'Biztosan törölni szeretnéd';

  @override
  String get actionCannotBeUndone => 'Ez a művelet nem vonható vissza.';

  @override
  String get barcodeInformation => 'Vonalkód információ';

  @override
  String get unknown => 'Ismeretlen';

  @override
  String get data => 'Adat';

  @override
  String get type => 'Típus';

  @override
  String get statistics => 'Statisztika';

  @override
  String get timesUsed => 'Használatok száma';

  @override
  String get uses => 'használat';

  @override
  String get created => 'Létrehozva';

  @override
  String get lastUpdated => 'Utoljára frissítve';

  @override
  String get cardDeletedSuccessfully => 'Kártya sikeresen törölve';

  @override
  String get failedToDeleteCard => 'Sikertelen kártya törlés';

  @override
  String get tapToAddCoverImage => 'Koppints borítókép hozzáadásához';

  @override
  String get cardDeleteError => 'Sikertelen kártya törlés';

  @override
  String get updateGlobalCard => 'Globális Kártya Frissítése';

  @override
  String get shareCardGlobally => 'Kártya Globális Megosztása';

  @override
  String get cardExistsInGlobalPool =>
      'Ez a kártya már létezik a globális készletben.';

  @override
  String get updateGlobalCardConfirm =>
      'Biztosan frissíteni szeretnéd a globális verzióját';

  @override
  String get overwriteGlobalCard =>
      'Ez felülírja a meglévő globális kártyát a jelenlegi verziódra.';

  @override
  String get shareCardGloballyConfirm => 'Biztosan meg szeretnéd osztani';

  @override
  String get shareCardGloballyConfirm2 => 'globálisan?';

  @override
  String get cardVisibleToAllUsers =>
      'Ez láthatóvá teszi a kártyát minden felhasználó számára a globális készletben.';

  @override
  String get update => 'Frissítés';

  @override
  String get share => 'Megosztás';

  @override
  String get globalCardUpdatedSuccess => 'Globális kártya sikeresen frissítve!';

  @override
  String get cardSharedGloballySuccess => 'Kártya globálisan megosztva!';

  @override
  String get shareCardGloballyError => 'Sikertelen globális kártya megosztás';

  @override
  String get imageSharedGloballySuccess => 'Kép globálisan megosztva!';

  @override
  String get shareImageGloballyError => 'Sikertelen globális kép megosztás';

  @override
  String get shareImageGlobally => 'Kép Globális Megosztása';

  @override
  String get imageNameHint => 'Kép neve';

  @override
  String get display => 'Megjelenés';

  @override
  String get tags => 'Címkék';

  @override
  String get sync => 'Szinkronizálás';

  @override
  String get theme => 'Téma';

  @override
  String get themeDescription => 'Válaszd ki a preferált app témát';

  @override
  String get languageDescription => 'Válaszd ki a preferált nyelvet';

  @override
  String get layout => 'Elrendezés';

  @override
  String get layoutDescription => 'Válaszd ki hogyan jelenjenek meg a kártyák';

  @override
  String get gridColumns => 'Rács Oszlopok';

  @override
  String get gridColumnsDescription => 'Oszlopok száma a rács nézetben';

  @override
  String get oneColumn => '1 oszlop';

  @override
  String get fourColumns => '4 oszlop';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraDescription => 'Kamera viselkedés beállítása';

  @override
  String get autoOpenCamera => 'Kamera automatikus megnyitása';

  @override
  String get autoOpenCameraDescription =>
      'Automatikusan megnyitja a kamerát új kártya hozzáadásakor';

  @override
  String get statisticsSection => 'Statisztikák';

  @override
  String get statisticsSectionDescription =>
      'Használati statisztikák kezelése az összes kártyához';

  @override
  String get resetStatistics => 'Összes statisztika törlése';

  @override
  String get resetStatisticsDescription =>
      'Az összes kártya használati számának nullázása';

  @override
  String get resetStatisticsConfirmation =>
      'Biztosan törölni szeretnéd az összes kártya használati statisztikáját? Ez a művelet nem visszavonható.';

  @override
  String get reset => 'Törlés';

  @override
  String get statisticsResetSuccess => 'Minden statisztika sikeresen törölve';

  @override
  String get noTagsYetDescription =>
      'A címkék itt fognak megjelenni, amint hozzáadod őket a kártyáidhoz';

  @override
  String get dragToReorderTags => 'Húzd a Címkéket az Átrendezéshez';

  @override
  String get dragToReorderTagsDescription =>
      'Az itt meghatározott sorrend befolyásolja a címkék megjelenését a főképernyőn';

  @override
  String get position => 'Pozíció';

  @override
  String get cards => 'Kártyák';

  @override
  String get images => 'Képek';

  @override
  String globalCardsCount(int count) {
    return 'Globális kártyák ($count)';
  }

  @override
  String globalImagesCount(int count) {
    return 'Globális képek ($count)';
  }

  @override
  String get configureWebdavFirst =>
      'Kérlek először állítsd be a szerver kapcsolatot a Szinkronizálás fülön';

  @override
  String get failedToLoadGlobalCards => 'Sikertelen globális kártyák betöltése';

  @override
  String get cardImportedSuccess => 'Kártya sikeresen importálva!';

  @override
  String get failedToImportCard => 'Sikertelen kártya importálás';

  @override
  String get globalCardDeletedSuccess => 'Globális kártya sikeresen törölve!';

  @override
  String get failedToDeleteGlobalCard => 'Sikertelen globális kártya törlés';

  @override
  String get globalFolderNotAvailable => 'Globális mappa nem elérhető';

  @override
  String get globalFolderRequired =>
      'A globális funkciókhoz szükség van egy \"/pockard_global\" mappára a szerveren.';

  @override
  String get createGlobalFolderManually =>
      'Kérlek, hozd létre ezt a mappát manuálisan a szerveren a globális képmegosztás engedélyezéséhez.';

  @override
  String get tapToHideControls => 'Koppints bárhová a vezérlők elrejtéséhez';

  @override
  String get tapToShowControls =>
      'Koppints bárhová a vezérlők megjelenítéséhez';

  @override
  String get showCoverImage => 'Borítókép megjelenítése';

  @override
  String get unableToGenerateBarcode => 'Nem sikerült a vonalkód generálása';

  @override
  String get invalidBarcodeData =>
      'Érvénytelen adat vagy nem támogatott formátum';

  @override
  String get noBarcodeDataAvailable => 'Nincs elérhető vonalkód adat';

  @override
  String get noBarcodeDataMessage =>
      'Ez a kártya nem tartalmaz vonalkód vagy QR kód adatot.';

  @override
  String get usageCountLabel => 'Használatok Száma';

  @override
  String get fillAllConnectionFields =>
      'Kérlek töltsd ki az összes kapcsolati mezőt';

  @override
  String get globalFolderDetected =>
      'Globális mappa észlelve - Globális funkciók engedélyezve';

  @override
  String get globalFolderNotFound =>
      'Globális mappa nem található - Globális funkciók letiltva';

  @override
  String get connectionError => 'Kapcsolódási hiba';

  @override
  String get parallelSync => 'Párhuzamos Szinkronizálás';

  @override
  String get disconnectAndChangeServer => 'Leválasztás és Szerver Váltása';

  @override
  String get disconnectFromServer => 'Leválasztás a Szerverről';

  @override
  String get disconnectConfirmation =>
      'Biztosan le szeretnél választani? Újra meg kell adnod a szerver hitelesítő adatait.';

  @override
  String get disconnectedSuccessfully => 'Sikeresen leválasztva';

  @override
  String get noCardsToSync => 'Nincsenek szinkronizálandó kártyák';

  @override
  String get noCardsToImport => 'Nem találhatók importálandó kártyák';

  @override
  String get importComplete => 'Importálás befejezve';

  @override
  String get newCards => 'új kártya';

  @override
  String get updated => 'frissítve';

  @override
  String get importFailed => 'Importálás sikertelen';

  @override
  String deleteGlobalImageConfirm(String imageName) {
    return 'Biztosan törölni szeretnéd a(z) \"$imageName\" képet a globális készletből?';
  }

  @override
  String get takePhotoAndEdit => 'Fotó készítése és szerkesztés';

  @override
  String get gallery => 'Galéria';

  @override
  String get choosePhotoAndEdit => 'Fotó kiválasztása és szerkesztés';

  @override
  String get errorPickingImage => 'Hiba a kép kiválasztása során';

  @override
  String get uploadToGlobalImages => 'Feltöltés a globális képekhez';

  @override
  String get upload => 'Feltöltés';

  @override
  String get failedToUploadImage => 'Nem sikerült feltölteni a képet';

  @override
  String get failedToLoadImage => 'Nem sikerült betölteni a képet';

  @override
  String get logoAddedSuccess => 'Logó sikeresen hozzáadva!';

  @override
  String get failedToProcessLogo => 'Sikertelen logó feldolgozás';

  @override
  String get searchingForLogos => 'Logók keresése...';

  @override
  String get tryAgain => 'Próbáld Újra';

  @override
  String get customColor => 'Egyéni Szín';

  @override
  String get chooseCustomColor => 'Egyéni Szín Választása';

  @override
  String get changeImage => 'Kép Módosítása';

  @override
  String get removeImage => 'Kép Eltávolítása';

  @override
  String get generateImageOption => 'Kép Generálása';

  @override
  String get searchLogoOption => 'Logó Keresése';

  @override
  String get globalImages => 'Globális Képek';

  @override
  String get editCurrentImage => 'Jelenlegi Kép Szerkesztése';

  @override
  String get errorEditingImage => 'Hiba a kép szerkesztése során';

  @override
  String get serverAddressHint =>
      'https://dav.example.com vagy https://192.168.0.200:8080';

  @override
  String get username => 'Felhasználónév';

  @override
  String get password => 'Jelszó';

  @override
  String get adjustLogo => 'Logó igazítása';

  @override
  String get shopNameHint => 'Írd be az üzlet nevét (pl. tesco, lidl)';

  @override
  String get enterTextHint =>
      'Írd be a szöveget a képedhez\nNyomj Entert az új sorhoz';

  @override
  String get importCard => 'Kártya importálása';

  @override
  String get importCardDescription => 'Kártya hozzáadása a gyűjteményedhez';

  @override
  String get deleteFromGlobalPool => 'Törlés a globális készletből';

  @override
  String get deleteFromGlobalPoolDescription =>
      'Kártya eltávolítása a globális készletből';

  @override
  String deleteGlobalCardConfirm(String cardName) {
    return 'Biztosan törölni szeretnéd a(z) \"$cardName\" kártyát a globális készletből?';
  }

  @override
  String get imageNameHint2 => 'Adj nevet a képnek';

  @override
  String get editCoverImage => 'Borítókép szerkesztése';

  @override
  String get cameraPermissionRequired =>
      'Kamera engedély szükséges a vonalkód beolvasásához';

  @override
  String get scanFromImage => 'Képről beolvasás';

  @override
  String get noBarcodeFoundInImage => 'Nem található vonalkód a képen';

  @override
  String get errorScanningImage => 'Hiba a kép beolvasása közben';

  @override
  String get failedToLoadGlobalImages2 =>
      'Nem sikerült betölteni a globális képeket';

  @override
  String get failedToDownloadImage => 'Nem sikerült letölteni a képet';

  @override
  String get failedToLoadGlobalImages =>
      'Nem sikerült betölteni a globális képeket';

  @override
  String get globalImageDeletedSuccess => 'Globális kép sikeresen törölve!';

  @override
  String get failedToDeleteGlobalImage =>
      'Nem sikerült törölni a globális képet';

  @override
  String get centerCodeInFrame => 'Helyezd a kódot a keret közepére';

  @override
  String get noImagesSharedYet => 'Még nem került kép a globális készletbe';

  @override
  String get readyForSync => 'Szinkronizálásra kész';

  @override
  String get noCardsSharedYet => 'Még nem került kártya a globális készletbe';

  @override
  String get connectedCheck => 'Csatlakozva ✓';

  @override
  String get exporting => 'Exportálás...';

  @override
  String get exportCards => 'Összes exportálása';

  @override
  String get importing => 'Importálás...';

  @override
  String get layoutRows => 'Sorok';

  @override
  String get layoutGrid => 'Rács';

  @override
  String get themeLightDesc => 'Világos téma élénk színekkel';

  @override
  String get themeDarkDesc => 'Sötét téma gyenge fényviszonyokhoz';

  @override
  String get themeAmoledDesc => 'Teljesen fekete téma AMOLED kijelzőkhöz';

  @override
  String get themeMaterialYouDesc => 'Material You téma dinamikus színekkel';

  @override
  String get layoutRowsDesc => 'Kártyák megjelenítése függőleges listában';

  @override
  String get layoutGridDesc => 'Kártyák megjelenítése rács elrendezésben';

  @override
  String get tryDifferentSearch => 'Próbálj meg egy másik keresőkifejezést';

  @override
  String get searchForLogos => 'Logók keresése';

  @override
  String get enterShopName => 'Adj meg egy bolt nevet a logó kereséséhez';

  @override
  String loadMore(int count) {
    return 'További betöltése ($count van még)';
  }

  @override
  String get tooltipRefresh => 'Frissítés';

  @override
  String get tooltipEditConfig => 'Beállítások szerkesztése';

  @override
  String syncSuccessWithCleanup(int cardCount, int deletedCount) {
    return 'Sikeresen szinkronizálva $cardCount kártya és törölve $deletedCount törölt kártya';
  }

  @override
  String syncSuccessExport(int count) {
    return 'Sikeresen exportálva $count kártya';
  }

  @override
  String get noCoverImage => 'Nincs borítókép';

  @override
  String get addCoverImageToCard => 'Adj borítóképet ehhez a kártyához';

  @override
  String get chooseFromGlobalImages => 'Válassz a globális képekből';

  @override
  String get addTagsHint => 'Címkék hozzáadása...';

  @override
  String get noBarcodeOnly => 'Nincs vonalkód (csak borítókép)';

  @override
  String get exceptionConfigureWebdav =>
      'Kérlek, először konfiguráld a szerver kapcsolatot a Szinkronizálás fülön';

  @override
  String get exceptionFailedSearchLogos => 'Nem sikerült logókat keresni';

  @override
  String get exceptionFailedDownloadLogo => 'Nem sikerült letölteni a logót';

  @override
  String get exceptionFailedProcessLogo => 'Nem sikerült feldolgozni a logót';

  @override
  String get exceptionFailedFinalizeLogo =>
      'Nem sikerült véglegesíteni a logót';

  @override
  String get exceptionFailedInitWebdav =>
      'Nem sikerült inicializálni a szerver klienst';

  @override
  String get exceptionUserNotConfigured =>
      'Szerver felhasználó nincs beállítva';

  @override
  String get text => 'Szöveg';

  @override
  String get textColor => 'Szöveg színe';

  @override
  String get white => 'Fehér';

  @override
  String get black => 'Fekete';

  @override
  String get server => 'Szerver';

  @override
  String get globalFeatures => 'Globális funkciók';

  @override
  String get enabled => 'Engedélyezve';

  @override
  String get disabled => 'Letiltva';

  @override
  String get createGlobalFolderHint =>
      'Hozd létre a /pockard_global mappát a szerveren a globális funkciók engedélyezéséhez';

  @override
  String get webdavConnection => 'Szerver kapcsolat';

  @override
  String get serverConfiguration => 'Szerver beállítások';

  @override
  String get syncActions => 'Szinkronizálási műveletek';

  @override
  String get connected => 'Csatlakozva';

  @override
  String get notConnected => 'Nincs csatlakozva';

  @override
  String lastSyncLabel(String date) {
    return 'Utolsó szinkronizálás: $date';
  }

  @override
  String get coverImageSuffix => '(Borítókép)';

  @override
  String get status => 'Állapot';

  @override
  String get noBarcodeLabel => 'Nincs vonalkód';

  @override
  String get preview => 'Előnézet';

  @override
  String get backgroundColor => 'Háttérszín';

  @override
  String get pinCard => 'Kártya kitűzése';

  @override
  String get unpinCard => 'Kártya kitűzésének megszüntetése';

  @override
  String get cardPinned => 'Kártya kitűzve';

  @override
  String get cardUnpinned => 'Kártya kitűzése megszüntetve';

  @override
  String get pinError => 'Hiba a kártya kitűzése közben';

  @override
  String get showGridNames => 'Kártyanevek megjelenítése';

  @override
  String get showGridNamesDescription =>
      'Kártyanevek megjelenítése a képek alatt rácsnézetben';

  @override
  String get layoutMinimal => 'Minimális';

  @override
  String get layoutMinimalDesc =>
      'Ultra-kompakt lista csak nevekkel és apró előnézetekkel';

  @override
  String get imageOnlyLabel => 'Csak kép';

  @override
  String get imageOnlyMode => 'Csak kép mód - nincs szükség vonalkód adatra';

  @override
  String get tapToUploadBarcodeImage =>
      'Koppints ide vonalkód kép feltöltéséhez';

  @override
  String get barcodeImageUploaded => 'Vonalkód kép feltöltve';

  @override
  String get selectBarcodeImage => 'Vonalkód kép kiválasztása';

  @override
  String get removeBarcodeImage => 'Vonalkód kép eltávolítása';
}

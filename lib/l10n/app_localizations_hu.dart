// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get actionCannotBeUndone => 'Ez a művelet nem vonható vissza.';

  @override
  String get addCard => 'Kártya Hozzáadása';

  @override
  String get addCoverImageToCard => 'Adj borítóképet ehhez a kártyához';

  @override
  String get adjustLogo => 'Logó igazítása';

  @override
  String get allCards => 'Összes';

  @override
  String get appName => 'Pockard';

  @override
  String get autoOpenCamera => 'Kamera automatikus megnyitása';

  @override
  String get autoOpenCameraDescription =>
      'Automatikusan megnyitja a kamerát új kártya hozzáadásakor';

  @override
  String get backgroundColor => 'Háttérszín';

  @override
  String get barcodeDataHint => 'Vagy add meg a vonalkódot manuálisan';

  @override
  String barcodeError(Object error) {
    return 'Hiba a vonalkód beolvasása során: $error';
  }

  @override
  String get barcodeImageUploaded => 'Vonalkód kép feltöltve';

  @override
  String get barcodePreviewHint =>
      'Olvass be vagy adj meg vonalkód adatot az előnézethez';

  @override
  String get barcodeInformation => 'Vonalkód információ';

  @override
  String get barcodeLabel => 'Vonalkód/QR Kód';

  @override
  String get barcodePreview => 'Vonalkód előnézet';

  @override
  String get barcodeTypeLabel => 'Vonalkód típusa';

  @override
  String get black => 'Fekete';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraDescription => 'Kamera viselkedés beállítása';

  @override
  String get cameraPermissionRequired =>
      'Kamera engedély szükséges a vonalkód beolvasásához';

  @override
  String get cancel => 'Mégse';

  @override
  String get cardAddedSuccess => 'Kártya sikeresen hozzáadva!';

  @override
  String get cardDeletedSuccess => 'Kártya sikeresen törölve!';

  @override
  String cardDeleteError(Object error) {
    return 'Sikertelen kártya törlés: $error';
  }

  @override
  String get cardExistsInGlobalPool =>
      'Ez a kártya már létezik a globális készletben.';

  @override
  String get cardImportedSuccess => 'Kártya sikeresen importálva!';

  @override
  String get cardName => 'Kártya Neve';

  @override
  String get cardNameHint => 'Add meg a kártya nevét';

  @override
  String get cardNameRequired => 'Kérlek add meg a kártya nevét';

  @override
  String get cardPinned => 'Kártya kitűzve';

  @override
  String get cards => 'Kártyák';

  @override
  String cardSaveError(Object error) {
    return 'Hiba a kártya mentése során: $error';
  }

  @override
  String get cardSharedGloballySuccess => 'Kártya globálisan megosztva!';

  @override
  String get cardUnpinned => 'Kártya kitűzése megszüntetve';

  @override
  String get cardUpdatedSuccess => 'Kártya sikeresen frissítve!';

  @override
  String get cardVisibleToAllUsers =>
      'Ez láthatóvá teszi a kártyát minden felhasználó számára a globális készletben.';

  @override
  String get centerCodeInFrame => 'Helyezd a kódot a keret közepére';

  @override
  String get changeImage => 'Kép Módosítása';

  @override
  String get chooseCustomColor => 'Egyéni Szín Választása';

  @override
  String get chooseFromGlobalImages => 'Válassz a globális képekből';

  @override
  String get choosePhotoAndEdit => 'Fotó kiválasztása és szerkesztés';

  @override
  String get close => 'Bezárás';

  @override
  String get configureWebdavFirst =>
      'Kérlek először állítsd be a szerver kapcsolatot a Szinkronizálás fülön';

  @override
  String get connected => 'Csatlakozva';

  @override
  String get connectedCheck => 'Csatlakozva ✓';

  @override
  String connectionFailed(Object error) {
    return 'Kapcsolódási hiba: $error';
  }

  @override
  String get connectionSuccessful => 'Sikeres kapcsolódás!';

  @override
  String get coverImageLabel => 'Borítókép (opcionális)';

  @override
  String get coverImageSuffix => '(Borítókép)';

  @override
  String get created => 'Létrehozva';

  @override
  String get createGlobalFolderHint =>
      'Hozd létre a /pockard_global mappát a szerveren a globális funkciók engedélyezéséhez';

  @override
  String get createGlobalFolderManually =>
      'Kérlek hozd létre ezt a mappát manuálisan a szervereden a globális megosztás engedélyezéséhez.';

  @override
  String get customColor => 'Egyéni Szín';

  @override
  String get data => 'Adat';

  @override
  String daysAgo(Object days) {
    return '$days napja';
  }

  @override
  String get delete => 'Törlés';

  @override
  String get deleteCard => 'Kártya Törlése';

  @override
  String deleteCardMessage(Object cardName) {
    return 'Biztosan törölni szeretnéd a(z) \"$cardName\" kártyát? Ez a művelet nem visszavonható.';
  }

  @override
  String get deleteFromGlobalPool => 'Törlés a globális készletből';

  @override
  String get deleteFromGlobalPoolDescription =>
      'Kártya eltávolítása a globális készletből';

  @override
  String get deleteGlobalCard => 'Globális kártya törlése';

  @override
  String deleteGlobalCardConfirm(Object cardName) {
    return 'Biztosan törölni szeretnéd a(z) \"$cardName\" kártyát a globális készletből?';
  }

  @override
  String get deleteGlobalImage => 'Globális kép törlése';

  @override
  String deleteGlobalImageConfirm(Object imageName) {
    return 'Biztosan törölni szeretnéd a(z) \"$imageName\" képet a globális készletből?';
  }

  @override
  String get disabled => 'Letiltva';

  @override
  String get disconnect => 'Kapcsolat bontása';

  @override
  String get disconnectAndChangeServer => 'Leválasztás és Szerver Váltása';

  @override
  String get disconnectConfirmation =>
      'Biztosan le szeretnél választani? Újra meg kell adnod a szerver hitelesítő adatait.';

  @override
  String get disconnectedSuccessfully => 'Sikeresen leválasztva';

  @override
  String get disconnectFromServer => 'Leválasztás a Szerverről';

  @override
  String get display => 'Megjelenés';

  @override
  String get done => 'Kész';

  @override
  String get dragToReorderTags => 'Húzd a Címkéket az Átrendezéshez';

  @override
  String get dragToReorderTagsDescription =>
      'Az itt meghatározott sorrend befolyásolja a címkék megjelenését a főképernyőn';

  @override
  String get editCard => 'Szerkesztés';

  @override
  String get emptyCardsMessage =>
      'Koppints a + gombra az első hűségkártyád hozzáadásához';

  @override
  String get emptyCardsTitle => 'Még nincsenek kártyák';

  @override
  String get enabled => 'Engedélyezve';

  @override
  String get enterImageName => 'Add meg a kép nevét:';

  @override
  String get enterShopName => 'Adj meg egy bolt nevet a logó kereséséhez';

  @override
  String get enterTextHint =>
      'Írd be a szöveget a képedhez\nNyomj Entert az új sorhoz';

  @override
  String get error => 'Hiba';

  @override
  String errorDeletingGlobalCard(Object error) {
    return 'Hiba a globális kártya törlésekor: $error';
  }

  @override
  String errorDeletingGlobalImage(Object error) {
    return 'Hiba a globális kép törlésekor: $error';
  }

  @override
  String errorDownloadingCard(Object error) {
    return 'Hiba a kártya letöltésekor: $error';
  }

  @override
  String errorDownloadingImage(Object error) {
    return 'Hiba a kép letöltésekor: $error';
  }

  @override
  String errorEditingImage(Object error) {
    return 'Hiba a kép szerkesztése során: $error';
  }

  @override
  String errorGeneratingImage(Object error) {
    return 'Hiba a kép generálásakor: $error';
  }

  @override
  String errorImportingCards(Object error) {
    return 'Hiba a kártyák importálásakor: $error';
  }

  @override
  String errorPickingImage(Object error) {
    return 'Hiba a kép kiválasztása során: $error';
  }

  @override
  String errorProcessingLogo(Object error) {
    return 'Hiba a logó feldolgozásakor: $error';
  }

  @override
  String errorScanningImage(Object error) {
    return 'Hiba a kép beolvasása közben: $error';
  }

  @override
  String errorUploadingImage(Object error) {
    return 'Hiba a kép feltöltésekor: $error';
  }

  @override
  String get exceptionConfigureWebdav =>
      'Kérlek, először konfiguráld a szerver kapcsolatot a Szinkronizálás fülön';

  @override
  String get exceptionFailedDownloadLogo => 'Nem sikerült letölteni a logót';

  @override
  String get exceptionFailedFinalizeLogo =>
      'Nem sikerült véglegesíteni a logót';

  @override
  String get exceptionFailedProcessLogo => 'Nem sikerült feldolgozni a logót';

  @override
  String get exceptionFailedSearchLogos => 'Nem sikerült logókat keresni';

  @override
  String get exceptionUserNotConfigured =>
      'Szerver felhasználó nincs beállítva';

  @override
  String get exceptionWebdavNotInitialized =>
      'WebDAV kliens nincs inicializálva';

  @override
  String get exceptionGlobalFolderNotAvailable =>
      'Globális mappa nem elérhető a szerveren';

  @override
  String exceptionLocalFileNotFound(Object path) {
    return 'Helyi fájl nem létezik: $path';
  }

  @override
  String get exceptionImageNotFound => 'Kép nem található';

  @override
  String get exceptionContextNotAvailable =>
      'Kontextus nem elérhető a vágáshoz';

  @override
  String get exceptionLogoSelectionCancelled => 'Logó kiválasztás megszakítva';

  @override
  String get exportCards => 'Összes exportálása';

  @override
  String get exporting => 'Exportálás...';

  @override
  String get fillAllConnectionFields =>
      'Kérlek töltsd ki az összes kapcsolati mezőt';

  @override
  String get filterAll => 'Összes';

  @override
  String get fourColumns => '4 oszlop';

  @override
  String get gallery => 'Galéria';

  @override
  String get generateImage => 'Kép generálása';

  @override
  String globalCardsCount(Object count) {
    return 'Globális kártyák ($count)';
  }

  @override
  String get globalCardUpdatedSuccess => 'Globális kártya sikeresen frissítve!';

  @override
  String get globalFeatures => 'Globális funkciók';

  @override
  String get globalFolderAvailable => 'Globális mappa elérhető';

  @override
  String get globalFolderDetected =>
      'Globális mappa észlelve - Globális funkciók engedélyezve';

  @override
  String get globalFolderNotAvailable => 'Globális mappa nem elérhető';

  @override
  String get globalFolderRequired =>
      'A globális funkciók egy \"/pockard_global\" mappát igényelnek a szervereden.';

  @override
  String get globalImages => 'Globális Képek';

  @override
  String globalImagesCount(Object count) {
    return 'Globális képek ($count)';
  }

  @override
  String get globalPool => 'Globális Készlet';

  @override
  String get gridColumns => 'Rács Oszlopok';

  @override
  String get gridColumnsDescription => 'Oszlopok száma a rács nézetben';

  @override
  String hoursAgo(Object hours) {
    return '$hours órája';
  }

  @override
  String get imageDeletedSuccess => 'Kép sikeresen törölve!';

  @override
  String get imageName => 'Kép neve';

  @override
  String get imageNameHint => 'Kép neve';

  @override
  String get imageOnlyLabel => 'Csak kép';

  @override
  String get images => 'Képek';

  @override
  String get imageSharedGloballySuccess => 'Kép globálisan megosztva!';

  @override
  String get imageUploadedSuccess => 'Kép sikeresen feltöltve!';

  @override
  String get importCard => 'Kártya importálása';

  @override
  String get importCardDescription => 'Kártya hozzáadása a gyűjteményedhez';

  @override
  String get importCards => 'Összes importálása';

  @override
  String get importComplete => 'Importálás befejezve';

  @override
  String get importFailed => 'Importálás sikertelen';

  @override
  String get importing => 'Importálás...';

  @override
  String get invalidBarcodeData =>
      'Érvénytelen adat vagy nem támogatott formátum';

  @override
  String get invalidBarcodeDataPreview => 'Érvénytelen vonalkód adat';

  @override
  String get justNow => 'Most';

  @override
  String get languageDescription => 'Válaszd ki a preferált nyelvet';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get languageLabel => 'Nyelv';

  @override
  String get languageSystem => 'Rendszer alapértelmezett';

  @override
  String get lastSync => 'Utolsó szinkronizálás';

  @override
  String lastSyncLabel(Object date) {
    return 'Utolsó szinkronizálás: $date';
  }

  @override
  String get lastUpdated => 'Utoljára frissítve';

  @override
  String get layout => 'Elrendezés';

  @override
  String get layoutDescription => 'Válaszd ki hogyan jelenjenek meg a kártyák';

  @override
  String get layoutGrid => 'Rács';

  @override
  String get layoutGridDesc => 'Kártyák megjelenítése rács elrendezésben';

  @override
  String get layoutMinimal => 'Minimális';

  @override
  String get layoutMinimalDesc =>
      'Ultra-kompakt lista csak nevekkel és apró előnézetekkel';

  @override
  String get layoutRows => 'Sorok';

  @override
  String get layoutRowsDesc => 'Kártyák megjelenítése függőleges listában';

  @override
  String get loading => 'Betöltés...';

  @override
  String loadMore(Object count) {
    return 'További betöltése ($count van még)';
  }

  @override
  String get logoAddedSuccess => 'Logó sikeresen hozzáadva!';

  @override
  String get maxBrightness => 'Maximális fényerő';

  @override
  String get maxBrightnessDescription =>
      'Automatikusan maximális fényerőre állítás vonalkód megtekintésekor';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes perce';
  }

  @override
  String get newCards => 'új kártya';

  @override
  String get no => 'Nem';

  @override
  String get noBarcodeDataAvailable => 'Nincs elérhető vonalkód adat';

  @override
  String get noBarcodeDataMessage =>
      'Ez a kártya nem tartalmaz vonalkód vagy QR kód adatot.';

  @override
  String get noBarcodeFoundInImage => 'Nem található vonalkód a képen';

  @override
  String get noBarcodeOnly => 'Nincs vonalkód (csak borítókép)';

  @override
  String get noCardsSharedYet => 'Még nem került kártya a globális készletbe';

  @override
  String get noCardsToImport => 'Nem találhatók importálandó kártyák';

  @override
  String get noCardsToSync => 'Nincsenek szinkronizálandó kártyák';

  @override
  String get noCoverImage => 'Nincs borítókép';

  @override
  String get noGlobalCards => 'Még nincsenek elérhető globális kártyák';

  @override
  String get noGlobalImages => 'Még nincsenek elérhető globális képek';

  @override
  String get noImagesSharedYet => 'Még nem került kép a globális készletbe';

  @override
  String get noLogosFound =>
      'Nem található logó. Próbálj más keresési kifejezést.';

  @override
  String get noTagsYet =>
      'Még nincsenek címkék. A címkék itt jelennek meg, miután hozzáadtad őket a kártyáidhoz.';

  @override
  String get notConnected => 'Nincs csatlakozva';

  @override
  String get oneColumn => '1 oszlop';

  @override
  String get overwriteGlobalCard =>
      'Ez felülírja a meglévő globális kártyát a jelenlegi verziódra.';

  @override
  String get parallelSync => 'Párhuzamos Szinkronizálás';

  @override
  String get parallelSyncDescription =>
      'Kártyák egyidejű feltöltése (gyorsabb, de túlterhelheti egyes szervereket)';

  @override
  String get password => 'Jelszó';

  @override
  String get pinCard => 'Kártya kitűzése';

  @override
  String pinError(Object error) {
    return 'Hiba a kártya kitűzése közben: $error';
  }

  @override
  String get position => 'Pozíció';

  @override
  String get preview => 'Előnézet';

  @override
  String get processingLogo => 'Logó feldolgozása...';

  @override
  String get readyForSync => 'Szinkronizálásra kész';

  @override
  String get refresh => 'Frissítés';

  @override
  String get removeImage => 'Kép Eltávolítása';

  @override
  String get reset => 'Törlés';

  @override
  String get resetStatistics => 'Összes statisztika törlése';

  @override
  String get resetStatisticsConfirmation =>
      'Biztosan törölni szeretnéd az összes kártya használati statisztikáját? Ez a művelet nem visszavonható.';

  @override
  String get resetStatisticsDescription =>
      'Az összes kártya használati számának nullázása';

  @override
  String get retry => 'Újra';

  @override
  String get save => 'Mentés';

  @override
  String get saveCard => 'Kártya Mentése';

  @override
  String get scanBarcode => 'Vonalkód/QR kód beolvasása';

  @override
  String get scanFromImage => 'Képről beolvasás';

  @override
  String get search => 'Keresés';

  @override
  String get searchCards => 'Kártyák keresése...';

  @override
  String get searchForLogos => 'Logók keresése';

  @override
  String get searchingForLogos => 'Logók keresése...';

  @override
  String get searchLogo => 'Logó keresése';

  @override
  String showingLogosCount(Object displayed, Object total) {
    return '$displayed / $total logó megjelenítve';
  }

  @override
  String get selectBarcodeImage => 'Vonalkód kép kiválasztása';

  @override
  String get server => 'Szerver';

  @override
  String get serverAddress => 'Szerver címe';

  @override
  String get serverAddressHint =>
      'pl. https://dav.example.com vagy https://192.168.0.200:8080\nvagy domain porttal kombinálva';

  @override
  String get serverConfiguration => 'Szerver beállítások';

  @override
  String get settings => 'Beállítások';

  @override
  String get share => 'Megosztás';

  @override
  String get shareCardGlobally => 'Kártya Globális Megosztása';

  @override
  String get shareCardGloballyConfirm => 'Biztosan meg szeretnéd osztani';

  @override
  String get shareCardGloballyConfirm2 => 'globálisan?';

  @override
  String get shareCardGloballyError => 'Sikertelen globális kártya megosztás';

  @override
  String get shareGlobally => 'Globális megosztás';

  @override
  String get shareImageGlobally => 'Kép Globális Megosztása';

  @override
  String get shareImageGloballyError => 'Sikertelen globális kép megosztás';

  @override
  String get shopNameHint => 'Írd be az üzlet nevét (pl. tesco, lidl)';

  @override
  String get showBarcode => 'Vonalkód megjelenítése';

  @override
  String get showCoverImage => 'Borítókép megjelenítése';

  @override
  String get showGridNames => 'Kártyanevek megjelenítése';

  @override
  String get showGridNamesDescription =>
      'Kártyanevek megjelenítése a képek alatt rácsnézetben';

  @override
  String get sortDateAdded => 'Hozzáadás dátuma';

  @override
  String get sortName => 'Név (A-Z)';

  @override
  String get sortRecent => 'Legutóbb használt';

  @override
  String get sortUsage => 'Legtöbbet használt';

  @override
  String get statistics => 'Statisztika';

  @override
  String get statisticsResetSuccess => 'Minden statisztika sikeresen törölve';

  @override
  String get statisticsSection => 'Statisztikák';

  @override
  String get statisticsSectionDescription =>
      'Használati statisztikák kezelése az összes kártyához';

  @override
  String get status => 'Állapot';

  @override
  String get success => 'Sikeres';

  @override
  String get sync => 'Szinkronizálás';

  @override
  String get syncActions => 'Szinkronizálási műveletek';

  @override
  String get syncCompletedSuccess => 'Szinkronizálás sikeresen befejezve!';

  @override
  String get syncFailed => 'Szinkronizálás sikertelen';

  @override
  String get syncing => 'Szinkronizálás...';

  @override
  String get syncNotConfigured => 'A szinkronizálás nincs beállítva.';

  @override
  String get syncNotConfiguredHint =>
      'Menj a Beállítások → Szinkronizálás menüpontba a szerver szinkronizálás beállításához.';

  @override
  String get syncNow => 'Szinkronizálás most';

  @override
  String get syncStatusDialogTitle => 'Szinkronizálási státusz';

  @override
  String get syncStatusError => 'Hiba';

  @override
  String get syncStatusLastAttempt => 'Utolsó kísérlet';

  @override
  String get syncStatusLastSuccess => 'Utolsó sikeres';

  @override
  String get syncStatusNever => 'Soha';

  @override
  String syncSuccessExport(Object count) {
    return 'Sikeresen exportálva $count kártya';
  }

  @override
  String syncSuccessWithCleanup(Object cardCount, Object deletedCount) {
    return 'Sikeresen szinkronizálva $cardCount kártya és törölve $deletedCount törölt kártya';
  }

  @override
  String get tags => 'Címkék';

  @override
  String get tagsHint => 'Címkék hozzáadása...';

  @override
  String get tagsLabel => 'Címkék (opcionális)';

  @override
  String get takePhotoAndEdit => 'Fénykép készítése és szerkesztése';

  @override
  String get tapToAddCoverImage => 'Koppints borítókép hozzáadásához';

  @override
  String get tapToHideControls => 'Koppints bárhová a vezérlők elrejtéséhez';

  @override
  String get tapToShowControls =>
      'Koppints bárhová a vezérlők megjelenítéséhez';

  @override
  String get tapToUploadBarcodeImage =>
      'Koppints ide vonalkód kép feltöltéséhez';

  @override
  String get testConnection => 'Kapcsolat tesztelése';

  @override
  String get text => 'Szöveg';

  @override
  String get textColor => 'Szöveg színe';

  @override
  String get theme => 'Téma';

  @override
  String get themeAmoled => 'Teljesen fekete (AMOLED)';

  @override
  String get themeAmoledDesc => 'Teljesen fekete téma AMOLED kijelzőkhöz';

  @override
  String get themeDark => 'Sötét';

  @override
  String get themeDarkDesc => 'Sötét téma gyenge fényviszonyokhoz';

  @override
  String get themeDescription => 'Válaszd ki a preferált app témát';

  @override
  String get themeLight => 'Világos';

  @override
  String get themeLightDesc => 'Világos téma élénk színekkel';

  @override
  String get themeMaterialYou => 'Material You';

  @override
  String get themeMaterialYouDesc => 'Material You téma dinamikus színekkel';

  @override
  String get timesUsed => 'Használatok száma';

  @override
  String get tooltipRefresh => 'Frissítés';

  @override
  String get tryAgain => 'Próbáld Újra';

  @override
  String get tryDifferentSearch => 'Próbálj meg egy másik keresőkifejezést';

  @override
  String get type => 'Típus';

  @override
  String get unableToGenerateBarcode => 'Nem sikerült a vonalkód generálása';

  @override
  String get unknown => 'Ismeretlen';

  @override
  String get unknownError => 'Ismeretlen hiba történt';

  @override
  String get unpinCard => 'Kártya kitűzésének megszüntetése';

  @override
  String get update => 'Frissítés';

  @override
  String get updated => 'frissítve';

  @override
  String get updateGlobalCard => 'Globális Kártya Frissítése';

  @override
  String get updateGlobalCardConfirm =>
      'Biztosan frissíteni szeretnéd a globális verzióját';

  @override
  String get upload => 'Feltöltés';

  @override
  String get uploadImage => 'Kép Feltöltése';

  @override
  String get uploadToGlobalImages => 'Feltöltés a globális képekhez';

  @override
  String usageCount(Object count) {
    return '$count használat';
  }

  @override
  String get usageCountLabel => 'Használatok Száma';

  @override
  String get username => 'Felhasználónév';

  @override
  String get uses => 'használat';

  @override
  String get webdavConnection => 'Szerver kapcsolat';

  @override
  String get white => 'Fehér';

  @override
  String get yes => 'Igen';

  @override
  String get yesterday => 'Tegnap';
}

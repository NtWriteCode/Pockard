/// Supported barcode types for the application
/// This file contains all barcode type definitions used across card forms
class BarcodeTypes {
  static const List<Map<String, String>> supportedTypes = [
    {'value': 'IMAGE_ONLY', 'label': 'Image Only'},
    {'value': 'TEXT', 'label': 'Text Only'},
    {'value': 'QR', 'label': 'QR Code'},
    {'value': 'CODE128', 'label': 'Code 128'},
    {'value': 'CODE39', 'label': 'Code 39'},
    {'value': 'CODE93', 'label': 'Code 93'},
    {'value': 'EAN13', 'label': 'EAN-13'},
    {'value': 'EAN8', 'label': 'EAN-8'},
    {'value': 'UPC_A', 'label': 'UPC-A'},
    {'value': 'UPC_E', 'label': 'UPC-E'},
    {'value': 'CODABAR', 'label': 'Codabar'},
    {'value': 'ITF', 'label': 'ITF'},
    {'value': 'PDF417', 'label': 'PDF417'},
    {'value': 'DATAMATRIX', 'label': 'Data Matrix'},
    {'value': 'AZTEC', 'label': 'Aztec'},
  ];

  /// Map detected barcode types to our supported types
  static String mapBarcodeType(String detectedType) {
    switch (detectedType.toUpperCase()) {
      case 'QRCODE':
      case 'QR_CODE':
        return 'QR';
      case 'TEXT':
      case 'UNKNOWN':
        return 'QR'; // Default to QR for unknown types
      default:
        // Check if the detected type is already in our supported list
        if (supportedTypes.any((type) => type['value'] == detectedType.toUpperCase())) {
          return detectedType.toUpperCase();
        }
        return 'QR'; // Default fallback
    }
  }

  /// Get barcode type label from value
  static String getLabel(String value) {
    final type = supportedTypes.firstWhere((type) => type['value'] == value, orElse: () => {'value': value, 'label': value});
    return type['label']!;
  }
}

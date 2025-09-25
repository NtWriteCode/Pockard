import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB in bytes

  Future<String?> pickEditAndSaveImage({required BuildContext context, ImageSource source = ImageSource.gallery}) async {
    try {
      // Get localization strings before async operations
      final l10n = AppLocalizations.of(context)!;
      final editTitle = l10n.editCoverImage;
      final doneTitle = l10n.done;
      final cancelTitle = l10n.cancel;

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      // Open cropping interface
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: editTitle,
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: editTitle,
            doneButtonTitle: doneTitle,
            cancelButtonTitle: cancelTitle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile == null) return null;

      // Process the cropped image
      return await _processAndSaveImage(croppedFile.path);
    } catch (e) {
      debugPrint('Error picking and editing image: $e');
      return null;
    }
  }

  Future<String?> editExistingImage(String existingImagePath, BuildContext context) async {
    try {
      // Open cropping interface for existing image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: existingImagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: AppLocalizations.of(context)!.editCoverImage,
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: AppLocalizations.of(context)!.editCoverImage,
            doneButtonTitle: AppLocalizations.of(context)!.done,
            cancelButtonTitle: AppLocalizations.of(context)!.cancel,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile == null) return null;

      // Delete the old image file
      try {
        final File oldFile = File(existingImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        debugPrint('Error deleting old image: $e');
      }

      // Process the cropped image
      return await _processAndSaveImage(croppedFile.path);
    } catch (e) {
      debugPrint('Error editing existing image: $e');
      return null;
    }
  }

  Future<String?> _processAndSaveImage(String sourcePath) async {
    try {
      // Get app documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory(path.join(appDocDir.path, 'images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final String uuid = const Uuid().v4();
      final String extension = path.extension(sourcePath);
      final String fileName = '$uuid$extension';
      final String finalPath = path.join(imagesDir.path, fileName);

      // Check file size and compress if necessary
      final File originalFile = File(sourcePath);
      final int fileSize = await originalFile.length();

      File finalFile;
      if (fileSize > maxFileSize) {
        finalFile = await _compressImage(originalFile, finalPath);
      } else {
        finalFile = await originalFile.copy(finalPath);
      }

      return finalFile.path;
    } catch (e) {
      debugPrint('Error processing and saving image: $e');
      return null;
    }
  }

  Future<File> _compressImage(File originalFile, String outputPath) async {
    int quality = 85;
    File? compressedFile;

    do {
      final result = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        outputPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        compressedFile = File(result.path);
        final int compressedSize = await compressedFile.length();
        
        if (compressedSize <= maxFileSize) {
          break;
        }
      }

      quality -= 10;
    } while (quality > 10);

    if (compressedFile == null || quality <= 10) {
      // If compression failed or quality is too low, use original file
      return await originalFile.copy(outputPath);
    }

    return compressedFile;
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  bool _isImageFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  Future<void> cleanupUnusedImages(List<String> usedImagePaths) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory(path.join(appDocDir.path, 'images'));
      
      if (!await imagesDir.exists()) return;

      final List<FileSystemEntity> files = await imagesDir.list().toList();
      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          if (!usedImagePaths.contains(file.path)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up unused images: $e');
    }
  }

}
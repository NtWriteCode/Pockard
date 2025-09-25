import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'svg_analyzer_service.dart';

/// Service for processing logo images from SVG sources
/// Handles background detection, padding, and high-resolution conversion
class LogoProcessingService {
  static final LogoProcessingService _instance = LogoProcessingService._internal();
  factory LogoProcessingService() => _instance;
  LogoProcessingService._internal();

  /// Detect background color by sampling multiple edge pixels
  /// Returns null if no consistent background is detected
  Future<Color?> detectBackgroundColor(String imagePath) async {
    try {
      debugPrint('🔍 Detecting background color: $imagePath');
      
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('❌ Image file does not exist');
        return null;
      }
      
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      final int width = image.width;
      final int height = image.height;
      final int inset = 10; // Pixels to inset from edges
      
      // Sample 8 edge points
      final List<Offset> samplePoints = [
        Offset(inset.toDouble(), inset.toDouble()), // Top-left
        Offset((width - inset).toDouble(), inset.toDouble()), // Top-right
        Offset(inset.toDouble(), (height - inset).toDouble()), // Bottom-left
        Offset((width - inset).toDouble(), (height - inset).toDouble()), // Bottom-right
        Offset((width / 2).toDouble(), inset.toDouble()), // Top-center
        Offset((width / 2).toDouble(), (height - inset).toDouble()), // Bottom-center
        Offset(inset.toDouble(), (height / 2).toDouble()), // Left-center
        Offset((width - inset).toDouble(), (height / 2).toDouble()), // Right-center
      ];
      
      // Get pixel data
      final ByteData? pixelData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (pixelData == null) {
        image.dispose();
        debugPrint('❌ Failed to get pixel data');
        return null;
      }
      
      // Sample colors from all points
      final List<Color> sampledColors = [];
      for (final point in samplePoints) {
        final int x = point.dx.toInt().clamp(0, width - 1);
        final int y = point.dy.toInt().clamp(0, height - 1);
        final int pixelIndex = (y * width + x) * 4;
        
        final int r = pixelData.getUint8(pixelIndex);
        final int g = pixelData.getUint8(pixelIndex + 1);
        final int b = pixelData.getUint8(pixelIndex + 2);
        final int a = pixelData.getUint8(pixelIndex + 3);
        
        sampledColors.add(Color.fromARGB(a, r, g, b));
      }
      
      image.dispose();
      
      // Check if colors are consistent
      // Calculate average color
      int totalR = 0, totalG = 0, totalB = 0, totalA = 0;
      for (final color in sampledColors) {
        totalR += (color.r * 255.0).round() & 0xff;
        totalG += (color.g * 255.0).round() & 0xff;
        totalB += (color.b * 255.0).round() & 0xff;
        totalA += (color.a * 255.0).round() & 0xff;
      }
      
      final Color avgColor = Color.fromARGB(
        (totalA / sampledColors.length).round(),
        (totalR / sampledColors.length).round(),
        (totalG / sampledColors.length).round(),
        (totalB / sampledColors.length).round(),
      );
      
      // Check how many colors match the average (within 10% tolerance)
      int matchingColors = 0;
      const double tolerance = 0.1; // 10% tolerance
      
      for (final color in sampledColors) {
        final int colorR = (color.r * 255.0).round() & 0xff;
        final int colorG = (color.g * 255.0).round() & 0xff;
        final int colorB = (color.b * 255.0).round() & 0xff;
        final int colorA = (color.a * 255.0).round() & 0xff;
        final int avgR = (avgColor.r * 255.0).round() & 0xff;
        final int avgG = (avgColor.g * 255.0).round() & 0xff;
        final int avgB = (avgColor.b * 255.0).round() & 0xff;
        final int avgA = (avgColor.a * 255.0).round() & 0xff;
        
        final double rDiff = (colorR - avgR).abs() / 255.0;
        final double gDiff = (colorG - avgG).abs() / 255.0;
        final double bDiff = (colorB - avgB).abs() / 255.0;
        final double aDiff = (colorA - avgA).abs() / 255.0;
        
        if (rDiff < tolerance && gDiff < tolerance && bDiff < tolerance && aDiff < tolerance) {
          matchingColors++;
        }
      }
      
      debugPrint('📊 Background detection: $matchingColors/${sampledColors.length} matching pixels');
      debugPrint('🎨 Average color: $avgColor');
      
      // If 7 or more out of 8 samples match, we have a solid background
      if (matchingColors >= 7) {
        // Check if the background is transparent (alpha < 250 to account for near-transparency)
        final int avgAlpha = (avgColor.a * 255.0).round() & 0xff;
        if (avgAlpha < 250) {
          debugPrint('⚠️ Detected transparent background, using fallback');
          return null;
        }
        debugPrint('✅ Solid background detected: $avgColor');
        return avgColor;
      } else {
        debugPrint('⚠️ No consistent background detected');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error detecting background color: $e');
      return null;
    }
  }

  /// Convert SVG to high-res PNG with smart padding
  /// Returns path to padded high-res PNG ready for user cropping
  Future<String?> convertSvgToHighResPaddedPng(String svgPath) async {
    try {
      debugPrint('🔄 Converting SVG to high-res padded PNG: $svgPath');
      
      // Step 1: Convert SVG to high-res PNG (2000px max dimension)
      final pngBytes = await SvgAnalyzerService.svgStringToPngBytes(svgPath, maxDimension: 2000.0);
      if (pngBytes == null) {
        debugPrint('❌ Failed to convert SVG to PNG');
        return null;
      }

      // Step 2: Save to temporary file
      final Directory tempDir = await Directory.systemTemp.createTemp('logo_conversion');
      final String tempFileName = '${const Uuid().v4()}_original.png';
      final String tempFilePath = path.join(tempDir.path, tempFileName);
      
      final File tempPngFile = File(tempFilePath);
      await tempPngFile.writeAsBytes(pngBytes);
      
      debugPrint('✅ SVG converted to PNG: $tempFilePath');
      
      // Step 3: Detect background color
      final Color? backgroundColor = await detectBackgroundColor(tempFilePath);
      
      // Step 4: Get image dimensions
      final Uint8List imageBytes = await tempPngFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;
      
      final int originalWidth = originalImage.width;
      final int originalHeight = originalImage.height;
      
      debugPrint('📐 Original dimensions: ${originalWidth}x$originalHeight');
      
      // Step 5: Calculate padded dimensions
      // Always add 10% padding, and make square if rectangular
      final int longerDimension = originalWidth > originalHeight ? originalWidth : originalHeight;
      final int paddedDimension = (longerDimension * 1.1).round(); // 10% padding
      
      debugPrint('📦 Padded dimensions: ${paddedDimension}x$paddedDimension');
      
      // Step 6: Create padded canvas
      final String paddedPath = await _createPaddedCanvas(
        originalImage: originalImage,
        targetSize: paddedDimension,
        backgroundColor: backgroundColor ?? Colors.white,
        tempDir: tempDir,
      );
      
      originalImage.dispose();
      
      // Clean up original temp file
      if (await tempPngFile.exists()) {
        await tempPngFile.delete();
      }
      
      debugPrint('✅ High-res padded PNG created: $paddedPath');
      return paddedPath;
    } catch (e) {
      debugPrint('❌ Error converting SVG to high-res padded PNG: $e');
      return null;
    }
  }

  /// Create a padded canvas with the original image centered
  Future<String> _createPaddedCanvas({
    required ui.Image originalImage,
    required int targetSize,
    required Color backgroundColor,
    required Directory tempDir,
  }) async {
    debugPrint('🎨 Creating padded canvas: ${targetSize}x$targetSize, bg: $backgroundColor');
    
    // Create a picture recorder to draw on
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, targetSize.toDouble(), targetSize.toDouble()),
    );
    
    // Fill background
    final Paint bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, targetSize.toDouble(), targetSize.toDouble()),
      bgPaint,
    );
    
    // Calculate position to center the original image
    final double offsetX = (targetSize - originalImage.width) / 2;
    final double offsetY = (targetSize - originalImage.height) / 2;
    
    debugPrint('📍 Centering image at offset: ($offsetX, $offsetY)');
    
    // Draw the original image centered
    canvas.drawImage(
      originalImage,
      Offset(offsetX, offsetY),
      Paint(),
    );
    
    // Convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image paddedImage = await picture.toImage(targetSize, targetSize);
    
    // Convert to PNG bytes
    final ByteData? byteData = await paddedImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    
    paddedImage.dispose();
    picture.dispose();
    
    // Save to temp file
    final String paddedFileName = '${const Uuid().v4()}_padded.png';
    final String paddedPath = path.join(tempDir.path, paddedFileName);
    final File paddedFile = File(paddedPath);
    await paddedFile.writeAsBytes(pngBytes);
    
    debugPrint('✅ Padded canvas created: $paddedPath');
    return paddedPath;
  }

  /// Downscale an image to target size (usually 500x500 for final logo)
  Future<String?> downscaleImage(String sourcePath, int targetSize) async {
    try {
      debugPrint('📏 Downscaling image to ${targetSize}x$targetSize');
      
      final File sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file does not exist: $sourcePath');
        return null;
      }
      
      final String outputPath = await _getImageOutputPath();
      
      // Downscale using flutter_image_compress
      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        outputPath,
        quality: 95, // High quality for final logo
        minWidth: targetSize,
        minHeight: targetSize,
        format: CompressFormat.png,
      );
      
      if (result != null) {
        debugPrint('✅ Image downscaled to: ${result.path}');
        return result.path;
      } else {
        debugPrint('❌ Failed to downscale image');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error downscaling image: $e');
      return null;
    }
  }

  /// Get a unique output path in the images directory
  Future<String> _getImageOutputPath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory(path.join(appDocDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final String fileName = '${const Uuid().v4()}_logo.png';
    return path.join(imagesDir.path, fileName);
  }
}



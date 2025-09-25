import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAnalysisResult {
  final Color? backgroundColor;
  final bool hasTransparentBackground;

  SvgAnalysisResult({
    this.backgroundColor,
    this.hasTransparentBackground = false,
  });
}

class SvgAnalyzerService {
  /// Analyze an SVG file to determine its background color
  /// Converts SVG to PNG first, then samples pixel at (10, 10)
  static Future<SvgAnalysisResult> analyzeSvg(String svgPath) async {
    try {
      debugPrint('🔍 Analyzing SVG: $svgPath');
      final file = File(svgPath);
      if (!await file.exists()) {
        debugPrint('❌ SVG file does not exist: $svgPath');
        return SvgAnalysisResult(hasTransparentBackground: true);
      }

      // Convert SVG to PNG first
      final pngBytes = await svgStringToPngBytes(svgPath);
      if (pngBytes == null) {
        debugPrint('❌ Failed to convert SVG to PNG');
        return SvgAnalysisResult(hasTransparentBackground: true);
      }

      // Sample pixel at (10, 10) from the PNG
      final backgroundColor = await _samplePixelFromPng(pngBytes);
      
      final result = SvgAnalysisResult(
        backgroundColor: backgroundColor,
        hasTransparentBackground: backgroundColor == null,
      );
      
      debugPrint('🎨 Analysis result: backgroundColor=${result.backgroundColor}, hasTransparent=${result.hasTransparentBackground}');
      return result;
    } catch (e) {
      debugPrint('❌ Error analyzing SVG: $e');
      return SvgAnalysisResult(hasTransparentBackground: true);
    }
  }

  /// Convert SVG to PNG bytes using flutter_svg 2.x API
  /// Preserves original aspect ratio and dimensions
  static Future<Uint8List?> svgStringToPngBytes(String svgPath, {double? maxDimension}) async {
    try {
      debugPrint('🔄 Converting SVG to PNG');
      
      final file = File(svgPath);
      final svgStringContent = await file.readAsString();
      
      final SvgStringLoader svgStringLoader = SvgStringLoader(svgStringContent);
      final PictureInfo pictureInfo = await vg.loadPicture(svgStringLoader, null);
      final ui.Picture picture = pictureInfo.picture;
      
      // Get original dimensions
      final double originalWidth = pictureInfo.size.width;
      final double originalHeight = pictureInfo.size.height;
      
      // Calculate target dimensions preserving aspect ratio
      double targetWidth = originalWidth;
      double targetHeight = originalHeight;
      
      if (maxDimension != null) {
        final double aspectRatio = originalWidth / originalHeight;
        if (originalWidth > originalHeight) {
          targetWidth = maxDimension;
          targetHeight = maxDimension / aspectRatio;
        } else {
          targetHeight = maxDimension;
          targetWidth = maxDimension * aspectRatio;
        }
      }
      
      debugPrint('📐 Original: $originalWidth x $originalHeight, Target: $targetWidth x $targetHeight');
      
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(targetWidth, targetHeight)));
      
      // Use uniform scaling to preserve aspect ratio
      final double scale = targetWidth / originalWidth;
      canvas.scale(scale, scale);
      canvas.drawPicture(picture);
      
      final ui.Image imgByteData = await recorder.endRecording().toImage(targetWidth.ceil(), targetHeight.ceil());
      final ByteData? bytesData = await imgByteData.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageData = bytesData?.buffer.asUint8List() ?? Uint8List(0);
      pictureInfo.picture.dispose();
      
      debugPrint('✅ SVG converted to PNG: ${imageData.length} bytes');
      return imageData;
    } catch (e) {
      debugPrint('❌ Error converting SVG to PNG: $e');
      return null;
    }
  }

  /// Sample pixel at (10, 10) from PNG bytes
  static Future<Color?> _samplePixelFromPng(Uint8List pngBytes) async {
    try {
      debugPrint('📸 Sampling pixel at (10, 10) from PNG');
      
      // Decode PNG to image
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Sample pixel at (10, 10)
      final pixelData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (pixelData != null) {
        final pixelIndex = (10 * image.width + 10) * 4; // (y * width + x) * 4 bytes per pixel
        final r = pixelData.getUint8(pixelIndex);
        final g = pixelData.getUint8(pixelIndex + 1);
        final b = pixelData.getUint8(pixelIndex + 2);
        final a = pixelData.getUint8(pixelIndex + 3);
        
        final color = Color.fromARGB(a, r, g, b);
        debugPrint('🎨 Sampled pixel color: $color');
        
        // Clean up
        image.dispose();
        
        return color;
      }
      
      debugPrint('❌ Failed to sample pixel from PNG');
      return null;
    } catch (e) {
      debugPrint('❌ Error sampling pixel from PNG: $e');
      return null;
    }
  }
}
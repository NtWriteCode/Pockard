import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/svg_analyzer_service.dart';
import '../constants/app_colors.dart';

/// A reusable widget for displaying cover images (PNG/JPG/SVG)
/// Handles SVG background color detection and proper rendering
class CoverImageWidget extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? borderRadius;
  final Widget Function(BuildContext)? placeholderBuilder;
  final Widget Function(BuildContext)? errorBuilder;

  const CoverImageWidget({super.key, required this.imagePath, this.fit = BoxFit.contain, this.borderRadius, this.placeholderBuilder, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return _buildSvgImage(context);
    } else {
      return _buildRasterImage(context);
    }
  }

  Widget _buildSvgImage(BuildContext context) {
    return FutureBuilder<SvgAnalysisResult>(
      future: SvgAnalyzerService.analyzeSvg(imagePath),
      builder: (context, snapshot) {
        // Determine background color
        Color backgroundColor = AppColors.white; // Default
        if (snapshot.hasData && snapshot.data!.backgroundColor != null) {
          backgroundColor = snapshot.data!.backgroundColor!;
        } else if (snapshot.hasData && snapshot.data!.hasTransparentBackground) {
          backgroundColor = AppColors.white; // Use white for transparent SVGs
        }

        return Container(
          decoration: BoxDecoration(color: backgroundColor, borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.file(
              File(imagePath),
              fit: fit,
              alignment: Alignment.center,
              placeholderBuilder: placeholderBuilder != null ? (context) => placeholderBuilder!(context) : null,
              errorBuilder: errorBuilder != null ? (context, error, stackTrace) => errorBuilder!(context) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRasterImage(BuildContext context) {
    return Image.file(File(imagePath), fit: fit, alignment: Alignment.center, errorBuilder: errorBuilder != null ? (context, error, stackTrace) => errorBuilder!(context) : null);
  }
}

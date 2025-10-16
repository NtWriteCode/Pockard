import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LogoResult {
  final String name;
  final String imageUrl;
  final String altText;

  LogoResult({required this.name, required this.imageUrl, required this.altText});

  @override
  String toString() {
    return 'LogoResult{name: $name, imageUrl: $imageUrl, altText: $altText}';
  }
}

class LogoSearchService {
  static const String _baseUrl = 'https://worldvectorlogo.com/search/';
  static const String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36';

  /// Search for logos on World Vector Logo
  /// Returns a list of LogoResult objects with all available results
  static Future<List<LogoResult>> searchLogos(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final url = '$_baseUrl${Uri.encodeComponent(query.trim())}';
      debugPrint('Searching logos for: $query');
      debugPrint('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      if (response.statusCode == 200) {
        return _parseLogosFromHtml(response.body);
      } else {
        debugPrint('Failed to fetch logos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching logos: $e');
      return [];
    }
  }

  /// Parse logos from HTML response
  static List<LogoResult> _parseLogosFromHtml(String html) {
    final List<LogoResult> logos = [];

    // Regex to find logo images
    final RegExp logoRegex = RegExp(r'<img class="logo__img" src="([^"]+)" alt="([^"]+)"[^>]*>', multiLine: true);

    final RegExp nameRegex = RegExp(r'<span class="logo__name">([^<]+)</span>', multiLine: true);

    // Find all logo images
    final logoMatches = logoRegex.allMatches(html);
    final nameMatches = nameRegex.allMatches(html);

    // Create a list of names
    final List<String> names = nameMatches.map((match) => match.group(1) ?? '').toList();

    int index = 0;
    for (final match in logoMatches) {
      final imageUrl = match.group(1);
      final altText = match.group(2);

      if (imageUrl != null && altText != null) {
        // Extract name from alt text (remove "logo vector" suffix)
        String name = altText.replaceAll(RegExp(r'logo vector$'), '').trim();

        // If we have a name from the span, use that instead
        if (index < names.length && names[index].isNotEmpty) {
          name = names[index];
        }

        logos.add(LogoResult(name: name, imageUrl: imageUrl, altText: altText));
        index++;
      }
    }

    debugPrint('Found ${logos.length} total logos');
    return logos;
  }

  /// Download a logo image to local storage
  static Future<String?> downloadLogo(String imageUrl, String fileName) async {
    try {
      debugPrint('Downloading logo: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl), headers: {'User-Agent': _userAgent});

      if (response.statusCode == 200) {
        // Get the app's documents directory
        final Directory appDir = await Directory.systemTemp.createTemp('logo_downloads');
        final String filePath = '${appDir.path}/$fileName';

        // Write the image data to file
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        debugPrint('Logo downloaded to: $filePath');
        return filePath;
      } else {
        debugPrint('Failed to download logo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading logo: $e');
      return null;
    }
  }
}

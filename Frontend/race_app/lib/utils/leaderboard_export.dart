import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/models/time_log.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/utils/format_utils.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;

/// A utility class for exporting leaderboard data in various formats
class LeaderboardExport {
  /// Exports the leaderboard data for the specified segment to a CSV file
  static Future<void> exportLeaderboardToCsv(
    BuildContext context, {
    required Segment segment,
  }) async {
    try {
      final leaderboardData = await _getLeaderboardData(context, segment);
      if (leaderboardData == null) return;
      
      // Convert to CSV and trigger download
      final csvData = _convertToCsvFormat(leaderboardData, segment);
      final csv = const ListToCsvConverter().convert(csvData);
      
      _downloadFile(
        bytes: utf8.encode(csv),
        fileName: 'leaderboard_${segment.toString().split('.').last}.csv',
        mimeType: 'text/csv',
        context: context,
        successMessage: 'Leaderboard exported successfully',
      );
    } catch (e) {
      _showSnackBar(context, 'Failed to export leaderboard: $e');
    }
  }

  /// Takes a screenshot of the leaderboard widget and saves it as a PNG file
  static Future<void> takeLeaderboardScreenshot(
    BuildContext context, {
    required Segment segment,
    required GlobalKey leaderboardKey,
  }) async {
    try {
      final boundary = leaderboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar(context, 'Failed to capture screenshot: Widget not found');
        return;
      }

      // Capture the image with high quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose(); // Dispose of image to free memory
      
      if (byteData == null) {
        _showSnackBar(context, 'Failed to capture screenshot: No image data');
        return;
      }

      _downloadFile(
        bytes: byteData.buffer.asUint8List(),
        fileName: 'leaderboard_screenshot_${segment.toString().split('.').last}.png',
        mimeType: 'image/png',
        context: context,
        successMessage: 'Screenshot saved successfully',
      );
    } catch (e) {
      _showSnackBar(context, 'Failed to capture screenshot: $e');
    }
  }
  
  /// Exports the full leaderboard with all participants for the specified segment
  static Future<void> exportFullLeaderboardToCsv(
    BuildContext context, {
    required Segment segment,
    int? maxEntries,
  }) async {
    try {
      final leaderboardData = await _getLeaderboardData(context, segment);
      if (leaderboardData == null) return;
      
      // Convert to CSV with all entries
      final csvData = _convertToCsvFormat(
        leaderboardData, 
        segment,
        maxEntries: maxEntries,
      );
      final csv = const ListToCsvConverter().convert(csvData);
      
      _downloadFile(
        bytes: utf8.encode(csv),
        fileName: 'full_leaderboard_${segment.toString().split('.').last}.csv',
        mimeType: 'text/csv',
        context: context,
        successMessage: 'Full leaderboard exported successfully',
      );
    } catch (e) {
      _showSnackBar(context, 'Failed to export leaderboard: $e');
    }
  }

  /// Gets the leaderboard data for the specified segment
  static Future<List<ParticipantLeaderData>?> _getLeaderboardData(
    BuildContext context,
    Segment segment,
  ) async {
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final participantsProvider = Provider.of<ParticipantsProvider>(context, listen: false);
    final timeLogsProvider = Provider.of<TimeLogsProvider>(context, listen: false);

    if (raceProvider.race.startTime == null) {
      _showSnackBar(context, 'Cannot export: Race has not started');
      return null;
    }

    final timeLogs = timeLogsProvider.timeLogsBySegment(segment);
    if (timeLogs.isEmpty) {
      _showSnackBar(context, 'No data available for ${segment.toString().split('.').last} segment');
      return null;
    }

    // Process leaderboard data
    final participantsWithTimes = <int, ParticipantLeaderData>{};
    for (var log in timeLogs) {
      if (log.deleted) continue;

      final participant = participantsProvider.getParticipantByBib(log.bib);
      if (participant == null) continue;

      final duration = log.timestamp.difference(raceProvider.race.startTime!);
      participantsWithTimes[log.bib] = ParticipantLeaderData(
        participant: participant,
        duration: duration,
      );
    }

    // Sort by duration and return
    final leaders = participantsWithTimes.values.toList()
      ..sort((a, b) => a.duration.compareTo(b.duration));
      
    return leaders;
  }

  /// Converts the leaderboard data to CSV format
  static List<List<dynamic>> _convertToCsvFormat(
    List<ParticipantLeaderData> leaders,
    Segment segment, {
    int? maxEntries,
  }) {
    final List<List<dynamic>> csvData = [
      ['Position', 'Bib', 'Name', 'Time', 'Segment'],
    ];
    
    final entries = maxEntries != null && maxEntries < leaders.length 
        ? leaders.sublist(0, maxEntries) 
        : leaders;

    for (int i = 0; i < entries.length; i++) {
      final leader = entries[i];
      csvData.add([
        i + 1,
        leader.participant.bib,
        leader.participant.name,
        FormatUtils.formatDuration(leader.duration),
        segment.toString().split('.').last,
      ]);
    }
    
    return csvData;
  }

  /// Downloads a file with the specified bytes
  static void _downloadFile({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required BuildContext context,
    required String successMessage,
  }) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
      
    html.document.body?.append(anchor);
    anchor.click();
    
    // Clean up
    Future.delayed(const Duration(milliseconds: 100), () {
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    });
    
    _showSnackBar(context, successMessage);
  }

  /// Shows a snackbar with the specified message
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
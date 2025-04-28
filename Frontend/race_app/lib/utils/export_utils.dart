import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/models/time_log.dart';
import 'package:share_plus/share_plus.dart';

class ExportUtils {
  static Future<void> exportParticipantsToCsv(
    List<Participant> participants,
    List<TimeLog> timeLogs,
  ) async {
    // Group time logs by participant BIB
    final timesByBib = <int, Map<String, DateTime>>{};
    for (final log in timeLogs) {
      if (!timesByBib.containsKey(log.bib)) {
        timesByBib[log.bib] = {};
      }
      
      switch (log.segment) {
        case Segment.swim:
          timesByBib[log.bib]!['swim'] = log.timestamp;
          break;
        case Segment.cycle:
          timesByBib[log.bib]!['cycle'] = log.timestamp;
          break;
        case Segment.run:
          timesByBib[log.bib]!['run'] = log.timestamp;
          break;
      }
    }
    
    // Create CSV header
    final headers = [
      'BIB',
      'Name',
      'Age',
      'Gender',
      'Category',
      'Swim Time',
      'Cycle Time',
      'Run Time',
    ];
    
    // Create CSV rows
    final rows = participants.map((participant) {
      final times = timesByBib[participant.bib] ?? {};
      
      return [
        participant.bib.toString(),
        participant.name,
        participant.age?.toString() ?? '',
        participant.gender ?? '',
        times['swim'] != null ? _formatDateTime(times['swim']!) : '',
        times['cycle'] != null ? _formatDateTime(times['cycle']!) : '',
        times['run'] != null ? _formatDateTime(times['run']!) : '',
      ];
    }).toList();
    
    // Combine header and rows
    final csvContent = [
      headers.join(','),
      ...rows.map((row) => row.join(',')),
    ].join('\n');
    
    // Save to file and share
    await _saveAndShareCsv(csvContent, 'race-dashboard.csv');
  }
  
  static Future<void> _saveAndShareCsv(String csvContent, String fileName) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          throw Exception('Storage permission denied');
        }
      }
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      
      // Write to file
      final file = File(filePath);
      await file.writeAsString(csvContent);
      
      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Race Dashboard Export',
      );
    } catch (e) {
      rethrow;
    }
  }
  
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}


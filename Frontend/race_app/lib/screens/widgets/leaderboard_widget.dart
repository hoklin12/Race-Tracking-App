import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/models/time_log.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/screens/widgets/category_tab_button_widget.dart';
import 'package:race_app/utils/format_utils.dart';
import 'package:race_app/utils/leaderboard_export.dart'; 

class LeaderboardWidget extends StatefulWidget {
  final Race race;

  const LeaderboardWidget({
    super.key,
    required this.race,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<String> _categories = ['Swim', 'Cycle', 'Run'];
  int _selectedCategoryIndex = 0;

  // Create a global key for the leaderboard to use for screenshots
  final GlobalKey _leaderboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.index != _selectedCategoryIndex) {
        setState(() {
          _selectedCategoryIndex = _tabController!.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Add export buttons
                _buildExportMenu(context),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryTabs(),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _leaderboardKey,
              child: Consumer<TimeLogsProvider>(
                builder: (context, timeLogsProvider, _) {
                  return _buildLeaderboardContent(context, timeLogsProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to create the export menu
  Widget _buildExportMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        final segment = Segment.values[_selectedCategoryIndex];

        switch (value) {
          case 'export_csv':
            await LeaderboardExport.exportLeaderboardToCsv(
              context,
              segment: segment,
            );
            break;
          case 'export_full_csv':
            await LeaderboardExport.exportFullLeaderboardToCsv(
              context,
              segment: segment,
            );
            break;
          case 'screenshot':
            await LeaderboardExport.takeLeaderboardScreenshot(
              context,
              segment: segment,
              leaderboardKey: _leaderboardKey,
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'export_full_csv',
          child: Row(
            children: [
              Icon(Icons.list),
              SizedBox(width: 8),
              Text('Export Full Leaderboard'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'screenshot',
          child: Row(
            children: [
              Icon(Icons.screenshot),
              SizedBox(width: 8),
              Text('Take Screenshot'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _categories.length,
          (index) => CategoryTabButton(
            label: _categories[index],
            icon: _getCategoryIcon(index),
            isSelected: _selectedCategoryIndex == index,
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
                _tabController?.animateTo(index);
              });
            },
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.pool;
      case 1:
        return Icons.directions_bike;
      case 2:
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }

  Widget _buildLeaderboardContent(
      BuildContext context, TimeLogsProvider timeLogsProvider) {
    // Rest of the method remains unchanged
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final participantsProvider =
        Provider.of<ParticipantsProvider>(context, listen: false);

    if (raceProvider.race.startTime == null) {
      return _buildEmptyPodium();
    }

    if (timeLogsProvider.isLoading && timeLogsProvider.timeLogs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (timeLogsProvider.error != null) {
      return Center(
        child: Text(
          timeLogsProvider.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final segment = Segment.values[_selectedCategoryIndex];
    final timeLogs = timeLogsProvider.timeLogsBySegment(segment);

    if (timeLogs.isEmpty) {
      return _buildEmptyPodium();
    }

    // Compute leaderboard data directly without caching
    final participantsWithTimes = <int, ParticipantLeaderData>{};

    // Process all time logs for this segment
    for (var log in timeLogs) {
      if (log.deleted) continue; // Skip deleted logs

      final participant = participantsProvider.getParticipantByBib(log.bib);
      if (participant == null) continue; // Skip logs without a participant

      // Calculate duration from race start
      final duration = log.timestamp.difference(raceProvider.race.startTime!);

      participantsWithTimes[log.bib] = ParticipantLeaderData(
        participant: participant,
        duration: duration,
      );
    }

    // Sort by duration (fastest first)
    final leaders = participantsWithTimes.values.toList()
      ..sort((a, b) => a.duration.compareTo(b.duration));

    final displayCount = leaders.length > 3 ? 3 : leaders.length;

    if (displayCount == 0) {
      return _buildEmptyPodium();
    }

    // Create podium display with correct order: 2nd (left), 1st (center), 3rd (right)
    final podiumData = List<ParticipantLeaderData?>.filled(3, null);
    if (displayCount >= 1) {
      podiumData[1] = leaders[0]; // 1st place in center
    }
    if (displayCount >= 2) {
      podiumData[0] = leaders[1]; // 2nd place on left
    }
    if (displayCount >= 3) {
      podiumData[2] = leaders[2]; // 3rd place on right
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SizedBox(
            width: 100,
            child: podiumData[0] != null
                ? _buildPositionItem(
                    2,
                    podiumData[0]!.participant.name,
                    FormatUtils.formatDuration(podiumData[0]!.duration),
                    Colors.blue,
                  )
                : _buildEmptyPositionItem(Colors.blue),
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: 100,
          child: podiumData[1] != null
              ? _buildPositionItem(
                  1,
                  podiumData[1]!.participant.name,
                  FormatUtils.formatDuration(podiumData[1]!.duration),
                  Colors.amber,
                )
              : _buildEmptyPositionItem(Colors.amber),
        ),
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            width: 100,
            child: podiumData[2] != null
                ? _buildPositionItem(
                    3,
                    podiumData[2]!.participant.name,
                    FormatUtils.formatDuration(podiumData[2]!.duration),
                    Colors.orange,
                  )
                : _buildEmptyPositionItem(Colors.orange),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildEmptyPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SizedBox(
            width: 100,
            child: _buildEmptyPositionItem(Colors.blue),
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: 100,
          child: _buildEmptyPositionItem(Colors.amber),
        ),
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            width: 100,
            child: _buildEmptyPositionItem(Colors.orange),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildPositionItem(
      int position, String name, String time, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, color: color, size: 24),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            overflow: TextOverflow.ellipsis,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyPositionItem(Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, color: color, size: 24),
            const SizedBox(width: 2),
            const Text(
              "----",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "--:--:--",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            overflow: TextOverflow.ellipsis,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/models/time_log.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/screens/widgets/category_tab_button_widget.dart';
import 'package:race_app/utils/format_utils.dart';

class LeaderboardWidget extends StatefulWidget {
  final Race race;

  const LeaderboardWidget({
    super.key,
    required this.race,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<String> _categories = ['Swim', 'Cycle', 'Run'];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _selectedCategoryIndex = _tabController!.index;
      });
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
            const Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                ),
                SizedBox(width: 8),
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryTabs(),
            const SizedBox(height: 16),
            _buildLeaderboardContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the buttons as a group
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

  Widget _buildLeaderboardContent() {
    final raceProvider = Provider.of<RaceProvider>(context);
    final timeLogsProvider = Provider.of<TimeLogsProvider>(context);

    if (raceProvider.race.startTime == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // Shift 2nd place left
            child: SizedBox(
              width: 100,
              child: _buildEmptyPositionItem(const Color.fromARGB(255, 199, 199, 199)), // 2nd
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: 100,
            child: _buildEmptyPositionItem(Colors.amber), // 1st
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Shift 3rd place right
            child: SizedBox(
              width: 100,
              child: _buildEmptyPositionItem(Colors.brown), // 3rd
            ),
          ),
          const Spacer(flex: 1),
        ],
      );
    }

    final segment = Segment.values[_selectedCategoryIndex];
    final timeLogs = timeLogsProvider.getTimeLogsForSegment(segment);

    final participantsWithTimes = timeLogs.map((log) {
      final duration = log.timestamp.difference(raceProvider.race.startTime!);
      return {
        'bib': log.bib.toString(),
        'duration': duration,
      };
    }).toList();

    participantsWithTimes.sort((a, b) => (a['duration'] as Duration).compareTo(b['duration'] as Duration));

    final displayCount = participantsWithTimes.length > 3 ? 3 : participantsWithTimes.length;

    if (displayCount == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // Shift 2nd place left
            child: SizedBox(
              width: 100,
              child: _buildEmptyPositionItem(Colors.grey), // 2nd
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: 100,
            child: _buildEmptyPositionItem(Colors.amber), // 1st
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Shift 3rd place right
            child: SizedBox(
              width: 100,
              child: _buildEmptyPositionItem(Colors.brown), // 3rd
            ),
          ),
          const Spacer(flex: 1),
        ],
      );
    }

    // Reorder: 2nd (left), 1st (center), 3rd (right)
    final reorderedParticipants = List<Map<String, dynamic>>.filled(3, {});
    if (displayCount >= 1) {
      reorderedParticipants[1] = participantsWithTimes[0]; // 1st place in center
    }
    if (displayCount >= 2) {
      reorderedParticipants[0] = participantsWithTimes[1]; // 2nd place on left
    }
    if (displayCount >= 3) {
      reorderedParticipants[2] = participantsWithTimes[2]; // 3rd place on right
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Padding(
          padding: const EdgeInsets.only(left: 16.0), // Shift 2nd place left
          child: SizedBox(
            width: 100,
            child: reorderedParticipants[0].isNotEmpty
                ? _buildPositionItem(
                    2,
                    reorderedParticipants[0]['bib'] as String,
                    FormatUtils.formatDuration(reorderedParticipants[0]['duration'] as Duration),
                    Colors.blue,
                  )
                : _buildEmptyPositionItem(Colors.blue),
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: 100,
          child: reorderedParticipants[1].isNotEmpty
              ? _buildPositionItem(
                  1,
                  reorderedParticipants[1]['bib'] as String,
                  FormatUtils.formatDuration(reorderedParticipants[1]['duration'] as Duration),
                  Colors.amber,
                )
              : _buildEmptyPositionItem(Colors.amber),
        ),
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.only(right: 16.0), // Shift 3rd place right
          child: SizedBox(
            width: 100,
            child: reorderedParticipants[2].isNotEmpty
                ? _buildPositionItem(
                    3,
                    reorderedParticipants[2]['bib'] as String,
                    FormatUtils.formatDuration(reorderedParticipants[2]['duration'] as Duration),
                    Colors.orange,
                  )
                : _buildEmptyPositionItem(Colors.orange),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildPositionItem(int position, String bib, String time, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, color: color, size: 24),
            Text(
              bib,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
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
            const Text(
              "----",
              style: TextStyle(
                fontSize: 20,
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
import 'package:flutter/material.dart';
import 'package:race_app/models/race.dart';
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
      elevation: 0, // Match the flat appearance of RaceReportWidget's Container
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Match RaceReportWidget's border radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.emoji_events, // award/trophy icon
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
        children: List.generate(
          _categories.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                  _tabController?.animateTo(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(index),
                        color: _selectedCategoryIndex == index
                            ? Colors.black
                            : Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _categories[index],
                        style: TextStyle(
                          color: _selectedCategoryIndex == index
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    if (widget.race.startTime == null) {
      // Race hasn't started
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEmptyPositionItem(const Color.fromARGB(255, 199, 199, 199)),
          _buildEmptyPositionItem(Colors.amber),
          _buildEmptyPositionItem(Colors.orange),
        ],
      );
    }

    // Get the segment key based on the selected category
    final segmentKey = _categories[_selectedCategoryIndex].toLowerCase();

    // Filter participants with segment times and calculate durations
    final participantsWithSegment = widget.race.participants
        .where((p) => p.segmentTimes != null && p.segmentTimes!.containsKey(segmentKey))
        .map((p) {
          final segmentTime = p.segmentTimes![segmentKey]!;
          final duration = segmentTime.difference(widget.race.startTime!);
          return {
            'id': p.id,
            'bib': p.bib.toString(),
            'duration': duration,
          };
        })
        .toList();

    // Sort by duration (fastest first)
    participantsWithSegment.sort((a, b) => (a['duration'] as Duration).compareTo(b['duration'] as Duration));

    // Display top 3 or fewer if not enough participants
    final displayCount = participantsWithSegment.length > 3 ? 3 : participantsWithSegment.length;

    if (displayCount == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEmptyPositionItem(Colors.blue),
          _buildEmptyPositionItem(Colors.amber),
          _buildEmptyPositionItem(Colors.orange),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        if (index < displayCount) {
          final participant = participantsWithSegment[index];
          final position = index + 1;
          final color = position == 1
              ? Colors.blue
              : position == 2
                  ? Colors.amber
                  : Colors.orange;
          return SizedBox(
            width: 100, // Consistent width for each item
            child: _buildPositionItem(
              position,
              participant['bib'] as String,
              FormatUtils.formatDuration(participant['duration'] as Duration),
              color,
            ),
          );
        } else {
          // Placeholder for empty positions
          final color = index == 0
              ? Colors.blue
              : index == 1
                  ? Colors.amber
                  : Colors.orange;
          return SizedBox(
            width: 100,
            child: _buildEmptyPositionItem(color),
          );
        }
      }),
    );
  }

  Widget _buildPositionItem(int position, String bib, String time, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min, // Ensures row takes minimal space
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
          mainAxisSize: MainAxisSize.min, // Ensures row takes minimal space
          children: [
            Icon(Icons.workspace_premium, color: color, size: 24),
            Text(
              "---",
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
          "--:---:--",
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
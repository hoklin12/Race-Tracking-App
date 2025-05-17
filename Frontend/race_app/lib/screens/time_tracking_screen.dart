import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/models/time_log.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/screens/widgets/category_tab_button_widget.dart';
import 'package:race_app/screens/widgets/time_tracking_participant_item.dart';
import 'package:race_app/theme/app_theme.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  Segment _selectedSegment = Segment.swim;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
      ),
      body: Consumer3<RaceProvider, ParticipantsProvider, TimeLogsProvider>(
        builder:
            (context, raceProvider, participantsProvider, timeLogsProvider, _) {
          final canTrackTime = raceProvider.canTrackTime;

          if (participantsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (participantsProvider.error != null) {
            return Center(
              child: Text(
                participantsProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSegmentSelector(context, canTrackTime),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name, BIB, or category...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                _buildParticipantsList(
                  context,
                  canTrackTime,
                  participantsProvider,
                  timeLogsProvider,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentSelector(BuildContext context, bool canTrackTime) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Segment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: Segment.values.map((segment) {
                  String label;
                  IconData icon;

                  switch (segment) {
                    case Segment.swim:
                      label = 'Swim';
                      icon = Icons.pool;
                      break;
                    case Segment.cycle:
                      label = 'Cycle';
                      icon = Icons.directions_bike;
                      break;
                    case Segment.run:
                      label = 'Run';
                      icon = Icons.directions_run;
                      break;
                  }

                  return CategoryTabButton(
                    label: label,
                    icon: icon,
                    isSelected: _selectedSegment == segment,
                    onTap: canTrackTime
                        ? () {
                            setState(() {
                              _selectedSegment = segment;
                            });
                          }
                        : () {},
                    foregroundColor: Colors.black,
                  );
                }).toList(),
              ),
            ),
            if (!canTrackTime)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Segment selection is only available when a race is ongoing.',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsList(
    BuildContext context,
    bool canTrackTime,
    ParticipantsProvider participantsProvider,
    TimeLogsProvider timeLogsProvider,
  ) {
    final allParticipants = participantsProvider.participants;
    final List<Participant> participantsToShow = [];

    for (var participant in allParticipants) {
      final latestSegment =
          timeLogsProvider.getLatestSegmentForParticipant(participant.bib);
      final hasCompleted =
          timeLogsProvider.hasCompletedAllSegments(participant.bib);

      if (hasCompleted) continue;

      if (_selectedSegment == Segment.swim && latestSegment == null) {
        participantsToShow.add(participant);
      } else if (_selectedSegment == Segment.cycle &&
          latestSegment == Segment.swim) {
        participantsToShow.add(participant);
      } else if (_selectedSegment == Segment.run &&
          latestSegment == Segment.cycle) {
        participantsToShow.add(participant);
      }
    }

    final filteredParticipants = participantsToShow.where((participant) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return participant.name.toLowerCase().contains(query) ||
          participant.bib.toString().contains(query);
    }).toList();

    if (filteredParticipants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Text(
          _searchQuery.isEmpty
              ? _selectedSegment == Segment.swim
                  ? 'No participants available for Swim.'
                  : _selectedSegment == Segment.cycle
                      ? 'No participants have completed Swim yet.'
                      : 'No participants have completed Cycle yet.'
              : 'No participants match your search.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = filteredParticipants[index];
        return TimeTrackingParticipantItem(
          participant: participant,
          canTrackTime: canTrackTime,
          onTrack: () => _recordTime(
            context,
            participant.bib,
            timeLogsProvider,
          ),
        );
      },
    );
  }

  void _recordTime(
    BuildContext context,
    int bib,
    TimeLogsProvider timeLogsProvider,
  ) async {
    try {
      await timeLogsProvider.trackTime(
        bib: bib,
        segment: _selectedSegment,
      );

      final hasCompleted = timeLogsProvider.hasCompletedAllSegments(bib);
      final message = hasCompleted
          ? 'Participant BIB #$bib has completed all segments!'
          : 'Time recorded for BIB #$bib in the ${_getSegmentName(_selectedSegment)} segment';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('permission_denied')
                ? 'Permission denied: Check Firebase rules for time_logs'
                : 'Failed to record time: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getSegmentName(Segment segment) {
    switch (segment) {
      case Segment.swim:
        return 'Swim';
      case Segment.cycle:
        return 'Cycle';
      case Segment.run:
        return 'Run';
    }
  }
}

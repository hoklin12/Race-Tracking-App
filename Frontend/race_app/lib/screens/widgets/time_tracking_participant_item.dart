import 'package:flutter/material.dart';
import 'package:race_app/models/participant.dart';

class TimeTrackingParticipantItem extends StatelessWidget {
  final Participant participant;
  final bool canTrackTime;
  final VoidCallback onTrack;

  const TimeTrackingParticipantItem({
    super.key,
    required this.participant,
    required this.canTrackTime,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(participant.bib.toString()),
        ),
        title: Text(participant.name),
        subtitle: Text([
          participant.age != null ? '${participant.age} years' : null,
          participant.gender,
        ].where((item) => item != null).join(' • ')),
        trailing: ElevatedButton.icon(
          onPressed: canTrackTime ? onTrack : null,
          icon: const Icon(Icons.timer),
          label: const Text('Track'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
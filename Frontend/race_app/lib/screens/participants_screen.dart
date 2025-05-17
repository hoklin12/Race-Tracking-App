import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/screens/add_participant_screen.dart';
import 'package:race_app/screens/edit_participant_screen.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    final participantsProvider =
        Provider.of<ParticipantsProvider>(context, listen: false);
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, _) {
        final isRaceStarted = raceProvider.race.status != RaceStatus.notStarted;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Participants'),
          ),
          body: Column(
            children: [
              if (isRaceStarted)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Can't add participant when race is started",
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
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
              Expanded(
                child: StreamBuilder<List<Participant>>(
                  stream: participantsProvider.streamParticipants(),
                  builder: (context, snapshot) {
                    print(
                        'StreamBuilder state: ${snapshot.connectionState}, data: ${snapshot.data?.length}, error: ${snapshot.error}');
                    final provider = Provider.of<ParticipantsProvider>(context,
                        listen: true);
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error
                                  .toString()
                                  .contains('permission_denied')
                              ? 'Permission denied: Check Firebase rules'
                              : snapshot.error
                                      .toString()
                                      .contains('FormatException')
                                  ? 'Data format error: Invalid participant data in Firebase'
                                  : 'Error loading participants: ${snapshot.error}',
                        ),
                      );
                    }
                    if (provider.error != null) {
                      return Center(
                        child: Text(
                          provider.error!.contains('permission_denied')
                              ? 'Permission denied: Check Firebase rules'
                              : provider.error!.contains('FormatException')
                                  ? 'Data format error: Invalid participant data in Firebase'
                                  : provider.error!,
                        ),
                      );
                    }
                    final participants =
                        (snapshot.hasData && snapshot.data!.isNotEmpty
                                ? snapshot.data!
                                : provider.participants)
                            .where((participant) {
                      if (_searchQuery.isEmpty) return true;
                      final query = _searchQuery.toLowerCase();
                      return participant.name.toLowerCase().contains(query) ||
                          participant.bib.toString().contains(query);
                    }).toList();

                    if (participants.isEmpty &&
                        snapshot.connectionState == ConnectionState.waiting &&
                        provider.participants.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (participants.isEmpty) {
                      return const Center(
                        child: Text(
                            'No participants found. Add a participant to start.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        return ParticipantListItem(
                          participant: participant,
                          onEdit: isRaceStarted
                              ? () {}
                              : () => _editParticipant(context, participant),
                          onDelete: isRaceStarted
                              ? () {}
                              : () => _deleteParticipant(context, participant),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed:
                    isRaceStarted ? null : () => _addParticipant(context),
                heroTag: 'add',
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addParticipant(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddParticipantScreen()),
    );
  }

  void _editParticipant(BuildContext context, Participant participant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditParticipantScreen(participant: participant),
      ),
    );
  }

  void _deleteParticipant(BuildContext context, Participant participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participant'),
        content: Text('Are you sure you want to delete ${participant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<ParticipantsProvider>(context, listen: false)
                    .deleteParticipant(participant.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Participant deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().contains('permission_denied')
                            ? 'Permission denied: Check Firebase rules'
                            : e.toString().contains('FormatException')
                                ? 'Data format error: Invalid participant data in Firebase'
                                : 'Failed to delete participant: $e',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ParticipantListItem extends StatelessWidget {
  final Participant participant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ParticipantListItem({
    super.key,
    required this.participant,
    required this.onEdit,
    required this.onDelete,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

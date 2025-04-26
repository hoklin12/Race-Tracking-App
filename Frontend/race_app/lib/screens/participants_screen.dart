import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/screens/add_participant_screen.dart';
import 'package:race_app/screens/edit_participant_screen.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: Column(
        children: [
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
            child: Consumer<ParticipantsProvider>(
              builder: (context, provider, _) {
                final participants = provider.participants.where((participant) {
                  if (_searchQuery.isEmpty) return true;
                  
                  final query = _searchQuery.toLowerCase();
                  return participant.name.toLowerCase().contains(query) ||
                      participant.bib.toString().contains(query) ||
                      (participant.category?.toLowerCase().contains(query) ?? false);
                }).toList();

                if (participants.isEmpty) {
                  return const Center(
                    child: Text('No participants found'),
                  );
                }

                return ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ParticipantListItem(
                      participant: participant,
                      onEdit: () => _editParticipant(context, participant),
                      onDelete: () => _deleteParticipant(context, participant),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addParticipant(context),
        child: const Icon(Icons.add),
      ),
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
            onPressed: () {
              Provider.of<ParticipantsProvider>(context, listen: false)
                  .deleteParticipant(participant.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Participant deleted')),
              );
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
          participant.category,
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


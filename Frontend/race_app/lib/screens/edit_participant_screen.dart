import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/providers/participants_provider.dart';

class EditParticipantScreen extends StatefulWidget {
  final Participant participant;

  const EditParticipantScreen({
    super.key,
    required this.participant,
  });

  @override
  State<EditParticipantScreen> createState() => _EditParticipantScreenState();
}

class _EditParticipantScreenState extends State<EditParticipantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bibController;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String? _selectedGender;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  @override
  void initState() {
    super.initState();
    _bibController = TextEditingController(text: widget.participant.bib.toString());
    _nameController = TextEditingController(text: widget.participant.name);
    _ageController = TextEditingController(
      text: widget.participant.age != null ? widget.participant.age.toString() : '',
    );
    _selectedGender = widget.participant.gender;
  }

  @override
  void dispose() {
    _bibController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Participant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _bibController,
                decoration: const InputDecoration(
                  labelText: 'BIB Number*',
                  hintText: 'Enter BIB number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a BIB number';
                  }
                  final bib = int.tryParse(value);
                  if (bib == null) {
                    return 'Please enter a valid number';
                  }
                  final provider = Provider.of<ParticipantsProvider>(context, listen: false);
                  if (!provider.isBibNumberUnique(bib, widget.participant.id)) {
                    return 'BIB number must be unique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name*',
                  hintText: 'Enter participant name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter age (optional)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Please enter a valid age';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  hintText: 'Select gender (optional)',
                ),
                value: _selectedGender,
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateParticipant,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateParticipant() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ParticipantsProvider>(context, listen: false);
      
      final updatedParticipant = widget.participant.copyWith(
        bib: int.parse(_bibController.text),
        name: _nameController.text,
        age: _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
        gender: _selectedGender,
      );
      
      provider.updateParticipant(updatedParticipant);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participant updated successfully')),
      );
      
      Navigator.pop(context);
    }
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/providers/participants_provider.dart';

class AddParticipantScreen extends StatefulWidget {
  const AddParticipantScreen({super.key});

  @override
  State<AddParticipantScreen> createState() => _AddParticipantScreenState();
}

class _AddParticipantScreenState extends State<AddParticipantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bibController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  bool _isSubmitting = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

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
        title: const Text('Add Participant'),
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
                  final provider =
                      Provider.of<ParticipantsProvider>(context, listen: false);
                  if (!provider.isBibNumberUnique(bib)) {
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
                onPressed: _isSubmitting ? null : _saveParticipant,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Participant'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveParticipant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final provider =
          Provider.of<ParticipantsProvider>(context, listen: false);

      final participant = Participant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bib: int.parse(_bibController.text),
        name: _nameController.text,
        age: _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        gender: _selectedGender,
        segmentTimes: null,
        overallTime: null,
      );

      try {
        await provider.addParticipant(participant);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participant added successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().contains('permission_denied')
                    ? 'Permission denied: Check Firebase rules'
                    : e.toString().contains('is not a subtype')
                        ? 'Data format error: Check Firebase data structure'
                        : 'Failed to add participant: $e',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/candidate.dart';
import '../services/candidate_service.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _partyController = TextEditingController();
  final _sloganController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final candidate = Candidate(
      id: const Uuid().v4(), // generate unique ID
      name: _nameController.text.trim(),
      symbol: _symbolController.text.trim(),
      party: _partyController.text.trim(),
      slogan: _sloganController.text.trim(),
    );

    final result = await CandidateService().addCandidate(candidate);

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result.contains('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidate added successfully!')),
      );
      Navigator.pop(context, true); // return to refresh candidates
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _partyController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Candidate'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              _buildTextField(_nameController, 'Name', 'Enter candidate name'),
              _buildTextField(_symbolController, 'Symbol', 'e.g. 🦁 or 🏏'),
              _buildTextField(_partyController, 'Party', 'Enter party name'),
              _buildTextField(_sloganController, 'Slogan', 'Enter slogan'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(_isLoading ? 'Adding...' : 'Add Candidate'),
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator:
            (value) =>
                value == null || value.trim().isEmpty ? 'Required field' : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/election_model.dart';
import '../models/candidate.dart';
import '../services/election_service.dart';
import '../services/candidate_service.dart';

class AddElectionScreen extends StatefulWidget {
  const AddElectionScreen({super.key});

  @override
  State<AddElectionScreen> createState() => _AddElectionScreenState();
}

class _AddElectionScreenState extends State<AddElectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _endDate;
  bool _isLoading = false;

  List<Candidate> _allCandidates = [];
  final Set<String> _selectedCandidateIds = {};

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    final candidates = await CandidateService().getCandidates();
    setState(() {
      _allCandidates = candidates;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select end date."),
        ),
      );
      return;
    }

    if (_selectedCandidateIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one candidate.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, int> selectedCandidatesMap = {
      for (var id in _selectedCandidateIds) id: 0,
    };

    final election = Election(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      startDate: DateTime.now(),
      endDate: _endDate!,
      candidates: selectedCandidatesMap,
    );

    final result = await ElectionService().addElection(election);

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result.contains('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Election added successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Election'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                _titleController,
                'Title',
                'Enter election title',
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                context,
                label: "End Date",
                date: _endDate,
                onTap: () => _pickEndDate(context),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Candidates:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _allCandidates.isEmpty
                  ? const Center(child: Text('No candidates found.'))
                  : Column(
                    children:
                        _allCandidates.map((candidate) {
                          final isSelected = _selectedCandidateIds.contains(
                            candidate.id,
                          );
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(
                              '${candidate.name} (${candidate.party})',
                            ),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedCandidateIds.add(candidate.id);
                                } else {
                                  _selectedCandidateIds.remove(candidate.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.how_to_vote),
                label: Text(_isLoading ? "Adding..." : "Add Election"),
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date != null
              ? "${date.day}-${date.month}-${date.year}"
              : "Select $label",
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

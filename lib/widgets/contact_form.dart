import 'package:flutter/material.dart';
import '../services/mailer_service.dart';

class ContactUsForm extends StatefulWidget {
  const ContactUsForm({super.key});

  @override
  State<ContactUsForm> createState() => _ContactUsFormState();
}

class _ContactUsFormState extends State<ContactUsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String? _errorMsg;
  bool _isLoading = false;

  Future<void> _submitForm() async {
    setState(() {
      _errorMsg = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final error = await MailerService.sendContactEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        _formKey.currentState!.reset();
      } else {
        setState(() {
          _errorMsg = error;
        });
      }
    } else {
      setState(() {
        _errorMsg = 'All fields are required';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: const Text(
                'Contact Us',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              validator:
                  (value) => value!.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) return 'Please enter your email';
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!regex.hasMatch(value)) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _messageController,
              label: 'Message',
              icon: Icons.message,
              maxLines: 5,
              validator:
                  (value) =>
                      value!.isEmpty ? 'Please enter your message' : null,
            ),
            const SizedBox(height: 15),

            if (_errorMsg != null)
              Text(_errorMsg!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitForm,
              icon: const Icon(Icons.send),
              label: Text(_isLoading ? 'Sending...' : 'Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor:
                    Colors.white, // <-- add this to make text/icon white
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

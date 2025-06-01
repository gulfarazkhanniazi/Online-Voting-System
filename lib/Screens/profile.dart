import 'package:first_app/widgets/mainLayout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider.dart';
import './login.dart';
import './signup.dart';
import '../widgets/contact_form.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.name.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Show network profile image only when logged in
            if (isLoggedIn)
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                ),
              ),

            const SizedBox(height: 20),

            // Logged-in User Info
            if (isLoggedIn)
              Column(
                children: [
                  ProfileDetailTile(title: 'Name', value: userProvider.name),
                  ProfileDetailTile(title: 'Email', value: userProvider.email),
                  ProfileDetailTile(title: 'CNIC', value: userProvider.cnic),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      userProvider.clearUser();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully'),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainLayout()),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              )
            else
              // Not Logged In UI
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'You are not logged in',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 110),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Login screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignupScreen()),
                          );
                        },
                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Contact Us Form Section
            const ContactUsForm(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailTile extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetailTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

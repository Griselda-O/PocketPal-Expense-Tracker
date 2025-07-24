import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocketpal/pigeons/pigeon.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _obscure = true;
  bool _registering = false;
  String? _error;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _registering = true;
        _error = null;
      });
      try {
        print('DEBUG: Attempting Firebase Auth registration for $_email');
        final user = await AuthService().register(_email, _password);
        print('DEBUG: Firebase Auth registration result: user=${user?.uid}');
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('loggedIn', true);
          print('DEBUG: Attempting Firestore write for user ${user.uid}');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'name': _name,
                'email': _email,
                'phone': _phone,
                'profileImageUrl': null,
                'bio': '',
                'monthlyBudget': 500.0,
              });
          print('DEBUG: Firestore write successful for user ${user.uid}');
          Navigator.pushReplacementNamed(context, '/');
        } else {
          setState(() => _error = 'Registration failed.');
          print('DEBUG: Registration failed, user is null');
        }
      } catch (e, stack) {
        setState(() => _error = e.toString());
        print('DEBUG: Registration error: $e');
        print('DEBUG: Stack trace: $stack');
      } finally {
        setState(() => _registering = false);
      }
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Enter your email';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Enter your phone number';
    if (v.length < 8) return 'Enter a valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter your name' : null,
                    onChanged: (v) => _name = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                    onChanged: (v) => _phone = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    onChanged: (v) => _email = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (v) => v == null || v.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    onChanged: (v) => _password = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v != _password ? 'Passwords do not match' : null,
                    onChanged: (v) => _confirmPassword = v,
                  ),
                  const SizedBox(height: 32),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      final userDetails = PigeonUserDetails()
                        ..name = _name
                        ..email = _email
                        ..phone = _phone;
                      await UserApi().registerUser(userDetails);
                      // Optionally, fetch details back
                      final details = await UserApi().getUserDetails();
                      print(details.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User registered:  {details.name}'),
                        ),
                      );
                    },
                    child: Text('Register'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

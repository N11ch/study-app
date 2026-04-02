import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../core/constants/app_config.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = 'STUDENT';

  //* UPDATE PROFILE FUNCTION IS HERE!
  // THIS IS A DANGEROUS ZONE, IF YOU DON'T KNOW WHAT YOUR DOING THEN DON'T TOUCH IT
  // just pls don't touch this function
  // todo: implement this method if we already got the new style, atleast we already make it
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // todo: we need to put the body here dog
        final const RESPONSE = await post(
          Uri.parse('${AppConfig.API_URL}/user/update/profile'),
          headers: {'Content-Type': 'application/json'},
          // body: jsonEncode({
          //   ''
          // })
        );

        if(!mounted) return;
        final responseData = jsonDecode(RESPONSE.body);
        print(responseData);

        if(RESPONSE.statusCode == 200 || RESPONSE.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text("Nice!, Your profile has been updated"),
            backgroundColor: Colors.green
            ), 
          );

          // todo RE-ROUTE USER WHERE SHOULD IT GO, BASED ON THE USER ROLES
          Navigator.of(context).pushReplacementNamed("/");
        }

      } catch (e) {
        if (!mounted) return;
        print("Update Profile error (something error with the API): $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again later.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  //-------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              DropdownButton<String>(
                value: _selectedRole,
                items: ['STUDENT', 'TUTOR'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Hey friend, please implement the API logic here to save the profile
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

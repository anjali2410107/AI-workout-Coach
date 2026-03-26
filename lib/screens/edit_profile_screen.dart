import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile/profile_bloc.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late int age;
  late double weight;
  late double height;
  late String level;
  late List<String> goals;

  final _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final _allGoals = [
    'Build Muscle',
    'Lose Weight',
    'Improve Endurance',
    'Stay Active',
    'Increase Flexibility'
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.profile;

    nameController = TextEditingController(text: p.name);
    age = p.age;
    weight = p.weight;
    height = p.height;
    level = p.fitnessLevel;
    goals = p.fitnessGoal.split(', ');
  }

  void _save() {
    context.read<ProfileBloc>().add(ProfileSaved(
      name: nameController.text,
      age: age,
      weight: weight,
      height: height,
      fitnessGoals: goals,
      fitnessLevel: level,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 🔹 NAME
            _buildCard(
              child: TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 AGE
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => age--),
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Text('$age', style: const TextStyle(color: Colors.white)),
                      IconButton(
                        onPressed: () => setState(() => age++),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 WEIGHT
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weight', style: TextStyle(color: Colors.white)),
                  Slider(
                    value: weight,
                    min: 30,
                    max: 150,
                    onChanged: (v) => setState(() => weight = v),
                  ),
                  Text('${weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: Colors.white))
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 HEIGHT
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Height', style: TextStyle(color: Colors.white)),
                  Slider(
                    value: height,
                    min: 100,
                    max: 220,
                    onChanged: (v) => setState(() => height = v),
                  ),
                  Text('${height.toStringAsFixed(0)} cm',
                      style: const TextStyle(color: Colors.white))
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 LEVEL
            _buildCard(
              child: DropdownButton<String>(
                value: level,
                dropdownColor: Colors.black,
                items: _levels
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: (v) => setState(() => level = v!),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 GOALS
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _allGoals.map((g) {
                  final selected = goals.contains(g);
                  return CheckboxListTile(
                    value: selected,
                    title: Text(g,
                        style: const TextStyle(color: Colors.white)),
                    onChanged: (_) {
                      setState(() {
                        selected ? goals.remove(g) : goals.add(g);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 SAVE BUTTON
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
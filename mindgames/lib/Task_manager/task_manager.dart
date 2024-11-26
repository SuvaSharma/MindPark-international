import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mindgames/level8page.dart';

class TaskManager {
  // ... other code ...

  Future<void> loadJsonAndNavigate(BuildContext context) async {
    try {
      // Load the JSON file content
      String jsonContent = await DefaultAssetBundle.of(context)
          .loadString('assets/Task/task_data.json');

      // Print the loaded JSON content
      log('Loaded JSON: $jsonContent');

      // Decode the JSON content
      List<dynamic> tasks = jsonDecode(jsonContent)['tasks'];

      // Print the decoded tasks
      log('Decoded tasks: $tasks');

      // Check if the required task is present in the JSON
      bool isLevel8Unlocked = tasks.any((task) => task['id'] == 8);

      // Navigate to Level 8 page if it's unlocked
      if (isLevel8Unlocked) {
        if (!context.mounted) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Level8page()),
        );
      } else {
        // Handle the case when Level 8 is locked
        // You can show a message or perform any other action here
        log('Level 8 is locked!');
      }
    } catch (e) {
      // Handle any potential exceptions
      log('Error loading or decoding JSON: $e');
    }

    // ... other code ...
  }
}

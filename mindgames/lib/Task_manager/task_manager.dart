import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mindgames/Task_manager/task.dart';
import 'package:mindgames/level8page.dart';
import 'package:path_provider/path_provider.dart';

class TaskManager {
  // ... other code ...

  Future<void> loadJsonAndNavigate(BuildContext context) async {
    try {
      // Load the JSON file content
      String jsonContent = await DefaultAssetBundle.of(context)
          .loadString('assets/Task/task_data.json');

      // Print the loaded JSON content
      print('Loaded JSON: $jsonContent');

      // Decode the JSON content
      List<dynamic> tasks = jsonDecode(jsonContent)['tasks'];

      // Print the decoded tasks
      print('Decoded tasks: $tasks');

      // Check if the required task is present in the JSON
      bool isLevel8Unlocked = tasks.any((task) => task['id'] == 8);

      // Navigate to Level 8 page if it's unlocked
      if (isLevel8Unlocked) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Level8page()),
        );
      } else {
        // Handle the case when Level 8 is locked
        // You can show a message or perform any other action here
        print('Level 8 is locked!');
      }
    } catch (e) {
      // Handle any potential exceptions
      print('Error loading or decoding JSON: $e');
    }

    // ... other code ...
  }
}

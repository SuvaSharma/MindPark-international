// import 'package:flutter/material.dart';
// import 'package:mindgames/DatabaseHelper.dart';
// import 'package:mindgames/models/GameRecord.dart'; // Import the database helper

// class LeaderboardPage extends StatelessWidget {
//   // final DatabaseHelper databaseHelper = DatabaseHelper();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Color.fromARGB(255, 51, 106, 134),
//         body: FutureBuilder(
//           future: databaseHelper.getAllGameRecords(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error: ${snapshot.error}'),
//               );
//             } else {
//               List<GameRecordModel> gameRecords =
//                   snapshot.data as List<GameRecordModel>;

//               Map<String, List<GameRecordModel>> groupedByDate =
//                   groupByDate(gameRecords);

//               return ListView.builder(
//                 itemCount: groupedByDate.length,
//                 itemBuilder: (context, index) {
//                   String date = groupedByDate.keys.elementAt(index);
//                   List<GameRecordModel> records = groupedByDate[date]!;

//                   return ExpansionTile(
//                     title: Text(
//                       'Date: $date',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                     children: records.map((record) {
//                       return ListTile(
//                         title: Text(
//                           'Characters Count: ${record.charactersCount}\nIncorrect Taps: ${record.incorrectTaps}\nDifficulty: ${record.difficulty}',
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Map<String, List<GameRecordModel>> groupByDate(
//       List<GameRecordModel> gameRecords) {
//     Map<String, List<GameRecordModel>> groupedByDate = {};

//     for (GameRecordModel record in gameRecords) {
//       if (groupedByDate.containsKey(record.date)) {
//         groupedByDate[record.date]!.add(record);
//       } else {
//         groupedByDate[record.date] = [record];
//       }
//     }

//     return groupedByDate;
//   }
// }

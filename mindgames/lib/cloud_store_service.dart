import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:mindgames/CPTDataModel.dart';
import 'package:mindgames/CPTResult.dart';
import 'package:mindgames/DSTDataModel.dart';
import 'package:mindgames/DSTResult.dart';
import 'package:mindgames/SDMTResult.dart';
import 'package:mindgames/StroopResult.dart';
import 'package:mindgames/TMTResult.dart';
import 'package:mindgames/child.dart';
import 'package:mindgames/ert_result.dart';
import 'package:mindgames/game.dart';
import 'package:mindgames/graph_data.dart';
import 'package:mindgames/models/LegoGameData.dart';
import 'package:mindgames/models/PictureSortingGamedata.dart';
import 'package:mindgames/models/blog.dart';
import 'package:mindgames/models/gaze_maze_model.dart';
import 'package:mindgames/models/jungle_jingles_model.dart';
import 'package:mindgames/models/maze_magic_model.dart';
import 'package:mindgames/models/number_counting_model.dart';
import 'package:mindgames/models/puzzle_paradise_model.dart';
import 'package:mindgames/models/simon_says_model.dart';
import 'package:mindgames/models/story.dart';
import 'package:mindgames/models/story_group.dart';
import 'package:mindgames/models/subscription_model.dart'
    show SubscriptionModel;
import 'package:mindgames/models/voiceloon_model.dart';
import 'package:mindgames/questionnaire_response.dart';
import 'package:mindgames/utils/calculate_mean_median.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/utils/task_data_point_helper.dart';
import 'package:mindgames/utils/text_formatter.dart';
import 'package:mindgames/word_model.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CloudStoreService {
  final db = FirebaseFirestore.instance;

  Future<bool> getTermsStatus(String? userId) async {
    if (userId == null) {
      return false;
    }

    try {
      QuerySnapshot querySnapshot =
          await db.collection('users').where('userId', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final agreedToTerms = querySnapshot.docs[0]['agreedToTerms'] ?? false;
        return agreedToTerms;
      } else {
        // Handle case where no document is found
        return false;
      }
    } catch (e) {
      // Handle any errors that occur
      log('Error fetching terms status: $e');
      return false;
    }
  }

  Future<void> addSDMTData(List<GameData> gameDataList) async {
    for (final gameData in gameDataList) {
      await db.collection('sdmt-data').add({
        'userId': gameData.userId,
        'sessionId': gameData.sessionId,
        'blockId': gameData.blockId,
        'trialId': gameData.trialId,
        'result': gameData.result,
        'responseTime': gameData.responseTime,
        'symbolDisplayTime': gameData.symbolDisplayTime
      }).then(
          (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
    }
  }

  Future<void> addSDMTResult(SDMTResult sdmtResult) async {
    await db.collection('level-result').add({
      'userId': sdmtResult.userId,
      'level': sdmtResult.level,
      'sessionId': sdmtResult.sessionId,
      'score': sdmtResult.score,
      'incorrectChoice': sdmtResult.incorrectChoice,
      'totalTrials': sdmtResult.totalTrials,
      'accuracy': sdmtResult.accuracy,
      'meanReactionTime': sdmtResult.meanReactionTime,
    }).then(
        (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> getSDMTData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'SDMT')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'score': item['score'],
        'incorrectChoice': item['incorrectChoice'],
        'totalTrials': item['totalTrials'],
        'accuracy': item['accuracy'],
        'meanReactionTime': item['meanReactionTime'],
      };
    }).toList();

    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<void> addStroopData(List<Word> wordDataList) async {
    for (final wordData in wordDataList) {
      await db.collection('stroop-data').add({
        'userId': wordData.userId,
        'sessionId': wordData.sessionId,
        'trialId': wordData.trialId,
        'word': wordData.word,
        'color': wordData.color,
        'type': wordData.type,
        'result': wordData.result,
        'responseTime': wordData.responseTime,
      }).then(
          (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
    }
  }

  Future<void> addStroopResult(StroopResult stroopResult) async {
    await db.collection('level-result').add({
      'userId': stroopResult.userId,
      'level': stroopResult.level,
      'sessionId': stroopResult.sessionId,
      'compatible': stroopResult.compatible,
      'incompatible': stroopResult.incompatible,
      'stroopScore': stroopResult.stroopScore,
      'correctResponse': stroopResult.correctResponse,
      'incorrectResponse': stroopResult.incorrectResponse,
      'accuracy': stroopResult.accuracy,
    }).then(
        (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> getStroopData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'Stroop')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'compatible': item['compatible'],
        'incompatible': item['incompatible'],
        'stroopScore': item['stroopScore'],
        'correctResponse': item['correctResponse'],
        'incorrectResponse': item['incorrectResponse'],
        'accuracy': item['accuracy'],
      };
    }).toList();
    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<void> addDSTData(List<DSTData> DSTDataList) async {
    for (final dstData in DSTDataList) {
      await db.collection('dst-data').add({
        'userId': dstData.userId,
        'sessionId': dstData.sessionId,
        'trialId': dstData.trialId,
        'sequenceGiven': dstData.sequenceGiven,
        'sequenceEntered': dstData.sequenceEntered,
        'result': dstData.result,
        'responseTime': dstData.responseTime,
      }).then(
          (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
    }
  }

  Future<void> addDSTResult(DSTResult dstResult) async {
    await db.collection('level-result').add({
      'userId': dstResult.userId,
      'level': dstResult.level,
      'sessionId': dstResult.sessionId,
      'score': dstResult.score,
      'span': dstResult.span,
    }).then(
        (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> getDSTData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'DST')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'score': item['score'],
        'span': item['span']
      };
    }).toList();

    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<void> addCPTData(List<CPTData> CPTDataList) async {
    for (final cptData in CPTDataList) {
      await db.collection('cpt-data').add({
        'userId': cptData.userId,
        'sessionId': cptData.sessionId,
        'trialId': cptData.trialId,
        'letter': cptData.letter,
        'result': cptData.result,
        'responseTime': cptData.responseTime,
      }).then(
          (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
    }
  }

  Future<void> addCPTResult(CPTResult cptResult) async {
    await db.collection('level-result').add({
      'userId': cptResult.userId,
      'level': cptResult.level,
      'sessionId': cptResult.sessionId,
      'accuracy': cptResult.accuracy,
      'responseTime': cptResult.responseTime,
      'commissionError': cptResult.commissionError,
      'omissionError': cptResult.omissionError,
      'inhibitoryControl': cptResult.inhibitoryControl,
    }).then(
        (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> getCPTData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'CPT')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'accuracy': item['accuracy'],
        'responseTime': item['responseTime'],
        'commissionError': item['commissionError'],
        'omissionError': item['omissionError'],
        'inhibitoryControl': item['inhibitoryControl'],
      };
    }).toList();

    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<void> addTMTResult(TMTResult tmtResult) async {
    log('$tmtResult');
    await db.collection('level-result').add({
      'userId': tmtResult.userId,
      'level': tmtResult.level,
      'difficulty': tmtResult.difficulty.name,
      'sessionId': tmtResult.sessionId,
      'accuracy': tmtResult.accuracy,
      'averageTime': tmtResult.averageTime,
      'gameData': tmtResult.gameData,
    }).then(
        (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> getTMTData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'TMT')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'level': item['level'],
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'accuracy': item['accuracy'],
        'gameData': item['gameData'].map((data) => {
              'part': data['part'],
              'status': data['status'],
              'correctNodeTapped': data['correctNodeTapped'],
              'incorrectNodeTapped': data['incorrectNodeTapped'],
              'time': data['timeTaken'],
              'accuracy': data['accuracy'],
            }),
      };
    }).toList();
    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<void> addERTResult(ERTResult ertResult) async {
    await db.collection('level-result').add({
      'userId': ertResult.userId,
      'level': ertResult.level,
      'difficulty': ertResult.difficulty.name,
      'sessionId': ertResult.sessionId,
      'accuracy': ertResult.accuracy,
      'score': ertResult.score,
    }).then(
      (DocumentReference doc) => log('Document added with ID: ${doc.id}'),
    );
  }

  Future<List<Map<String, dynamic>>> getERTData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'ERT')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'accuracy': item['accuracy'],
        'score': item['score'],
      };
    }).toList();

    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  //Lego Game
  Future<void> addLegoGameData(LegoGameData legoGameData) async {
    log("added lego game data");
    await db.collection('level-result').add({
      'userId': legoGameData.userId,
      'sessionId': legoGameData.sessionId,
      'level': legoGameData.level,
      'difficulty': legoGameData.difficulty.name,
      'accuracy': legoGameData.accuracy,
      'elapsedTime': legoGameData.elapsedTime,
    }).then(
      (DocumentReference doc) => log('Document added with ID: ${doc.id}'),
    );
  }

  // Retrieve Lego Game Data
  Future<List<Map<String, dynamic>>> getLegoGameData(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Lego Game')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          // 'score': item['score'],
          // 'timeTaken': Duration(milliseconds: item['timeTaken']),
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  // Add Voiceloon Game Data

  Future<void> addVoiceloonData(VoiceloonModel voiceloonModel) async {
    await db.collection('level-result').add({
      'userId': voiceloonModel.userId,
      'level': voiceloonModel.level,
      'difficulty': voiceloonModel.difficulty.name,
      'sessionId': voiceloonModel.sessionId,
      'score': voiceloonModel.score,
      'accuracy': voiceloonModel.accuracy,
      'status': voiceloonModel.status,
      'responseTime': voiceloonModel.responseTime,
    }).then(
      (DocumentReference doc) => log('Document added with ID: ${doc.id}'),
    );
  }

  // Retrieve Voiceloon Game Data
  Future<List<Map<String, dynamic>>> getVoiceloonGameData(
      String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Voiceloon')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          'score': item['score'],
          'responseTime': item['responseTime']
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  //Picture Sorting Game
  Future<void> addPictureSortingGameData(
      PictureSortingGameData pictureSortingGameData) async {
    log("added Picture sorting game data");
    await db.collection('level-result').add({
      'userId': pictureSortingGameData.userId,
      'sessionId': pictureSortingGameData.sessionId,
      'level': pictureSortingGameData.level,
      'difficulty': pictureSortingGameData.difficulty.name,
      'accuracy': pictureSortingGameData.accuracy,
      'elapsedTime': pictureSortingGameData.elapsedTime,
    }).then(
      (DocumentReference doc) => log('Document added with ID: ${doc.id}'),
    );
  }

  // Retrieve Picture Sorting Game Data
  Future<List<Map<String, dynamic>>> getPictureSortingGameData(
      String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Picture Sorting Game')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          // 'score': item['score'],
          // 'timeTaken': Duration(milliseconds: item['timeTaken']),
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  // Add Simon Says Data
  Future<void> addSimonSaysData(SimonSaysModel simonSaysModel) async {
    await db.collection('level-result').add({
      'userId': simonSaysModel.userId,
      'sessionId': simonSaysModel.sessionId,
      'level': simonSaysModel.level,
      'difficulty': simonSaysModel.difficulty.name,
      'score': simonSaysModel.score,
      'gameData': simonSaysModel.gameData
    }).then((DocumentReference doc) => log("Document added with ID $doc"));
  }

  // Retrieve Simon Says Data
  Future<List<Map<String, dynamic>>> getSimonSaysData(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Simon Says')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          'score': item['score'],
          'gameData': item['gameData']
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  Future<void> addGazeMazeData(GazeMazeModel gazeMazeModel) async {
    await db.collection('level-result').add({
      'userId': gazeMazeModel.userId,
      'sessionId': gazeMazeModel.sessionId,
      'level': gazeMazeModel.level,
      'difficulty': gazeMazeModel.difficulty.name,
      'score': gazeMazeModel.score,
      'averageStareTime': gazeMazeModel.averageStareTime,
      'accuracy': gazeMazeModel.accuracy,
      'gameData': gazeMazeModel.gameData
    }).then((DocumentReference doc) => log("Document added with ID $doc"));
  }

  // Retrieve Simon Says Data
  Future<List<Map<String, dynamic>>> getGazeMazeData(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Gaze Maze')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          'score': item['score'],
          'averageStareTime': item['averageStareTime'],
          'accuracy': item['accuracy'],
          'gameData': item['gameData']
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  Future<void> addPuzzleParadiseData(
      PuzzleParadiseModel puzzleParadiseModel) async {
    await db.collection('level-result').add({
      'userId': puzzleParadiseModel.userId,
      'sessionId': puzzleParadiseModel.sessionId,
      'level': puzzleParadiseModel.level,
      'status': puzzleParadiseModel.status,
      'difficulty': puzzleParadiseModel.difficulty.name,
      'imageName': puzzleParadiseModel.imageName,
      'timeTaken': puzzleParadiseModel.timeTaken,
    }).then((DocumentReference doc) => log("Document added with ID $doc"));
  }

  // Retrieve Puzzle Paradise Data
  Future<List<Map<String, dynamic>>> getPuzzleParadiseData(
      String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Puzzle Paradise')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          'imageName': item['imageName'],
          'timeTaken': item['timeTaken'],
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  Future<void> addJungleJinglesData(
      JungleJinglesModel jungleJinglesModel) async {
    await db.collection('level-result').add({
      'userId': jungleJinglesModel.userId,
      'sessionId': jungleJinglesModel.sessionId,
      'level': jungleJinglesModel.level,
      'difficulty': jungleJinglesModel.difficulty.name,
      'score': jungleJinglesModel.score,
    }).then((DocumentReference doc) => log("Document added with ID $doc"));
  }

  // Retrieve Number Counting Data
  Future<List<Map<String, dynamic>>> getJungleJinglesData(
      String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Jungle Jingles')
          .get();

      List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
        return {
          'sessionId': (item['sessionId'] as Timestamp).toDate(),
          'score': item['score'],
        };
      }).toList();

      dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
      return dataList;
    } catch (e) {
      return [];
    }
  }

  Future<void> addNumberCountingData(
      NumberCountingModel numberCountingModel) async {
    await db.collection('level-result').add({
      'userId': numberCountingModel.userId,
      'sessionId': numberCountingModel.sessionId,
      'level': numberCountingModel.level,
      'difficulty': numberCountingModel.difficulty.name,
      'score': numberCountingModel.score,
      'accuracy': numberCountingModel.accuracy,
    }).then((DocumentReference doc) => log("Document added with ID $doc"));
  }

  // Retrieve Number Counting Data
  Future<List<Map<String, dynamic>>> getNumberCountingData(
      String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'Number Counting')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'score': item['score'],
      };
    }).toList();

    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<void> addMazeMagicData(MazeMagicModel mazeMagicModel) async {
    await db.collection('level-result').add({
      'userId': mazeMagicModel.userId,
      'sessionId': mazeMagicModel.sessionId,
      'level': mazeMagicModel.level,
      'status': mazeMagicModel.status,
      'difficulty': mazeMagicModel.difficulty.name,
      'timeTaken': mazeMagicModel.timeTaken,
    }).then((DocumentReference doc) => log("Document added with ID $doc"));
  }

  // Retrieve Simon Says Data
  Future<List<Map<String, dynamic>>> getMazeMagicData(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'Puzzle Paradise')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      return {
        'sessionId': (item['sessionId'] as Timestamp).toDate(),
        'timeTaken': item['timeTaken'],
        'status': item['status'],
      };
    }).toList();

    dataList.sort((a, b) => b['sessionId'].compareTo(a['sessionId']));
    return dataList;
  }

  Future<double> getAttentionAverage(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Stroop')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Attention - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getMemoryAverage(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'DST')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['span']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Memory - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getInhibitionAverage(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'CPT')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['inhibitoryControl']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Inhibition - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getEQAverage(String? userId) async {
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: 'ERT')
        .get();

    double averageEQ = 0;
    for (var element in querySnapshot.docs) {
      averageEQ += element['accuracy'] / querySnapshot.docs.length;
    }

    return averageEQ;
  }

  Future<double> getSpeedAverage(String? userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'SDMT')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['score']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Speed - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      log('$e');
      return 0.0;
    }
  }

  Future<double> getExecutiveData(String? userId) async {
    try {
      double speedData = await getSpeedAverage(userId);
      double attentionData = await getAttentionAverage(userId);
      double memoryData = await getMemoryAverage(userId);
      double inhibitionData = await getInhibitionAverage(userId);

      double sumOfData =
          speedData + attentionData + memoryData + inhibitionData;
      double average = double.parse((sumOfData / 4).toStringAsFixed(2));
      return average;
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getLevelChartData(
      String? userId, String levelName) async {
    List<Map<String, dynamic>> levelGraphData = [];
    String parameter = '';
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: levelName)
        .get();

    for (var element in querySnapshot.docs) {
      switch (element['level']) {
        case 'SDMT':
          parameter = 'accuracy';
          break;
        case 'CPT':
          parameter = 'inhibitoryControl';
          break;
        case 'Stroop':
          parameter = 'accuracy';
          break;
        case 'TMT':
          parameter = 'accuracy';
          break;
        case 'DST':
          parameter = 'span';
          break;
        case 'ERT':
          parameter = 'accuracy';
          break;
      }
      levelGraphData.add({
        'sessionId': (element['sessionId'] as Timestamp).toDate(),
        parameter: element[parameter],
      });
    }

    levelGraphData.sort((a, b) => a['sessionId'].compareTo(b['sessionId']));

    return levelGraphData;
  }

  Future<List<Map<String, dynamic>>> getDataForTasks(
      String? userId, String levelName, String parameter) async {
    List<Map<String, dynamic>> dataList = [];
    QuerySnapshot querySnapshot = await db
        .collection('level-result')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: levelName)
        .get();

    for (var element in querySnapshot.docs) {
      dataList.add({
        'sessionId': (element['sessionId'] as Timestamp).toDate(),
        parameter: element[parameter]
      });
    }

    dataList.sort((a, b) => a['sessionId'].compareTo(b['sessionId']));

    return dataList;
  }

  Future<void> addChildren({
    required String? userId,
    required String name,
    required String age,
    required String gender,
    required DateTime createdDate,
  }) async {
    try {
      final querySnapshot =
          await db.collection('users').where("userId", isEqualTo: userId).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = querySnapshot.docs.first;
      DocumentReference userRef = userDoc.reference;

      String childId = customAlphabet(
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', 28);
      await userRef.update({
        'children': FieldValue.arrayUnion([
          {
            'childId': childId,
            'name': name,
            'age': age,
            'gender': gender,
            'createdDate': createdDate,
          }
        ])
      });
    } catch (e) {
      throw Exception('Error adding child: $e');
    }
  }

  Future<void> updateChild({
    required String userId,
    required String childId,
    required String name,
    required String age,
    required String gender,
  }) async {
    try {
      final querySnapshot =
          await db.collection('users').where("userId", isEqualTo: userId).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = querySnapshot.docs.first;
      DocumentReference userRef = userDoc.reference;

      final userData = userDoc.data();
      final children = userData['children'] as List<dynamic>;

      bool childFound = false;

      for (var child in children) {
        if (child['childId'] == childId) {
          child['name'] = name;
          child['age'] = age;
          child['gender'] = gender;
          childFound = true;
          break;
        }
      }

      if (!childFound) {
        throw Exception('Child not found');
      }

      await userRef.update({'children': children});
    } catch (e) {
      throw Exception('Error updating child: $e');
    }
  }

  Future<void> deleteChild({
    required String userId,
    required String childId,
  }) async {
    try {
      final querySnapshot =
          await db.collection('users').where("userId", isEqualTo: userId).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = querySnapshot.docs.first;
      DocumentReference userRef = userDoc.reference;

      final userData = userDoc.data();
      final children = userData['children'] as List<dynamic>;

      final updatedChildren =
          children.where((child) => child['childId'] != childId);

      await userRef.update({'children': updatedChildren});

      log('$userData');
    } catch (e) {
      log('$e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String? userId) async {
    QuerySnapshot querySnapshot =
        await db.collection('users').where('userId', isEqualTo: userId).get();
    final userDoc = querySnapshot.docs.first;
    final userData = userDoc.data() as Map<String, dynamic>;
    return userData;
  }

  Future<List<Map<String, dynamic>>> getChildren(String? userId) async {
    log('getting children');
    List<Map<String, dynamic>> childList = [];
    QuerySnapshot querySnapshot =
        await db.collection('users').where('userId', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;

      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null &&
          userData.containsKey('children') &&
          userData['children'] != null) {
        final childrenList = userData['children'] as List<dynamic>;

        for (var element in childrenList) {
          childList.add({
            'childId': element['childId'],
            'name': element['name'],
            'gender': element['gender'],
            'age': element['age'],
          });
        }
      }
    }

    childList.sort((a, b) => a['name'].compareTo(b['name']));

    return childList;
  }

  Future<void> addQuestionnaireResponse(
      QuestionnaireResponse questionnaireResponse) async {
    String assessmentId = customAlphabet(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', 28);
    await db.collection('questionnaire-response').add({
      'assessmentId': assessmentId,
      'userId': questionnaireResponse.userId,
      'childId': questionnaireResponse.childId,
      'category': questionnaireResponse.category,
      'assessmentDate': questionnaireResponse.assessmentDate,
      'response': questionnaireResponse.response
    }).then(
        (DocumentReference doc) => log('Document added with ID: ${doc.id}'));
  }

  Future<List<Map<String, dynamic>>> getQuestionnaireResponse(
      String userId, String childId, String category) async {
    QuerySnapshot querySnapshot = await db
        .collection('questionnaire-response')
        .where('userId', isEqualTo: userId)
        .where('childId', isEqualTo: childId)
        .where('category', isEqualTo: category)
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs
        .map((item) => {
              'assessmentId': item['assessmentId'],
              'userId': item['userId'],
              'childId': item['childId'],
              'category': item['category'],
              'assessmentDate': (item['assessmentDate'] as Timestamp).toDate(),
              'response': item['response'],
            })
        .toList();

    dataList.sort((a, b) => a['assessmentDate'].compareTo(b['assessmentDate']));

    return dataList;
  }

  Future<List<Map<String, dynamic>>> getADHDResponse(
      String userId, String childId) async {
    QuerySnapshot querySnapshot = await db
        .collection('questionnaire-response')
        .where('userId', isEqualTo: userId)
        .where('childId', isEqualTo: childId)
        .where('category', isEqualTo: 'ADHD')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      List<dynamic> responses = item['response'];
      int hyperactivityCount = 0;
      int inattentivenessCount = 0;

      for (int i = 0; i < responses.length; i++) {
        if (i <= 8 &&
            (responses[i]['answer'] == 2 || responses[i]['answer'] == 3)) {
          hyperactivityCount++;
        } else if (i > 8 &&
            (responses[i]['answer'] == 2 || responses[i]['answer'] == 3)) {
          inattentivenessCount++;
        }
      }

      return {
        'assessmentId': item['assessmentId'],
        'assessmentDate': (item['assessmentDate'] as Timestamp).toDate(),
        'result': {
          'hyperactivity': hyperactivityCount.toDouble(),
          'inattentiveness': inattentivenessCount.toDouble(),
        }
      };
    }).toList();

    dataList.sort((a, b) => a['assessmentDate'].compareTo(b['assessmentDate']));

    return dataList;
  }

  Future<List<Map<String, dynamic>>> getASDResponse(
      String userId, String childId) async {
    QuerySnapshot querySnapshot = await db
        .collection('questionnaire-response')
        .where('userId', isEqualTo: userId)
        .where('childId', isEqualTo: childId)
        .where('category', isEqualTo: 'ASD')
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((item) {
      List<dynamic> responses = item['response'];
      double socialCommunication = 0;
      double repetitiveBehavior = 0;

      for (int i = 0; i < responses.length; i++) {
        if (i <= 8) {
          socialCommunication += responses[i]['answer'] as double;
        } else if (i > 8) {
          repetitiveBehavior += responses[i]['answer'] as double;
        }
      }

      return {
        'assessmentId': item['assessmentId'],
        'assessmentDate': (item['assessmentDate'] as Timestamp).toDate(),
        'result': {
          'socialCommunication': socialCommunication.toDouble(),
          'repetitiveBehavior': repetitiveBehavior.toDouble(),
        },
        'totalScore': socialCommunication + repetitiveBehavior,
      };
    }).toList();

    dataList.sort((a, b) => a['assessmentDate'].compareTo(b['assessmentDate']));

    return dataList;
  }

  Future<Map<String, dynamic>> getQuestionnaireResponseById(
      String assessmentId) async {
    QuerySnapshot querySnapshot = await db
        .collection('questionnaire-response')
        .where('assessmentId', isEqualTo: assessmentId)
        .get();

    Map<String, dynamic> responseData = {};

    if (querySnapshot.docs.isNotEmpty) {
      final firstData = querySnapshot.docs.first;

      responseData = {
        'assessmentDate': (firstData['assessmentDate'] as Timestamp).toDate(),
        'response': firstData['response'].map((item) => {
              'question': item['question'],
              'answer': item['answer'],
            }),
      };
    }

    return responseData;
  }

  Future<void> addPIN(String userId, String pin) async {
    String hashPin(String pin) {
      final bytes = utf8.encode(pin); // Convert string to bytes
      final hashed = sha256.convert(bytes); // Hash using SHA-256
      return hashed.toString(); // Convert hash to string
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("userId", isEqualTo: userId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .update({
          'PIN': hashPin(pin),
        });
      } catch (e) {
        log('$e');
      }
    }
  }

  Future<bool> verifyPIN(String userId, String pin) async {
    String hashPin(String pin) {
      final bytes = utf8.encode(pin); // Convert string to bytes
      final hashed = sha256.convert(bytes); // Hash using SHA-256
      return hashed.toString(); // Convert hash to string
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final storedHashedPIN = userDoc['PIN'];

        final hashedInputPIN = hashPin(pin);
        return hashedInputPIN == storedHashedPIN;
      } else {
        log('No user found with the provided userId');
        return false;
      }
    } catch (e) {
      log('$e');
      return false;
    }
  }

  // APIs to fetch ADHD and ASD status in homepage
  Future<Map<String, dynamic>> getADHDStatus(String childId) async {
    try {
      final querySnapshot = await db
          .collection('questionnaire-response')
          .where('childId', isEqualTo: childId)
          .where('category', isEqualTo: 'ADHD')
          .orderBy("assessmentDate", descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first;
        Map<String, dynamic> latestData = {
          'assessmentId': data['assessmentId'],
          'assessmentDate': (data['assessmentDate'] as Timestamp).toDate(),
          'response': data['response'],
        };

        int hyperactivityCount = 0;
        int inattentivenessCount = 0;
        final responses = latestData['response'];

        for (int i = 0; i < responses.length; i++) {
          if (i <= 8 &&
              (responses[i]['answer'] == 2 || responses[i]['answer'] == 3)) {
            hyperactivityCount++;
          } else if (i > 8 &&
              (responses[i]['answer'] == 2 || responses[i]['answer'] == 3)) {
            inattentivenessCount++;
          }
        }

        final adhdLikelihood =
            hyperactivityCount > 6 || inattentivenessCount > 6 ? 'HIGH' : 'LOW';
        final result = {
          'assessmentDate': latestData['assessmentDate'],
          'likelihood': adhdLikelihood
        };

        return result;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getASDStatus(String childId) async {
    try {
      final querySnapshot = await db
          .collection('questionnaire-response')
          .where('childId', isEqualTo: childId)
          .where('category', isEqualTo: 'ASD')
          .orderBy("assessmentDate", descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first;
        Map<String, dynamic> latestData = {
          'assessmentId': data['assessmentId'],
          'assessmentDate': (data['assessmentDate'] as Timestamp).toDate(),
          'response': data['response'],
        };

        double socialCommunication = 0;
        double repetitiveBehavior = 0;
        final responses = latestData['response'];

        for (int i = 0; i < responses.length; i++) {
          if (i <= 8) {
            socialCommunication += responses[i]['answer'] as double;
          } else if (i > 8) {
            repetitiveBehavior += responses[i]['answer'] as double;
          }
        }

        final totalScore = socialCommunication + repetitiveBehavior;

        final asdLikelihood = totalScore <= 10
            ? 'LOW'
            : totalScore <= 20
                ? 'MODERATE'
                : 'HIGH';

        final result = {
          'assessmentDate': latestData['assessmentDate'],
          'likelihood': asdLikelihood,
        };
        return result;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Future<double> getTMTDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'TMT')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('TMT - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getPixelPuzzleDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Lego Game')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Logi Game - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getPuzzleParadiseDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Puzzle Paradise')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final totalGamesPlayed = querySnapshot.docs.length;

        QuerySnapshot totalGamesCompleted = await db
            .collection('level-result')
            .where('userId', isEqualTo: userId)
            .where('level', isEqualTo: 'Puzzle Paradise')
            .where('difficulty', isEqualTo: difficulty.name)
            .where('status', isEqualTo: 'Completed')
            .get();

        if (totalGamesCompleted.docs.isNotEmpty) {
          double successRate =
              totalGamesCompleted.docs.length / totalGamesPlayed * 100;

          log('Puzzle Paradise - ${difficulty.name} - ${double.parse(successRate.toStringAsFixed(2))}');
          return double.parse(successRate.toStringAsFixed(2));
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } catch (e) {
      log("Error $e");
      return 0;
    }
  }

  Future<double> getPictureSortingGameDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Picture Sorting Game')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Picture Sorting - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getFineMotorDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      double tmtData = await getTMTDataWithDifficulty(userId, difficulty);
      double pixelPuzzleData =
          await getPixelPuzzleDataWithDifficulty(userId, difficulty);
      double puzzleParadiseData =
          await getPuzzleParadiseDataWithDifficulty(userId, difficulty);
      double pictureSortingData =
          await getPictureSortingGameDataWithDifficulty(userId, difficulty);

      double sumOfData =
          tmtData + pixelPuzzleData + puzzleParadiseData + pictureSortingData;
      double average = sumOfData / 4;

      return double.parse(average.toStringAsFixed(2));
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getSimonSaysDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Simon Says')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['score']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Simon Says - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getMoodMagicDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'ERT')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('ERT - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getJungleJinglesDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Jungle Jingles')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['score']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Jungle Jingles - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getGazeMazeDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Gaze Maze')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Gaze Maze - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getSocialDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      double simonSaysData =
          await getSimonSaysDataWithDifficulty(userId, difficulty);
      double moodMagicData =
          await getMoodMagicDataWithDifficulty(userId, difficulty);
      double jungleJinglesData =
          await getJungleJinglesDataWithDifficulty(userId, difficulty);
      double gazeMazeData =
          await getGazeMazeDataWithDifficulty(userId, difficulty);

      double sumOfData =
          simonSaysData + moodMagicData + jungleJinglesData + gazeMazeData;
      double average = double.parse((sumOfData / 4).toStringAsFixed(2));
      return average;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getVoiceloonDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Voiceloon')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final totalGamesPlayed = querySnapshot.docs.length;

        QuerySnapshot totalGamesCompleted = await db
            .collection('level-result')
            .where('userId', isEqualTo: userId)
            .where('level', isEqualTo: 'Voiceloon')
            .where('difficulty', isEqualTo: difficulty.name)
            .where('status', isEqualTo: 'Completed')
            .get();

        if (totalGamesCompleted.docs.isNotEmpty) {
          double successRate =
              totalGamesCompleted.docs.length / totalGamesPlayed * 100;

          log('Voiceloon - ${difficulty.name} - ${double.parse(successRate.toStringAsFixed(2))}');
          return double.parse(successRate.toStringAsFixed(2));
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } catch (e) {
      log("Error $e");
      return 0;
    }
  }

  Future<double> getVerbalDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      double voiceloonData =
          await getVoiceloonDataWithDifficulty(userId, difficulty);

      double sumOfData = voiceloonData;
      double average = double.parse((sumOfData / 1).toStringAsFixed(2));
      return average;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getNumberCountingDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Number Counting')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<double> dataList = [];
        for (var item in querySnapshot.docs) {
          dataList.add(item['accuracy']);
        }

        // double mean = calculateMedian(dataList);
        double median = calculateMedian(dataList);

        log('Counting Game - ${difficulty.name} - ${double.parse(median.toStringAsFixed(2))}');
        return double.parse(median.toStringAsFixed(2));
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<double> getMathDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      double numberCountingData =
          await getNumberCountingDataWithDifficulty(userId, difficulty);

      double sumOfData = numberCountingData;
      double average = double.parse((sumOfData / 1).toStringAsFixed(2));
      return average;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getMazeMagicDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('level-result')
          .where('userId', isEqualTo: userId)
          .where('level', isEqualTo: 'Maze Magic')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final totalGamesPlayed = querySnapshot.docs.length;

        QuerySnapshot totalGamesCompleted = await db
            .collection('level-result')
            .where('userId', isEqualTo: userId)
            .where('level', isEqualTo: 'Maze Magic')
            .where('difficulty', isEqualTo: difficulty.name)
            .where('status', isEqualTo: 'Completed')
            .get();

        if (totalGamesCompleted.docs.isNotEmpty) {
          double successRate =
              totalGamesCompleted.docs.length / totalGamesPlayed * 100;

          log('Maze Magic - ${difficulty.name} - ${double.parse(successRate.toStringAsFixed(2))}');
          return double.parse(successRate.toStringAsFixed(2));
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } catch (e) {
      log("Error $e");
      return 0;
    }
  }

  Future<double> getCognitiveDataWithDifficulty(
      String? userId, Difficulty difficulty) async {
    try {
      double mazeMagicData =
          await getMazeMagicDataWithDifficulty(userId, difficulty);

      double sumOfData = mazeMagicData;
      double average = double.parse((sumOfData / 1).toStringAsFixed(2));
      return average;
    } catch (e) {
      return 0.0;
    }
  }

  // Graph data for details page
  Future<List<GraphData>> getPixelPuzzleGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Lego Game')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);

      final groupedData = <String, List<double>>{};

      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['accuracy'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getTMTGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'TMT')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      final groupedData = <String, List<double>>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['accuracy'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final averageAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: averageAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getPictureSortingGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Picture Sorting Game')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final groupedData = <String, List<double>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['accuracy'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getPuzzleParadiseGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Puzzle Paradise')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('Got no data');
        return [];
      }

      final groupedData = <String, List<Map<String, dynamic>>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);

      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';

        groupedData.putIfAbsent(yearMonthKey, () => []).add(data);
      }

      final List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;
      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';
        if (groupedData.containsKey(yearMonthKey)) {
          final dataForMonth = groupedData[yearMonthKey]!;
          final numberOfCompletedTasks = dataForMonth
              .where((item) => item['status'] == 'Completed')
              .length;
          final totalTasks = dataForMonth.length;
          final successRate = numberOfCompletedTasks / totalTasks * 100;

          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: successRate));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }

        // Move to the next month
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('error caught');
      return [];
    }
  }

  Future<List<GraphData>> getFineMotorGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final tmtGraphData = await getTMTGraphData(child, difficulty);
      final pixelPuzzleGraphData =
          await getPixelPuzzleGraphData(child, difficulty);
      final pictureSortingGraphData =
          await getPictureSortingGraphData(child, difficulty);
      final puzzleParadiseGraphData =
          await getPuzzleParadiseGraphData(child, difficulty);

      // Find the list with the most data among these four lists
      final result = listWithMostElements([
        tmtGraphData,
        pixelPuzzleGraphData,
        pictureSortingGraphData,
        puzzleParadiseGraphData,
      ]);

      int numberOfDataPoints = result.length;

      List<GraphData> graphDataList = [];
      for (int i = 0; i < numberOfDataPoints; i++) {
        int year = result[i].year;
        int month = result[i].month;

        // Safely get data or use 0 if index is out of range
        double tmtData = i < tmtGraphData.length ? tmtGraphData[i].data : 0;
        double pixelPuzzleData =
            i < pixelPuzzleGraphData.length ? pixelPuzzleGraphData[i].data : 0;
        double pictureSortingData = i < pictureSortingGraphData.length
            ? pictureSortingGraphData[i].data
            : 0;
        double puzzleParadiseData = i < puzzleParadiseGraphData.length
            ? puzzleParadiseGraphData[i].data
            : 0;

        double averageAccuracy = (tmtData +
                pixelPuzzleData +
                pictureSortingData +
                puzzleParadiseData) /
            4;

        graphDataList
            .add(GraphData(year: year, month: month, data: averageAccuracy));
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getSimonSaysGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Simon Says')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final groupedData = <String, List<double>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['score'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getMoodMagicGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'ERT')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final groupedData = <String, List<double>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['accuracy'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getGazeMazeGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Gaze Maze')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final groupedData = <String, List<double>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['accuracy'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getJungleJinglesGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Jungle Jingles')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final groupedData = <String, List<double>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['score'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getSocialGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final simonSaysGraphData = await getSimonSaysGraphData(child, difficulty);
      final moodMagicGraphData = await getMoodMagicGraphData(child, difficulty);
      final gazeMazeGraphData = await getGazeMazeGraphData(child, difficulty);
      final jungleJinglesGraphData =
          await getJungleJinglesGraphData(child, difficulty);

      final result = listWithMostElements([
        simonSaysGraphData,
        moodMagicGraphData,
        gazeMazeGraphData,
        jungleJinglesGraphData,
      ]);
      int numberOfDataPoints = result.length;

      List<GraphData> graphDataList = [];
      for (int i = 0; i < numberOfDataPoints; i++) {
        int year = result[i].year;
        int month = result[i].month;

        // Safely get data or use 0 if index is out of range
        double simonSaysData =
            i < simonSaysGraphData.length ? simonSaysGraphData[i].data : 0;
        double moodMagicData =
            i < moodMagicGraphData.length ? moodMagicGraphData[i].data : 0;
        double gazeMazeData =
            i < gazeMazeGraphData.length ? gazeMazeGraphData[i].data : 0;
        double jungleJinglesData = i < jungleJinglesGraphData.length
            ? jungleJinglesGraphData[i].data
            : 0;

        double averageAccuracy =
            (simonSaysData + moodMagicData + gazeMazeData + jungleJinglesData) /
                4;

        graphDataList
            .add(GraphData(year: year, month: month, data: averageAccuracy));
      }
      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getVoiceloonGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Voiceloon')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('Got no data');
        return [];
      }

      final groupedData = <String, List<Map<String, dynamic>>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);

      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';

        groupedData.putIfAbsent(yearMonthKey, () => []).add(data);
      }

      final List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;
      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';
        if (groupedData.containsKey(yearMonthKey)) {
          final dataForMonth = groupedData[yearMonthKey]!;
          final numberOfCompletedTasks = dataForMonth
              .where((item) => item['status'] == 'Completed')
              .length;
          final totalTasks = dataForMonth.length;
          final successRate = numberOfCompletedTasks / totalTasks * 100;

          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: successRate));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }

        // Move to the next month
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('error caught');
      return [];
    }
  }

  Future<List<GraphData>> getVerbalGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final voiceloonGraphData = await getVoiceloonGraphData(child, difficulty);

      // the length of all of these graph item will be the same, we can use tmtdata length to iterate through each data and find average
      final result = listWithMostElements([voiceloonGraphData]);
      int numberOfDataPoints = result.length;

      List<GraphData> graphDataList = [];
      for (int i = 0; i < numberOfDataPoints; i++) {
        int year = result[i].year;
        int month = result[i].month;

        log('${voiceloonGraphData[i].data}');

        final voiceloonData =
            i < voiceloonGraphData.length ? voiceloonGraphData[i].data : 0;

        double averageAccuracy = (voiceloonData) / 1;

        graphDataList
            .add(GraphData(year: year, month: month, data: averageAccuracy));
      }
      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getMazeMagicGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Maze Magic')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('Got no data');
        return [];
      }

      final groupedData = <String, List<Map<String, dynamic>>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);

      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';

        groupedData.putIfAbsent(yearMonthKey, () => []).add(data);
      }

      final List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;
      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';
        if (groupedData.containsKey(yearMonthKey)) {
          final dataForMonth = groupedData[yearMonthKey]!;
          final numberOfCompletedTasks = dataForMonth
              .where((item) => item['status'] == 'Completed')
              .length;
          final totalTasks = dataForMonth.length;
          final successRate = numberOfCompletedTasks / totalTasks * 100;

          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: successRate));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }

        // Move to the next month
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('error caught');
      return [];
    }
  }

  Future<List<GraphData>> getCognitiveGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final mazeMagicGraphData = await getMazeMagicGraphData(child, difficulty);

      // the length of all of these graph item will be the same, we can use tmtdata length to iterate through each data and find average
      final result = listWithMostElements([mazeMagicGraphData]);
      int numberOfDataPoints = result.length;

      List<GraphData> graphDataList = [];
      for (int i = 0; i < numberOfDataPoints; i++) {
        int year = result[i].year;
        int month = result[i].month;

        double mazeMagicData =
            i < mazeMagicGraphData.length ? mazeMagicGraphData[i].data : 0;
        double averageAccuracy = (mazeMagicData) / 1;

        graphDataList
            .add(GraphData(year: year, month: month, data: averageAccuracy));
      }
      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getNumberCountingGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level-result')
          .where('userId', isEqualTo: child!.childId)
          .where('level', isEqualTo: 'Number Counting')
          .where('difficulty', isEqualTo: difficulty.name)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final groupedData = <String, List<double>>{};

      final createdDate = child.createdDate;
      DateTime firstDate = DateTime(createdDate.year, createdDate.month);
      DateTime lastDate = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final sessionDate = (data['sessionId'] as Timestamp).toDate();
        final yearMonthKey = '${sessionDate.year}-${sessionDate.month}';
        final accuracy = (data['accuracy'] ?? 0.0).toDouble();

        groupedData.putIfAbsent(yearMonthKey, () => []).add(accuracy);
      }

      List<GraphData> graphDataList = [];

      DateTime currentDate = firstDate;

      while (currentDate.isBefore(lastDate) ||
          currentDate.isAtSameMomentAs(lastDate)) {
        final yearMonthKey = '${currentDate.year}-${currentDate.month}';

        if (groupedData.containsKey(yearMonthKey)) {
          final monthData = groupedData[yearMonthKey];
          final avgAccuracy =
              monthData!.reduce((a, b) => a + b) / monthData.length;
          graphDataList.add(GraphData(
              year: currentDate.year,
              month: currentDate.month,
              data: avgAccuracy));
        } else {
          graphDataList.add(GraphData(
              year: currentDate.year, month: currentDate.month, data: 0.0));
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<GraphData>> getMathGraphData(
      Child? child, Difficulty difficulty) async {
    try {
      final numberCountingGraphData =
          await getNumberCountingGraphData(child, difficulty);

      // the length of all of these graph item will be the same, we can use tmtdata length to iterate through each data and find average
      final result = listWithMostElements([numberCountingGraphData]);
      int numberOfDataPoints = result.length;

      List<GraphData> graphDataList = [];
      for (int i = 0; i < numberOfDataPoints; i++) {
        int year = result[i].year;
        int month = result[i].month;

        double numberCountingData = i < numberCountingGraphData.length
            ? numberCountingGraphData[i].data
            : 0;
        double averageAccuracy = (numberCountingData) / 1;

        graphDataList
            .add(GraphData(year: year, month: month, data: averageAccuracy));
      }
      return graphDataList;
    } catch (e) {
      log('$e');
      return [];
    }
  }

  // Future<void> deletePixelPuzzleData() async {
  //   try {
  //     QuerySnapshot querySnapshot = await db
  //         .collection('level-result')
  //         .where('level', isEqualTo: 'Lego Game')
  //         .where('difficulty', isEqualTo: 'easy')
  //         .get();

  //     for (var doc in querySnapshot.docs) {
  //       await doc.reference.delete();
  //     }
  //   } catch (e) {
  //     log('$e');
  //   }
  // }

  Future<List<Blog>> getBlogPosts() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      int selectedIndex = _prefs.getInt('language_index') ?? 0;

      final databaseName = selectedIndex == 0 ? 'blogs' : 'blogs-nepali';

      QuerySnapshot querySnapshot = await db.collection(databaseName).get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Blog> blogList = querySnapshot.docs
            .map(
              (item) => Blog(
                title: item['title'],
                subtitle: item['subtitle'],
                author: item['author'],
                date: (item['date'] as Timestamp).toDate(),
                content: item['content'],
                posterImgUrl: item['poster_img_url'],
                readTime: item['read_time'],
                tags: (item['tags'] as List<dynamic>).cast<String>(),
              ),
            )
            .toList();

        return blogList;
      } else {
        return [];
      }
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<Blog>> getWPBlogPosts() async {
    const ENGLISH_ID = 3205;
    const NEPALI_ID = 1731944;

    try {
      final _prefs = await SharedPreferences.getInstance();
      int selectedIndex = _prefs.getInt('language_index') ?? 0;

      final LANGUAGE_ID = selectedIndex == 0 ? ENGLISH_ID : NEPALI_ID;
      final response = await http.get(Uri.parse(
          'https://public-api.wordpress.com/wp/v2/sites/mindparkdotblog.wordpress.com/posts?categories=$LANGUAGE_ID'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is List) {
          List<Blog> blogList = data
              .map(
                (item) {
                  // Ensure class_list is a List<String>
                  List<String> classList =
                      (item['class_list'] as List<dynamic>?)?.cast<String>() ??
                          [];

                  String content = cleanText(item['content']['rendered']);
                  int wordCount = content.split(RegExp(r'\s+')).length;
                  log(content);
                  int readTime = (wordCount / 225).ceil(); // Assuming 225 wpm
                  String cleanContent =
                      removeFigureTag(item['content']['rendered']);

                  return Blog(
                    title: cleanText(item['title']['rendered']),
                    subtitle: cleanText(item['excerpt']['rendered']),
                    author: 'MindPark',
                    date: DateTime.parse(item['date']),
                    content: cleanContent,
                    posterImgUrl: item['jetpack_featured_media_url'] ?? '',
                    readTime: readTime,
                    tags: classList
                        .where((tag) => tag.startsWith('tag-'))
                        .map((tag) => tag.replaceFirst(
                            'tag-', '')) // Remove 'tag-' prefix
                        .toList(),
                  );
                },
              )
              .toList()
              .cast<Blog>();

          return blogList;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<StoryGroup>> getStoryCategories() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      int selectedIndex = _prefs.getInt('language_index') ?? 0;
      final response = await http.get(Uri.parse(
          'https://public-api.wordpress.com/wp/v2/sites/mindparkdotblog.wordpress.com/pages?parent=0'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is List) {
          List<StoryGroup> categoryList = data
              .map(
                (item) {
                  String content = item['content']['rendered'];
                  String imageUrl = getImageURL(content);
                  String nepaliText = getNepaliContent(content);

                  return StoryGroup(
                    id: item['id'],
                    image: imageUrl,
                    title: selectedIndex == 0
                        ? cleanText(item['title']['rendered'])
                        : nepaliText,
                  );
                },
              )
              .toList()
              .cast<StoryGroup>();

          return categoryList;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<List<Story>> getStoryPosts(int categoryId) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      int selectedIndex = _prefs.getInt('language_index') ?? 0;

      final response = await http.get(Uri.parse(
          'https://public-api.wordpress.com/wp/v2/sites/mindparkdotblog.wordpress.com/pages?parent=$categoryId&orderby=date&order=asc&per_page=20'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is List) {
          List<Story> storyList = data
              .map(
                (item) {
                  String content = item['content']['rendered'];
                  String englishTitle = getEnglishTitle(content);
                  String nepaliTitle = getNepaliTitle(content);
                  String nepaliContent = getNepaliContent(content);

                  String imageUrl = getImageURL(content);

                  return Story(
                    category: categoryId,
                    id: item['id'],
                    image: imageUrl,
                    title: selectedIndex == 0 ? englishTitle : nepaliTitle,
                    content: selectedIndex == 0
                        ? cleanText(item['title']['rendered'])
                        : nepaliContent,
                  );
                },
              )
              .toList()
              .cast<Story>();

          return storyList;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      log('$e');
      return [];
    }
  }

  Future<void> addOrUpdateSubscriptionData(
      SubscriptionModel subscriptionModel) async {
    try {
      // find existing subscription
      var existingSubscription = await db
          .collection('subscription')
          .where('userId', isEqualTo: subscriptionModel.userId)
          .get();

      if (existingSubscription.docs.isNotEmpty) {
        // if subscription exists
        String docId = existingSubscription.docs[0].id;
        var docData = existingSubscription.docs[0].data();

        // get the transaction history
        List<dynamic> currentTransactionHistory =
            docData['transactionHistory'] ?? [];

        // check if the new transaction exist in the history
        bool transactionExists = currentTransactionHistory.any((transaction) =>
            transaction['invoiceId'] ==
            subscriptionModel.transactionHistory![0].invoiceId);

        log('The transaction exists: $transactionExists');

        if (!transactionExists) {
          // If the transaction does not exist, add the new transaction
          currentTransactionHistory
              .add(subscriptionModel.transactionHistory![0].toMap());

          // Update the document with the new transaction history
          await db.collection('subscription').doc(docId).update({
            // Add any other fields you want to update like planPrice, status, etc.
            ...subscriptionModel.toMap(),
            'transactionHistory':
                currentTransactionHistory, // Update the other fields
          }).then((_) => log('Document updated with new transaction'));
        } else {
          log('Transaction already exists in the history.');
        }
      } else {
        await db.collection('subscription').add(subscriptionModel.toMap()).then(
            (DocumentReference doc) =>
                log('New subscription created with ID: ${doc.id}'));
      }
    } catch (e) {
      log('$e');
    }
  }

  Future<SubscriptionModel?> getSubscriptionData(String? email) async {
    try {
      final querySnapshot = await db
          .collection('subscription')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('No subscription found for user email: $email');
        return null;
      }

      List<Map<String, dynamic>> documents =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      if (documents.isEmpty) {
        log('No valid data found in query snapshot');
        return null;
      }
      log('${documents[0]}');
      final subscriptionModel = SubscriptionModel.fromMap(documents[0]);

      log('Subscription data loaded successfully');
      return subscriptionModel;
    } catch (e) {
      log('Error fetching subscription data: $e');
      rethrow;
    }
  }

  static final CloudStoreService _shared = CloudStoreService._sharedInstance();
  CloudStoreService._sharedInstance();
  factory CloudStoreService() => _shared;
}

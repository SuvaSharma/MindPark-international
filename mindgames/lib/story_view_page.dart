import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/story.dart';
import 'package:mindgames/widgets/custom_story_widget.dart';
import 'package:transparent_image/transparent_image.dart';

class StoryViewPage extends StatefulWidget {
  const StoryViewPage({required this.categoryId, super.key});
  final int categoryId;

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Future<List<Story>> _storyFuture; // Store the future in a variable
  CloudStoreService cloudStoreService = CloudStoreService();

  @override
  void initState() {
    super.initState();

    // Initialize the Future here
    _storyFuture = cloudStoreService.getStoryPosts(widget.categoryId);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playAnimationForNewStory() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Story>>(
          future: _storyFuture, // Use the state variable here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: SizedBox(
                height: screenWidth * 0.09,
                width: screenWidth * 0.09,
                child: CircularProgressIndicator(
                    backgroundColor: Colors.black.withOpacity(0.2),
                    color: const Color(0xFF309092)),
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('No stories available.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                      )));
            }

            final stories = snapshot.data!;
            log('printing the stories');
            log('$stories');

            return CustomStory(
              momentCount: stories.length,
              momentBuilder: (context, index) {
                _playAnimationForNewStory();
                final story = stories[index];

                return Stack(
                  children: [
                    FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: story.image,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  textAlign: TextAlign.center,
                                  story.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  color: Colors.white,
                                  thickness: 2,
                                  indent: screenWidth * 0.35,
                                  endIndent: screenWidth * 0.35,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  story.content,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              momentDurationGetter: (index) => const Duration(seconds: 10),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/story_group.dart';
import 'package:mindgames/story_view_page.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';

class ParentsPortalPage extends StatefulWidget {
  const ParentsPortalPage({super.key});

  @override
  State<ParentsPortalPage> createState() => _ParentsPortalPageState();
}

class _ParentsPortalPageState extends State<ParentsPortalPage> {
  bool startAnimation = false;
  CloudStoreService cloudStoreService = CloudStoreService();
  late Future<List<StoryGroup>> storyCategoriesFuture;

  @override
  void initState() {
    super.initState();
    storyCategoriesFuture = fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        startAnimation = true;
      });
    });
  }

  Future<List<StoryGroup>> fetchData() async {
    return await cloudStoreService.getStoryCategories();
  }

  Future<void> _refreshData() async {
    setState(() {
      storyCategoriesFuture = fetchData(); // Refresh the future
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainWrapper()));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData, // Trigger the refresh
            color: const Color(0xFF309092),
            child: FutureBuilder<List<StoryGroup>>(
              future: storyCategoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: SizedBox(
                    height: screenSize.width * 0.09,
                    width: screenSize.width * 0.09,
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.black.withOpacity(0.2),
                        color: const Color(0xFF309092)),
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load content'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No content available'));
                } else {
                  List<StoryGroup> stories = snapshot.data!;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.10),
                            child: Text(
                              'Help Your Child With Day-To-Day-Life!'.tr,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.055,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF309092),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: stories.length,
                          itemBuilder: (context, index) {
                            return _buildItem(
                                stories[index], screenSize, index);
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(StoryGroup story, Size screenSize, int index) {
    return GestureDetector(
      onTap: () => _openStoryView(story.id),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.01,
          horizontal: screenSize.width * 0.05,
        ),
        child: AnimatedContainer(
          height: screenSize.height * 0.1,
          width: screenSize.width,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300 + (index * 100)),
          transform: Matrix4.translationValues(
              startAnimation ? 0 : screenSize.width, 0, 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF37B197), Color(0xFF309092)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
                child: Text(
                  "${convertToNepaliNumbers((index + 1).toString())}.",
                  style: TextStyle(
                    fontSize: screenSize.height * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  story.title.tr,
                  style: TextStyle(
                    fontSize: screenSize.height * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 3,
                  softWrap: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: screenSize.width * 0.02),
                child: CircleAvatar(
                  radius: screenSize.width * 0.09,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(story.image),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStoryView(int categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewPage(categoryId: categoryId),
      ),
    );
  }
}

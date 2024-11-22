import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/blog.dart';
import 'package:mindgames/post_page.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:transparent_image/transparent_image.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late Future<List<Blog>> _blogFuture;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  void _loadBlogs() {
    _blogFuture = cloudStoreService.getWPBlogPosts();
  }

  Future<void> _refreshContent() async {
    setState(() {
      _loadBlogs();
    });
    await _blogFuture;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/levelscreen.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF309092),
              onRefresh: _refreshContent,
              child: FutureBuilder<List<Blog>>(
                future: _blogFuture,
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
                    return const Center(child: Text('Failed to load content'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No content available'));
                  } else {
                    List<Blog> blogData = snapshot.data!;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEWS'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: blogData.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PostPage(blog: blogData[index]),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 51, 106, 134),
                                        width: 1,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: screenHeight * 0.02),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04,
                                        vertical: screenWidth * 0.02,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: blogData[index]
                                                    .tags!
                                                    .indexed
                                                    .map(((int, String) item) {
                                                  final (_, text) = item;
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        right: screenHeight *
                                                            0.005),
                                                    decoration: BoxDecoration(
                                                      color: const Color
                                                              .fromARGB(
                                                              255, 51, 106, 134)
                                                          .withOpacity(0.87),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              screenWidth *
                                                                  0.025),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            screenWidth * 0.015,
                                                        vertical:
                                                            screenWidth * 0.01,
                                                      ),
                                                      child: Text(
                                                        text.toUpperCase(),
                                                        style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.03,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                              Text(
                                                DateFormat('d MMM, yyyy')
                                                    .format(
                                                        blogData[index].date),
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  color: const Color.fromARGB(
                                                          255, 51, 106, 134)
                                                      .withOpacity(0.87),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      blogData[index].title,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.05,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      blogData[index].subtitle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.02),
                                              Hero(
                                                tag: blogData[index]
                                                    .posterImgUrl,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              51,
                                                              106,
                                                              134),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            screenWidth * 0.02),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            screenWidth * 0.02),
                                                    child: FadeInImage
                                                        .memoryNetwork(
                                                      height:
                                                          screenWidth * 0.25,
                                                      width: screenWidth * 0.25,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          kTransparentImage,
                                                      image: blogData[index]
                                                          .posterImgUrl,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Row(
                                            children: [
                                              Text(
                                                '{min} Min Read'
                                                    .tr
                                                    .replaceFirst(
                                                        '{min}',
                                                        convertToNepaliNumbers(
                                                            '${blogData[index].author} • ${blogData[index].readTime}'))
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  color: const Color.fromARGB(
                                                          255, 51, 106, 134)
                                                      .withOpacity(0.87),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

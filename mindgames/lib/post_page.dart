import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindgames/models/blog.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PostPage extends StatefulWidget {
  final Blog blog;
  const PostPage({
    required this.blog,
    super.key,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: widget.blog.tags!.indexed
                                .map(((int, String) item) {
                              final (_, text) = item;
                              return Container(
                                margin: EdgeInsets.only(
                                    right: screenHeight * 0.005),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.025),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.015,
                                    vertical: screenWidth * 0.01,
                                  ),
                                  child: Text(text.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.white,
                                      )),
                                ),
                              );
                            }).toList(),
                          ),
                          Text(
                            '{min} Min Read'
                                .tr
                                .replaceFirst(
                                    '{min}',
                                    convertToNepaliNumbers(
                                        '${widget.blog.readTime}'))
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(widget.blog.title,
                          style: TextStyle(
                            height: 1.2,
                            fontSize: screenWidth * 0.070,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          )),
                      SizedBox(height: screenHeight * 0.01),
                      Text(widget.blog.subtitle,
                          style: TextStyle(
                            height: 1.2,
                            fontSize: screenWidth * 0.05,
                            color: Colors.black54,
                          )),
                      SizedBox(height: screenHeight * 0.02),
                      Hero(
                        tag: widget.blog.posterImgUrl,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.05)),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.05),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: widget.blog.posterImgUrl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(widget.blog.author.toUpperCase(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.black54,
                          )),
                      Text(DateFormat('d MMMM, yyyy').format(widget.blog.date),
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.black54,
                          )),
                      const Divider(),
                      SizedBox(height: screenHeight * 0.02),
                      HtmlWidget(
                        widget.blog.content,
                        customWidgetBuilder: (element) {
                          if (element.localName == 'img') {
                            final link = element.attributes['data-orig-file'];
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.05)),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.05),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: link!,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        customStylesBuilder: (element) {
                          if (element.localName == 'h2') {
                            return {
                              'color': 'blue',
                              'font-weight': 'bold',
                            };
                          }
                          if (element.localName == 'h3') {
                            return {
                              'color': 'rgba(48, 144, 146, 1)',
                            };
                          }
                          if (element.localName == 'a') {
                            if (int.tryParse(element.text) != null) {
                              return {
                                'color': 'white',
                                'text-decoration': 'none',
                                'font-size': '${screenWidth * 0.03}px',
                                'border-radius': '${screenWidth * 0.05}px',
                                'background-color': 'rgba(48, 144, 146, 0.9)',
                                'width': '${screenWidth * 0.04}px',
                                'text-align': 'center'
                              };
                            }

                            return {
                              'color': 'rgba(48, 144, 146, 0.9)',
                              'text-decoration': 'none',
                            };
                          }
                          if (element.localName == 'img') {
                            print(element.attributes);
                            return {
                              'border': '1px solid rgba(0, 0, 0, 0.55)',
                              'border-radius': '${screenWidth * 0.05}px',
                            };
                          }

                          return null;
                        },
                        onTapUrl: (url) {
                          launchUrl(Uri.parse(url));
                          return true;
                        },
                        enableCaching: true,
                        textStyle: TextStyle(
                          fontSize: screenWidth * 0.048,
                          height: 1.4,
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

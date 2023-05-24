import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alphabetlearning/ARViewPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_to_speech/text_to_speech.dart';

class alphabet extends StatefulWidget {

  @override
  _alphabetState createState() => _alphabetState();
}
class ImageData {
  final String imageUrl;
  final String modelUrl;
  final String imageName;
  final String description;

  ImageData(this.imageUrl, this.modelUrl, this.imageName, this.description);
}
class _alphabetState extends State<alphabet> {

  int currentIndex = 0;
  final ScrollController _listController = ScrollController();
  final List<String> alphabetList = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];
  TextToSpeech tts = TextToSpeech();
  @override
  void initState() {
    super.initState();
    initializeFirebase();
    fetchImageData(alphabetList[currentIndex]);
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }


  Future<ImageData> fetchImageData(String alphabet) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('alphabet')
          .doc(alphabet)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['imageUrl'] != null && data['modelUrl'] != null && data['name'] != null && data['description'] != null) {
          final imageUrl = data['imageUrl'].toString();
          final modelUrl = data['modelUrl'].toString();
          final imageName = data['name'].toString();
          final description = data['description'].toString();
          return ImageData(imageUrl, modelUrl, imageName, description);
        }
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }

    return ImageData('', '', '', '');
  }

  final PageController _pageController = PageController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void goToPreviousAlphabet() {
    setState(() {
      currentIndex = currentIndex > 0 ? currentIndex - 1 : 0;
    });
  }

  void goToNextAlphabet() {
    setState(() {
      currentIndex = currentIndex < alphabetList.length - 1 ? currentIndex + 1 : alphabetList.length - 1;
    });
  }

  void _scrollToSelectedIndex(int index) {
    final double itemWidth = 76.0; // Width of each item in the list
    final double screenWidth = MediaQuery.of(context).size.width;
    final int visibleItemCount = (screenWidth / itemWidth).floor();

    final double selectedItemOffset = index * itemWidth;
    final double halfVisibleItemsOffset = (visibleItemCount / 2) * itemWidth;
    final double scrollOffset = selectedItemOffset - halfVisibleItemsOffset;

    _pageController.jumpToPage(index);
    _listController.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alphabets'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _listController,
              physics: BouncingScrollPhysics(),
              itemCount: alphabetList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                      _pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _scrollToSelectedIndex(index);
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentIndex == index ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        alphabetList[index],
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity != 0) {
                  if (details.primaryVelocity! > 0) {
                    goToPreviousAlphabet();
                  } else {
                    goToNextAlphabet();
                  }
                  _scrollToSelectedIndex(currentIndex);
                }
              },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                  _scrollToSelectedIndex(currentIndex);
                });
              },
              itemCount: alphabetList.length,
              itemBuilder: (context, index) {
                final alphabet = alphabetList[index];
                return FutureBuilder<ImageData>(
                  future: fetchImageData(alphabet),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error fetching image data'));
                    } else if (snapshot.hasData) {
                      final imageUrl = snapshot.data!.imageUrl;
                      final modelUrl = snapshot.data!.modelUrl;
                      final imageName = snapshot.data!.imageName;
                      final description = snapshot.data!.description;
                      print('>>>>>>> $imageUrl, >>>>>> $modelUrl');
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(
                              alphabet,
                              style: TextStyle(fontSize: 40),
                            ),
                            SizedBox(height: 20),
                            Image.network(
                              imageUrl,
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  imageName,
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(height: 20),
                                IconButton.outlined(
                                  icon: const Icon(Icons.volume_up_outlined),
                                  onPressed: () {
                                    tts.speak(description);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ARViewPage(firebaseUrl: modelUrl)),);
                              },
                              child: Text('View in AR'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            ),
          ),
          ),
        ],
      ),
    );
  }
}


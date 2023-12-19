import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:alphabetlearning/ARViewPage.dart';
import 'package:text_to_speech/text_to_speech.dart';

class AnimalPage extends StatefulWidget {
  @override
  _AnimalPageState createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  late List<Animal> _animals = [];
  int _currentIndex = 0;
  final double _itemWidth = 80;
  final double _itemSpacing = 8;
  final double _selectedItemScale = 1.2;
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final ScrollController _listScrollController = ScrollController();
  final double _listScrollOffset = 100.0;

  @override
  void initState() {
    super.initState();
    fetchAnimals();
  }

  Future<void> fetchAnimals() async {
    try {
      final animalsSnapshot = await FirebaseFirestore.instance.collection('animals').get();
      final animalsData = animalsSnapshot.docs.map((doc) => doc.data()).toList();
      final animalsList = animalsData
          .map((data) => Animal(
        name: data['name'],
        imageUrl: data['imageUrl'],
        modelUrl: data['modelUrl'],
        description: data['description'],
      ))
          .toList();

      setState(() {
        _animals = animalsList;
      });
    } catch (e) {
      print('Error fetching animals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animals.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Animal Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _listScrollController,
              itemCount: _animals.length,
              itemBuilder: (context, index) {
                final animal = _animals[index];
                final isSelected = index == _currentIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      _pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                    _scrollToSelectedIndex(index);
                  },
                  child: Container(
                    width: _itemWidth,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 16 : _itemSpacing,
                      right: index == _animals.length - 1 ? 16 : 0,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: isSelected ? _itemWidth * 0.2 * _selectedItemScale : _itemWidth * 0.2,
                          backgroundImage: NetworkImage(animal.imageUrl),
                          backgroundColor: Colors.blueGrey.shade100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          animal.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _animals.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _scrollToSelectedIndex(index);
              },
              itemBuilder: (context, index) {
                final animal = _animals[index];
                final isSelected = index == _currentIndex;
                final cardMargin = isSelected ? EdgeInsets.only(bottom: 20.0) : EdgeInsets.zero;

                return Padding(
                  padding: cardMargin,
                  child: Align(
                    alignment: isSelected ? Alignment.center : Alignment.bottomCenter,
                    child: AnimalCard(animal: animal),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedIndex(int index) {
    final itemOffset = index * (_itemWidth + _itemSpacing);
    final scrollOffset = itemOffset - _listScrollOffset;
    _listScrollController.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class AnimalCard extends StatelessWidget {
  final Animal animal;
  AnimalCard({required this.animal});

  TextToSpeech tts = TextToSpeech();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            animal.name,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Expanded(
            child: Image.network(
              animal.imageUrl,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                animal.description,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.volume_up_outlined),
                onPressed: () {
                  tts.speak(animal.description);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ARViewPage(firebaseUrl: animal.modelUrl),
                    ),
                  );
                },
                child: Text('View in AR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Animal {
  final String name;
  final String imageUrl;
  final String modelUrl;
  final String description;

  Animal({
    required this.name,
    required this.imageUrl,
    required this.modelUrl,
    required this.description,
  });
}

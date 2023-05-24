import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewPage extends StatefulWidget {
  final String firebaseUrl;

  ARViewPage({required this.firebaseUrl});

  @override
  _ARViewPageState createState() => _ARViewPageState();
}

class _ARViewPageState extends State<ARViewPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = false;

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('AR View'),
        ),
        body: Stack(
          children: [
            ModelViewer(
              src: widget.firebaseUrl,
              alt: "letter",
              ar: true,
              autoRotate: true,
              cameraControls: true,
            ),
          ],
        ),
      );
    }
  }


}




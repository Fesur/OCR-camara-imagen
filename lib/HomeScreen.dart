import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'RecognizerScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onCapturePressed() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return RecognizerScreen(File(image.path));
      }));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 50, bottom: 10, left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMainContent(),
            _buildBottomCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Card(
        color: Colors.black,
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_cameraController);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Card(
      color: Colors.blueAccent,
      child: Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomCardButton(Icons.camera, 50, _onCapturePressed),
            _buildBottomCardButton(Icons.image_outlined, 35, () async {
              XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);
              if (xfile != null) {
                File image = File(xfile.path);
                Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                  return RecognizerScreen(image);
                }));
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCardButton(IconData icon, double size, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageLabelingPage extends StatefulWidget {
  @override
  _ImageLabelingPageState createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  File? _image; 
  List<String> _labels = []; 
  final ImagePicker _picker = ImagePicker(); // Image picker 

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _labels = []; 
      });
      _detectLabels(); 
    }
  }

  // Method to detect labels using Google ML Kit
  Future<void> _detectLabels() async {
    if (_image == null) return;

    try {
      final InputImage inputImage = InputImage.fromFile(_image!);
      final ImageLabeler labeler = ImageLabeler(options: ImageLabelerOptions());
      final List<ImageLabel> labels = await labeler.processImage(inputImage);

      setState(() {
        _labels = labels
            .map((label) => '${label.label} (${label.confidence.toStringAsFixed(2)})')
            .toList();
      });

      labeler.close();
    } catch (e) {
      setState(() {
        _labels = ['Error processing the image: $e'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Capture Image'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Select from Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_labels.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Labels:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ..._labels.map((label) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(label),
                      )),
                ],
              ),
            if (_labels.isEmpty && _image != null)
              Text(
                'No labels detected.',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Bodycontent extends StatefulWidget {
  const Bodycontent({super.key});

  @override
  State<Bodycontent> createState() => _BodycontentState();
}

class _BodycontentState extends State<Bodycontent> {
  File? selectedImages;
  var pred = null;

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      setState(() {
        selectedImages = File(returnedImage.path);
        _uploadImage();
      });
    }
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage != null) {
      setState(() {
        selectedImages = File(returnedImage.path);
        _uploadImage();
      });
    }
  }

  Future<void> _uploadImage() async {
    if (selectedImages == null) {
      return;
    }

    final uri = Uri.parse("${dotenv.env['HOST_IP']}predict");
    final request = http.MultipartRequest('POST', uri);

    request.files
        .add(await http.MultipartFile.fromPath('file', selectedImages!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseString);
      final prediction = jsonResponse['prediction'];
      print('Prediction: $prediction');
      // Do something with the prediction, e.g., display it
      setState(() {
        if (prediction == 0) {
          setState(() {
            pred = 'Hotdog';
          });
        } else {
          setState(() {
            pred = 'Not Hotdog';
          });
        }
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          selectedImages != null
              ? Column(
                  children: [
                    Image.file(
                      selectedImages!,
                      height: 200, // Adjust the size as needed
                      width: 200, // Adjust the size as needed
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    pred == null
                        ? CircularProgressIndicator()
                        : Text(
                            pred,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 30),
                          ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedImages = null;
                            pred = null;
                          });
                        },
                        child: Text('Clear selection'))
                  ],
                )
              : const Text('Select an Image'),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: Text('Open Gallery'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: Text('Open Camera'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

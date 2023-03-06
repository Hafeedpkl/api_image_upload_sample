import 'dart:core';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  File? image;
  final _picker = ImagePicker();
  bool showSpinner = false;
  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
    } else {
      print('no Image Selected');
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showSpinner = true;
    });
    var stream = http.ByteStream(image!.openRead());
    stream.cast();
    var length = await image!.length();
    var uri = Uri.parse('https://fakestoreapi.com/products');
    var request = http.MultipartRequest('POST', uri);
    request.fields['title'] = 'Static title';
    var multiPort = http.MultipartFile('image', stream, length);
    request.files.add(multiPort);
    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });
      print('image uploaded');
    } else {
      setState(() {
        showSpinner = false;
      });
      print('falure');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => getImage(),
                child: Container(
                    child: image == null
                        ? Center(
                            child: Text('Pick Image'),
                          )
                        : Container(
                            child: Center(
                              child: Image.file(
                                File(image!.path).absolute,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
              ),
              SizedBox(
                height: 150,
              ),
              GestureDetector(
                onTap: uploadImage,
                child: Container(
                  color: Colors.green,
                  child: Center(child: Text('upload')),
                  height: 50,
                  width: 200,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // uploadImage(String title, File file) async {
  //   var request = http.MultipartRequest(
  //       "POST", Uri.parse("https://api.imgur.com/3/image"));
  //   request.fields['title'] = "dummyImage";
  //   request.headers['Authorization'] = "apikey";
  //   var picture = http.MultipartFile.fromBytes(
  //       'images',
  //       (await rootBundle.load('assets/images/20220904_105549.png'))
  //           .buffer
  //           .asUint16List(),
  //       filename: 'testimage.png');
  //   request.files.add(picture);
  //   var response = await request.send();
  //   var responseData = await response.stream.toBytes();
  //   var result = String.fromCharCodes(responseData);
  //   print(result);
  // }
}

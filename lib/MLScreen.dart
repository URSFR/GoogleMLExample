import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'  as ImageL;
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'as ImageO;

import 'package:image_picker/image_picker.dart';

class MLScreen extends StatefulWidget {
  const MLScreen({Key? key}) : super(key: key);

  @override
  State<MLScreen> createState() => _MLScreenState();
}

class _MLScreenState extends State<MLScreen> {
  bool scanning = false;
  final mode = ImageO.DetectionMode.single;
  XFile? imageFile;

  String resultText = "";
  String detectType = "Text";
  List detectList = [
    "Text",
    "Text V2",
    "Face",
    "Object",
    "Label",
    "Pose",
  ];

  FaceDetector detector = GoogleMlKit.vision.faceDetector(
    const FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ),
  );

  final optionsPose = PoseDetectorOptions(model: PoseDetectionModel.base,mode: PoseDetectionMode.singleImage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Machine Learning Example"),
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton2<String>(
                        isExpanded: true,
                        hint: Row(
                          children: const [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Colors.yellow,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                'Detection Type',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        iconSize: 14,
                        iconEnabledColor: Colors.blue,
                        iconDisabledColor: Colors.white,
                        buttonHeight: 50,
                        buttonWidth: 180,
                        buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                        buttonDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black26,
                          ),
                          color: Colors.white,
                        ),
                        buttonElevation: 2,
                        itemHeight: 40,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownWidth: 200,
                        dropdownPadding: null,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(width: 2,color: Colors.black),
                          color: Colors.white,
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                        offset: const Offset(-20, 0),
                        value: detectType,
                        focusColor: Colors.blue,
                        items: detectList.map((appliance) => DropdownMenuItem<String>(
                          value: appliance,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(appliance,style: TextStyle(fontSize: 14),)
                          ),
                        )).toList(),onChanged: (item){
                      setState((){
                        detectType=item!;

                      });
                    }),
                    SizedBox(height: 15,),
                    if (scanning) const CircularProgressIndicator(),
                    if (!scanning && imageFile == null)
                      Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300]!,
                      ),
                    if (imageFile != null) Image.file(File(imageFile!.path)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () {
                                getImage(ImageSource.gallery);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 30,
                                    ),
                                    Text(
                                      "Gallery",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[600]),
                                    )
                                  ],
                                ),
                              ),
                            )),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () {
                                getImage(ImageSource.camera);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                    ),
                                    Text(
                                      "Camera",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[600]),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                        resultText,
                        style: detectType=="Text V2"?GoogleFonts.zcoolXiaoWei(fontSize: 20):GoogleFonts.anton(fontSize: 20),
                      ),
                    )
                  ],
                )),
          )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        scanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      scanning = false;
      imageFile = null;
      resultText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    if(detectType=="Text"){
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = GoogleMlKit.vision.textDetector();
      RecognisedText recognisedText = await textDetector.processImage(inputImage);
      await textDetector.close();
      resultText = "";
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          resultText = resultText + line.text + "\n";
        }
      }
      scanning = false;
      setState(() {});
    }
    else if(detectType=="Text V2"){
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = GoogleMlKit.vision.textDetectorV2();
      RecognisedText recognisedText = await textDetector.processImage(inputImage);
      await textDetector.close();
      resultText = "";
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          resultText = resultText + line.text + "\n";
        }
      }
      scanning = false;
      setState(() {});
    }
    else if(detectType=="Face"){
      final inputImage = InputImage.fromFilePath(image.path);
      List<Face> faces = await detector.processImage(inputImage);

      if (faces.length > 0 && faces[0].smilingProbability != null) {
        double? prob = faces[0].smilingProbability;

        if (prob! > 0.8) {
          setState(() {
            scanning = false;
            resultText = "Happy";
          });
        } else if (prob > 0.3 && prob < 0.8) {
          setState(() {
            resultText = "Normal";
            scanning = false;

          });
        } else if (prob > 0.06152385 && prob < 0.3) {
          setState(() {
            resultText = "Sad";
            scanning = false;

          });
        } else {
          setState(() {
            resultText = "Angry";
            scanning = false;

          });
        }
    }
      else{
        setState((){
          resultText = "ERROR DETECTING THE FACE";
          scanning = false;
        });

      }

  }
    else if(detectType == "Label"){
      final inputImage = ImageL.InputImage.fromFilePath(image.path);
      ImageL.ImageLabeler imageLabeler = ImageL.ImageLabeler(options: ImageL.ImageLabelerOptions(confidenceThreshold: 0.75));
      List<ImageL.ImageLabel> labels = await imageLabeler.processImage(inputImage);
      StringBuffer sb = StringBuffer();
      for (ImageL.ImageLabel imgLabel in labels) {
        String lblText = imgLabel.label;
        double confidence = imgLabel.confidence;
        sb.write(lblText);
        sb.write(" : ");
        sb.write((confidence * 100).toStringAsFixed(2));
        sb.write("%\n");
      }
      imageLabeler.close();
      resultText = sb.toString();
      scanning = false;
      setState(() {});
    }
    else if(detectType == "Object"){
      final options = ImageO.ObjectDetectorOptions(
        mode: mode,
        classifyObjects: true,
        multipleObjects: true,
      );

      final objectDetector = ImageO.ObjectDetector(options: options);
      final inputImage = ImageO.InputImage.fromFilePath(image.path);

      final List<ImageO.DetectedObject> objects = await objectDetector.processImage(inputImage);
      StringBuffer sb = StringBuffer();

      for(ImageO.DetectedObject detectedObject in objects){
        final rect = detectedObject.boundingBox;
        final trackingId = detectedObject.trackingId;

        for(ImageO.Label label in detectedObject.labels){
          String lblText = label.text;
          double confidence = label.confidence;
          sb.write(lblText);
          sb.write(" : ");
          sb.write((confidence * 100).toStringAsFixed(2));
          sb.write("%\n");


        }

      }
      objectDetector.close();
      resultText = sb.toString();
      scanning = false;
      setState(() {});
    }
    else if(detectType=="Pose"){
      final poseDetector = PoseDetector(optionsPose);

      final inputImage = InputImage.fromFilePath(image.path);

      final List<Pose> poses = await poseDetector.processImage(inputImage);

      for (Pose pose in poses) {
        // to access all landmarks
        pose.landmarks.forEach((_, landmark) {
          final type = landmark.type;
          final x = landmark.x;
          final y = landmark.y;
          resultText="${landmark.type.name} ${landmark.x} ${landmark.y}";
          scanning=false;
          poseDetector.close();

          setState((){

          });
        });

            // to access specific landmarks
            final landmark = pose.landmarks[PoseLandmarkType.leftAnkle];

        }

    }
}
}
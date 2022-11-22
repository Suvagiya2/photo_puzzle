
import 'dart:io';
import 'dart:typed_data';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;

void main() {
  runApp(MaterialApp(home: demo()));
}

class demo extends StatefulWidget {
  const demo({Key? key}) : super(key: key);

  @override
  State<demo> createState() => _demoState();
}

class _demoState extends State<demo> {
  double divide = 3;

  List<Image> splitImage(List<int> input) {
    // convert image to image from image package
    imglib.Image? image = imglib.decodeImage(input);

    int x = 0, y = 0;
    int width = (image!.width / divide).round();
    int height = (image.height / divide).round();

    // split image to parts
    List<imglib.Image> parts = [];
    for (int i = 0; i < divide; i++) {
      for (int j = 0; j < divide; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }
    // convert image from image package to Image Widget to display
    List<Image> output = [];
    for (var img in parts) {
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }
    return output;
  }



  Future<File> getImageFileFromAssets(String path) async {
    final byteData=await rootBundle.load('$path');
    var directory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)+"/myapp";
    Directory d=Directory(directory);
    if(!await d.exists())
      {
        await d.create();
      }
    final file=File('${d.path}/img.jpeg');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes,byteData.lengthInBytes));
    return file;
  }

  List<Image> imglist=[];
  List<Image> tempimglist=[];
  List<bool> t=List.filled(9, false);

  create() async {
  File f=await getImageFileFromAssets('images/photo.jpg');
  print(f.path);
  List<int> intimglist=await f.readAsBytes();
  imglist=await splitImage(intimglist);
  tempimglist.addAll(imglist);

  imglist.shuffle();
  setState((){});
  }

  @override
  void initState() {
    create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("new project"),
      ),
      body: Column(
        children: [
          Container(
            height: 400,
            child: GridView.builder(itemCount: imglist.length,itemBuilder: (context, index) {
              return DragTarget(onAccept: (int data) {
                setState(() {
                  Image temp;
                  temp=imglist[data];
                  imglist[data]=imglist[index];
                  imglist[index]=temp;
                });
                if(listEquals(tempimglist, imglist))
                  {
                    showDialog(builder: (context) {
                      return AlertDialog(
                        title: Text("you are win"),
                      );
                    },context: context);
                  }
              },builder: (context, candidateData, rejectedData) {
                  return Draggable(onDragEnd: (details) {
                    setState(() {
                      t=List.filled(9, false);
                    });
                  },
                    onDraggableCanceled: (velocity, offset) {
                    setState(() {
                      t=List.filled(9, false);
                    });
                  },
                    onDragStarted: () {
                      setState(() {
                        for(int i=0;i<t.length;i++)
                          {
                            if(index!=i)
                              {
                                t[i]=true;
                              }
                          }
                        print(t);
                      });
                    },
                    child: Container(
                    child: imglist[index],
                  ),
                    data:index,
                    feedback: Container(
                      height: 117,
                      width: 117,
                      child: imglist[index],
                    ),
                  );
              },);
            },gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisSpacing: 2,mainAxisSpacing: 2,crossAxisCount: divide.toInt())),
          ),
          InkWell(
            onTap:() {
              setState(() {
                imglist.shuffle();
              });
            },
            child: Container(
              height: 30,
              width: 80,
              color: Colors.black,
              child: Center(child: Text("Refresh" ,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
            ),
          )
        ],
      ),
    );
  }
}

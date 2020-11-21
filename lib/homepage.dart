import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photofilters/photofilters.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as imageLib;
import 'package:share/share.dart';




File inputImage;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fileName;
  List<Filter> filters = presetFiltersList;
  List<String> imagePaths = [];
  final picker = ImagePicker();
  bool wannaSave = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
           Container(
            
            width: 500,
            height: 700,          
            child: inputImage == null ?
            Image.asset("lib/assets/Pick.gif") :
            Image.file(inputImage),
          ),
          ]),
      ),
      floatingActionButton: 
      inputImage == null ?
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton.extended(
            label: Text("Camera"),
            heroTag: 'cambtn',
            onPressed: () {
              takeInput("cam");
//              Navigator.pushNamed(context, '/edit');
            },
            icon: Icon(Icons.camera),
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            label: Text("Gallery"),
            heroTag: 'galrybtn',
            onPressed: (){
              takeInput("gallery");
//              Navigator.pushNamed(context, '/edit');
            },
            icon: Icon(Icons.photo_library),
          )
        ],
      )
      :
      wannaSave == false ?
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [          
          FloatingActionButton.extended(
            label: Text("Cancel"),
            heroTag: 'backbtn',
            onPressed: (){
              setState(() {
                inputImage = null;
              });
              Navigator.pushNamed(context, '/');
            },
            icon: Icon(Icons.cancel),
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            label: Text("Edit"),
            heroTag: 'editbtn',
            icon: Icon(Icons.edit),
            onPressed: () {
              filter(context);

  }
          )
        ],
      )
      :
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            label: Text("Edit"),
            heroTag: 'editbtn2',
            icon: Icon(Icons.edit),
            onPressed: (){
              filter(context);
            },
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            label: Text("Save"),
            heroTag: 'savebtn',
            icon: Icon(Icons.save_alt),
            onPressed: (){
              saveImage();
              showMyDialog(context);
            },
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            label: Text("Share"),
            heroTag: 'sharebtn',
            icon: Icon(Icons.share),
            onPressed: (){
              imagePaths.add(inputImage.path);
              shareImage(context);
            },
          ),
        ],
      )
    );
  }

  takeInput(String mode) async{
    if (mode == "cam"){
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      fileName = basename(pickedFile.path);
      setState(() {
      inputImage = File(pickedFile.path);
      });
    }
    if (mode == "gallery") {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      fileName = basename(pickedFile.path);
      
      setState(() {
      inputImage = File(pickedFile.path);
    });
      
  }
}

  filter(context) async{
    var image = imageLib.decodeImage(inputImage.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
        title: Text("Select the Filter"),
        image: image,
        filters: presetFiltersList,
        filename: fileName,
        loader: Center(child: CircularProgressIndicator()),
        fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        inputImage = imagefile['image_filtered'];
        wannaSave = true;
      });
      print(inputImage.path);

    }
  }

  Future saveImage() async {
   // renameImage();
    await GallerySaver.saveImage(inputImage.path, albumName: "PhotoEditor");
    setState(() {
      wannaSave = false;
    });

  }

    
  void shareImage(context) {
    final RenderBox box = context.findRenderObject();
    if (Platform.isAndroid) {
      Share.shareFiles(imagePaths,
          subject: 'Image edited by Photo Editor',
          text:
              'Hey, Look what I did!!',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      Share.share(
          'Hey, Look what I edited with this amazing app called Photo Editor.',
          subject: 'Image edited by Photo Editor',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }








  Future<void> showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Saved!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  inputImage = null;
                  wannaSave = false;
                });
                Navigator.pop(context);
                //Navigator.popAndPushNamed(context, '/');
                //Navigator.pushNamed(context, '/');
              },
            ),
          ],
        );
      },
    );
  }



}


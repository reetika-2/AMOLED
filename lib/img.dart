import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_utils/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';


class Img extends StatefulWidget {
final String imgpath;

String result;
Img(this.imgpath);



  @override
  _ImgState createState() => _ImgState();
}


  final LinearGradient backgroundGradient = LinearGradient(
      colors: [Color(0x10000000), Color(0x30000000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);




class _ImgState extends State<Img> {
  @override
bool downloading = false;
  var progress = "";
  Widget build(BuildContext context) {


  PermissionGroup permission1 = PermissionGroup.storage;
  final Random random = Random();


  Future<void> download(String imgUrl) async {
    Dio dio = Dio();
    bool checkPermission1;
    final List<PermissionGroup> permissions = <PermissionGroup>[permission1];
    await PermissionHandler()
        .checkPermissionStatus(permission1)
        .then((PermissionStatus status) {
      setState(() {
        if (status == PermissionStatus.denied) {
          checkPermission1 = false;
        } else {
          if (status == PermissionStatus.granted) {
            checkPermission1 = true;
          }
        }
      });
    });
    // print(checkPermission1);
    if (checkPermission1 == false) {
      await PermissionHandler().requestPermissions(permissions);
      await PermissionHandler()
          .checkPermissionStatus(permission1)
          .then((PermissionStatus status) {
        setState(() {
          if (status == PermissionStatus.denied) {
            checkPermission1 = false;
          } else {
            if (status == PermissionStatus.granted) {
              checkPermission1 = true;
            }
          }
        });
      });
    }
    if (checkPermission1 == true) {
      var dir = await getExternalStorageDirectory();
      var dirloc = "${dir.path}/Abstract/";
      var randid = random.nextInt(10000);

      try {
        FileUtils.mkdir([dirloc]);
        await dio.download(imgUrl, dirloc + randid.toString() + ".jpg",
            onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            downloading = true;
            progress =
                ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
          });
        });
      } catch (e) {
        print(e);
      }

      setState(() {
        progress = "Download Completed.";
        Fluttertoast.showToast(
            msg: 'Image Saved to Gallery.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 5,
            backgroundColor: Colors.black12,
            textColor: Colors.white,
            fontSize: 18.0);
        downloading = false;
      });
    } else {
      setState(() {
        progress = "Permission Denied!";
      });
    }
  }


setWallpaper(String img_URL) async {
 await Wallpaper.homeScreen(img_URL);
   if (!mounted) return;
    setState(() {

      Fluttertoast.showToast(
        msg: "Wallpaper Set Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black12,
        textColor: Colors.white,
        fontSize: 16.0
    );
 
    
     });
            
}

  shareImg(String imgUrl) async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(imgUrl));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('Amoled Wallpaper', 'amoled.jpg', bytes, 'image/jpg');
      // await Share.file('Abstract Wallpaper', 'abs.jpg', bytes, 'image/jpg');
    } catch (error) {
      print('Error Sharing Image: $error');
    }
  }

    return Scaffold(
      // appBar: AppBar(
      //     title: Text('AMOLED'),
      //     backgroundColor: Colors.transparent,
      //     leading: IconButton(
      //       icon: Icon(
      //         Icons.arrow_back, 
      //         color: Colors.white,
      //         ),
      //     onPressed: () => Navigator.pop(context, false),
      //     ),
      // ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height, 
          child: Container(
           decoration: BoxDecoration(gradient: backgroundGradient),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height, 
                        child: Image(image: NetworkImage(widget.imgpath),fit: BoxFit.cover,)
                      ),

                       Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AppBar(
                              elevation: 0.0,
                              backgroundColor: Colors.transparent,
                              leading: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: Colors.white,
                                  ),
                                 onPressed: ()=>shareImg(widget.imgpath),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                     Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                    children:<Widget>[
                      Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                      Container(
                        height: 50.0,
                        width: MediaQuery.of(context).size.width/2,
                        child: MaterialButton(
                          onPressed: ()=> download(widget.imgpath),
                          child: Text('DOWNLOAD'),
                          height: 50.0,
                          minWidth: double.infinity,
                          color: Colors.black45,
                          textColor: Colors.white,
                        ),
                      ),
                      Container(
                        height: 50.0,
                        width: MediaQuery.of(context).size.width/2,
                        child: MaterialButton(
                          onPressed: ()=> setWallpaper(widget.imgpath),
                          child: Text('SET AS WALLPAPER'),
                          height: 50.0,
                          minWidth: double.infinity,
                          color: Colors.black45,
                          textColor: Colors.white,
                        ),
                        
                      ),
                      
                    ],
                    ),
                     Padding(
                      padding: EdgeInsets.only(bottom: 50.0),
                      ),
                    ]
                  ),
                  
            
                ),
               
              
              ],
            ),
           
          )
          
      ),
       
     
    );
  }
  
}
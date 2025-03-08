import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'globals.dart' as globals;

class MyCamera extends StatefulWidget{
  const MyCamera({super.key});

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {

  Function? _setPhotoButtonState;

  CameraController? _cameraController;

  Future<void>? _initializeControllerFuture;
  bool _isTaking = false;
  late int _selectedCameraIndex;

  @override
  void initState() {
    super.initState();
    _isTaking = false;
    _selectedCameraIndex = 0;

    availableCameras().then((initCameras){
      if(initCameras.isEmpty){
        print("error 1: No cameras available");
      }

      try{
        globals.cameras = initCameras;
        globals.currentCamera = initCameras.first;
        _selectedCameraIndex = 0;

        if(globals.currentCamera==null){
          print("error 2: Cameras available but could not be read");
        }
        if(globals.currentCamera!=null){
          _cameraController = CameraController(globals.currentCamera!, ResolutionPreset.ultraHigh);
        }

        if(_cameraController!=null){
          _initializeControllerFuture = _cameraController!.initialize();
        }

      }catch(error){
        print("error 3: $error");
      }

      if(mounted) setState(() {});


    });


  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Center(child: Text("Camera Controller Error: ${snapshot.error}"));
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }
        if(snapshot.connectionState == ConnectionState.done){
          if(_cameraController == null){
            return Center(child: Text("Camera Controller Error: _cameraController is null"));
          }
          return CameraPreview(_cameraController!);
        }

        return Center(child: Text("Camera Connection State: ${snapshot.connectionState.name}"));
      },
    );
  }
}
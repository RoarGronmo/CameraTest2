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
          return Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(_cameraController!)
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: (){
                            toggleCameraLens();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states){
                              if(states.contains(WidgetState.disabled)){
                                return Colors.grey;
                              }else{
                                return Colors.white;
                              }
                            })
                          ),
                          child: const Icon(Icons.cameraswitch_outlined),
                        )
                      ]
                    ),
                  ),
                ),
              )
            ],
          );
        }

        return Center(child: Text("Camera Connection State: ${snapshot.connectionState.name}"));
      },
    );
  }

  void toggleCameraLens(){
    _selectedCameraIndex = globals.cameras?.indexOf(globals.currentCamera!)??0;

    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Select camera"),
        content: StatefulBuilder(builder: (context, setAlertState){
          return SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height*0.4
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: globals.cameras?.length??0,
                      itemBuilder: (context, index){
                        return ListTile(
                          title: Text(globals.cameras![index].name),
                          subtitle: Text("Lens direction: ${globals.cameras![index].lensDirection.toString()}"),
                          leading: Radio<int>(
                            onChanged: (intValue){
                              try{
                                _selectedCameraIndex = intValue??0;
                                globals.currentCamera = globals.cameras![_selectedCameraIndex];

                                _cameraController = CameraController(globals.currentCamera!, ResolutionPreset.ultraHigh);

                                if(_cameraController!=null) {
                                  _initializeControllerFuture = _cameraController!.initialize();
                                }

                              }catch(error){
                                print("error 10: $error");
                              }

                              if(mounted){
                                setState(() {});
                                setAlertState((){});
                              }
                            },
                            value: index,
                            groupValue: _selectedCameraIndex,
                          )
                        );
                      }
                    )
                  )
                ],
              ),
            )
          );
        }),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text("OK")
          ),
        ],
      );
    });

  }
}
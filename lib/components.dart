//import 'dart:html';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'dart:typed_data';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:scanning_effect/scanning_effect.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_editor/image_editor.dart' as image_editor;
import 'package:widgets_to_image/widgets_to_image.dart';

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:image/image.dart' as img_man;
import 'package:colorfilter_generator/addons.dart';
import 'package:on_image_matrix/on_image_matrix.dart';
//import 'package:image_compare/image_compare.dart';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_pixelmatching/flutter_pixelmatching.dart';

import 'page1.dart';



class WelcomeMsg extends StatefulWidget
{
@override
WelcomeMsg_state createState()
{
  return WelcomeMsg_state();
}
}

class WelcomeMsg_state extends State<WelcomeMsg> with SingleTickerProviderStateMixin
{

  late AnimationController animation_ctrl =  AnimationController(vsync: this,duration: Duration(seconds: 1))..repeat(reverse: true);
  double letter_space = 5;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animation_ctrl.dispose();
  }
  @override
  Widget build(BuildContext build_context)
  {
    return Container(
          alignment: Alignment.center,
          child:DefaultTextStyleTransition(
               
              style: TextStyleTween(begin:TextStyle(shadows:[Shadow(color: Colors.black87,offset: Offset(1, 1),blurRadius: 1)],
                                    color: Color.fromARGB(255, 33, 174, 54),
                                    fontSize: 20,
                                    letterSpacing: 1,
                                    wordSpacing: 5
                                    ),
                                    end:TextStyle(shadows:[Shadow(color: Colors.black87,offset: Offset(1, 1),blurRadius: 1)],
                                    color: Color.fromARGB(255, 33, 174, 54),
                                    fontSize: 20,
                                    letterSpacing: 5,
                                    wordSpacing: 5
                                    )).animate(animation_ctrl), 
              child: Text("IMAGE ANALYZER"),
                  ));
    
  }
}


class ImagePicker1 extends StatefulWidget
{
  @override
  ImagePicker1State createState()
  {
    return ImagePicker1State();
  }
}
//OnImageController image_ctrl =OnImageController();
WidgetsToImageController widget_img_ctrl = WidgetsToImageController();
WidgetsToImageController widget_img_ctrl2 = WidgetsToImageController();
class ImagePicker1State extends State<ImagePicker1> with SingleTickerProviderStateMixin
{
  bool is_image = false;
  bool start_comparision = false;
  String image_path = '';
  String image_2_path = '';
  bool is_image2 = false;
  bool image_update_fin = false;
  late AnimationController scan_ctrl = AnimationController(vsync: this,duration: Duration(seconds: 1))..repeat(reverse: true);
  double comparision_value = 0.0;
  //late OnImageController image_ctrl ;//=OnImageController();

  late StreamController<Uint8List> picture_strm = StreamController();
  
  
  late PageController page_ctrl = PageController(initialPage: 0);
  
  
  late Widget page_1, page_2, page_3;

  late Isolate edit_isolate;

  double brightness_contrast = 0,brightness_contrast2 =0, exposure_val = 0, exposure_val2 = 0, saturation_val = 3,saturation_val2 = 3;

  bool page_1_ctrls = false;
  bool page_2_ctrls = false;

  bool is_saving_img = false;
  bool is_saving_img2 = false;

  late img_man.Image my_image;

  late Uint8List my_image_bytes ;
  late Uint8List image_2_bytes;

  late SendPort rem_send_port;


  final my_send = ReceivePort();

  final my_recv_port = ReceivePort();
  late SendPort my_send_port = my_recv_port.sendPort; 

  final compare_recv_port = ReceivePort();
  late final compare_send_port = compare_recv_port.sendPort;
  late SendPort compare_remote_send_port;
  
  late StreamSubscription image_compare_listener;


      

  void loadImage() async
  {
    List<int> img_bytes = await File(image_path).readAsBytes();
    //my_image = img_man.decodeImage(img_bytes) as img_man.Image;
    
    //img_man.adjustColor(my_image, brightness: 5);
  }
  

  void setPage1Ctrls(){
    setState(() {
      page_1_ctrls = !page_1_ctrls;
    });
  }

  void setPage2Ctrls(){
    setState(() {
      page_2_ctrls = !page_2_ctrls;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    StreamSubscription my_port_listener = my_recv_port.listen(
        (message){
          if(message is SendPort)
          {
            rem_send_port = message;
            
          }
          else
          {
           // my_image_bytes = message;
            //setAnImage();
              print(message);
              print("and \n\n $my_image_bytes");
            
          }
         });

    image_compare_listener = compare_recv_port.listen((message) {
      if( message is SendPort)
      {
        compare_remote_send_port = message;
        print("received other send port");
      }
      else
      {
        print("image comparision: $message");
        comparision_value = (message);
        startComparision();
      }
    });
    
    
    Isolate.spawn(xcompareImages,compare_send_port).then((value) => edit_isolate = value);
    
    //
  }

  void setSavingImg()
  {
    setState(() {
      is_saving_img = !is_saving_img;
    });
  }

  void setSavingImg2()
  {
    setState(() {
      is_saving_img2 = !is_saving_img2;
    });
  }

  void startComparision()
  {
    setState(() {
      start_comparision = !start_comparision;
    });
  }

    void setBrightness(double bright_val)
    {
     

    
      setState(() {
        brightness_contrast = bright_val;
        
        
        print("using image brightness $brightness_contrast");
      });
    }

    void setExposure(double expos_val)
    {
      setState(() {
        exposure_val = expos_val;
        
        //print("using image exposure $exposure_val");
      });
    }

    void setSaturation(double satu_val)
    {
      setState(() {
        saturation_val = satu_val;
        
        //print("using image saturation $saturation_val");
      });
    }

    void setBrightness2(double bright_val)
    {
     

    
      setState(() {
        brightness_contrast2 = bright_val;
        
        
        print("using image brightness $brightness_contrast2");
      });
    }

    void setExposure2(double expos_val)
    {
      setState(() {
        exposure_val2 = expos_val;
        
        //print("using image exposure $exposure_val");
      });
    }

    void setSaturation2(double satu_val)
    {
      setState(() {
        saturation_val2 = satu_val;
        
        //print("using image saturation $saturation_val");
      });
    }

    void setAnImage()
    {
      setState(() {
        //is_image=false;
        //is_image= true;
        image_update_fin = true;
      });
    }

    void setImage(active_img) async
    {
      my_image_bytes = await active_img.readAsBytes();
      my_image = img_man.decodeImage(my_image_bytes) as img_man.Image;
    
      setState((){
        image_path = active_img.path;

        
      
        is_image = true;
        print("using image path $image_path and $is_image");
      });
    }

    void setImage2(String img_path)
    {
      
      setState(() {
        image_2_path = img_path;
        is_image2 = true;
        print("using image path $image_2_path and $is_image2");
      });
    }

    

    static xcompareImages(SendPort main_send_port) async
    {
      ReceivePort this_recv_port = ReceivePort();
      SendPort this_send_port = this_recv_port.sendPort;

      main_send_port.send(this_send_port);

      await for(var msg in this_recv_port)
      {
        var image_1 = msg[0];
        var image_2 = msg[1];
        double img_diff = 0;
        double temp_res = 0.0;

        final matching = PixelMatching();
// setup target image
        await matching?.initialize(image: image_1);
// compare image 
    final double? similarity = await matching?.similarity(image_2);
        //await compareImages(src1: image_1, src2: image_2);

        main_send_port.send((similarity as double));
      
      }

    }

  @override
  void dispose() {
    
    // TODO: implement dispose
    super.dispose();
   // image_ctrl.dispose();
  }

  
  @override
  Widget build(BuildContext build_context)
  {
    

    page_1 = Column(
                                        children: [
                                          Text("Click Below to Choose Image",style: TextStyle(color: Colors.white,letterSpacing: 3)),InkWell( 
                                              onTap: () async{
                                                print("hello tap");
                                                ImagePicker image_picker = ImagePicker();
                                                XFile image_file = await image_picker.pickImage(source: ImageSource.gallery) as XFile;
                                                
                                                print(image_file.path);
                                                setImage(image_file);
                                                
                                              },
                                              child:Stack(
                                              children:[
                                                        
                                                          Container(
                                                                
                                                                margin: EdgeInsets.only(top: 20),
                                                                width: 280,
                                                                height:300,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(color: Colors.black),
                                                                    color: Colors.transparent,
                                                                    boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]
                                                                    ),
                                                                child:(is_image==false)?Icon(IconData(0xf80d, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 100,color: Colors.blueGrey,): WidgetsToImage(child: OnImageMatrixWidget(
                                                            
                                                                colorFilter: OnImageMatrix.matrix(
                                                                  brightnessAndContrast: brightness_contrast,
                                                                  saturation: saturation_val,
                                                                  exposure: exposure_val, 
                                                            ),
                                                            
                                                            child: Image.memory(my_image_bytes,fit:BoxFit.fill)
                                                            //Image.file(fit:BoxFit.fill,File(image_path)),
                                                            
                                                            ),
                                                            controller: widget_img_ctrl,)

                                              ),
                                              (is_saving_img==true)?Container(
                                                                margin: EdgeInsets.only(top: 20),
                                                                width: 280,
                                                                height:300,
                                                                color: const Color.fromARGB(210, 30, 29, 29),
                                                                
                                                                child:LoadingFlipping.circle()
                                                          ):Container(
                                                            margin: EdgeInsets.only(top: 20),
                                                                width: 280,
                                                                height:300,
                                                                child: Text("Touch here to replace or add image",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 2))
                                                          )
                                                ]
                                            )
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      child: Icon(IconData(0xe1a3, fontFamily: 'MaterialIcons')),
                                      onTap: () async
                                            {
                                              print("crop started");
                                             CroppedFile crop_file = await ImageCropper().cropImage(sourcePath: image_path,uiSettings: [AndroidUiSettings(lockAspectRatio: false)]) as CroppedFile;
                                             print("crop finished");
                                             String crop_path = crop_file.path;
                                             
                                             print("the cropped file is at $crop_path");
                                             setImage(crop_file);
                                            },
                                      ),
                                      
                                      Container(
                                        //color: Colors.blueGrey,
                                        margin: EdgeInsets.only(left: 20),
                                        child:InkWell(
                                          child: Icon(IconData(0xf00d, fontFamily: 'MaterialIcons')),
                                          onTap: () async
                                              {
                                                //image editor controls
                                                print("image editor on");
                                                setPage1Ctrls();
                                                

                                              },
                                      )),
                                      Container(
                                        child: Column(
                                              children: [
                                            
                                              ])
                                      )
                                      ]
                                  ),
                              ElevatedButton(
                                              onPressed: () async
                                                          {
                                                            if(is_image==true)
                                                            //if(true)
                                                            {
                                                             // image_ctrl.saveBytes();
                                                              
                                                              
                                                           
                                                              setSavingImg();
                                                              my_image_bytes = await widget_img_ctrl.capture() as Uint8List;
                                                              setSavingImg();

                                                              if(is_saving_img==false)
                                                              {
                                                                page_ctrl.nextPage(duration: Duration(seconds: 1), 
                                                                curve: Curves.bounceOut);
                                                              }
                                                              
                                                              
                                                              
                                                            }
                                                            else{
                                                                showDialog<String>(context:build_context, builder: (BuildContext dialog_bc)=>AlertDialog(
                                                                  title: Text("Image Error"),
                                                                  content: Text("please insert image first"),
                                                                  actions: [TextButton(onPressed: (){Navigator.pop(dialog_bc,"OK");}, child: Text("OK"))],

                                                                  ));
                                                            }
                                                          }, 
                                              child: Text("Continue...."),
                                              style: ButtonStyle(
                                                                              backgroundColor: MaterialStatePropertyAll(Colors.black87),
                                                                              elevation: MaterialStatePropertyAll(20),
                                                                              shadowColor: MaterialStatePropertyAll(Colors.blueAccent)
                                              )

                                            ),
                                            (page_1_ctrls==true)?Column(children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                              Icon(IconData(0xe109, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 20,color: Colors.black87,),
                                                              Slider(value: brightness_contrast, divisions: 10,max:10, label:"brightness", onChanged: (double value) async{
                                                                setBrightness(value);
                                                                image_update_fin = false;
                                                                
                                                                ColorFilter cf = OnImageMatrix.matrix(
                                                                  brightnessAndContrast: brightness_contrast,
                                                                  saturation: saturation_val,
                                                                  exposure: exposure_val, 
                                                            ) as ColorFilter;
                                                       
                                                        })
                                              ]),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                              Icon(IconData(0xf729, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 20,color: Colors.black87,),
                                                              Slider(value: exposure_val, divisions: 10,max:5, label:"exposure", onChanged: (double value){
                                                                setExposure(value);
                                                                
                                                        })
                                              ])
                                            ],):Container(),
                            ]);
    
    page_2 = Column(
                                        children: [
                                          Text("Touch Below To Take Image",style:TextStyle(color: Colors.white,letterSpacing: 3)),InkWell( 
                                              onTap: () async{
                                                print("hello tap");
                                                ImagePicker image_picker = ImagePicker();
                                                XFile image_file = await image_picker.pickImage(source: ImageSource.camera) as XFile;
                                            
                                                print(image_file.path);
                                                image_2_bytes = await image_file.readAsBytes();
                                                setImage2(image_file.path);
                                                
                                              },
                                              child:Stack(
                                              children:[
                                                Container(
                                                
                                                margin: EdgeInsets.only(top: 10),
                                                width: 280,
                                                height:300,
                                                decoration: BoxDecoration(border: Border.all(color: Colors.black),boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]),
                                                child:(is_image2==false)?Icon(IconData(0xef1e, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 100,color: Colors.blueGrey,): //Image.memory(image_2_bytes,fit: BoxFit.fill)
                                                WidgetsToImage(child: OnImageMatrixWidget(
                                                            
                                                                colorFilter: OnImageMatrix.matrix(
                                                                  brightnessAndContrast: brightness_contrast2,
                                                                  saturation: saturation_val2,
                                                                  exposure: exposure_val2, 
                                                            ),
                                                            
                                                            child: Image.memory(image_2_bytes,fit:BoxFit.fill)
                                                            //Image.file(fit:BoxFit.fill,File(image_path)),
                                                            
                                                            ),
                                                            controller: widget_img_ctrl2,)

                                              ),
                                              (is_saving_img2==true)?Container(
                                                                margin: EdgeInsets.only(top: 20),
                                                                width: 280,
                                                                height:300,
                                                                color: const Color.fromARGB(210, 30, 29, 29),
                                                                
                                                                child:LoadingFlipping.circle()
                                                          ):Container(
                                                            margin: EdgeInsets.only(top: 20),
                                                                width: 280,
                                                                height:300,
                                                                child: Text("Touch here to replace or add image",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 2))
                                                          )
                                                ]
                                            )
                              ),
                                                //Image.file(fit:BoxFit.fill,File(image_2_path))
                                                //child: Image.file(File(image_path))

                                              
                              
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      child: Icon(IconData(0xe1a3, fontFamily: 'MaterialIcons')),
                                      onTap: () async
                                              {
                                                 print("crop started");
                                             CroppedFile crop_file = await ImageCropper().cropImage(sourcePath: image_2_path,uiSettings: [AndroidUiSettings(lockAspectRatio: false)]) as CroppedFile;
                                             print("crop finished");
                                             String crop_path = crop_file.path;
                                             print("the cropped file is at $crop_path");
                                             setImage2(crop_path);

                                              },
                                      ),
                                      
                                      Container(
                                        //color: Colors.blueGrey,
                                        margin: EdgeInsets.only(left: 20),
                                        child:InkWell(
                                          child: Icon(IconData(0xf00d, fontFamily: 'MaterialIcons')),
                                          onTap: () async
                                              {
                                                //image editor controls
                                                print("image editor on");
                                                setPage2Ctrls();
                                                

                                              },
                                      ))]),
                             // Container(
                              //  alignment: Alignment.topCenter,
                              Row(
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  
                                  children:[
                                              ElevatedButton(
                                                  onPressed: ()
                                                              {
                                                                page_ctrl.previousPage(duration: Duration(seconds: 1),
                                                                curve: Curves.bounceOut);
                                                              }, 
                                                  child: Text("BACK"),
                                                  style: ButtonStyle(
                                                                              backgroundColor: MaterialStatePropertyAll(Colors.black87),
                                                                              elevation: MaterialStatePropertyAll(20),
                                                                              shadowColor: MaterialStatePropertyAll(Colors.blueAccent)
                                                                            )
                                                            ),
                                              Container(
                                                margin: EdgeInsets.only(left:10),
                                                child: ElevatedButton(
                                                onPressed: () async
                                                            {
                                                            if(is_image2==true)
                                                             if(true)
                                                              {
                                                                setSavingImg2();
                                                              image_2_bytes = await widget_img_ctrl2.capture() as Uint8List;
                                                              setSavingImg2();
              
                                                                page_ctrl.nextPage(duration: Duration(seconds: 1), 
                                                                curve: Curves.bounceOut);
                                                              }
                                                              else{
                                                                showDialog<String>(context:build_context, builder: (BuildContext dialog_bc)=>AlertDialog(
                                                                  title: Text("Image Error"),
                                                                  content: Text("please insert image first"),
                                                                  actions: [TextButton(onPressed: (){Navigator.pop(dialog_bc,"OK");}, child: Text("OK"))],

                                                                  ));
                                                              }
                                                            }, 
                                                child: Text("Compare Images"),
                                                style: ButtonStyle(
                                                                              backgroundColor: MaterialStatePropertyAll(Colors.black87),
                                                                              elevation: MaterialStatePropertyAll(20),
                                                                              shadowColor: MaterialStatePropertyAll(Colors.blueAccent)
                                                                            ))
                                                        )
                                            ]
                                ),
                                (page_2_ctrls==true)?Column(children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                              Icon(IconData(0xe109, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 20,color: Colors.black87,),
                                                              Slider(value: brightness_contrast2, divisions: 10,max:10, label:"brightness", onChanged: (double value) async{
                                                                setBrightness2(value);
                                                                image_update_fin = false;
                                                                
                                                            
                                                       
                                                        })
                                              ]),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                              Icon(IconData(0xf729, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 20,color: Colors.black87,),
                                                              Slider(value: exposure_val2, divisions: 10,max:5, label:"exposure", onChanged: (double value){
                                                                setExposure2(value);
                                                                
                                                        })
                                              ])]):Container(),
                            //  )
              ]);

    page_3 = Column(
                                        children: [Text("Comparing The Images",style: TextStyle(color: Colors.white,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3)),
                                        (is_image==true)&&(is_image2==true)?Row(
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                  
                                            children:[ 
                                                      Container(
                                                
                                                //margin: EdgeInsets.only(left: 20),
                                                width: 140,
                                                height:150,
                                                decoration: BoxDecoration(border: Border.all(color: Colors.black),boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]),
                                                        child: Image.memory(my_image_bytes,fit:BoxFit.fill)),
                                                        //Image.file(File(image_path),fit:BoxFit.fill)),
                                                        Container(
                                                
                                                //margin: EdgeInsets.only(left: 20),
                                                width: 140,
                                                height:150,
                                                decoration: BoxDecoration(border: Border.all(color: Colors.black),boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]),
                                                        child:Image.memory(image_2_bytes,fit:BoxFit.fill))
                                                        ///Image.file(File(image_2_path),fit:BoxFit.fill)),
                                                      ]
                                          ):Row(
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                  
                                            children:[ Container(
                                                
                                                //margin: EdgeInsets.only(left: 20),
                                                width: 140,
                                                height:150,
                                                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                                child:(is_image2==false)?Icon(IconData(0xf80d, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 100,color: Colors.blueGrey,):Image.file(File(image_2_path),fit:BoxFit.fill)
                                                //child: Image.file(File(image_path))

                                              ),
                                              Container(
                                                
                                                //margin: EdgeInsets.only(left: 20),
                                                width: 140,
                                                height:150,
                                                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                                child:(is_image2==false)?Icon(IconData(0xef1e, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 100,color: const Color.fromARGB(255, 0, 0, 0),):Image.file(File(image_2_path),fit:BoxFit.fill)
                                                //child: Image.file(File(image_path))

                                              ),
                                                      ]
                                          ),
                                          Row(
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  
                                  children:[
                                              ElevatedButton(
                                                          onPressed: ()
                                                                      {
                                                                        page_ctrl.previousPage(duration: Duration(seconds: 1), 
                                                                        curve: Curves.bounceOut);
                                                                      }, 
                                                          child: Text("BACK"),
                                                          style: ButtonStyle(
                                                                              backgroundColor: MaterialStatePropertyAll(Colors.black87),
                                                                              elevation: MaterialStatePropertyAll(20),
                                                                              shadowColor: MaterialStatePropertyAll(Colors.blueAccent))
                                                                              ),
                                            Container(
                                              margin: EdgeInsets.only(left:10),
                                              child:ElevatedButton(
                                                          onPressed: () async
                                                                      {
                                                                        if(start_comparision==false)
                                                                        {
                                                                        startComparision();
                                                                        
                                                                        compare_remote_send_port.send([my_image_bytes,image_2_bytes]);
                                                                        }
                                                                        
                                                                      }, 
                                                          child: (start_comparision==false)?Text("COMPARE"):Text("WAIT...."),
                                                          style: ButtonStyle(
                                                                              backgroundColor: (start_comparision==false)?MaterialStatePropertyAll(Colors.black87):MaterialStatePropertyAll(Color.fromARGB(213, 155, 85, 182)),
                                                                              elevation: (start_comparision==false)?MaterialStatePropertyAll(20):MaterialStatePropertyAll(100),
                                                                              shadowColor: (start_comparision==false)?MaterialStatePropertyAll(Colors.blueAccent):MaterialStatePropertyAll(Colors.black45)
                                                                            )
                                                          )
                                                      ),
                                            
                                          
                                            ]
                                ),
                                Container(
                                                
                                                  margin: EdgeInsets.only(left:(((MediaQuery.of(build_context).size.width)/50)),top:30),

                                                  child:Text("RESULTS",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3))
                                                ),
                                Container(
                                  height: 200,
                                  padding: EdgeInsets.only(top:20),
                                  
                                  //width: (MediaQuery.of(build_context).size.width)-100,
                                  margin: EdgeInsets.only(top:20,left: 20,right:30),
                                  decoration: BoxDecoration(
                                                 // border: Border.all(color: Colors.black),
                                                  //color: Color.fromARGB(255, 3, 88, 98),
                                                  gradient:LinearGradient(colors:[Color.fromARGB(213, 196, 90, 238),Color.fromARGB(201, 1, 146, 120),Color.fromARGB(201, 1, 146, 120),Color.fromARGB(255, 3, 88, 98)]),
                                                  boxShadow: [BoxShadow(color:Colors.black,blurRadius: 10,blurStyle: BlurStyle.solid)]
                                                      ),
                                  child:
                                      Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children:[
                                                
                                                Text("COMPARISION SCORE: ",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3)),
                                                Text(comparision_value==0.0?"0.0":(((comparision_value)*100).toStringAsFixed(3)),style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3)),
                                                Text("% similar",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3))
                                              ]
                                            )
                                          )
                            //  )
              ],
              );

    return Container(
              margin: EdgeInsets.only(top:5),
              height: 800,
              width: MediaQuery.of(build_context).size.width,
              alignment: Alignment.topCenter,
              //decoration: BoxDecoration(border: Border.all(color: Colors.black87)),
              child: PageView(
                    //reverse: true,
                    controller: page_ctrl,
                    scrollDirection: Axis.horizontal,
                    children:[
                            page_1,
                            page_2,
                            Stack(
                                  children: [
                                            page_3,
                                            start_comparision?SlideTransition(
                                              position: Tween<Offset>(begin: Offset(0,0), end:Offset(8,0)).animate(scan_ctrl),
                                              
                                              child:Container(
                                                        margin: EdgeInsets.only(left: 20,top: 15),
                                                        width: 20,
                                                        height: 150,
                                                        
                                                        decoration: BoxDecoration(
                                                                            gradient: LinearGradient(colors: [Color.fromARGB(255, 96, 188, 99),const Color.fromARGB(200, 130, 198, 132),Color.fromARGB(100, 170, 215, 172),const Color.fromARGB(80, 167, 235, 169)]),
                                                                            //color:Colors.green,
                                                                            //boxShadow: [BoxShadow(color:Colors.lightGreen,blurRadius: 2,offset: Offset(1, 1),spreadRadius: 2)
                                                                            
                                                                                  ),
                                                        )):Container(),
                                              
                                            ]
                            )
                                          
                            
              ])
              
      );
  }
}

class WelcomeEyes extends StatefulWidget
{
@override
WelcomeEyes_state createState()
{
  return WelcomeEyes_state();
}
}

class WelcomeEyes_state extends State<WelcomeEyes> with SingleTickerProviderStateMixin
{

  late AnimationController animation_ctrl =  AnimationController(vsync: this,duration: Duration(seconds: 1))..repeat(reverse: true);
  double letter_space = 5;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    this.dispose();
  }
  @override
  Widget build(BuildContext build_context)
  {
    double screen_width = (MediaQuery.of(build_context).size.width)-85;
    return Container(
          alignment: Alignment.center,
          width: 10,
          margin: EdgeInsets.only(left:(screen_width/2)),
          child: SizeTransition(
                      axis: Axis.horizontal,
                      sizeFactor: Tween<double>(begin:0.5,end: 5 ).animate(animation_ctrl),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children:[Icon(IconData(0xf00f0, fontFamily: 'MaterialIcons'),fill: 1.0),Icon(IconData(0xf00f0, fontFamily: 'MaterialIcons'),fill: 1.0)]),
                  /*style: TextStyle(shadows:[Shadow(color: Colors.black87,offset: Offset(1, 1),blurRadius: 1)],
                                    color: Color.fromARGB(255, 243, 166, 1),
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    wordSpacing: 5
                                    ),
                  )*/));
  
  }
}

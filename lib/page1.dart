//import "dart:ffi";
import "dart:typed_data";
import "dart:ui";
import "dart:io";
import "dart:async";
import "dart:isolate";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:on_image_matrix/on_image_matrix.dart";


import "package:widgets_to_image/widgets_to_image.dart";
import "package:animated_text_kit/animated_text_kit.dart";
import "package:loading_animations/loading_animations.dart";
import "package:image_cropper/image_cropper.dart";

class Page1 extends StatefulWidget
{
  late PageController use_page_ctrl;
  late Page1State page_1_state;

  Page1(PageController main_page_ctrl)
  {
    use_page_ctrl = main_page_ctrl;
    
  }


  Page1State createState()
  {
    page_1_state = Page1State(use_page_ctrl);
    return page_1_state;
  }
}
GlobalKey page1_gk = GlobalKey();
class Page1State extends State<Page1> with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin<Page1> 
{
  
  bool is_image = false;

  OnImageMatrix active_matrix = OnImageMatrix.matrix();
  
  String image_path = '';
  
  
  bool image_update_fin = false;

  @override
  bool get wantKeepAlive => true;
  
  

  late PageController page_ctrl;//= PageController(initialPage: 0);

  late WidgetsToImageController widget_img_ctrl;
  

  double brightness_contrast = 0, exposure_val = 0, saturation_val = 3;

  bool page_1_ctrls = false;
  

  bool is_saving_img = false;

  bool state_man = false;
  

  late Uint8List my_image_bytes ;
  late Uint8List main_image_bytes ;

  void setPage1Ctrls(){
    setState(() {
      page_1_ctrls = !page_1_ctrls;
    });
  }


  Page1State(PageController use_page_ctrl)
  {
    page_ctrl = use_page_ctrl;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget_img_ctrl = WidgetsToImageController();
    
    print("hello again");
    
    //
  }

  void setSavingImg()
  {
    setState(() {
      is_saving_img = !is_saving_img;
    });
  }

    void redraw()
    {
      setState(() {
        state_man = !state_man;
      });
    }



    void setBrightness(double bright_val)
    {
     /* active_matrix=OnImageMatrix.matrix(
                                                                  brightnessAndContrast: brightness_contrast,
                                                                  //saturation: saturation_val,
                                                                  exposure: bright_val, 
                                                            );*/
      setState(() {
        brightness_contrast = bright_val;
        
        
        print("using image brightness $brightness_contrast");
      });
    }

    void setExposure(double expos_val)
    {
     /* active_matrix= OnImageMatrix.matrix(
                                                                  brightnessAndContrast: brightness_contrast,
                                                                  //saturation: saturation_val,
                                                                  exposure: exposure_val, 
                                                            );
                                                          */
      setState(() {
        exposure_val = expos_val;
        
        //print("using image exposure $exposure_val");
      });
    }

    void setSaturation(double satu_val)
    {
      setState(() {
        saturation_val = satu_val;
      });
    }

    
    void setAnImage()
    {
      setState(() {
        image_update_fin = true;
      });
    }

    void setImage(active_img) async
    {
      my_image_bytes = await active_img.readAsBytes();
      main_image_bytes = my_image_bytes;
    
      setState((){
        image_path = active_img.path;
        is_image = true;
        print("using image path $image_path and $is_image");
      });
    }

    




  Uint8List getCurrentImage()
  {

    return my_image_bytes;
  }

  @override
  Widget build(BuildContext build_context)
  {
    return 
        Column(
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
                                                                  //saturation: saturation_val,
                                                                  exposure: exposure_val, 
                                                            ),
                                                            
                                                            child: Image.memory(main_image_bytes,fit:BoxFit.fill)
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
                                              child: (is_saving_img==false)?Text("Continue...."):AnimatedTextKit(animatedTexts: [TyperAnimatedText("--",textStyle: TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3),curve: Curves.easeInOut,speed:Duration(milliseconds:300))],
                                                        repeatForever: true),
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
                                                                print("brightness now $value");
                                                                
                                                       
                                                        })
                                              ]),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                              Icon(IconData(0xf729, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 20,color: Colors.black87,),
                                                              Slider(value: exposure_val, divisions: 10,max:5, label:"exposure", onChanged: (double value){
                                                                setExposure(value);
                                                                print("exposure now $value");
                                                        })
                                              ])
                                            ],):Container(),
                            ]);
  }
}
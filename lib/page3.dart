//import "dart:ffi";
import "dart:typed_data";
import "dart:ui";
import "dart:io";
import "dart:async";
import "dart:isolate";

import "package:flutter/material.dart";


import "package:widgets_to_image/widgets_to_image.dart";
import "package:animated_text_kit/animated_text_kit.dart";
import "package:loading_animations/loading_animations.dart";
import "package:flutter_pixelmatching/flutter_pixelmatching.dart";
//import "package:image_compare/image_compare.dart";

import 'page1.dart';
import 'page2.dart';


class Page3 extends StatefulWidget
{
  late PageController use_page_ctrl;
  late Page1 page_1_ref;
  late Page2 page_2_ref;
  late Page3State page_3_state;

  Page3(this.use_page_ctrl,this.page_1_ref,this.page_2_ref)
  {

  }

  @override
  Page3State createState()
  {
    page_3_state = Page3State(use_page_ctrl,page_1_ref,page_2_ref);
    return page_3_state;
  }
}

class Page3State extends State<Page3> with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin<Page3> 
{
  bool is_image = false;
  bool start_comparision = false;

  bool state_man = false;

  late Page1 page_1_ref;
  late Page2 page_2_ref;

  @override
  bool get wantKeepAlive => true;
  
 // String image_path = '';
 // String image_2_path = '';

  bool is_image2 = false;
  

  late AnimationController scan_ctrl = AnimationController(vsync: this,duration: Duration(seconds: 5))..repeat(reverse: true);
  double comparision_value = 0.0;
  //late OnImageController image_ctrl ;//=OnImageController();

  
  late PageController page_ctrl;
  

  late Isolate edit_isolate;

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

  
      
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    

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
    print("re injt");
    //
  }

  void startComparision()
  {
    print(start_comparision);
    setState(() {
      start_comparision = !start_comparision;
    });
  }

    
  void redraw()
    {
      setState(() {
        state_man = !state_man;
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
        //await compareImages(src1: image_1, src2: image_2);
        final matching = PixelMatching();
// setup target image
        await matching?.initialize(image: image_1);
// compare image 
    final double? similarity = await matching?.similarity(image_2);
        //await compareImages(src1: image_1, src2: image_2);

        main_send_port.send((similarity as double));

      
      }

    }

  Page3State(this.page_ctrl,this.page_1_ref,this.page_2_ref)
  {
    

    print(is_image);

  }
  @override
  Widget build(BuildContext build_context)
  {
    is_image = page_1_ref.page_1_state.is_image;
    is_image2 = page_2_ref.page_2_state.is_image;
    if((is_image==true)&&(is_image2==true))
    {
      my_image_bytes = page_1_ref.page_1_state.getCurrentImage();
      image_2_bytes = page_2_ref.page_2_state.getCurrentImage();
    }
    else
    {
      /*
      
      */
    }
    

    print("re built");
    return
    Stack(
        children: 
          [                  
            Column(
                children: [
                        Text("Comparing The Images",
                                style: TextStyle(color: Colors.white,
                                fontWeight:FontWeight.bold,
                                letterSpacing: 3)
                            ),

                        (is_image==true)&&(is_image2==true)?
                            Row(
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[ 
                                              Container(
                                                //margin: EdgeInsets.only(left: 20),
                                                          width: 140,
                                                          height:150,
                                                          decoration: BoxDecoration(
                                                                                  border: Border.all(color: Colors.black),
                                                                                  boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]
                                                                                ),
                                                          child: Image.memory(my_image_bytes,fit:BoxFit.fill)
                                                        ),
                                                        //Image.file(File(image_path),fit:BoxFit.fill)),
                                              Container
                                                (
                                                  width: 140,
                                                  height:150,
                                                  decoration: BoxDecoration(
                                                                              border: Border.all(color: Colors.black),
                                                                              boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]
                                                                           ),
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
                                                child:Icon(IconData(0xf80d, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 100,color: Colors.blueGrey,)
                                                //child: Image.file(File(image_path))

                                              ),
                                              Container(
                                                //margin: EdgeInsets.only(left: 20),
                                                width: 140,
                                                height:150,
                                                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                                child:Icon(IconData(0xef1e, fontFamily: 'MaterialIcons'),semanticLabel: "choose an image",size: 100,color: const Color.fromARGB(255, 0, 0, 0),)
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
                                                                        if((is_image)&&(is_image2))
                                                                        {
                                                                        if(start_comparision==false)
                                                                        {
                                                                        startComparision();
                                                                        
                                                                        compare_remote_send_port.send([my_image_bytes,image_2_bytes]);
                                                                        }
                                                                        }
                                                                        else
                                                                        {
                                                                          showDialog(context: build_context, 
                                                                                      builder: (build_context){
                                                                                      return AlertDialog(title: Text("No Images"),
                                                                                                           content: Text("please insert images 1st"),
                                                                                                           actions:[
                                                                                                           TextButton(onPressed: (){page_ctrl.previousPage(duration: Duration(seconds: 1), 
                                                                                                          curve: Curves.bounceOut);}, child: Text("OK"))
                                               ]
                                      );
                  });

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
                                                
                                                Text("SIMILARITY : ",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3)),
                                                Text(comparision_value==0.0?"0":(((comparision_value)*100).toStringAsFixed(3)),style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3)),
                                                Text("%",style:TextStyle(color: Colors.white70,
                                                        fontWeight:FontWeight.bold,
                                                        letterSpacing: 3))
                                              ]
                                            )
                                          )
                            //  )
              ],
              ),
              
              Container(

                 //width: 280,
                height:150,
                margin: EdgeInsets.only(top: 15),
               // color: Colors.yellow,
               alignment: Alignment.center,
              child:
              Container(
                width: 280,
                height:150,
               // color: Colors.yellow,
              child:(start_comparision)?AlignTransition(
                                              //position: Tween<Offset>(begin: Offset(0,0), end:Offset(0,0)).animate(scan_ctrl),
                                              alignment: AlignmentTween(begin:Alignment.topLeft, end: Alignment.topRight).animate(scan_ctrl),
                                              
                                              child:Container(
                                                        //margin: EdgeInsets.only(top: 15),
                                                        width: 50,
                                                        height: 150,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                                            gradient: LinearGradient(colors: [Color.fromARGB(214, 2, 95, 5),Color.fromARGB(199, 2, 117, 6),Color.fromARGB(99, 3, 169, 11),const Color.fromARGB(80, 167, 235, 169)]),
                                                                            //color:Colors.green,
                                                                            //boxShadow: [BoxShadow(color:Colors.lightGreen,blurRadius: 2,offset: Offset(1, 1),spreadRadius: 2)
                                                        
                                                                                  )
                                                        /*child:Text("scanning"),*/
                                                        )):Container())),
                                              
                                            ]
                            );

  }
}

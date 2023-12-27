import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_analyzer/components.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar
        (
          toolbarHeight: 30,
          elevation: 2,
          backgroundColor: Color.fromARGB(255, 53, 6, 46),
          title:WelcomeMsg(),
          
          //Colors.white70,
          ),
        body: Container(
          //color: Color.fromARGB(255, 230, 230, 237),
          
          decoration: BoxDecoration( 
                                      gradient: LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter,
                                                  colors: [Color.fromARGB(214, 114, 5, 157),Color.fromARGB(201, 1, 146, 120),Color.fromARGB(255, 3, 88, 98)]),
                                    //color: Color.fromARGB(255, 230, 230, 237),
                                    //borderRadius: BorderRadius.only(topLeft:Radius.circular(50)),
                                    //border: Border(top: BorderSide(color: Color.fromARGB(255, 188, 205, 202),width:5,style:BorderStyle.solid))
                                    //Border.all(color: Color.fromARGB(255, 154, 250, 237))
                                    ),
      //constraints: BoxConstraints.expand(),
      //color: Colors.white70,
          child: ListView(
           // crossAxisAlignment: CrossAxisAlignment.start,
            
            children: [
              WelcomeEyes(),
              ImagePicker1()
            ],
          ),
        ),
      ),
    );
  }
}



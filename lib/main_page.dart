import "dart:ui";

import "package:flutter/material.dart";

import "page1.dart";
import "page2.dart";
import "page3.dart";

class MainPage extends StatefulWidget
{
  MainPageState main_page_state = MainPageState();

  @override
  MainPageState createState()
  {
    return main_page_state;
  }
}


class MainProps
{
  late PageController page_ctrl;
  
}

class MainPageState extends State<MainPage>
{
  late PageController page_ctrl;
  late Page1 page_1;
  late Page2 page_2;
  late Page3 page_3;

  

  @override
  void initState()
  {
      page_ctrl = PageController();
      page_1 = Page1(page_ctrl);
      page_2 = Page2(page_ctrl);
      page_3 = Page3(page_ctrl,page_1,page_2);

      page_ctrl.addListener(() {
        double active_page = page_ctrl.page as double;
        print("active page is: $active_page");

        switch(active_page)
        {
          case 0:
            page_1.page_1_state.redraw();
          break;
          case 1:
            page_2.page_2_state.redraw();
          break;

          case 2:
            page_3.page_3_state.redraw();
          break;
        }
       });

  }

  @override
  Widget build(BuildContext build_context)
  {

    return
    Container(
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
                            page_3,
                                            
              ])
              
      );
  }
}
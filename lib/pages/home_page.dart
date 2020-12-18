/* Music'scool App - Copyright (C) 2020  Music'scool DK

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>. */

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:musicscool/models/student.dart';
import 'package:musicscool/widgets/countdown_timer_widget.dart';
import 'package:musicscool/widgets/homework_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/services/api_test_service.dart';
import 'package:musicscool/widgets/lesson_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:musicscool/generated/l10n.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiTestService _api = ApiTestService();
  bool _notifications = true;
  List<Lesson> _lessons = <Lesson>[];
  bool _initial = true;
  final ValueNotifier<int> _initialScrollIndex = ValueNotifier<int>(0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _scrollController = ScrollController();

  /// Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  void scrollTo(int index) => itemScrollController.scrollTo(
      index: index,
      duration: Duration(seconds: 2),
      curve: Curves.easeInOutCubic,
      alignment: 0.0);

  void jumpTo(int index) =>
      itemScrollController.jumpTo(index: index, alignment: 0.0);

  _HomePageState() {
    _api.allLessons().then((lessons) {
      int i = 0;
      for (; i<lessons.length; ++i) {
        if (lessons[i].isNext) {
          break;
        }
      }
      setState(() {
        _lessons = lessons;
      });
      if (_initialScrollIndex.value == 0) {
          _initialScrollIndex.value = i;
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget countdownView(BuildContext context) {
    return FutureBuilder<User>(
      future: _api.user,
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          return studentCountdownView(context, snapshot.data.student);
        }
        else {
          return CircularProgressIndicator();
        }
        }
        );
  }

  Widget studentCountdownView(BuildContext context, Student student) {
    var devSize = MediaQuery.of(context).size;
    double boxWidth = min(devSize.width / 5.5, 100.0);
    String start = DateFormat.yMMMEd().format(student.nextLesson.from) + ' ' +
        DateFormat.Hm().format(student.nextLesson.from);

    return Container(
      // decoration: BoxDecoration(
      //     image: DecorationImage(
      //         image:
      //         AssetImage('assets/images/background4.jpg'),
      //         fit: BoxFit.cover)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      //EdgeInsets.symmetric(vertical: devSize.height / 6),
      child: Column(
          children: <Widget> [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget> [
                Text('Hi, Mrs. Pixie')
              ]
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      Text(S.of(context).aboutToRock,
                          textScaleFactor: 1.25,
                        style: TextStyle(height: 4.0)
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width:2.0),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          child: Column(

                          children: <Widget> [
                            CountdownTimer(to: student.nextLesson.from, boxWidth: boxWidth),
                            Text(''),
                            Text(start, textScaleFactor: 1.25)
                          ]
                        )
                      ),
                      Text('', textScaleFactor: 1.25,
                      style: TextStyle(height: 4.0)),
                      Text('', textScaleFactor: 1.25,
                          style: TextStyle(height: 4.0))
                    ]
                  )
                ]
              ),
            ),
          ]
      ),
    );
  }

  Widget mainLessonView(BuildContext context) {
    return Container(
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         image:
        //         AssetImage('assets/images/background4.jpg'),
        //         fit: BoxFit.cover)),
        child: ValueListenableBuilder(
            builder: (BuildContext context, int value, Widget child) {
              if (_initial && _initialScrollIndex.value != 0) {
                WidgetsBinding.instance.addPostFrameCallback((_){
                  scrollTo(_initialScrollIndex.value);
                  setState(() {
                    _initial = false;
                  });
                });
              }
              return ScrollablePositionedList.separated(
                  padding: const EdgeInsets.all(8),
                  initialScrollIndex: value,
                  itemCount: _lessons != null ? _lessons.length : 0,
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemBuilder: (BuildContext context, int index) =>
                  index > 0 ? LessonWidget(lesson: _lessons[index], index: index) : null,
                  separatorBuilder: (BuildContext context, int index) =>
                  const Divider());
            },
            valueListenable: _initialScrollIndex
        ));
  }

  Widget emptyView(BuildContext context) {
    return Column(
      children: <Widget> [

      ]
    );
  }

  Widget homeworkLessonsView(BuildContext context) {
    return Container(
        child: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<List<Lesson>> snap) {
              if (!snap.hasData) {
                return CircularProgressIndicator();
              }
              print(snap.data.length);
              return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snap.data.length,
//                  itemScrollController: itemScrollController,
//                  itemPositionsListener: itemPositionsListener,
                  itemBuilder: (BuildContext context, int index) =>
                  HomeworkWidget(lesson: snap.data[index], expanded: index == 0),
                  separatorBuilder: (BuildContext context, int index) =>
                  const Divider());
            },
            future: _api.getHomeworkLessons()
        ));
  }

  Widget upcomingLessonsView(BuildContext context) {
    return Container(
        child: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<List<Lesson>> snap) {
              if (!snap.hasData) {
                return CircularProgressIndicator();
              }
              return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snap.data.length,
//                  itemScrollController: itemScrollController,
//                  itemPositionsListener: itemPositionsListener,
                  itemBuilder: (BuildContext context, int index) =>
                    LessonWidget(lesson: snap.data[index]),
                  separatorBuilder: (BuildContext context, int index) =>
                  const Divider());
            },
            future: _api.getUpcomingLessons()
        ));
  }

  Widget settingsView(BuildContext context) {
    return FutureBuilder<User>(
        future: _api.user,

        builder: (context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            return userInfo(context, snapshot.data);
          }
          else {
            return CircularProgressIndicator();
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 2,
      child: Scaffold(
        key: _scaffoldKey,
        // bottomNavigationBar: BottomAppBar(
        //   color: Theme.of(context).primaryColor,
        //   child:
        // ),
        appBar: AppBar(
//          toolbarHeight: 160,
//           leading: IconButton(
//             icon: Icon(Icons.menu),
//             onPressed: () => _scaffoldKey.currentState.openDrawer()
//           ),
          title: SvgPicture.asset('assets/images/Musicscool - Logo - Zwart beeld- en woordmerk.svg',
          height: 48 /* @todo Size dynamically */ //),
          ),
          centerTitle: true,
          bottom: TabBar(
              labelStyle: TextStyle(fontSize: 10),
              tabs: <Widget> [
                Tab(text: 'Info', icon: Icon(CupertinoIcons.info_circle_fill)), //Icons.info)),
                Tab(text: 'Homework', icon: Icon(CupertinoIcons.music_albums_fill)), //doc_on_doc_fill)),//Icons.book)),
                Tab(text: 'Next', icon: Icon(CupertinoIcons.house_fill)), //Icons.home)),
                Tab(text: 'Upcoming', icon: Icon(CupertinoIcons.calendar)), //Icons.fast_forward)),
//                Tab(text: '')
              ]
          )
        ),
          body: Container(
    decoration: BoxDecoration(
    image: DecorationImage(
    image:
    AssetImage('assets/images/background4.jpg'),
    fit: BoxFit.cover)),
    child: TabBarView(
            children: <Widget> [
              settingsView(context),
              homeworkLessonsView(context),
              countdownView(context),
              upcomingLessonsView(context),
            ]
          ),
          )
        //   drawer: Drawer(
        //       child: FutureBuilder<User>(
        //           future: _api.user,
        //
        //     builder: (context, AsyncSnapshot<User> snapshot) {
        //       if (snapshot.hasData) {
        //         return userInfo(context, snapshot.data);
        //       }
        //       else {
        //         return CircularProgressIndicator();
        //       }
        //     }
        //   )
        // )
      ),
    );
  }

  Widget contactButton({BuildContext context, IconData icon, String label, String url}) {
    // return TextButton.icon(icon: Icon(icon), label: Text(label),
    //     onPressed: () {
    //       launch(url);
    //     }
    // );
    return FlatButton(
      onPressed: () {
        launch(url);
      },
      color: Colors.black, //Theme.of(context).primaryColor,
        textColor: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
//            side: BorderSide(color: Colors.white10)
        ),
      child: Column(
        children: <Widget> [
          Icon(icon, size: 36),
          Text(label)
        ]
      )
    );
    // return TextButton.icon(icon: Icon(Icons.sms), label: Text('SMS'),
    //     onPressed: () {
    //       launch('sms://${user.student.schoolContact.phone}');
    //     }
    // );
  }

  Widget userInfo(BuildContext context, User user) {
    return ListView(
        padding: EdgeInsets.zero,
        children: <Widget> [
          ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            leading: Icon(CupertinoIcons.person_fill) //Icons.person)
          ),
          // SizedBox(
          //   height: 140.0,
          //   child: UserAccountsDrawerHeader(
          //     accountName: Text(user.name),
          //     accountEmail: Text(user.email),
          //     //currentAccountPicture: CircleAvatar(child: Icon(Icons.person)) //Text('MS'))
          //   ),
          // ),
          ListTile(),
          ExpansionTile(
            title: Text('Contact'),
            leading: Icon(CupertinoIcons.doc_person_fill),
            // CircleAvatar(
            //   backgroundColor: Colors.black,
            //     child: SvgPicture.asset('assets/images/Musicscool - Logo - Okergeel beeldmerk.svg',
            //     color: Theme.of(context).primaryColor)),
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: <Widget> [
                    CircleAvatar(
                      minRadius: 24,
                      maxRadius: 48,
                      backgroundColor: Colors.black,
                        child: SvgPicture.asset('assets/images/Musicscool - Logo - Okergeel beeldmerk.svg',
                        color: Theme.of(context).primaryColor)),
                    Text(''),
                    Text("Music'scool", textScaleFactor: 1.75),
                    Text(''),
                    Text('Penselstrøget 56', textScaleFactor: 1.2),
                    Text('4000 Roskilde', textScaleFactor: 1.2),
                    Text('Danmark', textScaleFactor: 1.2),
                    Text(''),
                    Wrap(spacing: 12.0,
                      children: <Widget> [
                        contactButton(context: context,
                            icon: CupertinoIcons.phone_fill,
                            label: 'Call',
                            url: 'tel://${user.student.schoolContact.phone}'
                        ),
                        contactButton(context: context,
                            icon: CupertinoIcons.bubble_left_fill,
                            label: 'SMS',
                            url: 'sms://${user.student.schoolContact.phone}'
                        ),
                        contactButton(context: context,
                            icon: CupertinoIcons.envelope_fill,
                            label: 'Email',
                            url: 'mailto:${user.student.schoolContact.email}'
                        ),
                      ]
                    ),
                  //   TextButton.icon(icon: Icon(Icons.open_in_browser), label: Text('Privacy Policy'),
                  //       onPressed: () {
                  //         launch('https://musicscool.dk/privacypolicy');
                  //       }
                  //   )
                  ]
                )
              ),
            ]
          ),
          ExpansionTile(
              title: Text('Settings'),
              leading: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [Icon(CupertinoIcons.gear_alt_fill)]),
            children: <Widget> [
              SwitchListTile(
                  title: Text('Notifications'),
                  value: _notifications,
                  secondary: Icon(Icons.notifications),
                  onChanged: (bool value) {
                    setState(() {
                      _notifications = value;
                    });
                  }
              ),
              InkWell(
                  child: ListTile(
                      title: Text(S.of(context).privacyPolicy),
                      leading: Icon(Icons.open_in_browser)
                  ),
                  onTap: () {
                    launch('https://musicscool.dk/privacypolicy');
                  }
              ),
              InkWell(
                  child: ListTile(
                      title: Text('Logout'),
                      leading: Icon(Icons.logout)
                  ),
                  onTap: () {

                  }
              )

            ]
          ),
        ]
    );
  }
}

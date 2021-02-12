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
import 'package:musicscool/services/api.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:musicscool/widgets/countdown_timer_widget.dart';
import 'package:musicscool/widgets/homework_widget.dart';
import 'package:musicscool/widgets/lesson_list_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/widgets/lesson_widget.dart';
import 'package:musicscool/generated/l10n.dart';
import 'package:musicscool/helpers.dart';
import 'package:musicscool/strings.dart' show privacyPolicyUrl, appName;
import 'package:musicscool/locale_strings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _notificationsEnabled;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  static const _tabCount = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
         length: _tabCount,
         initialIndex: 2,
         vsync: this);
    AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    _notificationsEnabled = auth.notificationsEnabled;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget waiting() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget> [
        CircularProgressIndicator()
      ]
    );
  }

  Widget countdownView(BuildContext context) {
    return Consumer<AuthModel>(
        builder: (context, model, child) {
          if (model == null) return waiting();
          return FutureBuilder<User>(
            future: model.user,
            builder: (context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.student != null) {
                  return studentCountdownView(context, snapshot.data);
                }
                else {
                  return Column(
                    children: <Widget> [
                      Text(S.of(context).youAreNotAStudent)
                    ]
                  );
                }
              }
              else if (snapshot.hasError) {
                if (!(snapshot.error is AuthenticationFailed)) {
                  showUnexpectedError(context);
                }
                return Container();
              }
              else {
                return waiting();
              }
            }
          );
      }
    );
  }

  Widget studentCountdownTimer(BuildContext context, User user) {
    if (user?.student?.nextLesson != null) {
      var devSize = MediaQuery.of(context).size;
      double boxWidth = min(devSize.width / 5.5, 100.0);
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Text(S.of(context).heyUser(user.firstName),
                    textScaleFactor: 1.25),
                Text(S.of(context).aboutToRock,
                    textScaleFactor: 1.25),
                Text(''),
              ],
            ),
            Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width:2.0),
                    borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                    children: <Widget>[
                      CountdownTimer(to: user.student.nextLesson.from, boxWidth: boxWidth),
                      Text(''),
                      Text(formattedDateTime(context, user.student.nextLesson.from), textScaleFactor: 1.25)
                    ]
                )
            ),
            Text('', textScaleFactor: 1.25,
                style: TextStyle(height: 4.0)),
          ]
      );
    }
    else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget> [
          Text(S.of(context).youHaveNoUpcomingLessons)
          ]
      );
    }
  }
  Widget studentCountdownView(BuildContext context, User user) {
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
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  studentCountdownTimer(context, user)
                ]
              ),
            ),
          ]
      ),
    );
  }

  Widget homeworkLessonsView(BuildContext context) {
    return LessonListView(
        itemGetter: (int page, int perPage) {
          AuthModel auth = Provider.of<AuthModel>(context, listen:false);
          return auth.getHomeworkLessons(
              page: page,
              perPage: perPage);
        },
        itemRefresh: () async {
          AuthModel auth = Provider.of<AuthModel>(context, listen:false);
          await auth.cacheClearPast();
        },
        itemBuilder: (BuildContext context, Lesson item, int index) =>
            HomeworkWidget(lesson: item, expanded: index == 0)
    );
  }

  Widget upcomingLessonsView(BuildContext context) {
    return LessonListView(
        itemGetter: (int page, int perPage) {
          AuthModel auth = Provider.of<AuthModel>(context, listen: false);
          return auth.getUpcomingLessons(
              page: page,
              perPage: perPage);
        },
        itemRefresh: () async {
          AuthModel auth = Provider.of<AuthModel>(context, listen:false);
          await auth.cacheClearUpcoming();
        },
        itemBuilder: (BuildContext context, Lesson item, int index) =>
            LessonWidget(lesson: item)
    );
  }

  Widget settingsView(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, model, child) {
      if (model == null) return waiting();
      return FutureBuilder<User>(
          future: model.user,
          builder: (context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              return userInfo(context, snapshot.data);
            }
            else if (snapshot.hasError && !(snapshot.error is AuthenticationFailed)) {
              showUnexpectedError(context);
              return InkWell(
                child: ListTile(
                    title: Text(S.of(context).logout),
                    leading: Icon(Icons.logout)
                ),
                onTap: () {
                  Provider.of<AuthModel>(context, listen:false).logout();
                }
              );
            }
            else {
              return waiting();
            }
          }
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // bottomNavigationBar: BottomAppBar(
        //   color: Theme.of(context).primaryColor,
        //   child:
        // ),
        appBar: AppBar(
          toolbarHeight: 150,
            title: SvgPicture.asset('assets/images/Musicscool - Logo - Zwart beeld- en woordmerk.svg',
                height: 75 /* @todo Size dynamically */ //),
            ),
            centerTitle: true,
            bottom: TabBar(
                controller: _tabController,
                labelStyle: TextStyle(fontSize: 10),
                tabs: [
                  Tab(text: S.of(context).info, icon: Icon(CupertinoIcons.info_circle_fill)), //Icons.info)),
                  Tab(text: S.of(context).homework, icon: Icon(CupertinoIcons.music_albums_fill)), //doc_on_doc_fill)),//Icons.book)),
                  Tab(text: S.of(context).next, icon: Icon(CupertinoIcons.timer_fill)), //Icons.home)),
                  Tab(text: S.of(context).upcoming, icon: Icon(CupertinoIcons.calendar)), //Icons.fast_forward)),
                ]
            )
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background4.jpg'),
                  fit: BoxFit.cover)),
          child: TabBarView(
              controller: _tabController,
              children: <Widget> [
                settingsView(context),
                homeworkLessonsView(context),
                countdownView(context),
                upcomingLessonsView(context),
              ]
          ),
        )
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
          Text(label, strutStyle: StrutStyle(height: 1.5))
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
    List<Text> address = user.schoolContact.address.map((String line) {
      return Text(line, textScaleFactor: 1.2);
    }).toList();
    AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    return ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              leading: Icon(CupertinoIcons.person_fill) //Icons.person)
          ),
          ExpansionTile(
              title: Text(S.of(context).contact),
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
                          Text(appName, textScaleFactor: 1.75),
                          Text(''),
                          ...address,
                          // Text('Penselstrøget 56', textScaleFactor: 1.2),
                          // Text('4000 Roskilde', textScaleFactor: 1.2),
                          // Text('Danmark', textScaleFactor: 1.2),
                          Text(''),
                          Wrap(spacing: 12.0,
                              children: <Widget> [
                                contactButton(context: context,
                                    icon: CupertinoIcons.phone_fill,
                                    label: S.of(context).call,
                                    url: 'tel://${user.schoolContact.phone}'
                                ),
                                contactButton(context: context,
                                    icon: CupertinoIcons.bubble_left_fill,
                                    label: S.of(context).sms,
                                    url: 'sms://${user.schoolContact.phone}'
                                ),
                                contactButton(context: context,
                                    icon: CupertinoIcons.envelope_fill,
                                    label: S.of(context).email,
                                    url: 'mailto:${user.schoolContact.email}'
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
              title: Text(S.of(context).settings),
              leading: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [Icon(CupertinoIcons.gear_alt_fill)]),
              children: <Widget> [
                SwitchListTile(
                    title: Text(S.of(context).notifications),
                    value: _notificationsEnabled,
                    secondary: Icon(Icons.notifications),
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      if (value == true) {
                        auth.enableNotifications().catchError((_) => showUnexpectedError(context));
                      }
                      else {
                        auth.disableNotifications();
                      }
                    }
                ),
                InkWell(
                    child: ListTile(
                        title: Text(S.of(context).privacyPolicy),
                        leading: Icon(Icons.open_in_browser)
                    ),
                    onTap: () {
                      launch(privacyPolicyUrl);
                    }
                ),
                InkWell(
                    child: ListTile(
                        title: Text(S.of(context).logout),
                        leading: Icon(Icons.logout)
                    ),
                    onTap: () {
                      Provider.of<AuthModel>(context, listen:false).logout();
                    }
                )

              ]
          ),
        ]
          // SizedBox(
          //   height: 140.0,
          //   child: UserAccountsDrawerHeader(
          //     accountName: Text(user.name),
          //     accountEmail: Text(user.email),
          //     //currentAccountPicture: CircleAvatar(child: Icon(Icons.person)) //Text('MS'))
          //   ),
          // ),
          //ListTile(),
        //]
    );
  }
}

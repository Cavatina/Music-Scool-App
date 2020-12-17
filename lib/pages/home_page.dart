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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState.openDrawer()
        ),
        title: SvgPicture.asset('assets/images/Musicscool - Logo - Zwart beeld- en woordmerk.svg',
        height: 48 /* @todo Size dynamically */),
        centerTitle: true,
      ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                    AssetImage('assets/images/background4.jpg'),
                    fit: BoxFit.cover)),
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
                    index > 0 ? LessonWidget(lesson: _lessons[index]) : null,
                    separatorBuilder: (BuildContext context, int index) =>
                    const Divider());
                },
                valueListenable: _initialScrollIndex
                )),
        drawer: Drawer(
            child: FutureBuilder<User>(
                future: _api.user,

          builder: (context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              return userInfo(context, snapshot.data);
            }
            else {
              return CircularProgressIndicator();
            }
          }
        )
      )
    );
  }

  Widget userInfo(BuildContext context, User user) {
    return ListView(
        padding: EdgeInsets.zero,
        children: <Widget> [
          SizedBox(
            height: 140.0,
            child: UserAccountsDrawerHeader(
              accountName: Text(user.name),
              accountEmail: Text(user.email),
              //currentAccountPicture: CircleAvatar(child: Text('MS'))
            ),
          ),
          ListTile(
            title: Text("Music'scool"),
            leading: SvgPicture.asset('assets/images/Musicscool - Logo - Wit beeldmerk.svg')
          ),
          Divider(),
          InkWell(
              child: ListTile(
                  title: Text(user.student.schoolContact.name),
                  leading: Icon(Icons.sms)
              ),
              onTap: () {
                launch('sms:${user.student.schoolContact.phone}');
              }
          ),
          InkWell(
              child: ListTile(
                  title: Text(user.student.schoolContact.phone),
                  leading: Icon(Icons.call)
              ),
              onTap: () {
                launch('tel:${user.student.schoolContact.phone}');
              }
          ),
          InkWell(
              child: ListTile(
                  title: Text(user.student.schoolContact.email),
                  leading: Icon(Icons.email)
              ),
              onTap: () {
                launch('mailto:${user.student.schoolContact.email}');
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
          ListTile(),
          ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings)
          ),
          Divider(),
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
              title: Text('Logout'),
              leading: Icon(Icons.logout)
            ),
            onTap: () {

            }
          )
        ]
    );
  }
}

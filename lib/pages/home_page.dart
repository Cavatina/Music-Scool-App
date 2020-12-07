/* My Music'Scool - Copyright (C) 2020  Music'Scool DK

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
import 'package:my_musicscool_app/models/lesson.dart';
import 'package:my_musicscool_app/services/api_test_service.dart';
import 'package:my_musicscool_app/widgets/lesson_widget.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiTestService _api = ApiTestService();
  List<Lesson> _lessons = <Lesson>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _scrollController = ScrollController();

  _HomePageState() {
    _api.allLessons().then((lessons) => setState(() => _lessons = lessons));
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
            child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _lessons != null ? _lessons.length : 0,
                itemBuilder: (BuildContext context, int index) =>
                    LessonWidget(lesson: _lessons[index]),
                separatorBuilder: (BuildContext context, int index) =>
                const Divider())),
        drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget> [
            DrawerHeader(
                child: Text('Hello, world!'),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor)
            ),

            InkWell(
              child: ListTile(
                title: Text('Privacy Policy'),
                trailing: Icon(Icons.open_in_browser)
              ),
                onTap: () {
                  launch('https://musicscool.dk/privacypolicy');
                }
            )
          ]
        )
      )
    );
  }
}

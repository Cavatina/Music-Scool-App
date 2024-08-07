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

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:musicscool/generated/l10n.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:provider/provider.dart';
import 'package:musicscool/helpers.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/strings.dart' show appName;
import 'package:musicscool/service_locator.dart';


class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background4.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight
                    ),
                    child: LoginForm()
              )
            );
          }
        )

    ));
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

enum _FormType { signIn, resetPassword }

class _LoginFormState extends State<LoginForm> {
  _FormType formType = _FormType.signIn;
  late FocusNode passwordFocus;
  late TextEditingController emailController, passwordController;

  @override
  void initState() {
    super.initState();
    passwordFocus = FocusNode();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    locator<AuthModel>().lastUsername.then((String lastUsername) {
      if (lastUsername.isNotEmpty == true) {
        emailController.value = TextEditingValue(text: lastUsername);
        passwordFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent));
    return AutofillGroup(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          CircleAvatar(
              minRadius: 24,
              maxRadius: 48,
              backgroundColor: Colors.black,
              child: SvgPicture.asset('assets/images/Musicscool - Logo - Okergeel beeldmerk.svg',
                  color: Theme.of(context).colorScheme.secondary)),
          Text(''),
          Text(appName, textScaler: TextScaler.linear(1.75)),
          Text(''),
          userPwSection(),
          buttonSection(context),
        ],
      )
    );
  }

  Container userPwSection() {
    List<Widget> children = <Widget> [
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        autofillHints: [AutofillHints.email],
        cursorColor: Colors.white,
        autofocus: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.email, color: Colors.white70),
          hintText: S.of(context).email,
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          hintStyle: TextStyle(color: Colors.white70),
        ),
      ),
    ];

    if (formType == _FormType.signIn) {
      children.add(SizedBox(height: 30.0));
      children.add(TextFormField(
        controller: passwordController,
        autofillHints: [AutofillHints.password],
        focusNode: passwordFocus,
        cursorColor: Colors.white,
        obscureText: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.lock, color: Colors.white70),
          hintText: S.of(context).password,
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          hintStyle: TextStyle(color: Colors.white70),
        ),
      ));
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: children,
      ),
    );
  }

  Container resetPasswordButtons(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context, listen: true);
    double buttonWidth = max(150, MediaQuery.of(context).size.width / 2.2);
    return Container(
//      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.transparent),
              onPressed: () {
                setState(() {
                  formType = _FormType.signIn;
                });
              },
              child: Text(S.of(context).cancel),
          ),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () {
                _auth.resetPassword(username: emailController.text).then((String email) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).passwordResetRequestSent(email)),
                      duration: Duration(seconds: 5)
                  ));
                }).catchError((_) {
                  showUnexpectedError(context);
                });
                setState(() {
                  formType = _FormType.signIn;
                });
              },
              style: ElevatedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
              child: Text(S.of(context).resetPassword, style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Container signInButtons(BuildContext context) {
    final AuthModel _auth = Provider.of<AuthModel>(context, listen: true);
    double buttonWidth = max(150, MediaQuery.of(context).size.width / 2.2);
    return Container(
//      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.transparent),
              onPressed: () {
                setState(() {
                  formType = _FormType.resetPassword;
                });
              },
              child: Text(S.of(context).forgotPassword),
          ),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () {
                if (emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).loginMissingEmail),
                      duration: Duration(seconds: 2)
                  )); // snapshot.error;
                }
                else if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).loginMissingPassword),
                      duration: Duration(seconds: 2)
                  )); // snapshot.error;
                }
                else {
                  _auth.login(
                      username: emailController.text,
                      password: passwordController.text).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S.of(context).loginFailed),
                        duration: Duration(seconds: 2)
                    )); // snapshot.error;
                  }, test: (e) => e is AuthenticationFailed,
                  ).catchError((_) => showUnexpectedError(context));
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              child: Text(S.of(context).signIn, style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
  Container buttonSection(BuildContext context) {
    switch (formType) {
      case _FormType.resetPassword:
        return resetPasswordButtons(context);
      default:
        return signInButtons(context);
    }
  }
}
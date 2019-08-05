import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _newPassword = '';
  final TextEditingController _newPasswordTextFieldController =
      TextEditingController();
  final TextEditingController _confirmTextFieldController =
      TextEditingController();
  bool _savingNewPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password"),
      ),
      body: ScopedModelDescendant(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: <Widget>[
                buildNewPasswordField(),
                buildConfirmPasswordField(),
                submitButton()
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget buildNewPasswordField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter password';
        }
        if (value.length < 6) {
          return 'Password should be atleast 6 characters long';
        }
      },
      obscureText: true,
      controller: _newPasswordTextFieldController,
      decoration: InputDecoration(
        labelText: "New Password",
      ),
      onSaved: (String value) {
        setState(() {
          _newPassword = value;
        });
      },
    );
  }

  Widget buildConfirmPasswordField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please confirm new password';
        }
        if (_newPasswordTextFieldController.text !=
            _confirmTextFieldController.text) {
          return 'Password does not match';
        }
      },
      obscureText: true,
      controller: _confirmTextFieldController,
      decoration: InputDecoration(
        labelText: "Confirm Password",
      ),
    );
  }

  Widget submitButton() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
          color: Colors.orange,
          disabledColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            'SET NEW PASSWORD',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _savingNewPassword
              ? null
              : () async {
                  setNewPassword(context, model);
                });
    });
  }

  setNewPassword(context, model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      _savingNewPassword = true;
    });
    Map<dynamic, dynamic> updateResponse;
    _formKey.currentState.save();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> payload = Map();

    payload = {
      'spree_user': {'email': email, 'password': _newPassword}
    };
    String url = Settings.SERVER_URL + "auth/change_password";

    http.Response response =
        await http.put(url, headers: headers, body: json.encode(payload));

    setState(() {
      _savingNewPassword = false;
    });
    if (response.statusCode == 200) {
      updateResponse = json.decode(response.body);
      String successMsg = updateResponse['status'];
      Navigator.popUntil(
          context, ModalRoute.withName(Navigator.defaultRouteName));
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(successMsg)));
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to change password")));
    }
  }
}

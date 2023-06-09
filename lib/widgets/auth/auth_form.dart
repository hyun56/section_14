import 'dart:io';

import 'package:flutter/material.dart';
import 'package:section_14/widgets/pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  //const AuthForm();

  const AuthForm(
    this.submitFn,
    this.isLoading,
  ); // add const

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn; // 아무것도 반환하지 않는 함수..?

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  final _userEmail = ''; // var -> final
  var _userName = '';
  var _userPassword = '';
  late File _userImageFile; // add late

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate(); // add !
    FocusScope.of(context).unfocus(); // 양식 제출할 때 키보드 닫히게..?

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        // Scaffold -> ScaffoldMessenger
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context)
              .colorScheme
              .error, // errorColor -> colorScheme.error
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save; // add !
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _userImageFile, _isLogin, context);

      // Use those values to send out auth request ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20), // add const
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16), // add const
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // 필요한 만큼만 늘어난다
                children: <Widget>[
                  if (!_isLogin) UserImagePicker(_pickedImage),
                  TextFormField(
                    key: const ValueKey('email'), // add const
                    autocorrect: false, // 자동 수정 기능
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        // add !
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      // add const
                      labelText: 'Email address',
                    ),
                    onSaved: (value) {
                      _userPassword = value!; // add !
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey('username'), // add const
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          // add !
                          return 'Password enter at least 4 characters.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          labelText: 'Username'), // add const
                      onSaved: (value) {
                        _userName = value!; // add !
                      },
                    ),
                  TextFormField(
                    key: const ValueKey('password'), // add const
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        // add !
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Password'), // add const
                    obscureText: true, // 사용자가 입력한 텍스트 숨기기
                    onSaved: (value) {
                      _userPassword = value!; // add !
                    },
                  ),
                  const SizedBox(height: 12), // add const
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    ElevatedButton(
                      // RaisedButton -> ElevatedButton
                      onPressed: _trySubmit,
                      child: Text(_isLogin ? 'Login' : 'Signup'), // 윗줄이랑 위치 변경
                    ),
                  if (!widget.isLoading)
                    TextButton(
                      // FlatButton -> TextButton
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      style: TextButton.styleFrom(
                        //primary: Theme.of(context).primaryColor, // 글자색
                        textStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'I already have an account'),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

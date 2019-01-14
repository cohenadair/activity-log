import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';

class LoginPage extends StatefulWidget {
  final AuthManager _authManager;

  LoginPage(this._authManager);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageMode {
  static var loggingIn = _LoginPageMode(
    title: 'Login',
    buttonText: 'Login',
    questionText: 'Don\'t have an account?',
    actionText: 'Sign up.'
  );

  static var signingUp = _LoginPageMode(
    title: 'Sign up',
    buttonText: 'Sign up',
    questionText: 'Already have an account?',
    actionText: 'Login.'
  );

  final String title;
  final String buttonText;
  final String questionText;
  final String actionText;

  _LoginPageMode({
    @required this.title,
    @required this.buttonText,
    @required this.questionText,
    @required this.actionText
  });
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  _LoginPageMode _mode = _LoginPageMode.loggingIn;

  String _errorText;
  bool _isLoading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Page(
      child: Form(
        key: _formKey,
        autovalidate: !_isLoggingIn,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _mode.title,
              style: Theme.of(context).textTheme.title,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              validator: _validateEmail,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              validator: _validatePassword,
            ),
            _errorText == null ? Container() : Padding(
              padding: Dimen.defaultTopPadding,
              child: Text(
                _errorText,
                style: Style.textError,
              ),
            ),
            Padding(
              padding: Dimen.defaultVerticalPadding,
              child: Row(
                children: <Widget>[
                  Button(
                    text: _mode.buttonText,
                    onPressed: _handleLoginOrSignUp,
                  ),
                  Padding(
                    padding: Dimen.defaultLeftPadding,
                    child: SizedBox.fromSize(
                      size: Size(20, 20),
                      child: _isLoading ? CircularProgressIndicator(
                        strokeWidth: 2,
                      ) : Container(),
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _mode.questionText,
                    style: TextStyle(
                      color: Colors.black,
                    )
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: _mode.actionText,
                    style: Style.textHyperlink,
                    recognizer: TapGestureRecognizer()..onTap = () {
                      setState(() {
                        _toggleMode();
                      });
                    }
                  )
                ]
              ),
            ),
          ],
        )
      )
    );
  }

  bool get _isLoggingIn => _mode == _LoginPageMode.loggingIn;

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _toggleMode() {
    setState(() {
      _mode = _isLoggingIn
          ? _LoginPageMode.signingUp : _LoginPageMode.loggingIn;
      _errorText = null;
    });
  }

  void _login() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _setIsLoading(true);

    widget._authManager.login(_emailController.text, _passwordController.text)
      .then((AuthError error) {
        setState(() {
          _isLoading = false;
          if (error == null) {
            return;
          }

          switch (error) {
            case AuthError.unknown:
              _errorText = 'Unknown login error. Check your ' +
                  'connection and try again.';
              break;
            case AuthError.invalidCredentials:
              _errorText = 'Invalid login credentials';
              break;
          }
        });
      });
  }

  void _signUp() {
    _setIsLoading(true);

    widget._authManager.signUp(_emailController.text, _passwordController.text)
      .then((AuthError error) {
        setState(() {
          _isLoading = false;
          if (error == null) {
            return;
          }

          _errorText = 'Unknown sign up error. Check your ' +
              'connection and try again.';
        });
      });
  }

  void _handleLoginOrSignUp() {
    if (_isLoggingIn) {
      _login();
    } else {
      _signUp();
    }
  }

  String _validateEmail(String email) {
    if (StringUtils.isEmpty(_emailController.text)) {
      return 'Email address required';
    }

    // Validation isn't necessary when logging in.
    if (_isLoggingIn) {
      return null;
    }

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(email)) {
      return 'Invalid email format';
    }

    return null;
  }

  String _validatePassword(String password) {
    if (StringUtils.isEmpty(_passwordController.text)) {
      return 'Password is required';
    }

    // Validation isn't necessary when logging in.
    if (_isLoggingIn) {
      return null;
    }

    if (password.length < 6) {
      return 'Password length must be greater than 6 characters';
    }

    return null;
  }
}
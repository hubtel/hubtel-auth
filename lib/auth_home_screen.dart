import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hubtel_auth/models/auth_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthHomeScreen extends StatefulWidget {
  final String appId;

  const AuthHomeScreen({Key? key, required this.appId}) : super(key: key);

  @override
  State<AuthHomeScreen> createState() => _AuthHomeScreenState();
}

class _AuthHomeScreenState extends State<AuthHomeScreen> {
  late final WebViewController _controller;
  int loadingPercentage = 0;
  bool stopLoading = false;

  @override
  void initState() {
    _controller = WebViewController()
      ..loadHtmlString(_generateHtmlForLogin(appId: widget.appId))
      ..setNavigationDelegate(
        NavigationDelegate(
            onUrlChange: (url) {},
            onPageFinished: (url) {
              setState(() {
                stopLoading = true;
              });
            }),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        "AuthCompleted",
        onMessageReceived: (javascriptMessage) {
          final Map<String, dynamic>? decodedMessage =
              jsonDecode(javascriptMessage.message);

          print(decodedMessage);
          try {
            final authData = AuthData.fromJson(decodedMessage);
            Navigator.pop(context, authData);
          } catch (e) {
            print(e);
          }
        },
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
          backgroundColor: Colors.white,
        ),
        body: stopLoading
            ? WebViewWidget(controller: _controller)
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              ));
  }

  static String _generateHtmlForLogin({required String appId}) {
    return """
    <!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <style type="text/css">
    body, html {
      margin: 0;
      padding: 0;
      height: 100%;
      overflow: hidden;
    }

    #frame {
      position: absolute;
      left: 0;
      right: 0;
      bottom: 0;
      top: 0px;
    }
  </style>
</head>
<body>
<div id="frame">
  <iframe src="https://auth.hubtel.com/$appId" frameborder="0" width="100%"
          height="100%"></iframe>
</div>
<script>
  window.onload = function () {
    window.addEventListener("message", function handler(event) {
      if (event.origin === "https://auth.hubtel.com" && event.data.data.token) {
        //On auth Success
        AuthCompleted.postMessage(JSON.stringify(event.data.data));
      }
    });
  }
</script>
</body>
</html>

    """;
  }
}

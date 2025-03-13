import 'package:flutter/material.dart';

class DemoPage extends StatefulWidget {
  final data;
  DemoPage(this.data);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Text(
          "${widget.data['username']},/ ${widget.data['title']},/ ${widget.data['location']},"),
    ));
  }
}

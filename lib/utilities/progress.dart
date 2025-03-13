import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Container circularProgress() {
  return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const SpinKitThreeBounce(
        color: Colors.grey,
        size: 35,
      )
      // const CircularProgressIndicator
      // (
      //  		valueColor: AlwaysStoppedAnimation(Colors.teal),
      // 	)
      );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.teal),
    ),
  );
}

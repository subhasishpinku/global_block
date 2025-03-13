import 'package:flutter/material.dart';

AppBar header(context, isAppTitle, titleText, removeBackButton) 
{
	return AppBar
	(
    	automaticallyImplyLeading: removeBackButton ? false : true,
      	title: Text
		(
        	isAppTitle ? 'Globe' : titleText,
        	style: TextStyle
			(
				color: Colors.white,
				fontFamily: isAppTitle ? "Signatra" : '',
				fontSize: isAppTitle ? 50.0 : 22.0,
        	),
        	overflow: TextOverflow.ellipsis,
      	),
		centerTitle: true,
		backgroundColor: Colors.teal
    );
}

import 'package:flutter/material.dart';
import 'package:hentaiz_viewer/view_models/application_view_model.dart';
import 'package:hentaiz_viewer/views/main_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final app =  MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainPage(),
    );
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => ApplicationViewModel(),)
      ],
      child: app,
    );
  }
}


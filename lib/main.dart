import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pac firebase',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Pac demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController name1=TextEditingController(),name2=TextEditingController();

  save()async{

    if(name1.text.isEmpty || name2.text.isEmpty){
      return;
    }
   var col= Firestore.instance.collection("users");
    Map<String,String> data=new Map();
    data['firstname']=name1.text;
    data['lastname']=name2.text;
    await col.add(data).then((value) {
      name1.clear();
      name2.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(

          children: <Widget>[
            SizedBox(height: 10.0,),
            Text(
              'Enter your names here:',
            ),
            Flexible(child:
                TextField(
                  controller: name1,
                  decoration: InputDecoration(
                    hintText: "First name"
                  ),
                )
            ),

            Flexible(child:
            TextField(
              controller: name2,
              decoration: InputDecoration(
                  hintText: "Last name"
              ),
            )
            ),
            RaisedButton(onPressed: save,color: Colors.blue,
              child: Text("Save data"),
            ),

            Expanded(child:
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("users").snapshots(),
                  builder: (context,snapshots){

                    if(snapshots.hasError){
                      return Center(child:Text("Error retrieving users",style: TextStyle(color: Colors.grey),));
                    }else if(snapshots.connectionState==ConnectionState.waiting){
                      return Center(child:Text("Loading users...",style: TextStyle(color: Colors.grey),));
                    }
                   else if(snapshots.hasData){
                      return snapshots.data.documents.length!=0? ListView.builder(
                        itemCount: snapshots.data.documents.length,
                          itemBuilder: (ctx,i){
                        return ListTile(
                          trailing:IconButton(icon: Icon(Icons.delete),onPressed: ()=>snapshots.data.documents[i].reference.delete(),),
                          leading: Icon(Icons.person),
                          title: Text(snapshots.data.documents[i].data['firstname']),
                          subtitle: Text(snapshots.data.documents[i].data['lastname']),
                        );
                      }):Center(child:Text("No users available",style: TextStyle(color: Colors.grey),));
                    }else{
                      return  Center(child: Text("Error getting data"),);
                    }

                  }
                )

            ),

          ],
        ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

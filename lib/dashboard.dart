import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:library_ms/loginscreen.dart';

//import 'package:library_ms/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:library_ms/booklist.dart';
import 'package:simple_coverflow/simple_coverflow.dart';

class MainPage extends StatefulWidget {
  static const String id = 'dash_board';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences sharedPreferences;
  final String url = 'https://lmssuiit.pythonanywhere.com/api/booklist';

  Future<List<List<dynamic>>> getBooks() async {
    sharedPreferences = await SharedPreferences.getInstance();
    http.Response response;
    String token = sharedPreferences.getString("token");
    String sessionId = sharedPreferences.getString("sessionid");
    String rollNo = sharedPreferences.getString("rollno");
    Map<String, String> header = {
      "Accept": "application/json",
      "Cookie": "csrftoken=$token;sessionid=$sessionId"
    };
    String bookUrl = "$url/$rollNo";
    try {
      response = await http.get(Uri.encodeFull(bookUrl), headers: header);
    } catch (e) {
      throw Exception("Failed to connect to internet");
    }
    print("Body: ${response.body}");
    print("Status: ${response.statusCode}");
    print("Header: ${response.headers}");
    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(res["data"] ?? "Failed to fetch list of books");
    }
    if (!res["success"]) {
      throw Exception(res["data"] ?? "Something went wrong");
    }
    return [res['issues'], res['returned']];
  }



  Widget getBooksListToDisplay(List<List<dynamic>> data){
    List issues = data[0];
    List returned = data[1];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child:  Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(

                child: Text("Issues:",style: GoogleFonts.dancingScript(fontSize: 40, color: Colors.black,fontWeight: FontWeight.bold))),
            Expanded(
              child:
              ListView.builder(
                itemCount: issues == null ? 0 : issues.length,

                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child:
                    Card(
                      color: Colors.teal,
                      elevation: 15.0,
                      shadowColor: Colors.teal,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Book: ${issues[index][0]}",style: GoogleFonts.breeSerif(fontSize: 20, color: Colors.white)),
                              SizedBox(height: 10.0,),
                              Text("Issued date: ${issues[index][1]} ",style: TextStyle(color: Colors.white),),
                              Text("Due date: ${issues[index][2]}",style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            ),
            Center(child: Text("Returned:",style: GoogleFonts.dancingScript(fontSize: 40, color: Colors.black,fontWeight: FontWeight.bold))),
            Expanded(
              child: ListView.builder(
                itemCount: returned == null ? 0 : returned.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Card(
                      color: Colors.teal,
                      elevation: 15.0,
                      shadowColor: Colors.teal,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Book: ${returned[index][0]}",style: GoogleFonts.breeSerif(fontSize: 20, color: Colors.white)),
                              SizedBox(height: 5.0,),
                              Text("Issued date: ${returned[index][1]} ",style: TextStyle(color: Colors.white)),
                              Text("Returned date: ${returned[index][2]}",style: TextStyle(color: Colors.white)),
                              Text("Due date: ${returned[index][3]} ",style: TextStyle(color: Colors.white)),

                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("DASHBOARD", style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.black,
        actions: <Widget>[
          FlatButton(


            onPressed: () {
              sharedPreferences.clear();
              // sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (BuildContext context) => loginscreen()),
                  (Route<dynamic> route) => false);
            },
            child:Icon(Icons.logout,color: Colors.white,) ,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: FutureBuilder<List<List<dynamic>>>(
          future: getBooks(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              if(snapshot.hasError){
                return Center(child: Text(snapshot.error.toString()));
              }
              return getBooksListToDisplay(snapshot.data);
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      drawer: Drawer(

        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: Text('Name'),
              accountEmail: Text('email'),
              decoration: BoxDecoration(color: Colors.teal),
            ),
            new ListTile(
              title: Text(
                'Booklist',
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {
                Navigator.pushNamed(context, booklist.id);
//                PopupMenuButton(
//                  child: Center(child: Text('click here')),
//                  itemBuilder: (context) {
//                    return List.generate(5, (index) {
//                      return PopupMenuItem(
//                        child: Text('button no $index'),
//                      );
//                    });
//                  },
//                );
              },
            ),
            new ListTile(
              title: Text('Settings'),
              onTap: () {},
            ),
            

          ],

        ),
      ),
    );
  }
}

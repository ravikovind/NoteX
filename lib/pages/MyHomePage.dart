import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notex/Methods/AuthMethods.dart';
import 'package:notex/pages/AddNote.dart';
import 'package:http/http.dart' as http;
import 'package:notex/pages/SettingPage.dart';
import 'package:notex/pages/UpdateNote.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = "JoiUser";
  String xid = "JoiUser";
  bool isDeleting = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController _controller;
  AuthMethods _methods = AuthMethods();

  Future<String> getXID() async {
    var user = await _methods.getCurrentUser();
    String _xid = user.email.split("@")[0].toString();
    setState(() {
      xid = _xid;
    });
    return xid;
  }

  void initState() {
    super.initState();
    getXID();
    _controller = StreamController();
    Timer.periodic(Duration(seconds: 4), (_) => getData());
  }

  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            heroTag: "Add Note",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => AddNote(
                            xid: xid,
                          )));
            },
            icon: Icon(
              Icons.note_add,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            label: Text(
              "Add Note",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            )),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(kIsWeb ? "NoteX  Web" : "NoteX"),
          leading: IconButton(
            icon: Icon(
              Icons.account_circle_rounded,
              size: 24.0,
            ),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  barrierColor: Colors.transparent,
                  elevation: 24.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0)),
                  ),
                  builder: (context) {
                    return StreamBuilder(
                        stream: _methods.getCurrentUser().asStream(),
                        builder: (BuildContext context,
                            AsyncSnapshot<User> snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData ||
                              snapshot.data == null) {
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.025,
                                  ),
                                  ListTile(
                                      leading: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )),
                                  CircleAvatar(
                                    backgroundColor: Colors.orange,
                                    radius: MediaQuery.of(context).size.height *
                                        0.1550,
                                    child: CircleAvatar(
                                      radius:
                                          MediaQuery.of(context).size.height *
                                              0.1425,
                                      backgroundImage:
                                          NetworkImage(snapshot.data.photoURL),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        barrierColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0))),
                                            content: ListTile(
                                              onTap: () {
                                                _methods
                                                    .signOut()
                                                    .whenComplete(() {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                });
                                              },
                                              trailing: Icon(
                                                Icons.logout,
                                                color: Colors.redAccent,
                                                size: 16.0,
                                              ),
                                              leading: Text(
                                                "sign out",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.height *
                                                0.125),
                                    leading: Text(
                                      snapshot.data.displayName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.logout,
                                      size: 20.0,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              fullscreenDialog: true,
                                              builder: (BuildContext context) {
                                                return SettingsPage();
                                              }));
                                    },
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.height *
                                                0.125),
                                    trailing: Icon(
                                      Icons.settings,
                                      size: 20.0,
                                    ),
                                    leading: Text(
                                      "Settings",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        });
                  });
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 24.0,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (BuildContext context) {
                          return SettingsPage();
                        }));
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _controller.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(0xff6C63FF),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("There is some error!!"),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text("No Data Available"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return MaterialButton(
                  onLongPress: () {
                    showDialog(
                      barrierColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                              content: isDeleting
                                  ? CircularProgressIndicator()
                                  : ListTile(
                                      onTap: () async {
                                        setState(() {
                                          isDeleting = true;
                                        });
                                        var rs = await deleteNote(
                                            xid, snapshot.data[index]["ID"]);
                                        if (rs.toString() == "true") {
                                          Navigator.pop(context);
                                          final snackBar = SnackBar(
                                              backgroundColor: Colors.white,
                                              content: Text(
                                                'note will be delete',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                  fontFamily: "Lato",
                                                ),
                                              ));

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                          setState(() {
                                            isDeleting = false;
                                          });
                                        } else {
                                          Navigator.pop(context);
                                          final snackBar = SnackBar(
                                              backgroundColor: Colors.white,
                                              content: Text(
                                                  'something went wrong!!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily: "Lato",
                                                      fontSize: 16)));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        }
                                      },
                                      trailing: Icon(
                                        Icons.delete_forever,
                                        color: Colors.redAccent,
                                        size: 16.0,
                                      ),
                                      leading: Text(
                                        "Delete Note",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                            );
                          },
                        );
                      },
                    );
                  },
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => UpdateNote(
                                  xid: xid,
                                  id: snapshot.data[index]["ID"],
                                  title:
                                      snapshot.data[index]["TITLE"].toString(),
                                  note: snapshot.data[index]["NOTE"].toString(),
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.all(4.0),
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: Column(
                      children: [
                        Text(
                          snapshot.data[index]["TITLE"].toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          snapshot.data[index]["NOTE"].toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.orange
                                  : Colors.black,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<String> deleteNote(String xid, String id) async {
    print(xid);
    var url = Uri.https(
        'note-x.000webhostapp.com', '/deleteNote.php', {'q': '{http}'});
    try {
      var rs = await http.post(
        url,
        body: {"xid": xid, "id": id},
      );
      return rs.body.toString();
    } catch (e) {
      return e.toString();
    }
  }

  getData() async {
    var url =
        Uri.https('note-x.000webhostapp.com', '/getNotes.php', {'q': '{http}'});
    try {
      var response = await http.post(
        url,
        body: {"xid": xid},
      );
      var data = jsonDecode(response.body);
      return _controller.add(data);
    } catch (e) {
      print(e.toString());
    }
  }
}

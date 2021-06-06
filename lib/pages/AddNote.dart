import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AddNote extends StatefulWidget {
  final String xid;

  const AddNote({Key key, @required this.xid}) : super(key: key);

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController _title;
  TextEditingController _note;
  bool isSaving = false;

  void initState() {
    super.initState();
    _title = TextEditingController();
    _note = TextEditingController();
  }

  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Container(
          padding: EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _title,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(32),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration.collapsed(
                      hintText: 'title',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: Color(0xffF9A826),
                      )),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: _note,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(255),
                  ],
                  maxLines: 10,
                  maxLength: 255,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration.collapsed(
                      hintText: 'write note here',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: Color(0xffF9A826),
                      )),
                ),
                SizedBox(
                  height: 16,
                ),
                isSaving
                    ? CircularProgressIndicator(
                        backgroundColor: Color(0xff6C63FF),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          padding: EdgeInsets.all(12.0),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          elevation: 4.0,
                          color: Colors.white,
                          onPressed: () async {
                            if (mounted)
                              setState(() {
                                isSaving = true;
                              });
                            print(_title.text);
                            print(_note.text);
                            print(widget.xid);
                            if (_title.text == "" || _note.text == "") {
                              final snackBar = SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    'title and note must not be empty!!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontFamily: "Lato",
                                    ),
                                  ));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              await addNote(
                                  _title.text, _note.text, widget.xid);
                            }
                            _title.clear();
                            _note.clear();

                            Navigator.pop(context);
                            if (mounted)
                              setState(() {
                                isSaving = false;
                              });
                          },
                          child: const Text(
                            'save',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xffF9A826),
                            ),
                          ),
                        ),
                      ),
                MaterialButton(
                  onPressed: () {
                    _title.clear();
                    _note.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('cancel'),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> addNote(String title, String note, String xid) async {
    var url =
        Uri.https('note-x.000webhostapp.com', '/addNote.php', {'q': '{http}'});
    try {
      var response = await http.post(
        url,
        body: {"title": title, "note": note, "xid": xid},
      );
      print(response.body.toString());
    } catch (e) {
      return print(e.toString() + " addx");
    }
  }
}


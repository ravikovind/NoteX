import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class UpdateNote extends StatefulWidget {
  final String xid;
  final String title;
  final String note;
  final String id;

  const UpdateNote(
      {Key key,
      @required this.xid,
      @required this.title,
      @required this.note,
      @required this.id})
      : super(key: key);

  @override
  _UpdateNoteState createState() => _UpdateNoteState();
}

class _UpdateNoteState extends State<UpdateNote> {
  TextEditingController _title;
  TextEditingController _note;
  bool isSaving = false;

  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.title);
    _note = TextEditingController(text: widget.note);
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
                    : MaterialButton(
                        padding: EdgeInsets.all(16.0),
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
                          var rs;
                          if (widget.title == _title.text &&
                              widget.note == _note.text) {
                          } else {
                            rs = await updateNote(
                                _title.text, _note.text, widget.xid, widget.id);
                          }
                          _title.clear();
                          _note.clear();
                          Navigator.pop(context);
                          if (mounted)
                            setState(() {
                              isSaving = false;
                            });
                          if (rs.toString() == "true") {
                            final snackBar = SnackBar(
                                backgroundColor: Colors.white,
                                content: Text(
                                  'note will be Updated',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontFamily: "Lato",
                                  ),
                                ));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: const Text(
                          '  Update  ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xffF9A826),
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

  Future<String> updateNote(
    String title,
    String note,
    String xid,
    String id,
  ) async {
    var url = Uri.https(
        'note-x.000webhostapp.com', '/updateNote.php', {'q': '{http}'});
    try {
      var response = await http.post(
        url,
        body: {
          "title": title,
          "note": note,
          "xid": xid,
          "id": id,
        },
      );
      print(response.body.toString());
      return response.body;
    } catch (e) {
      print(e.toString() + " UpdateX");
      return e.toString() + " UpdateX";
    }
  }
}

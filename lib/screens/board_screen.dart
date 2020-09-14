import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('Board');
  TextEditingController nameInputController;
  TextEditingController titleController;
  TextEditingController descriptionController;
  @override
  void initState() {
    super.initState();
    nameInputController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Board'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(includeMetadataChanges: true),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            // ignore: deprecated_member_use
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              var dateTime = DateTime.fromMillisecondsSinceEpoch(
                  document.data()['timeStamp'].seconds * 1000);
              var dateFormatted = DateFormat('EEEE, MMM d, y').format(dateTime);

              TextEditingController nameInputController =
                  TextEditingController(text: document.data()['name']);
              TextEditingController titleController =
                  TextEditingController(text: document.data()['title']);
              TextEditingController descriptionController =
                  TextEditingController(text: document.data()['description']);

              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    height: 180,
                    child: Card(
                      elevation: 9,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Text(document
                                  .data()['title']
                                  .toString()[0]
                                  .toUpperCase()),
                            ),
                            title: Text(document.data()['title']),
                            subtitle: Text(document.data()['description']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('By ${document.data()['name']} '),
                                Text(dateFormatted)
                              ],
                            ),
                          ),
                          /*Text((dateFormatted == null)
                              ? ""
                              : dateFormatted.toString()),*/
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.edit,
                                    size: 25,
                                  ),
                                  onPressed: () async {
                                    // print(document.id);
                                    await showDialog(
                                        context: context,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30.0))),
                                          child: AlertDialog(
                                            contentPadding:
                                                EdgeInsets.all(10.0),
                                            content: Column(
                                              children: [
                                                Text('Please update the form.'),
                                                Expanded(
                                                  child: TextField(
                                                    autofocus: true,
                                                    autocorrect: true,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            'Your Name*'),
                                                    controller:
                                                        nameInputController,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextField(
                                                    autofocus: true,
                                                    autocorrect: true,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    decoration: InputDecoration(
                                                        labelText: 'Title*'),
                                                    controller: titleController,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextField(
                                                    autofocus: true,
                                                    autocorrect: true,
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            'Description*'),
                                                    controller:
                                                        descriptionController,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              FlatButton(
                                                onPressed: () {
                                                  nameInputController.clear();
                                                  titleController.clear();
                                                  descriptionController.clear();
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  if (nameInputController
                                                          .text.isNotEmpty &&
                                                      titleController
                                                          .text.isNotEmpty &&
                                                      descriptionController
                                                          .text.isNotEmpty) {
                                                    FirebaseFirestore.instance
                                                        .collection('Board')
                                                        .doc(document.id)
                                                        .update({
                                                      'name':
                                                          nameInputController
                                                              .text,
                                                      'title':
                                                          titleController.text,
                                                      'description':
                                                          descriptionController
                                                              .text,
                                                      'timeStamp':
                                                          DateTime.now(),
                                                    }).then((response) {
                                                      Navigator.pop(context);
                                                    }).catchError((error) =>
                                                            print('Error'));
                                                  }
                                                },
                                                child: Text('Update'),
                                              ),
                                            ],
                                          ),
                                        ));
                                  }),
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.trashAlt,
                                    size: 25,
                                  ),
                                  onPressed: () async {
                                    //print(document.id);
                                    await FirebaseFirestore.instance
                                        .collection('Board')
                                        .doc(document.id)
                                        .delete()
                                        .then((value) => print("User Deleted"))
                                        .catchError((error) => print(
                                            "Failed to delete user: $error"));
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () => _showDialog(context),
        child: Icon(FontAwesomeIcons.pen),
      ),
    );
  }

  _showDialog(BuildContext context) async {
    await showDialog(
        context: context,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          child: AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            content: Column(
              children: [
                Text('Please fill up the form.'),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    autocorrect: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Your Name*'),
                    controller: nameInputController,
                  ),
                ),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    autocorrect: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Title*'),
                    controller: titleController,
                  ),
                ),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    autocorrect: true,
                    decoration: InputDecoration(labelText: 'Description*'),
                    controller: descriptionController,
                  ),
                ),
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  nameInputController.clear();
                  titleController.clear();
                  descriptionController.clear();
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  if (nameInputController.text.isNotEmpty &&
                      titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    FirebaseFirestore.instance.collection('Board').add({
                      'name': nameInputController.text,
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'timeStamp': DateTime.now(),
                    }).then((response) {
                      print(response.id);
                      nameInputController.clear();
                      titleController.clear();
                      descriptionController.clear();
                      Navigator.pop(context);
                    }).catchError((error) => print('Error'));
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ));
  }
}

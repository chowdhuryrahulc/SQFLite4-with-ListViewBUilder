// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sqffflittte4/database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DBManager dbManager = DBManager();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Student? student;
  List<Student>? studlist;
  int? updateIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQFlite Demo"),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (val) =>
                        val!.isNotEmpty ? null : 'Name Should Not Be Empty',
                  ),
                  TextFormField(
                    controller: _courseController,
                    decoration: InputDecoration(labelText: 'Course'),
                    validator: (val) =>
                        val!.isNotEmpty ? null : 'Course Should Not Be Empty',
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _submitStudent(context);
                      },
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text('Submit')),
                      style: ElevatedButton.styleFrom(
                          // primary: Colors.amber,
                          textStyle: TextStyle(color: Colors.white),
                          alignment: Alignment.center)),
                  FutureBuilder(
                      future: dbManager.getStudentList(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          studlist = snapshot.data; //TODO
                          return ListView.builder(
                              //Acts as for loop
                              shrinkWrap: true,
                              itemCount: studlist!.length,
                              itemBuilder: (BuildContext context, int index) {
                                Student st = studlist![index]; //TODO
                                print(st.course);
                                return Card(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Name: ${st.name}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text('Course: ${st.course}',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            _nameController.text = st.name;
                                            _courseController.text = st.course;
                                            //TODO
                                            student =
                                                st; //st assighned to global student object
                                            updateIndex = index;
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blueAccent,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            dbManager.deleteStudent(st
                                                .id!); //? Delete from Database
                                            setState(() {
                                              studlist!.removeAt(
                                                  index); //? Remove from the List that is displayed
                                            });
                                          },
                                          icon: Icon(Icons.delete,
                                              color: Colors.red))
                                    ],
                                  ),
                                );
                              });
                        }
                        return CircularProgressIndicator();
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitStudent(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (student == null) {
        Student st =
            Student(name: _nameController.text, course: _courseController.text);
        dbManager.insertStudent(st).then((id) {
          setState(() {
            _nameController.clear();
            _courseController.clear();
            print('Student added to Database $id');
          });
        });
      } else {
        // Student st =
        //     Student(name: _nameController.text, course: _courseController.text);

        student!.name = _nameController.text;
        student!.course = _courseController.text;
        // print(studlist);
        dbManager.updateStudent(student!).then((id) => {
              setState(() {
                studlist?[updateIndex!].name = _nameController.text;
                studlist?[updateIndex!].course = _courseController.text;
                print(studlist?[updateIndex!].course);
              }),
              _nameController.clear(),
              _courseController.clear(),
              student = null
            });
      }
    }
  }
}

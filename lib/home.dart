import 'package:crud/student.dart';
import 'package:flutter/material.dart';
import './db_helper.dart';
import './student.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isUpdating;
  int curUserId;
  String name;
  var dbHelper;
  final formKey = GlobalKey<FormState>();
  Future<List<Student>> students;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }


  clearName() {
    controller.text = '';
  }

  refreshList() {
    setState(() {
      students = dbHelper.getStudents();
    });
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Student s = Student(curUserId, name);
        dbHelper.update(s);
        setState(() {
          isUpdating = false;
        });
      } else {
        Student s = Student(null, name);
        dbHelper.save(s);
      }
      clearName();
      refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Student name"),
                      validator: (val) => val.length == 0 ? 'Enter Name' : null,
                      onSaved: (val) => name = val,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          onPressed: validate,
                          child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              isUpdating = false;
                            });
                            clearName();
                          },
                          child: Text('CANCEL'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            FutureBuilder(
                future: students,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Student> studentes = snapshot.data;
                    return DataTable(
                      columns: [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Delete")),
                      ],
                      rows: studentes
                          .map(
                            (student) => DataRow(cells: [
                              DataCell(
                                Text(student.name),
                                onTap: () {
                                  setState(() {
                                    isUpdating = true;
                                    curUserId = student.id;
                                  });
                                  controller.text = student.name;
                                },
                              ),
                              DataCell(IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  dbHelper.delete(student.id);
                                  refreshList();
                                },
                              )),
                            ]),
                          )
                          .toList(),
                    );
                  }
                  if (null == snapshot.data || snapshot.data.length == 0) {
                    return Text("No Data Found");
                  }

                  return CircularProgressIndicator();
                },
              ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: 
            // )
          ],
        ),
      ),
    );
  }
}

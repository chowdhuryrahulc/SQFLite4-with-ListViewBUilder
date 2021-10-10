// ignore_for_file: prefer_conditional_assignment

import 'dart:io';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  Database? _database;

  Future openDb() async {
    if (_database == null) {
      //If Database doesnt exist, then only create the Database
      _database = await openDatabase(
          join(await getDatabasesPath(), "Student.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE student (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, course TEXT)");
      });
    }
  }

  Future<int> insertStudent(Student student) async {
    await openDb();
    return await _database!.insert('student', student.toMap());
  }

  Future<List<Student>> getStudentList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database!.query('student');
    return List.generate(maps.length,
        (i) => Student(name: maps[i]['name'], course: maps[i]['course']));
  }

  Future<int> updateStudent(Student student) async {
    await openDb();
    // print();
    return await _database!.update('student', student.toMap(),
        where: 'id=?', whereArgs: [student.id]);
  }

  Future<void> deleteStudent(int id) async {
    await openDb();
    await _database!.delete('student', where: 'id=?', whereArgs: [id]);
  }
}

class Student {
  int? id;
  String name;
  String course;

  Student({this.id, required this.name, required this.course});
  Map<String, dynamic> toMap() {
    return {'name': name, 'course': course};
  }
}

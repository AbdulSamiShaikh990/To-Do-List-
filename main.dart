import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TODO App',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> todosList = [];

  @override
  void initState() {
    super.initState();
    _loadToDoItems(); // Load the ToDo items on app startup
  }

  void _loadToDoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoListJson = prefs.getString('todoList');

    if (todoListJson != null) {
      List<dynamic> todoListMap = json.decode(todoListJson);
      setState(() {
        todosList = todoListMap.map((item) => ToDo.fromJson(item)).toList();
      });
    }
  }

  void _saveToDoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todoListJson = json.encode(todosList);
    await prefs.setString('todoList', todoListJson);
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      todosList[index].isDone = !todosList[index].isDone;
      _saveToDoItems(); // Save the updated ToDo items
    });
  }

  void _deleteTask(int index) {
    setState(() {
      todosList.removeAt(index);
      _saveToDoItems(); // Save the updated ToDo items
    });
  }

  void _addTask(String taskText) {
    setState(() {
      todosList.add(ToDo(id: DateTime.now().toString(), todoText: taskText));
      _saveToDoItems(); // Save the updated ToDo items
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    TextEditingController taskTextController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a New ToDo Item'),
          content: TextField(
            controller: taskTextController,
            decoration: InputDecoration(labelText: 'Write Your Task Here :'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (taskTextController.text.isNotEmpty) {
                  _addTask(taskTextController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: _buildAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            searchBox(),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: 50,
                      bottom: 20,
                    ),
                    child: Text(
                      'All TODO\'S',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                  ),
                  for (ToDo todo in todosList)
                    ToDoItem(
                      toDo: todo,
                      onToggle: () =>
                          _toggleTaskStatus(todosList.indexOf(todo)),
                      onDelete: () => _deleteTask(todosList.indexOf(todo)),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (query) {
          // Implement your filtering logic here
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blueGrey,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            color: Colors.black,
            size: 30,
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('assets/images/sami.jpg'),
            ),
          ),
        ],
      ),
    );
  }
}

class ToDo {
  String id;
  String todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
    };
  }
}

class ToDoItem extends StatelessWidget {
  final ToDo toDo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  ToDoItem({
    required this.toDo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          onToggle();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          toDo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: Colors.blue,
        ),
        title: Text(
          toDo.todoText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            decoration: toDo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.symmetric(vertical: 8),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete();
            },
          ),
        ),
      ),
    );
  }
}

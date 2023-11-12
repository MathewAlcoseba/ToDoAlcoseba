import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'todo_item.dart';
import 'todo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Hive.registerAdapter(TodoItemAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive TODO List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _todoService.getAllTodos(),
        builder: (context, AsyncSnapshot<List<TodoItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TodoListPage(snapshot.data ?? []);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  final List<TodoItem> todos;

  TodoListPage(this.todos);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive TODO List"),
        backgroundColor: Colors.blueGrey,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
        builder: (context, Box<TodoItem> box, _) {
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              var todo = box.getAt(index);
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  title: Text(
                    todo!.title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (val) {
                      _todoService.toggleCompleted(index, todo);
                    },
                    activeColor: Colors.blueGrey,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _todoService.deleteTodo(index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Todo'),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Enter todo item",
                  ),
                ),
                actions: [
                  ElevatedButton(
                    child: Text('Add'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey,
                    ),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        var todo = TodoItem(_controller.text);
                        _todoService.addTodo(todo);
                        _controller.clear();
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              );
            }
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

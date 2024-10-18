import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painting Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PaintingListPage(),
    );
  }
}

class PaintingListPage extends StatefulWidget {
  @override
  _PaintingListPageState createState() => _PaintingListPageState();
}

class _PaintingListPageState extends State<PaintingListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _paintings = [];

  @override
  void initState() {
    super.initState();
    _loadPaintings();
  }

  void _loadPaintings() async {
    var paintings = await _dbHelper.getPaintings();
    setState(() {
      _paintings = paintings;
    });
  }

  void _addPainting() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddPaintingPage()))
        .then((_) {
      _loadPaintings(); // Load lại danh sách sau khi thêm
    });
  }

  void _updatePainting(Map<String, dynamic> painting) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => UpdatePaintingPage(painting: painting),
    ))
        .then((_) {
      _loadPaintings(); // Load lại danh sách sau khi cập nhật
    });
  }

  void _deletePainting(int id) async {
    await _dbHelper.deletePainting(id);
    _loadPaintings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Painting Art Manager'),
        backgroundColor: Colors.cyanAccent,
      ),
      body: ListView.builder(
        itemCount: _paintings.length,
        itemBuilder: (context, index) {
          final painting = _paintings[index];
          return Card(

            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(painting['title']),
              subtitle: Text('Price: ${painting['price']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _updatePainting(painting),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePainting(painting['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPainting,
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.blueGrey, // Đổi màu nền ở đây
    );
  }
}

class AddPaintingPage extends StatefulWidget {
  @override
  _AddPaintingPageState createState() => _AddPaintingPageState();
}

class _AddPaintingPageState extends State<AddPaintingPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  double _price = 0.0;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _savePainting() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _dbHelper.addPainting(_title, _description, _price);
      Navigator.of(context).pop(); // Quay lại danh sách
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Painting'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePainting,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdatePaintingPage extends StatefulWidget {
  final Map<String, dynamic> painting;

  UpdatePaintingPage({required this.painting});

  @override
  _UpdatePaintingPageState createState() => _UpdatePaintingPageState();
}

class _UpdatePaintingPageState extends State<UpdatePaintingPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late double _price;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _title = widget.painting['title'];
    _description = widget.painting['description'];
    _price = widget.painting['price'];
  }

  void _updatePainting() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _dbHelper.updatePainting(widget.painting['id'], _title, _description, _price);
      Navigator.of(context).pop(); // Quay lại danh sách
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Painting'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                initialValue: _title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _description,
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                initialValue: _price.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePainting,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

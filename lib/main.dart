import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookmark Widget App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> bookmarks = [];
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _loadGroups();
  }

  void _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks = (prefs.getStringList('bookmarks') ?? [])
          .map((e) => Map<String, dynamic>.from(json.decode(e)))
          .toList();
    });
  }

  void _loadGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      groups = (prefs.getStringList('groups') ?? [])
          .map((e) => Map<String, dynamic>.from(json.decode(e)))
          .toList();
    });
  }

  void _addBookmark(String url, String name) async {
    setState(() {
      bookmarks.add({'url': url, 'name': name});
    });
    await _saveBookmarks();
    await _updateWidget();
  }

  void _addGroup(String name) async {
    setState(() {
      groups.add({'name': name, 'bookmarks': []});
    });
    await _saveGroups();
    await _updateWidget();
  }

  Future<void> _saveBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'bookmarks', bookmarks.map((e) => json.encode(e)).toList());
  }

  Future<void> _saveGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'groups', groups.map((e) => json.encode(e)).toList());
  }

  Future<void> _updateWidget() async {
    await HomeWidget.saveWidgetData<String>('bookmarks', json.encode(bookmarks));
    await HomeWidget.saveWidgetData<String>('groups', json.encode(groups));
    await HomeWidget.updateWidget(
      name: 'BookmarkWidgetProvider',
      iOSName: 'BookmarkWidget',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark Widget App')),
      body: ListView(
        children: [
          ...bookmarks.map((bookmark) => ListTile(
                title: Text(bookmark['name']),
                onTap: () => _launchUrl(bookmark['url']),
              )),
          ...groups.map((group) => ListTile(
                title: Text(group['name']),
                onTap: () => _showGroupModal(group),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bookmark or Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Add Bookmark'),
              onPressed: () {
                Navigator.pop(context);
                _showBookmarkDialog();
              },
            ),
            ElevatedButton(
              child: const Text('Add Group'),
              onPressed: () {
                Navigator.pop(context);
                _showGroupDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarkDialog() {
    TextEditingController urlController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              _addBookmark(urlController.text, nameController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGroupDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Group Name'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              _addGroup(nameController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGroupModal(Map<String, dynamic> group) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: ListView(
          children: [
            Text(group['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...group['bookmarks'].map((bookmark) => ListTile(
              title: Text(bookmark['name']),
              onTap: () => _launchUrl(bookmark['url']),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
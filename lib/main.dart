import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:home_widget/home_widget.dart';
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
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
    await _updateWidget(name, url, isGroup: false);
  }

  void _addGroup(String name) async {
    setState(() {
      groups.add({'name': name, 'bookmarks': []});
    });
    await _saveGroups();
    await _updateWidget(name, '', isGroup: true);
  }

  void _editBookmark(int index, String url, String name) async {
    setState(() {
      bookmarks[index] = {'url': url, 'name': name};
    });
    await _saveBookmarks();
    await _updateWidget(name, url, isGroup: false);
  }

  void _editGroup(int index, String name) async {
    setState(() {
      groups[index]['name'] = name;
    });
    await _saveGroups();
    await _updateWidget(name, '', isGroup: true);
  }

  void _deleteBookmark(int index) async {
    String name = bookmarks[index]['name'];
    setState(() {
      bookmarks.removeAt(index);
    });
    await _saveBookmarks();
    await _removeWidget(name);
  }

  void _deleteGroup(int index) async {
    String name = groups[index]['name'];
    setState(() {
      groups.removeAt(index);
    });
    await _saveGroups();
    await _removeWidget(name);
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

  Future<void> _updateWidget(String name, String url,
      {required bool isGroup}) async {
    // await HomeWidget.saveWidgetData<String>('${name}_type', isGroup ? 'group' : 'bookmark');
    // await HomeWidget.saveWidgetData<String>('${name}_url', url);
    // await HomeWidget.updateWidget(
    //   name: 'BookmarkWidgetProvider',
    //   iOSName: 'BookmarkWidget',
    //   qualifiedAndroidName: 'com.ando.devs.web_access.BookmarkWidgetProvider',
    // );
  }

  Future<void> _removeWidget(String name) async {
    // await HomeWidget.saveWidgetData<String?>('${name}_type', null);
    // await HomeWidget.saveWidgetData<String?>('${name}_url', null);
    // await HomeWidget.updateWidget(
    //   name: 'BookmarkWidgetProvider',
    //   iOSName: 'BookmarkWidget',
    //   qualifiedAndroidName: 'com.ando.devs.web_access.BookmarkWidgetProvider',
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark Widget App')),
      body: ListView(
        children: [
          ...bookmarks.asMap().entries.map((entry) => ListTile(
                title: Text(entry.value['name']),
                onTap: () => _launchUrl(entry.value['url']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          _showBookmarkDialog(editIndex: entry.key),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteBookmark(entry.key),
                    ),
                  ],
                ),
              )),
          ...groups.asMap().entries.map((entry) => ListTile(
                title: Text(entry.value['name']),
                onTap: () => _showGroupModal(entry.value, entry.key),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showGroupDialog(editIndex: entry.key),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteGroup(entry.key),
                    ),
                  ],
                ),
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

  void _showBookmarkDialog({int? editIndex}) {
    TextEditingController urlController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    if (editIndex != null) {
      urlController.text = bookmarks[editIndex]['url'];
      nameController.text = bookmarks[editIndex]['name'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null ? 'Add Bookmark' : 'Edit Bookmark'),
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
            child: Text(editIndex == null ? 'Add' : 'Save'),
            onPressed: () {
              if (editIndex == null) {
                _addBookmark(urlController.text, nameController.text);
              } else {
                _editBookmark(
                    editIndex, urlController.text, nameController.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGroupDialog({int? editIndex}) {
    TextEditingController nameController = TextEditingController();

    if (editIndex != null) {
      nameController.text = groups[editIndex]['name'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null ? 'Add Group' : 'Edit Group'),
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
            child: Text(editIndex == null ? 'Add' : 'Save'),
            onPressed: () {
              if (editIndex == null) {
                _addGroup(nameController.text);
              } else {
                _editGroup(editIndex, nameController.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGroupModal(Map<String, dynamic> group, int groupIndex) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Text(group['name'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [
                  ...group['bookmarks'].asMap().entries.map((entry) => ListTile(
                        title: Text(entry.value['name']),
                        onTap: () => _launchUrl(entry.value['url']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showBookmarkDialogInGroup(
                                  groupIndex, entry.key),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteBookmarkFromGroup(
                                  groupIndex, entry.key),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            ElevatedButton(
              child: Text('Add Bookmark to Group'),
              onPressed: () => _showBookmarkDialogInGroup(groupIndex),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarkDialogInGroup(int groupIndex, [int? editIndex]) {
    TextEditingController urlController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    if (editIndex != null) {
      urlController.text = groups[groupIndex]['bookmarks'][editIndex]['url'];
      nameController.text = groups[groupIndex]['bookmarks'][editIndex]['name'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null
            ? 'Add Bookmark to Group'
            : 'Edit Bookmark in Group'),
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
            child: Text(editIndex == null ? 'Add' : 'Save'),
            onPressed: () {
              if (editIndex == null) {
                _addBookmarkToGroup(
                    groupIndex, urlController.text, nameController.text);
              } else {
                _editBookmarkInGroup(groupIndex, editIndex, urlController.text,
                    nameController.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _addBookmarkToGroup(int groupIndex, String url, String name) async {
    setState(() {
      groups[groupIndex]['bookmarks'].add({'url': url, 'name': name});
    });
    await _saveGroups();
  }

  void _editBookmarkInGroup(
      int groupIndex, int bookmarkIndex, String url, String name) async {
    setState(() {
      groups[groupIndex]['bookmarks']
          [bookmarkIndex] = {'url': url, 'name': name};
    });
    await _saveGroups();
  }

  void _deleteBookmarkFromGroup(int groupIndex, int bookmarkIndex) async {
    setState(() {
      groups[groupIndex]['bookmarks'].removeAt(bookmarkIndex);
    });
    await _saveGroups();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

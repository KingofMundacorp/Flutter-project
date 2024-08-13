import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableActionPane extends StatelessWidget {
  const SlidableActionPane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // The action pane property is now called 'startActionPane' and 'endActionPane'
      // Replace 'actionPane' with either 'startActionPane' or 'endActionPane'
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) {
              // Handle archive action
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (context) {
              // Handle share action
            },
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) {
              // Handle more action
            },
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
            icon: Icons.more_horiz,
            label: 'More',
          ),
          SlidableAction(
            onPressed: (context) {
              // Handle delete action
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigoAccent,
            child: Text('delete'),
            foregroundColor: Colors.white,
          ),
          title: Text('Tile '),
          subtitle: Text('SlidableDrawerDelegate'),
        ),
      ),
    );
  }
}

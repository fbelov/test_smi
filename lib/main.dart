import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Model representing a dock item.
class DockItemModel {
  final IconData icon;
  bool visible;
  bool onHover;
  ValueKey<int>? key;

  DockItemModel({
    required this.icon,
    this.visible = true,
    this.onHover = false,
    this.key,
  });
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// List of items in the dock.
  List<DockItemModel> list = [
    DockItemModel(icon: Icons.person, key: ValueKey(0)),
    DockItemModel(icon: Icons.message, key: ValueKey(1)),
    DockItemModel(icon: Icons.call, key: ValueKey(2)),
    DockItemModel(icon: Icons.camera, key: ValueKey(3)),
    DockItemModel(icon: Icons.photo, key: ValueKey(4)),
  ];

  /// Handles reordering of items when drag ends.
  void onDragEnd(DockItemModel item) {
    setState(() {
      // Make the dragged item visible again.
      item.visible = true;

      // Remove the item from its old position and insert it at the new position.
      list.removeAt(item.key?.value ?? 0);
      list.insert(
        list.firstWhere((element) => element.onHover).key?.value ?? 0,
        DockItemModel(
          icon: item.icon,
          onHover: item.onHover,
          key: item.key,
          visible: item.visible,
        ),
      );

      // Update keys for all items in the list.
      for (var i = 0; i < list.length; i++) {
        list[i].key = ValueKey(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: list,
            builder: (item) {
              return MouseRegion(
                key: item.key,
                onEnter: (event) => setState(() => item.onHover = true),
                onExit: (event) => setState(() => item.onHover = false),
                child: Draggable(
                  key: Key(Uuid().v4()),
                  onDragStarted: () => setState(() => item.visible = false),
                  onDragEnd: (_) => onDragEnd(item),
                  onDraggableCanceled: (velocity, offset) => onDragEnd(item),
                  feedback: _buildDockItem(item),
                  child: item.visible
                      ? _buildDockItem(item)
                      : SizedBox(key: item.key, height: 48),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the UI of a dock item.
  Widget _buildDockItem(DockItemModel item) {
    return Container(
      key: item.key,
      constraints: BoxConstraints(minWidth: item.onHover ? 58 : 48),
      height: item.onHover ? 58 : 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[item.hashCode % Colors.primaries.length],
      ),
      child: Center(
        child: Icon(item.icon, color: Colors.white),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatelessWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map(builder).toList(),
      ),
    );
  }
}

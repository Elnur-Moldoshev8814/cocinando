import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/my_slidable_action.dart';
import '../widgets/text_styles.dart';

class TaskItem {
  String title;
  List<TaskItem> subtasks;
  bool isEditing;
  bool isExpanded;

  TaskItem({
    required this.title,
    this.subtasks = const [],
    this.isEditing = false,
    this.isExpanded = true,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtasks': subtasks.map((e) => e.toJson()).toList(),
    'isExpanded': isExpanded,
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    title: json['title'],
    subtasks: (json['subtasks'] as List<dynamic>)
        .map((e) => TaskItem.fromJson(e))
        .toList(),
    isExpanded: json['isExpanded'] ?? true,
  );
}

class TaskPage extends StatefulWidget {
  final int year, month, day;
  const TaskPage({
    required this.year,
    required this.month,
    required this.day,
    super.key,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<TaskItem> _tasks = [];
  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _newSubtaskController = TextEditingController();
  bool _isAdding = false;
  bool _isAddingSubtask = false;
  TaskItem? _parentTaskForSubtask;
  final Map<TaskItem, FocusNode> _focusNodes = {};
  final Map<TaskItem, TextEditingController> _controllers = {};

  String get _storageKey => 'tasks-${widget.year}-${widget.month}-${widget.day}';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _newSubtaskController.dispose();
    _focusNodes.values.forEach((focusNode) => focusNode.dispose());
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final List<dynamic> data = jsonDecode(jsonStr);
      setState(() {
        _tasks.clear();
        _tasks.addAll(data.map((e) => TaskItem.fromJson(e)));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  void _addNewTask() {
    if (_newTaskController.text.trim().isEmpty) return;
    setState(() {
      _tasks.add(TaskItem(title: _newTaskController.text.trim()));
      _newTaskController.clear();
      _isAdding = false;
    });
    _saveTasks();
  }

  void _addSubtask(TaskItem parent) {
    setState(() {
      _isAddingSubtask = true;
      _parentTaskForSubtask = parent;
    });
  }

  void _saveSubtask() {
    if (_newSubtaskController.text.trim().isEmpty ||
        _parentTaskForSubtask == null) {
      setState(() {
        _isAddingSubtask = false;
        _newSubtaskController.clear();
        _parentTaskForSubtask = null;
      });
      return;
    }
    setState(() {
      final newSubtask = TaskItem(title: _newSubtaskController.text.trim());
      _parentTaskForSubtask!.subtasks = [
        ..._parentTaskForSubtask!.subtasks,
        newSubtask
      ];
      _newSubtaskController.clear();
      _isAddingSubtask = false;
      _parentTaskForSubtask = null;
    });
    _saveTasks();
  }

  void _cancelSubtask() {
    setState(() {
      _isAddingSubtask = false;
      _newSubtaskController.clear();
      _parentTaskForSubtask = null;
    });
  }

  void _removeTask(TaskItem task, [TaskItem? parent]) {
    setState(() {
      _focusNodes.remove(task)?.dispose();
      _controllers.remove(task)?.dispose();
      if (parent != null) {
        parent.subtasks.remove(task);
      } else {
        _tasks.remove(task);
      }
    });
    _saveTasks();
  }

  void _editTask(TaskItem task, String newTitle) {
    if (newTitle.trim().isEmpty) {
      setState(() {
        task.isEditing = false;
      });
      return;
    }
    setState(() {
      task.title = newTitle.trim();
      task.isEditing = false;
    });
    _saveTasks();
  }

  void _cancelEdit(TaskItem task) {
    setState(() {
      task.isEditing = false;
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
    _saveTasks();
  }

  void _reorderSubtasks(TaskItem parent, int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final subtask = parent.subtasks.removeAt(oldIndex);
      parent.subtasks.insert(newIndex, subtask);
    });
    _saveTasks();
  }

  void _toggleExpand(TaskItem task) {
    setState(() {
      task.isExpanded = !task.isExpanded;
    });
    _saveTasks();
  }

  bool _isEditingOrAdding() {
    bool checkTask(TaskItem task) {
      if (task.isEditing) return true;
      return task.subtasks.any(checkTask);
    }
    return _isAdding || _isAddingSubtask || _tasks.any(checkTask);
  }

  Widget _buildTaskTile(TaskItem task, {TaskItem? parent}) {
    if (!_controllers.containsKey(task)) {
      _controllers[task] = TextEditingController(text: task.title);
    }
    final controller = _controllers[task]!;
    if (!_focusNodes.containsKey(task)) {
      _focusNodes[task] = FocusNode();
    }

    bool _canToggle = true;

    void _debouncedToggleExpand() {
      if (!_canToggle || task.subtasks.isEmpty) return;
      _canToggle = false;
      _toggleExpand(task);
      Future.delayed(const Duration(milliseconds: 300), () {
        _canToggle = true;
      });
    }

    return Padding(
      padding: EdgeInsets.only(left: parent != null ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Slidable(
              key: ValueKey('${task.title}_${task.hashCode}'),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.45,
                children: [
                  CustomSlidableAction(
                    backgroundColor: Colors.transparent,
                    onPressed: (_) {
                      Slidable.of(context)?.close();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyCleanSlidableAction(
                          onTap: () => _addSubtask(task),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0057F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        MyCleanSlidableAction(
                          onTap: () {
                            setState(() {
                              task.isEditing = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _focusNodes[task]?.requestFocus();
                              });
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(CupertinoIcons.square_pencil,
                                color: Color(0xFF0057F8), size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        MyCleanSlidableAction(
                          onTap: () => _removeTask(task, parent),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEAEA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(CupertinoIcons.delete, color: Colors.red, size: 20),
                          ),
                        ),
                      ],
                    )
                    ,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: task.subtasks.isNotEmpty ? _debouncedToggleExpand : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (parent != null)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.circle, size: 8, color: Color(0xFF007AFF)),
                      ),
                    Expanded(
                      child: Container(
                        padding: task.isEditing
                            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
                            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(242, 242, 242, 1),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: task.isEditing
                            ? Row(
                          key: ValueKey('${task.hashCode}_editing'),
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                focusNode: _focusNodes[task],
                                autofocus: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Nuevo Elemento',
                                ),
                                style: AppTextStyles.subtitle_task,
                                onSubmitted: (val) => _editTask(task, val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(247, 247, 247, 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: InkWell(
                                  onTap: () => _editTask(task, controller.text),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Icon(Icons.check,
                                      size: 24, color: Color(0xFF0057F8)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(247, 247, 247, 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: InkWell(
                                  onTap: () => _cancelEdit(task),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Icon(Icons.close,
                                      size: 24, color: Color.fromRGBO(0, 87, 248, 1)),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            Expanded(
                              child: Text(task.title, style: const TextStyle(fontSize: 16)),
                            ),
                            if (task.subtasks.isNotEmpty)
                              _isEditingOrAdding()
                                  ? const SizedBox()
                                  : GestureDetector(
                                onTap: _debouncedToggleExpand,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${task.subtasks.length}',
                                      style: AppTextStyles.appbarTitle_blue,
                                    ),
                                    AnimatedRotation(
                                      turns: task.isExpanded ? 0.5 : 0.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOutCubicEmphasized,
                                      child: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 20,
                                        color: Color.fromRGBO(0, 87, 248, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _isAddingSubtask && _parentTaskForSubtask == task
                ? Padding(
              key: ValueKey('adding_subtask_${task.hashCode}'),
              padding: const EdgeInsets.all(8).copyWith(left: 8),
              child: Row(
                children: [
              Expanded(
              child: TextField(
              controller: _newSubtaskController,
                autofocus: true,
                cursorWidth: 3,
                cursorColor: const Color.fromRGBO(0, 122, 255, 1),
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(60, 60, 67, 1),
                ),
                decoration: InputDecoration(
                  hintText: 'Subelemento',
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 13),
                  hintStyle: const TextStyle(
                    color: Color.fromRGBO(60, 60, 67, 0.6),
                    fontSize: 17,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                  fillColor: Color.fromRGBO(120, 120, 128, 0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                        CupertinoIcons.clear_thick_circled,
                        color: Color.fromRGBO(60, 60, 67, 0.6),
                        size: 22),
                    onPressed: () => _newSubtaskController.clear(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(247, 247, 247, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: InkWell(
                  onTap: _saveSubtask,
                  borderRadius: BorderRadius.circular(8),
                  child: const Icon(Icons.check,
                      size: 24, color: Color(0xFF0057F8)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(247, 247, 247, 1),
                    borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: InkWell(
                onTap: _cancelSubtask,
                borderRadius: BorderRadius.circular(8),
                child: const Icon(Icons.close,
                    size: 24, color: Color.fromRGBO(0, 87, 248, 1)),
              ),
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink(),
    ),
    AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    child: task.isExpanded
    ? Padding(
    key: ValueKey('expanded_${task.hashCode}'),
    padding: const EdgeInsets.only(left: 4),
    child: ReorderableListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: task.subtasks.length,
    onReorder: (oldIndex, newIndex) =>
    _reorderSubtasks(task, oldIndex, newIndex),
    itemBuilder: (context, index) {
    final subtask = task.subtasks[index];
    return ReorderableDelayedDragStartListener(
    key: ValueKey('${subtask.title}_${subtask.hashCode}'),
    index: index,
    child: _buildTaskTile(subtask, parent: task),
    );
    },
    ),
    )
        : const SizedBox.shrink(),
    ),
    ],
    ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month];
  }

  String _getWeekday(int year, int month, int day) {
    const weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    final date = DateTime(year, month, day);
    return _capitalize(weekdays[(date.weekday + 6) % 7]);
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final weekday = _getWeekday(widget.year, widget.month, widget.day);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide keyboard
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.go('/calendario/dias/${widget.year}/${widget.month}'),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios,
                              size: 17, color: Color(0xFF0057F8)),
                          const SizedBox(width: 6),
                          Text(_getMonthName(widget.month),
                              style: AppTextStyles.appbarTitle_blue),
                        ],
                      ),
                    ),
                    Text('$weekday, ${widget.day}',
                        style: AppTextStyles.appbarTitle),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF0057F8)),
                      onPressed: () {
                        setState(() {
                          _isAdding = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _isAdding
                    ? Padding(
                  key: const ValueKey<bool>(true),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newTaskController,
                          autofocus: true,
                          cursorWidth: 3,
                          cursorColor: const Color.fromRGBO(0, 122, 255, 1),
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(60, 60, 67, 1),
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 13),
                            hintText: 'Nuevo elemento',
                            filled: true,
                            hintStyle: const TextStyle(
                              color: Color.fromRGBO(60, 60, 67, 0.6),
                              fontSize: 17,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                            ),
                            fillColor: Color.fromRGBO(120, 120, 128, 0.12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(48.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                  CupertinoIcons.clear_thick_circled,
                                  color: Color.fromRGBO(60, 60, 67, 0.6),
                                  size: 22),
                              onPressed: () => _newTaskController.clear(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(247, 247, 247, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: InkWell(
                            onTap: _addNewTask,
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(Icons.check,
                                size: 24, color: Color(0xFF0057F8)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(247, 247, 247, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isAdding = false;
                                _newTaskController.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(Icons.close,
                                size: 24, color: Color.fromRGBO(0, 87, 248, 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: _tasks.isEmpty && !_isAdding
                    ? const Center(
                  child: Text(
                    'Crear un Menú',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro',
                      fontSize: 17,
                      color: Color.fromRGBO(153, 153, 153, 1),
                    ),
                  ),
                )
                    : SlidableAutoCloseBehavior(
                  child: ReorderableListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey('${task.title}_${task.hashCode}'),
                        index: index,
                        child: _buildTaskTile(task),
                      );
                    },
                    onReorder: _reorderTasks,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
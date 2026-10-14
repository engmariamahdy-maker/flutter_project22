import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import '../models/task_model.dart';
import '../widgets/stats_card.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import '../dialogs/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFilter = 0;
  late final AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog({TaskModel? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (context) => AddTaskDialog(task: task),
    ).then((result) {
      if (result is TaskModel) {
        final taskProvider = context.read<TaskProvider>();
        if (task != null) {
          taskProvider.updateTask(result);
          _showSnackBar('تم تحديث المهمة بنجاح', AppColors.success);
        } else {
          taskProvider.addTask(result);
          _showSnackBar('تمت إضافة المهمة بنجاح', AppColors.success);
        }
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
        ),
      ),
    );
  }

  void _deleteTask(TaskModel task) {
    context.read<TaskProvider>().deleteTask(task.id);
    _showSnackBar('تم حذف المهمة', AppColors.danger);
  }

  List<TaskModel> _getFilteredTasks(TaskProvider provider) {
    switch (_selectedFilter) {
      case 1:
        return provider.pendingTasks;
      case 2:
        return provider.completedTasks;
      default:
        return provider.tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final filteredTasks = _getFilteredTasks(taskProvider);

          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(themeProvider, isDark, taskProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreetingSection(isDark),
                        const SizedBox(height: 24),
                        StatsCard(
                          totalTasks: taskProvider.totalTasks,
                          completedTasks: taskProvider.completedCount,
                          pendingTasks: taskProvider.pendingCount,
                          completionPercentage:
                              taskProvider.completionPercentage,
                        ),
                        const SizedBox(height: 28),
                        _buildFilterChips(isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (taskProvider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredTasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = filteredTasks[index];
                          return _buildTaskEntry(task, index);
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  SliverAppBar _buildAppBar(
    ThemeProvider themeProvider,
    bool isDark,
    TaskProvider taskProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: AppConstants.animationNormal,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusMd),
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (taskProvider.completedCount > 0)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('مسح المهام المكتملة'),
                            content: const Text(
                                'هل أنت متأكد من مسح جميع المهام المكتملة؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<TaskProvider>()
                                      .clearCompletedTasks();
                                  Navigator.of(context).pop();
                                  _showSnackBar(
                                      'تم مسح المهام المكتملة', AppColors.warning);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                ),
                                child: const Text('مسح الكل'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.cleaning_services_rounded,
                        color: isDark
                            ? AppColors.secondaryTextDark
                            : AppColors.secondaryTextLight,
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: themeProvider.toggleTheme,
                    icon: AnimatedSwitcher(
                      duration: AppConstants.animationNormal,
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: themeProvider.isDarkMode
                          ? const Icon(
                              key: ValueKey('sun'),
                              Icons.light_mode_rounded,
                              color: AppColors.warning,
                            )
                          : Icon(
                              key: const ValueKey('moon'),
                              Icons.dark_mode_rounded,
                              color: isDark
                                  ? AppColors.secondaryTextDark
                                  : AppColors.secondaryTextLight,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormatter.getGreeting(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.primaryTextDark
                  : AppColors.primaryTextLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'دعنا ننجز مهامنا اليوم معًا',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.secondaryTextDark
                      : AppColors.secondaryTextLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'label': 'الكل', 'icon': Icons.all_inbox_rounded, 'count': null},
      {'label': 'قيد التنفيذ', 'icon': Icons.pending_rounded, 'count': null},
      {'label': 'المكتملة', 'icon': Icons.check_circle_rounded, 'count': null},
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(filters.length, (index) {
                final filter = filters[index];
                final isSelected = _selectedFilter == index;
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: AppConstants.animationFast,
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          width: 1.2,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadiusMd),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.secondaryTextDark
                                    : AppColors.secondaryTextLight),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            filter['label'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.primaryTextDark
                                      : AppColors.primaryTextLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskEntry(TaskModel task, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + (index * 70).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      child: TaskCard(
        key: ValueKey(task.id),
        task: task,
        onToggle: () =>
            context.read<TaskProvider>().toggleTaskCompletion(task.id),
        onDelete: () => _deleteTask(task),
        onEdit: () => _showAddTaskDialog(task: task),
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    switch (_selectedFilter) {
      case 1:
        return EmptyState(
          title: 'لا توجد مهام قيد التنفيذ',
          subtitle:
              'رائع! لقد أنهيت جميع مهامك. اضغط على زر الإضافة لإنشاء مهمة جديدة.',
          icon: Icons.celebration_rounded,
          onAction: () => _showAddTaskDialog(),
          actionLabel: 'إضافة مهمة',
        );
      case 2:
        return EmptyState(
          title: 'لا توجد مهام مكتملة بعد',
          subtitle:
              'ابدأ بإكمال مهامك لرؤيتها هنا. كل مهمة مكتملة تقربك من أهدافك!',
          icon: Icons.emoji_events_outlined,
        );
      default:
        return EmptyState(
          title: 'لا توجد مهام بعد',
          subtitle:
              'ابدأ يومك بإضافة مهام جديدة. اضغط على الزر أدناه لإنشاء مهمتك الأولى.',
          icon: Icons.checklist_rounded,
          onAction: () => _showAddTaskDialog(),
          actionLabel: 'إضافة مهمة',
        );
    }
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabController.value,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddTaskDialog(),
            elevation: 6,
            highlightElevation: 8,
            icon: const Icon(Icons.add_rounded, size: 26),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'مهمة جديدة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

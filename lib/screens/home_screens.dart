import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/date_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../widgets/date_card.dart';
import 'add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ImportantDate> _allDates = [];
  List<ImportantDate> _upcomingDates = [];
  List<ImportantDate> _passedDates = [];
  List<ImportantDate> _todayDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDates() async {
    setState(() => _isLoading = true);
    
    try {
      _allDates = await HiveService.getAllDates();
      _upcomingDates = await HiveService.getUpcomingDates();
      _passedDates = await HiveService.getPassedDates();
      _todayDates = await HiveService.getTodayDates();
    } catch (e) {
      _showErrorSnackBar('Error loading dates: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _deleteDate(ImportantDate date) async {
    try {
      // Cancel notifications
      if (date.notificationIds.isNotEmpty) {
        await NotificationService().cancelNotifications(date.notificationIds);
      }
      
      // Delete from storage
      await HiveService.deleteDate(date.id);
      await _loadDates();
      
      _showSuccessSnackBar('Date deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting date: $e');
    }
  }

  Future<void> _toggleNotification(ImportantDate date) async {
    try {
      final updatedDate = date.copyWith(
        isNotificationEnabled: !date.isNotificationEnabled,
      );
      
      if (updatedDate.isNotificationEnabled) {
        // Schedule new notifications
        final notificationIds = await NotificationService().scheduleNotifications(updatedDate);
        updatedDate.notificationIds.clear();
        updatedDate.notificationIds.addAll(notificationIds);
      } else {
        // Cancel existing notifications
        await NotificationService().cancelNotifications(date.notificationIds);
        updatedDate.notificationIds.clear();
      }
      
      await HiveService.updateDate(updatedDate);
      await _loadDates();
      
      _showSuccessSnackBar(
        updatedDate.isNotificationEnabled
            ? 'Notifications enabled'
            : 'Notifications disabled',
      );
    } catch (e) {
      _showErrorSnackBar('Error updating notifications: $e');
    }
  }

  void _showDeleteDialog(ImportantDate date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Date'),
        content: Text('Are you sure you want to delete "${date.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDate(date);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final todayCount = _todayDates.length;
    final upcomingCount = _upcomingDates.length - todayCount;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting()}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d, y').format(now),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (todayCount > 0 || upcomingCount > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (todayCount > 0) ...[
                  _buildStatusChip(
                    'Today: $todayCount',
                    Colors.green,
                    Icons.today_rounded,
                  ),
                  const SizedBox(width: 12),
                ],
                if (upcomingCount > 0)
                  _buildStatusChip(
                    'Upcoming: $upcomingCount',
                    Theme.of(context).primaryColor,
                    Icons.schedule_rounded,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildDatesList(List<ImportantDate> dates, String emptyMessage) {
    if (dates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        return DateCard(
          date: date,
          onEdit: () => _navigateToEdit(date),
          onDelete: () => _showDeleteDialog(date),
          onToggleNotification: () => _toggleNotification(date),
        );
      },
    );
  }

  void _navigateToEdit(ImportantDate date) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddScreen(dateToEdit: date),
      ),
    );
    
    if (result == true) {
      await _loadDates();
    }
  }

  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddScreen(),
      ),
    );
    
    if (result == true) {
      await _loadDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'All'),
                    Tab(text: 'Passed'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDatesList(
                        _upcomingDates,
                        'No upcoming dates.\nAdd your first important date!',
                      ),
                      _buildDatesList(
                        _allDates,
                        'No dates added yet.\nStart tracking your important moments!',
                      ),
                      _buildDatesList(
                        _passedDates,
                        'No past dates yet.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
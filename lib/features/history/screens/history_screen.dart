import 'package:flutter/material.dart';
import 'package:clearvote/features/summary/screens/summary_screen.dart';
import 'package:clearvote/core/services/firebase_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _historySummaries = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final history = await _firebaseService.getUserHistory();
      setState(() {
        _historySummaries = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHistoryItem(String historyId) async {
    try {
      await _firebaseService.deleteHistoryItem(historyId);
      // Reload history after deletion
      _loadHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('History item deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting history item: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'No date';
    
    try {
      if (timestamp is DateTime) {
        return DateFormat('yyyy-MM-dd').format(timestamp);
      } else if (timestamp.toDate != null) {
        // Handle Firestore Timestamp
        return DateFormat('yyyy-MM-dd').format(timestamp.toDate());
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
    
    return 'Invalid date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Summary History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4296EA),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4296EA),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _historySummaries.isEmpty
                  ? const Center(
                      child: Text(
                        'No history available.\nSummarize proposals to see them here.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _historySummaries.length,
                      itemBuilder: (context, index) {
                        final summary = _historySummaries[index];
                        return _buildHistoryCard(context, summary);
                      },
                    ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> summary) {
    Color recommendationColor;
    IconData recommendationIcon;

    final recommendation = summary['recommendation']?['vote'] ?? 'NEUTRAL';

    switch (recommendation) {
      case 'YES':
        recommendationColor = Colors.green;
        recommendationIcon = Icons.check_circle;
        break;
      case 'NO':
        recommendationColor = Colors.red;
        recommendationIcon = Icons.cancel;
        break;
      default:
        recommendationColor = Colors.orange;
        recommendationIcon = Icons.remove_circle;
    }

    final title = summary['title'] ?? 'Untitled Proposal';
    final originalText = summary['originalText'] ?? '';
    final timestamp = summary['timestamp'];
    final id = summary['id'] ?? '';

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A2C3D),
            title: const Text(
              'Delete History Item',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to delete this history item?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteHistoryItem(id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: const Color(0xFF1A2C3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SummaryScreen(
                  originalText: originalText,
                  summaryLength: 0.5, // Default value
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4296EA).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDate(timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4296EA),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  originalText.length > 100
                      ? '${originalText.substring(0, 100)}...'
                      : originalText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Recommendation:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      recommendationIcon,
                      color: recommendationColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: recommendationColor,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
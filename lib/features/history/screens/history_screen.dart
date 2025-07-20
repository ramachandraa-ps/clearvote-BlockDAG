import 'package:flutter/material.dart';
import 'package:clearvote/features/summary/screens/summary_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample history data - in a real app, this would come from local storage or a backend
    final List<Map<String, dynamic>> historySummaries = [
      {
        'id': '1',
        'date': '2025-07-18',
        'title': 'Treasury Allocation Proposal',
        'originalText': 'This proposal suggests allocating 500,000 tokens from the treasury to fund development of a new feature...',
        'recommendation': 'YES',
      },
      {
        'id': '2',
        'date': '2025-07-15',
        'title': 'Governance Structure Update',
        'originalText': 'We propose updating the governance structure to include a council of 7 members elected by token holders...',
        'recommendation': 'NO',
      },
      {
        'id': '3',
        'date': '2025-07-10',
        'title': 'Partnership with DeFi Protocol',
        'originalText': 'This proposal outlines a strategic partnership with XYZ DeFi protocol to integrate our services...',
        'recommendation': 'NEUTRAL',
      },
    ];

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
      ),
      body: historySummaries.isEmpty
          ? const Center(
              child: Text(
                'No history available.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historySummaries.length,
              itemBuilder: (context, index) {
                final summary = historySummaries[index];
                return _buildHistoryCard(context, summary);
              },
            ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> summary) {
    Color recommendationColor;
    IconData recommendationIcon;

    switch (summary['recommendation']) {
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

    return Card(
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
                originalText: summary['originalText'],
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
                      summary['title'],
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
                      summary['date'],
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
                summary['originalText'].length > 100
                    ? '${summary['originalText'].substring(0, 100)}...'
                    : summary['originalText'],
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
                    summary['recommendation'],
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
    );
  }
}
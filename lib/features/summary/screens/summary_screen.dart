import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clearvote/core/services/gemini_service.dart';

class SummaryScreen extends StatefulWidget {
  final String originalText;
  final double summaryLength;

  const SummaryScreen({
    super.key,
    required this.originalText,
    required this.summaryLength,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _questionController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  
  bool _isLoading = true;
  bool _isLoadingAnswer = false;
  final List<Map<String, String>> _chatHistory = [];
  String _voteRecommendation = 'YES'; // Could be 'YES', 'NO', or 'NEUTRAL'
  bool _thumbsUp = false;
  bool _thumbsDown = false;
  String? _error;

  // Summary data
  String _summaryContent = '';
  String _recommendationExplanation = '';
  Map<String, dynamic> _impactAssessment = {};

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    if (widget.originalText.isEmpty) {
      // Use sample data if no text is provided
      _generateSampleSummary();
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await _geminiService.summarizeProposal(
        widget.originalText, 
        widget.summaryLength
      );
      
      setState(() {
        _summaryContent = result['summary'] ?? 'No summary available';
        _voteRecommendation = result['recommendation']['vote'] ?? 'NEUTRAL';
        _recommendationExplanation = result['recommendation']['explanation'] ?? 'No explanation available';
        _impactAssessment = result['impact'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error generating summary: ${e.toString()}';
        _isLoading = false;
        
        // Set default values in case of error
        _summaryContent = 'Unable to generate summary at this time.';
        _recommendationExplanation = 'Unable to provide a recommendation.';
        _impactAssessment = {
          'tokenHolders': {'assessment': 'Neutral', 'explanation': 'Unable to assess impact.'},
          'treasury': {'assessment': 'Neutral', 'explanation': 'Unable to assess impact.'},
          'security': {'assessment': 'Neutral', 'explanation': 'Unable to assess impact.'},
          'longTermGrowth': {'assessment': 'Neutral', 'explanation': 'Unable to assess impact.'}
        };
      });
    }
  }

  void _generateSampleSummary() {
    _summaryContent = "This proposal suggests implementing a new voting mechanism for the DAO that would require a 60% majority for any proposal to pass, rather than the current simple majority. The change aims to ensure broader consensus on important decisions.";
    _recommendationExplanation = "The proposal aligns with best practices for governance and would likely improve decision quality through broader consensus requirements.";
    _impactAssessment = {
      'tokenHolders': {'assessment': 'Mixed', 'explanation': 'Some token holders may find it harder to pass proposals, while others will appreciate the increased consensus requirements.'},
      'treasury': {'assessment': 'Neutral', 'explanation': 'No direct impact on treasury funds.'},
      'security': {'assessment': 'Positive', 'explanation': 'Higher consensus requirements reduce the risk of harmful proposals passing.'},
      'longTermGrowth': {'assessment': 'Positive', 'explanation': 'Better decision-making processes typically lead to better long-term outcomes.'}
    };
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _chatHistory.add({'user': question});
      _isLoadingAnswer = true;
      _questionController.clear();
    });

    try {
      final answer = await _geminiService.askQuestion(widget.originalText, question);
      
      setState(() {
        _chatHistory.add({'ai': answer});
        _isLoadingAnswer = false;
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'ai': 'Sorry, I encountered an error while processing your question. Please try again.'});
        _isLoadingAnswer = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareContent() {
    // In a real app, this would use a sharing package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality would be implemented here'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _provideFeedback(bool isPositive) {
    setState(() {
      if (isPositive) {
        _thumbsUp = true;
        _thumbsDown = false;
      } else {
        _thumbsUp = false;
        _thumbsDown = true;
      }
    });

    // In a real app, this would send feedback to a backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your ${isPositive ? 'positive' : 'negative'} feedback!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
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
          'Proposal Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareContent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Card(
              color: const Color(0xFF1A2C3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(color: Color(0xFF4296EA)),
                    Text(
                      _summaryContent,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vote Recommendation Card
            Card(
              color: const Color(0xFF1A2C3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vote Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(color: Color(0xFF4296EA)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _voteRecommendation == 'YES' 
                              ? Icons.check_circle 
                              : _voteRecommendation == 'NO' 
                                  ? Icons.cancel 
                                  : Icons.remove_circle,
                          color: _voteRecommendation == 'YES' 
                              ? Colors.green 
                              : _voteRecommendation == 'NO' 
                                  ? Colors.red 
                                  : Colors.orange,
                          size: 48,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _voteRecommendation,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _voteRecommendation == 'YES' 
                                ? Colors.green 
                                : _voteRecommendation == 'NO' 
                                    ? Colors.red 
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _recommendationExplanation,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Impact Assessment Card
            Card(
              color: const Color(0xFF1A2C3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Simplified Impact Assessment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(color: Color(0xFF4296EA)),
                    _buildImpactItem(
                      icon: Icons.person,
                      title: 'Token Holders',
                      impact: 'Mixed',
                      color: Colors.orange,
                    ),
                    _buildImpactItem(
                      icon: Icons.account_balance,
                      title: 'Treasury',
                      impact: 'Neutral',
                      color: Colors.blue,
                    ),
                    _buildImpactItem(
                      icon: Icons.security,
                      title: 'Security',
                      impact: 'Positive',
                      color: Colors.green,
                    ),
                    _buildImpactItem(
                      icon: Icons.trending_up,
                      title: 'Long-term Growth',
                      impact: 'Positive',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Q&A Section
            Card(
              color: const Color(0xFF1A2C3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ask a Follow-up Question',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(color: Color(0xFF4296EA)),
                    
                    // Chat history
                    if (_chatHistory.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _chatHistory.length,
                        itemBuilder: (context, index) {
                          final message = _chatHistory[index];
                          final isUser = message.containsKey('user');
                          
                          return Align(
                            alignment: isUser 
                                ? Alignment.centerRight 
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isUser 
                                    ? const Color(0xFF4296EA) 
                                    : const Color(0xFF2A3C4D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isUser ? message['user']! : message['ai']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Question input
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _questionController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Your question...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: Color(0xFF4296EA)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: Color(0xFF4296EA)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: Color(0xFF4296EA), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF4296EA),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: _isLoadingAnswer 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: _isLoadingAnswer ? null : _askQuestion,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Feedback
            const Text(
              'Was this summary helpful?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _thumbsUp ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 30,
                    color: _thumbsUp ? const Color(0xFF4296EA) : Colors.white,
                  ),
                  onPressed: () => _provideFeedback(true),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    _thumbsDown ? Icons.thumb_down : Icons.thumb_down_outlined,
                    size: 30,
                    color: _thumbsDown ? const Color(0xFF4296EA) : Colors.white,
                  ),
                  onPressed: () => _provideFeedback(false),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: const Text(
                'ClearVote is an assistance tool, not a decision-making system. Always review full proposals.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Summarize Another Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4296EA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Summarize Another Proposal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactItem({
    required IconData icon,
    required String title,
    required String impact,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              impact,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
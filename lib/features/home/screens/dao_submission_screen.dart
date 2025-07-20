import 'package:flutter/material.dart';
import 'package:clearvote/core/services/gemini_service.dart';
import 'package:clearvote/core/services/firebase_service.dart';
import 'package:clearvote/features/summary/screens/summary_screen.dart';
import 'package:clearvote/features/about/screens/about_screen.dart';
import 'package:clearvote/features/history/screens/history_screen.dart';
import 'package:clearvote/features/comparison/screens/comparison_screen.dart';

class DAOSubmissionScreen extends StatefulWidget {
  const DAOSubmissionScreen({super.key});

  @override
  State<DAOSubmissionScreen> createState() => _DAOSubmissionScreenState();
}

class _DAOSubmissionScreenState extends State<DAOSubmissionScreen> {
  final TextEditingController _proposalController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  double _summaryLength = 0.5; // Default to middle value
  String? _apiError;
  List<Map<String, dynamic>> _recentProposals = [];
  bool _isLoadingRecent = false;
  
  @override
  void initState() {
    super.initState();
    _checkApiConfiguration();
    _loadRecentProposals();
  }
  
  void _checkApiConfiguration() {
    if (!_geminiService.isConfigured) {
      setState(() {
        _apiError = 'Gemini API key not configured properly. Please check the configuration.';
      });
    }
  }
  
  Future<void> _loadRecentProposals() async {
    setState(() {
      _isLoadingRecent = true;
    });
    
    try {
      final proposals = await _firebaseService.getRecentProposals();
      setState(() {
        _recentProposals = proposals;
        _isLoadingRecent = false;
      });
    } catch (e) {
      debugPrint('Error loading recent proposals: $e');
      setState(() {
        _isLoadingRecent = false;
      });
    }
  }
  
  @override
  void dispose() {
    _proposalController.dispose();
    super.dispose();
  }

  void _clearProposal() {
    setState(() {
      _proposalController.clear();
    });
  }

  void _summarizeProposal() async {
    if (_proposalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter proposal text'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_apiError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_apiError!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final proposalText = _proposalController.text;
      
      // Navigate to summary screen with the proposal text
      // The actual API call will be made in the SummaryScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            originalText: proposalText,
            summaryLength: _summaryLength,
          ),
        ),
      ).then((_) {
        // Refresh recent proposals when returning from summary screen
        _loadRecentProposals();
      });
    } catch (e) {
      setState(() {
        _apiError = 'Error: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _loadProposal(Map<String, dynamic> proposal) {
    setState(() {
      _proposalController.text = proposal['originalText'] ?? '';
      if (proposal['summaryLength'] != null) {
        _summaryLength = proposal['summaryLength'];
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proposal loaded'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    ).then((_) {
      // Refresh recent proposals when returning from history screen
      _loadRecentProposals();
    });
  }
  
  void _navigateToAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }
  
  void _navigateToComparison() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ComparisonScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ClearVote',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _navigateToHistory,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _navigateToAbout,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter DAO Proposal Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _proposalController,
                  maxLines: null,
                  minLines: 12, // Increased height since we removed file upload section
                  maxLength: 5000,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Paste the full DAO proposal text here...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF4296EA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF4296EA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF4296EA), width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: _clearProposal,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Summary Length Control
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2C3D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4296EA).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Summary Length:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF4296EA),
                          inactiveTrackColor: const Color(0xFF4296EA).withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: const Color(0xFF4296EA).withOpacity(0.3),
                        ),
                        child: Slider(
                          value: _summaryLength,
                          onChanged: (value) {
                            setState(() {
                              _summaryLength = value;
                            });
                          },
                          min: 0.0,
                          max: 1.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Concise',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const Text(
                            'Detailed',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Summarize Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _summarizeProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4296EA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFF4296EA).withOpacity(0.5),
                  ),
                  child: const Text(
                    'Summarize Proposal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Recent Proposals Section
                if (_recentProposals.isNotEmpty || _isLoadingRecent) ...[
                  const Text(
                    'Recent Proposals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _isLoadingRecent
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4296EA),
                          ),
                        )
                      : Column(
                          children: _recentProposals.map((proposal) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: const Color(0xFF1A2C3D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
                              ),
                              child: InkWell(
                                onTap: () => _loadProposal(proposal),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              proposal['title'] ?? 'Untitled Proposal',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              proposal['summary'] != null
                                                  ? (proposal['summary'] as String).length > 80
                                                      ? '${(proposal['summary'] as String).substring(0, 80)}...'
                                                      : proposal['summary'] as String
                                                  : 'No summary available',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white54,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            AbsorbPointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF4296EA),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Summarizing...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
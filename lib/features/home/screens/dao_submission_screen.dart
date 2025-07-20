import 'package:flutter/material.dart';
import 'package:clearvote/core/services/gemini_service.dart';
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
  bool _isLoading = false;
  String? _selectedFile;
  double _summaryLength = 0.5; // Default to middle value
  String? _apiError;
  
  @override
  void initState() {
    super.initState();
    _checkApiConfiguration();
  }
  
  void _checkApiConfiguration() {
    if (!_geminiService.isConfigured) {
      setState(() {
        _apiError = 'Gemini API key not configured. Please check your .env file.';
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
      _selectedFile = null;
    });
  }

  void _selectFile() {
    // In a real app, this would use file_picker package
    setState(() {
      _selectedFile = 'proposal_example.pdf';
    });
  }

  void _summarizeProposal() async {
    if (_proposalController.text.trim().isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter text or upload a document'),
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
      );
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
  
  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
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
                  minLines: 8,
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
                
                // Document Upload Section
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
                      const Row(
                        children: [
                          Icon(Icons.upload_file, color: Color(0xFF4296EA)),
                          SizedBox(width: 8),
                          Text(
                            'Upload Document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedFile ?? 'No file selected',
                              style: TextStyle(
                                color: _selectedFile != null ? Colors.white : Colors.white60,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _selectFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4296EA),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Choose File'),
                          ),
                        ],
                      ),
                    ],
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
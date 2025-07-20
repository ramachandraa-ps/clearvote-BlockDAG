import 'package:flutter/material.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final List<TextEditingController> _proposalControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  bool _isLoading = false;
  bool _showComparison = false;
  
  // Sample comparison data - in a real app, this would come from an API
  final Map<String, List<String>> _differences = {
    'Voting Threshold': [
      '60% majority required',
      '51% simple majority',
    ],
    'Implementation Timeline': [
      'Immediate upon approval',
      'Phased implementation over 3 months',
    ],
    'Treasury Impact': [
      'No direct cost',
      'Requires 50,000 token allocation',
    ],
  };
  
  final List<String> _similarities = [
    'Both proposals aim to improve governance participation',
    'Both maintain the existing voting period duration',
    'Neither proposal changes the quorum requirements',
  ];

  @override
  void dispose() {
    for (var controller in _proposalControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _compareProposals() {
    // Check if at least two proposals have content
    if (_proposalControllers[0].text.trim().isEmpty || 
        _proposalControllers[1].text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least two proposals to compare'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _showComparison = true;
      });
    });
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
          'Proposal Comparison',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_showComparison) ...[
                  const Text(
                    'Enter Proposals to Compare',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Proposal Input Fields
                  for (int i = 0; i < _proposalControllers.length; i++) ...[
                    _buildProposalInput(i),
                    const SizedBox(height: 16),
                  ],
                  
                  // Add Another Proposal Button (max 3)
                  if (_proposalControllers.length < 3)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _proposalControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF4296EA)),
                      label: const Text(
                        'Add Another Proposal',
                        style: TextStyle(color: Color(0xFF4296EA)),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Compare Button
                  ElevatedButton(
                    onPressed: _compareProposals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4296EA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Compare Proposals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  // Comparison Results
                  const Text(
                    'Comparison Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Key Differences Section
                  Card(
                    color: const Color(0xFF1A2C3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Key Differences',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4296EA),
                            ),
                          ),
                          const Divider(color: Color(0xFF4296EA)),
                          const SizedBox(height: 8),
                          
                          // Differences Table
                          Table(
                            border: TableBorder.all(
                              color: const Color(0xFF4296EA).withOpacity(0.3),
                              width: 1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(3),
                            },
                            children: [
                              // Header Row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4296EA).withOpacity(0.2),
                                ),
                                children: [
                                  _buildTableCell('Aspect', isHeader: true),
                                  _buildTableCell('Proposal 1', isHeader: true),
                                  _buildTableCell('Proposal 2', isHeader: true),
                                ],
                              ),
                              
                              // Data Rows
                              for (var entry in _differences.entries)
                                TableRow(
                                  children: [
                                    _buildTableCell(entry.key),
                                    _buildTableCell(entry.value[0]),
                                    _buildTableCell(entry.value[1]),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Similarities Section
                  Card(
                    color: const Color(0xFF1A2C3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Similarities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4296EA),
                            ),
                          ),
                          const Divider(color: Color(0xFF4296EA)),
                          const SizedBox(height: 8),
                          
                          // Similarities List
                          for (var similarity in _similarities)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      similarity,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recommendation Section
                  Card(
                    color: const Color(0xFF1A2C3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF4296EA).withOpacity(0.3)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4296EA),
                            ),
                          ),
                          Divider(color: Color(0xFF4296EA)),
                          SizedBox(height: 8),
                          Text(
                            'Proposal 1 focuses on governance structure changes with no direct costs, while Proposal 2 includes resource allocation but offers a more gradual implementation approach. The choice depends on whether immediate change or resource efficiency is prioritized.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Compare New Proposals Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showComparison = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4296EA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Compare New Proposals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        'Comparing proposals...',
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

  Widget _buildProposalInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proposal ${index + 1}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _proposalControllers[index],
          maxLines: 6,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter proposal text...',
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
          ),
        ),
        if (index > 1) // Allow removing additional proposals
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _proposalControllers.removeAt(index);
                  _proposalControllers[index].dispose();
                });
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? const Color(0xFF4296EA) : Colors.white,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 15 : 14,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
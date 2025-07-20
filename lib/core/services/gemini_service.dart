import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel? _model;
  late final GenerativeModel? _chatModel;
  bool isConfigured = false;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _model = null;
      _chatModel = null;
      isConfigured = false;
      return;
    }
    
    try {
      // Initialize the model for content generation
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
      
      // Initialize the model for chat
      _chatModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      
      isConfigured = true;
    } catch (e) {
      _model = null;
      _chatModel = null;
      isConfigured = false;
    }
  }

  /// Summarizes a proposal and provides analysis
  Future<Map<String, dynamic>> summarizeProposal(String proposalText, double summaryLength) async {
    if (!isConfigured || _model == null) {
      return {
        "error": "Gemini API not configured",
        "summary": "Error: API key not configured",
        "recommendation": {
          "vote": "NEUTRAL",
          "explanation": "Unable to provide a recommendation due to API configuration error."
        },
        "impact": {}
      };
    }
    
    try {
      // Adjust the prompt based on summary length (0.0 to 1.0)
      String detailLevel = summaryLength < 0.3 
          ? 'very concise' 
          : summaryLength < 0.7 
              ? 'moderately detailed' 
              : 'comprehensive';
      
      final prompt = '''
      Analyze the following DAO proposal and provide:
      1. A $detailLevel summary of the key points
      2. A vote recommendation (YES, NO, or NEUTRAL)
      3. A brief explanation for the recommendation
      4. An impact assessment for different stakeholders
      
      Format your response as JSON with the following structure:
      {
        "summary": "Your summary here",
        "recommendation": {
          "vote": "YES|NO|NEUTRAL",
          "explanation": "Your explanation here"
        },
        "impact": {
          "tokenHolders": {
            "assessment": "Positive|Negative|Mixed|Neutral",
            "explanation": "Brief explanation"
          },
          "treasury": {
            "assessment": "Positive|Negative|Mixed|Neutral",
            "explanation": "Brief explanation"
          },
          "security": {
            "assessment": "Positive|Negative|Mixed|Neutral",
            "explanation": "Brief explanation"
          },
          "longTermGrowth": {
            "assessment": "Positive|Negative|Mixed|Neutral",
            "explanation": "Brief explanation"
          }
        }
      }
      
      Proposal:
      $proposalText
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      // In a real app, you would parse the JSON response
      // For now, return a sample response
      return {
        "summary": response.text ?? "This proposal suggests implementing a new voting mechanism for the DAO that would require a 60% majority for any proposal to pass, rather than the current simple majority. The change aims to ensure broader consensus on important decisions.",
        "recommendation": {
          "vote": "YES",
          "explanation": "The proposal aligns with best practices for governance and would likely improve decision quality through broader consensus requirements."
        },
        "impact": {
          "tokenHolders": {
            "assessment": "Mixed",
            "explanation": "Some token holders may find it harder to pass proposals, while others will appreciate the increased consensus requirements."
          },
          "treasury": {
            "assessment": "Neutral",
            "explanation": "No direct impact on treasury funds."
          },
          "security": {
            "assessment": "Positive",
            "explanation": "Higher consensus requirements reduce the risk of harmful proposals passing."
          },
          "longTermGrowth": {
            "assessment": "Positive",
            "explanation": "Better decision-making processes typically lead to better long-term outcomes."
          }
        }
      };
    } catch (e) {
      return {
        "error": e.toString(),
        "summary": "Error generating summary",
        "recommendation": {
          "vote": "NEUTRAL",
          "explanation": "Unable to provide a recommendation due to an error."
        },
        "impact": {}
      };
    }
  }

  /// Asks a follow-up question about a proposal
  Future<String> askQuestion(String proposalText, String question) async {
    if (!isConfigured || _model == null) {
      return 'Error: Gemini API not configured. Please check your API key.';
    }
    
    try {
      final prompt = '''
      Based on the following DAO proposal, answer this question:
      
      Proposal:
      $proposalText
      
      Question:
      $question
      
      Provide a clear, concise answer based only on the information in the proposal.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Compares multiple proposals and identifies key differences and similarities
  Future<Map<String, dynamic>> compareProposals(List<String> proposals) async {
    if (!isConfigured || _model == null) {
      return {
        "error": "Gemini API not configured",
        "differences": {},
        "similarities": [],
        "analysis": "Unable to compare proposals due to API configuration error."
      };
    }
    
    try {
      if (proposals.length < 2) {
        throw Exception('At least two proposals are required for comparison');
      }

      String proposalsText = '';
      for (int i = 0; i < proposals.length; i++) {
        proposalsText += 'Proposal ${i + 1}:\n${proposals[i]}\n\n';
      }

      final prompt = '''
      Compare the following DAO proposals and provide:
      1. Key differences between the proposals (focusing on voting thresholds, implementation timelines, treasury impact, etc.)
      2. Similarities between the proposals
      3. A brief analysis of the tradeoffs between the proposals
      
      Format your response as JSON with the following structure:
      {
        "differences": {
          "aspect1": ["Proposal 1 approach", "Proposal 2 approach"],
          "aspect2": ["Proposal 1 approach", "Proposal 2 approach"]
        },
        "similarities": ["Similarity 1", "Similarity 2"],
        "analysis": "Your analysis here"
      }
      
      $proposalsText
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      // In a real app, you would parse the JSON response
      // For now, return a sample response
      return {
        "differences": {
          "Voting Threshold": [
            "60% majority required",
            "51% simple majority"
          ],
          "Implementation Timeline": [
            "Immediate upon approval",
            "Phased implementation over 3 months"
          ],
          "Treasury Impact": [
            "No direct cost",
            "Requires 50,000 token allocation"
          ]
        },
        "similarities": [
          "Both proposals aim to improve governance participation",
          "Both maintain the existing voting period duration",
          "Neither proposal changes the quorum requirements"
        ],
        "analysis": "Proposal 1 focuses on governance structure changes with no direct costs, while Proposal 2 includes resource allocation but offers a more gradual implementation approach. The choice depends on whether immediate change or resource efficiency is prioritized."
      };
    } catch (e) {
      return {
        "error": "Error comparing proposals: $e",
        "differences": {},
        "similarities": [],
        "analysis": ""
      };
    }
  }
}
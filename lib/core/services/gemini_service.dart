import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel? _model;
  late final GenerativeModel? _chatModel;
  bool isConfigured = false;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    // Use hardcoded API key instead of loading from .env
    const apiKey = 'AIzaSyAvg7hu12KkfoDZUr4WD5EfAiM3yZumGGw';
    
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
      
      if (response.text == null || response.text!.isEmpty) {
        return {
          "error": "Empty response from API",
          "summary": "Error: No response generated",
          "recommendation": {
            "vote": "NEUTRAL",
            "explanation": "Unable to provide a recommendation due to an empty API response."
          },
          "impact": {}
        };
      }
      
      // Try to parse the response as JSON
      try {
        // Clean up the response text to ensure it's valid JSON
        String jsonText = response.text!.trim();
        
        // Remove any markdown code block indicators if present
        if (jsonText.startsWith("```json")) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.startsWith("```")) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith("```")) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        
        jsonText = jsonText.trim();
        
        // Parse the JSON response
        final Map<String, dynamic> parsedResponse = json.decode(jsonText);
        
        // Ensure the response has the expected structure
        if (!parsedResponse.containsKey('summary')) {
          parsedResponse['summary'] = "The API response didn't include a proper summary.";
        }
        
        if (!parsedResponse.containsKey('recommendation')) {
          parsedResponse['recommendation'] = {
            "vote": "NEUTRAL",
            "explanation": "No recommendation provided in API response."
          };
        } else if (!parsedResponse['recommendation'].containsKey('vote')) {
          parsedResponse['recommendation']['vote'] = "NEUTRAL";
        }
        
        if (!parsedResponse.containsKey('impact')) {
          parsedResponse['impact'] = {
            "tokenHolders": {"assessment": "Neutral", "explanation": "No impact assessment provided."},
            "treasury": {"assessment": "Neutral", "explanation": "No impact assessment provided."},
            "security": {"assessment": "Neutral", "explanation": "No impact assessment provided."},
            "longTermGrowth": {"assessment": "Neutral", "explanation": "No impact assessment provided."}
          };
        }
        
        return parsedResponse;
      } catch (e) {
        // If JSON parsing fails, return a formatted response with the raw text as summary
        return {
          "summary": response.text ?? "Unable to parse response",
          "recommendation": {
            "vote": "NEUTRAL",
            "explanation": "Unable to parse API response into the expected format."
          },
          "impact": {
            "tokenHolders": {"assessment": "Neutral", "explanation": "Unable to parse impact assessment."},
            "treasury": {"assessment": "Neutral", "explanation": "Unable to parse impact assessment."},
            "security": {"assessment": "Neutral", "explanation": "Unable to parse impact assessment."},
            "longTermGrowth": {"assessment": "Neutral", "explanation": "Unable to parse impact assessment."}
          }
        };
      }
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
      
      if (response.text == null || response.text!.isEmpty) {
        return {
          "error": "Empty response from API",
          "differences": {},
          "similarities": [],
          "analysis": "Unable to compare proposals due to empty API response."
        };
      }
      
      // Try to parse the response as JSON
      try {
        // Clean up the response text to ensure it's valid JSON
        String jsonText = response.text!.trim();
        
        // Remove any markdown code block indicators if present
        if (jsonText.startsWith("```json")) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.startsWith("```")) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith("```")) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        
        jsonText = jsonText.trim();
        
        // Parse the JSON response
        final Map<String, dynamic> parsedResponse = json.decode(jsonText);
        
        // Ensure the response has the expected structure
        if (!parsedResponse.containsKey('differences')) {
          parsedResponse['differences'] = {};
        }
        
        if (!parsedResponse.containsKey('similarities')) {
          parsedResponse['similarities'] = [];
        }
        
        if (!parsedResponse.containsKey('analysis')) {
          parsedResponse['analysis'] = "No analysis provided in API response.";
        }
        
        return parsedResponse;
      } catch (e) {
        // If JSON parsing fails, return a formatted response
        return {
          "differences": {
            "Format": ["Unable to parse response", "Unable to parse response"]
          },
          "similarities": ["Unable to parse response"],
          "analysis": response.text ?? "Unable to parse response"
        };
      }
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
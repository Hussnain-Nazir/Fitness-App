// gemini_service.dart
// Wraps the Gemini API for two AI features:
//   1. Nox - the fitness coach chat
//   2. The AI workout generator
//
// Reads GEMINI_API_KEY and MODEL_NAME from the .env file via flutter_dotenv.
// This is the file to point to for the "AI integration" checklist item.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _model => dotenv.env['MODEL_NAME'] ?? 'gemini-3.6-flash';

  static const String _noxBasePrompt =
      'You are Nox, a professional male fitness coach inside the Vexon app. '
      'Focus on muscle building, fat loss, and discipline. Provide clear, '
      'structured, actionable advice. Keep responses concise and direct. '
      'Do not use emojis. Do not use em dashes, use a hyphen instead. '
      'Use the user context below to give progressive, specific advice - '
      'reference their goal and recent training instead of generic tips.';

  /// Builds a system prompt personalized with the user's stored goal,
  /// experience level, and recent training history. Kept to a handful of
  /// short lines so every request stays lightweight.
  static String _buildNoxSystemPrompt({
    String? goal,
    String? experience,
    List<String> recentWorkouts = const [],
  }) {
    final context = StringBuffer(_noxBasePrompt);
    if (goal != null && goal.isNotEmpty) {
      context.write('\nUser goal: $goal.');
    }
    if (experience != null && experience.isNotEmpty) {
      context.write('\nUser experience level: $experience.');
    }
    if (recentWorkouts.isNotEmpty) {
      context.write('\nRecently completed workouts: ${recentWorkouts.join(', ')}.');
    }
    return context.toString();
  }

  static Uri _endpoint() => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
      );

  static Future<String> _generate({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your_gemini_api_key_here') {
      throw Exception(
        'Gemini API key is not configured. Add GEMINI_API_KEY to the .env file.',
      );
    }

    final response = await http
        .post(
          _endpoint(),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'system_instruction': {
              'parts': [
                {'text': systemPrompt}
              ]
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': userPrompt}
                ]
              }
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gemini API returned status ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Nox.');
    }

    final parts = candidates.first['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Empty response from Nox.');
    }

    return (parts.first['text'] as String).trim();
  }

  /// Sends a message to Nox and returns the coach's reply. `recentHistory`
  /// should be the last handful of turns (kept short by the caller);
  /// `goal`/`experience`/`recentWorkouts` come from the user's stored
  /// profile so Nox stays consistent across sessions without re-asking.
  static Future<String> askNox({
    required String message,
    List<String> recentHistory = const [],
    String? goal,
    String? experience,
    List<String> recentWorkouts = const [],
  }) async {
    final historyBlock = recentHistory.isEmpty
        ? ''
        : 'Conversation so far:\n${recentHistory.join('\n')}\n\n';
    return _generate(
      systemPrompt: _buildNoxSystemPrompt(
        goal: goal,
        experience: experience,
        recentWorkouts: recentWorkouts,
      ),
      userPrompt: '$historyBlock User: $message',
    );
  }

  /// Generates a structured workout plan from goal, time, and experience.
  static Future<String> generateWorkoutPlan({
    required String goal,
    required String timeAvailable,
    required String experienceLevel,
  }) async {
    final prompt =
        'Create a structured single-session workout plan.\n'
        'Goal: $goal\n'
        'Time available: $timeAvailable\n'
        'Experience level: $experienceLevel\n\n'
        'Format the plan as a numbered list of exercises with sets, reps, '
        'and rest periods. Keep it realistic for the time available.';

    return _generate(
      systemPrompt: _buildNoxSystemPrompt(goal: goal, experience: experienceLevel),
      userPrompt: prompt,
    );
  }
}

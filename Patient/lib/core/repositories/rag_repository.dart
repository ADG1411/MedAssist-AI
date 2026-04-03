import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/edge_function_service.dart';

final ragRepositoryProvider = Provider((ref) => RagRepository());

class RagRepository {
  bool get useMock => dotenv.env['USE_MOCK'] == 'true';

  Future<List<Map<String, dynamic>>> retrieveContext(String query) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        {
           'content': 'User reported severe GERD symptoms 2 days ago after eating spicy food.',
           'type': 'history',
        },
      ];
    } else {
      final res = await EdgeFunctionService.invoke('rag-retrieve', body: {'query': query, 'top_k': 3});
      return List<Map<String, dynamic>>.from(res['chunks'] ?? []);
    }
  }
}


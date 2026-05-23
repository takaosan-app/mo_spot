import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_config.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_location_alt_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('投稿（カメラ・ギャラリー）'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _insertSamplePost,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(_isSaving ? '保存中...' : 'サンプル投稿を保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _insertSamplePost() async {
    if (!SupabaseConfig.isConfigured) {
      _showSnackBar('Supabase設定がありません。--dart-defineでURLとanon keyを渡してください。');
      return;
    }

    if (!SupabaseConfig.hasDevUserId) {
      _showSnackBar('開発用user_idがありません。SUPABASE_DEV_USER_IDを設定してください。');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      await Supabase.instance.client.from('posts').insert({
        'user_id': SupabaseConfig.devUserId,
        'image_key': 'sample/$now.jpg',
        'latitude': 35.6586,
        'longitude': 139.7454,
        'ai_label': 'sample_spot',
        'japanese_name': 'サンプルスポット',
      });

      if (!mounted) {
        return;
      }

      _showSnackBar('postsテーブルにサンプルデータを保存しました。');
    } on PostgrestException catch (error) {
      debugPrint(_formatPostgrestError(error));

      if (!mounted) {
        return;
      }

      _showSnackBar('保存に失敗しました: ${error.message}');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar('保存に失敗しました: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatPostgrestError(PostgrestException error) {
    return [
      'Supabase insert failed.',
      'message: ${error.message}',
      if (error.code != null) 'code: ${error.code}',
      if (error.details != null) 'details: ${error.details}',
      if (error.hint != null) 'hint: ${error.hint}',
    ].join('\n');
  }
}

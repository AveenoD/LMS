import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_colors.dart';
import '../../providers/teacher_providers.dart';
import '../../services/api_service.dart';

import 'content_viewer_screen.dart';

class TeacherContentScreen extends ConsumerStatefulWidget {
  final int chapterId;
  final String chapterName;

  const TeacherContentScreen({
    super.key,
    required this.chapterId,
    required this.chapterName,
  });

  @override
  ConsumerState<TeacherContentScreen> createState() => _TeacherContentScreenState();
}

class _TeacherContentScreenState extends ConsumerState<TeacherContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(teacherContentProvider(widget.chapterId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.chapterName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Videos', icon: Icon(Icons.play_circle_fill)),
            Tab(text: 'Notes', icon: Icon(Icons.description)),
          ],
        ),
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (contents) {
          final videos = contents.where((c) => c['contentType'] == 'video').toList();
          final notes = contents.where((c) => c['contentType'] == 'document' || c['contentType'] == 'image').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(videos, 'video'),
              _buildList(notes, 'document'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadModal(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload New', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    final regExp = RegExp(r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  Widget _buildList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No ${type == 'video' ? 'videos' : 'notes'} uploaded yet.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideo = item['contentType'] == 'video';
        
        Widget leadingIcon;
        if (isVideo) {
          final videoId = _extractYouTubeId(item['fileUrl'] ?? '');
          if (videoId != null) {
            leadingIcon = ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://img.youtube.com/vi/$videoId/0.jpg',
                width: 60,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_filled, color: Colors.blue, size: 32),
              ),
            );
          } else {
            leadingIcon = const Icon(Icons.play_circle_filled, color: Colors.blue, size: 32);
          }
        } else {
          leadingIcon = Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
          );
        }

        return InkWell(
          onTap: () {
            final urlStr = item['fileUrl'] ?? '';
            final title = item['title'] ?? 'Untitled';
            final cType = item['contentType'] ?? 'document';
            
            if (urlStr.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentViewerScreen(
                    title: title,
                    fileUrl: urlStr,
                    contentType: cType,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                leadingIcon,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(item['fileUrl'] ?? 'null', style: TextStyle(color: Colors.blue.shade700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadModal(BuildContext context, WidgetRef ref) {
    final type = _tabController.index == 0 ? 'video' : 'notes';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _UploadModalContent(parentRef: ref, chapterId: widget.chapterId, initialUploadType: type),
    );
  }
}

class _UploadModalContent extends StatefulWidget {
  final WidgetRef parentRef;
  final int chapterId;
  final String initialUploadType;
  const _UploadModalContent({required this.parentRef, required this.chapterId, required this.initialUploadType});
  @override
  State<_UploadModalContent> createState() => _UploadModalContentState();
}

class _UploadModalContentState extends State<_UploadModalContent> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isUploading = false;
  String? _error;
  
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withReadStream: true,
        withData: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Limit to 10MB
        if (file.size > 10 * 1024 * 1024) {
          setState(() {
            _error = 'File size exceeds 10MB limit.';
            _selectedFile = null;
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'File picking failed: $e');
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final api = widget.parentRef.read(apiServiceProvider);

      if (widget.initialUploadType == 'video') {
        final url = _urlController.text.trim();
        if (url.isEmpty) {
          throw Exception('Please enter YouTube URL');
        }
        await api.post('/teacher/content', {
          'title': title,
          'fileUrl': url,
          'contentType': 'video',
          'chapterId': widget.chapterId,
        });
      } else {
        if (_selectedFile == null) {
          throw Exception('Please select a file');
        }

        // 1. Get Cloudinary Signature
        final sigRes = await api.get('/teacher/upload-signature');
        final apiKey = sigRes['apiKey'];
        final cloudName = sigRes['cloudName'];
        final timestamp = sigRes['timestamp'];
        final signature = sigRes['signature'];
        final folder = sigRes['folder'];

        if (apiKey == null || cloudName == null) {
          throw Exception("Cloudinary configuration is missing on the server.");
        }

        // 2. Upload to Cloudinary directly
        final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
        final req = http.MultipartRequest('POST', uri);
        
        req.fields['api_key'] = apiKey.toString();
        req.fields['timestamp'] = timestamp.toString();
        req.fields['signature'] = signature;
        req.fields['folder'] = folder;

        final file = File(_selectedFile!.path!);
        final fileLength = await file.length();
        req.files.add(http.MultipartFile(
          'file', 
          file.openRead(), 
          fileLength, 
          filename: _selectedFile!.name
        ));

        final streamedRes = await req.send();
        final res = await http.Response.fromStream(streamedRes);

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final data = jsonDecode(res.body);
          final fileUrl = data['secure_url'];
          
          final ext = _selectedFile!.extension?.toLowerCase() ?? '';
          final cType = ext == 'pdf' ? 'document' : 'image';

          // 3. Save to DB
          await api.post('/teacher/content', {
            'title': title,
            'fileUrl': fileUrl,
            'contentType': cType,
            'chapterId': widget.chapterId,
          });
        } else {
          throw Exception('Cloudinary upload failed: ${res.body}');
        }
      }

      if (mounted) {
        widget.parentRef.invalidate(teacherContentProvider(widget.chapterId));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.initialUploadType == 'video' ? 'Upload Video (URL)' : 'Upload Notes (File)', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade900)),
              ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            if (widget.initialUploadType == 'video') ...[
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'YouTube URL',
                  hintText: 'https://youtube.com/...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.url,
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile != null ? _selectedFile!.name : 'Select File (PDF/Image max 10MB)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Publish Material', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

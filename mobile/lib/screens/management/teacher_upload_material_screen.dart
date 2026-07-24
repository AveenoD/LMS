import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_colors.dart';
import '../../providers/teacher_providers.dart';
import '../../services/api_service.dart';

class TeacherUploadMaterialScreen extends ConsumerStatefulWidget {
  const TeacherUploadMaterialScreen({super.key});

  @override
  ConsumerState<TeacherUploadMaterialScreen> createState() => _TeacherUploadMaterialScreenState();
}

class _TeacherUploadMaterialScreenState extends ConsumerState<TeacherUploadMaterialScreen> {
  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(teacherContentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Uploaded Material', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (contents) {
          if (contents.isEmpty) {
            return const Center(child: Text('No material uploaded yet. Tap + to upload.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = contents[index];
              final url = item['youtube_url'].toString();
              final isPdfOrImage = url.contains('cloudinary') && !url.contains('video');
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPdfOrImage ? Icons.insert_drive_file : Icons.play_circle_filled, 
                        color: AppColors.primary, 
                        size: 32
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(url, style: TextStyle(color: Colors.blue.shade700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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

  void _showUploadModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _UploadModalContent(parentRef: ref),
    );
  }
}

class _UploadModalContent extends StatefulWidget {
  final WidgetRef parentRef;
  const _UploadModalContent({required this.parentRef});

  @override
  State<_UploadModalContent> createState() => _UploadModalContentState();
}

class _UploadModalContentState extends State<_UploadModalContent> {
  int _uploadType = 0; // 0 = YouTube Video, 1 = File (Image/PDF)
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = widget.parentRef.read(apiServiceProvider);
      String finalUrl = '';

      if (_uploadType == 0) {
        // YouTube URL
        finalUrl = _urlCtrl.text.trim();
        if (finalUrl.isEmpty) {
          throw Exception('Please enter a valid URL');
        }
      } else {
        // File Upload via API signature
        if (_selectedFile == null) {
          throw Exception('Please select a file to upload');
        }

        // Get signature
        final sigRes = await api.get('/teacher/upload-signature');
        final timestamp = sigRes['timestamp'].toString();
        final signature = sigRes['signature'];
        final cloudName = sigRes['cloudName'];
        final apiKey = sigRes['apiKey'];
        final folder = sigRes['folder'];

        if (apiKey == null || signature == null || cloudName == null) {
          throw Exception('Cloudinary configuration is missing on the server. Please check backend .env');
        }

        // Upload directly to Cloudinary
        var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
        var request = http.MultipartRequest('POST', uri);
        request.fields['api_key'] = apiKey;
        request.fields['timestamp'] = timestamp;
        request.fields['signature'] = signature;
        request.fields['folder'] = folder;
        
        var multipartFile = await http.MultipartFile.fromPath('file', _selectedFile!.path);
        request.files.add(multipartFile);
        
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        
        if (response.statusCode != 200) {
          throw Exception(jsonResponse['error']?['message'] ?? 'Failed to upload file');
        }
        
        finalUrl = jsonResponse['secure_url'];
      }

      // Save to backend
      await api.post('/teacher/content', {
        'title': title,
        'youtubeUrl': finalUrl,
      });

      widget.parentRef.invalidate(teacherContentProvider);
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text('Upload Material', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 24),
          
          // Type Selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('YouTube Video'),
                  selected: _uploadType == 0,
                  onSelected: (val) => setState(() => _uploadType = 0),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Image / PDF'),
                  selected: _uploadType == 1,
                  onSelected: (val) => setState(() => _uploadType = 1),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title (e.g. Chapter 1 Notes)'),
          ),
          const SizedBox(height: 16),

          if (_uploadType == 0)
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(labelText: 'YouTube Video URL'),
              keyboardType: TextInputType.url,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_selectedFile != null) ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 8),
                    Text('File selected: ${_selectedFile!.path.split('/').last}', style: const TextStyle(fontSize: 12)),
                    TextButton(onPressed: _pickFile, child: const Text('Change File')),
                  ] else ...[
                    const Icon(Icons.upload_file, color: Colors.grey, size: 40),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('Select File'),
                    )
                  ]
                ],
              ),
            ),
            
            const SizedBox(height: 24),

          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Publish Material'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}

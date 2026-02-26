 import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

// ==================
// Response Models
// ==================

class FileResponse {
  final String fileId;
  final String name;
  final String filename;
  final String uploadedAt;
  final String downloadUrl;

  FileResponse({
    required this.fileId,
    required this.name,
    required this.filename,
    required this.uploadedAt,
    required this.downloadUrl,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
      fileId: json['file_id']?.toString() ?? json['crp_id']?.toString() ?? '',
      name: json['name'] ?? '',
      filename: json['filename'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}

class ListFilesResponse {
  final String status;
  final String message;
  final List<FileResponse> files;

  ListFilesResponse({
    required this.status,
    required this.message,
    required this.files,
  });

  factory ListFilesResponse.fromJson(Map<String, dynamic> json) {
    // Extract files from data object (data contains: tag_id, files[], count)
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    final filesList = dataMap['files'] as List? ?? [];
    return ListFilesResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      files: filesList
          .map((file) => FileResponse.fromJson(file as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UploadFileResponse {
  final String status;
  final String message;
  final FileResponse? file;

  UploadFileResponse({
    required this.status,
    required this.message,
    this.file,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    return UploadFileResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      file: json['data'] != null ? FileResponse.fromJson(json['data']) : null,
    );
  }
}

class DeleteFileResponse {
  final String status;
  final String message;

  DeleteFileResponse({
    required this.status,
    required this.message,
  });

  factory DeleteFileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteFileResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class SetPinResponse {
  final String status;
  final String message;

  SetPinResponse({
    required this.status,
    required this.message,
  });

  factory SetPinResponse.fromJson(Map<String, dynamic> json) {
    return SetPinResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class CheckFilePinSetResponse {
  final String status;
  final String message;
  final bool filePinSet;

  CheckFilePinSetResponse({
    required this.status,
    required this.message,
    required this.filePinSet,
  });

  factory CheckFilePinSetResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CheckFilePinSetResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      filePinSet: data['file_pin_set'] ?? false,
    );
  }
}

class ValidateFilePinResponse {
  final String status;
  final String message;
  final bool valid;
  final String? result;

  ValidateFilePinResponse({
    required this.status,
    required this.message,
    required this.valid,
    this.result,
  });

  factory ValidateFilePinResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ValidateFilePinResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      valid: data['valid'] ?? false,
      result: data['result'],
    );
  }
}

// ==================
// Files Service
// ==================

class FilesService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String smValue = '67s87s6yys66';
  static const String sixs888iopValue = '6s888iop';
  static const String dgValue = 'testYU78dII8iiUIPSISJ';

  /// List all files for a tag
  /// Params: tag_id (required), ph (required - phone number)
  static Future<ListFilesResponse> listFiles({
    required String tagId,
    required String phoneNumber,
  }) async {
    try {
      print('Fetching files for tag ID: $tagId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/list_files_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'tag_id': tagId,
        'ph': phoneNumber,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('List files response: $jsonResponse');
        return ListFilesResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch files: $e');
    }
  }

  /// Upload a file for a tag
  /// Params: tag_id, ph (phone), name (file description), file_name (multipart file)
  /// Supported formats: PNG, JPEG, GIF
  /// Max: 5 files per tag
  static Future<UploadFileResponse> uploadFile({
    required String tagId,
    required String phoneNumber,
    required String fileName,
    required String filePath,
    required String fileDescription,
  }) async {
    try {
      print('📤 Uploading file: $filePath for tag ID: $tagId');

      final url = Uri.parse('$baseUrl/upload_files_api');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields['sm'] = smValue;
      request.fields['6s888iop'] = sixs888iopValue;
      request.fields['dg'] = dgValue;
      request.fields['tag_id'] = tagId;
      request.fields['ph'] = phoneNumber;
      request.fields['name'] = fileDescription;

      print('📋 Request fields:');
      print('  - tag_id: $tagId');
      print('  - ph: $phoneNumber');
      print('  - name: $fileDescription');

      // Add file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('❌ File not found: $filePath');
      }

      final fileSize = await file.length();
      print('📁 File details:');
      print('  - Original name: $fileName');
      print('  - File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      print('  - File path: $filePath');

      // Rename .jpg to .jpeg if needed (API might not support .jpg)
      String uploadFileName = fileName;
      if (fileName.toLowerCase().endsWith('.jpg')) {
        uploadFileName = fileName.replaceAll(RegExp(r'\.jpg$', caseSensitive: false), '.jpeg');
        print('⚠️  Renaming .jpg to .jpeg: $fileName → $uploadFileName');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file_name',
          filePath,
          filename: uploadFileName,
        ),
      );

      print('📤 Sending multipart request...');

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timeout'),
      );

      final responseBody = await response.stream.bytesToString();

      print('📡 Upload response status: ${response.statusCode}');
      print('📝 Upload response body: $responseBody');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(responseBody);
          print('✅ Upload file response: $jsonResponse');
          
          // Check if response is a valid object
          if (jsonResponse is! Map<String, dynamic>) {
            throw Exception('Invalid response format: Expected Map, got ${jsonResponse.runtimeType}');
          }
          
          return UploadFileResponse.fromJson(jsonResponse);
        } catch (e) {
          print('❌ JSON Parse Error: $e');
          print('🔍 Response body type: ${responseBody.runtimeType}');
          print('🔍 First 100 chars: ${responseBody.substring(0, min(100, responseBody.length))}');
          
          // Check if this is an unsupported file error
          if (responseBody.contains('Unsupported')) {
            throw Exception('❌ Unsupported File Format!\n\n'
                'The API does not support this file type.\n\n'
                'Supported formats:\n'
                '• JPEG (with .jpeg extension)\n'
                '• PNG (.png)\n'
                '• GIF (.gif)\n'
                '• PDF (.pdf)\n\n'
                'Try renaming: ${fileName.split('/').last}');
          }
          
          throw Exception('Failed to parse upload response: $e\nServer returned: ${responseBody.substring(0, min(200, responseBody.length))}');
        }
      } else {
        // Try to extract error message from JSON response
        try {
          final jsonResponse = jsonDecode(responseBody);
          if (jsonResponse is Map<String, dynamic>) {
            final errorMessage = jsonResponse['message'] ?? 'Upload failed';
            throw Exception(errorMessage);
          }
        } catch (e) {
          if (e is Exception) rethrow;
        }
        
        // Fallback to generic error
        throw Exception(
          'Upload API Error: ${response.statusCode}\nServer response: ${responseBody.substring(0, min(300, responseBody.length))}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a file
  /// Params: file_id (required - crp_id), ph (required - phone number)
  static Future<DeleteFileResponse> deleteFile({
    required String fileId,
    required String phoneNumber,
  }) async {
    try {
      print('Deleting file ID: $fileId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/delete_file_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'file_id': fileId,
        'ph': phoneNumber,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Delete file response: $jsonResponse');
        return DeleteFileResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Set PIN for file manager
  /// Params: tag_id (required), ph (required - phone number), passpin (required - 4-digit PIN)
  static Future<SetPinResponse> setPinAPI({
    required String tagId,
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      print('🔐 Setting PIN for tag ID: $tagId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/pinset_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'tag_id': tagId,
        'ph': phoneNumber,
        'passpin': pin,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Set PIN response: $jsonResponse');
        return SetPinResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to set PIN: $e');
    }
  }

  /// Verify PIN for file manager access
  /// Params: tag_id (required), ph (required - phone number), passpin (required - 4-digit PIN)
  static Future<SetPinResponse> verifyPinAPI({
    required String tagId,
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      print('🔑 Verifying PIN for tag ID: $tagId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/pinset_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'tag_id': tagId,
        'ph': phoneNumber,
        'passpin': pin,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ PIN verification response: $jsonResponse');
        return SetPinResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to verify PIN: $e');
    }
  }

  /// Check if PIN is set for a tag
  /// Params: tag_id (required), ph (required - phone number)
  /// Returns: file_pin_set (true if PIN is set, false otherwise)
  static Future<CheckFilePinSetResponse> checkFilePinSet({
    required String tagId,
    required String phoneNumber,
  }) async {
    try {
      print('🔍 Checking if PIN is set for tag ID: $tagId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/check_file_pin_set_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'tag_id': tagId,
        'ph': phoneNumber,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Check PIN set response: $jsonResponse');
        return CheckFilePinSetResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to check PIN status: $e');
    }
  }

  /// Validate file access PIN for a tag
  /// Params: tag_id (required), ph (required - phone number), passpin (required - PIN to validate)
  /// Returns: success with valid flag or error if invalid
  static Future<ValidateFilePinResponse> validateFilePin({
    required String tagId,
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      print('🔑 Validating file PIN for tag ID: $tagId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/validate_file_pin_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'tag_id': tagId,
        'ph': phoneNumber,
        'passpin': pin,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Validate PIN response: $jsonResponse');
        final validateResponse = ValidateFilePinResponse.fromJson(jsonResponse);
        
        // Check the status field first
        if (validateResponse.status == 'error') {
          throw Exception(validateResponse.message);
        }
        
        // Check if PIN validation was successful
        if (!validateResponse.valid) {
          throw Exception(validateResponse.message.isNotEmpty 
              ? validateResponse.message 
              : 'Invalid PIN - Access denied');
        }
        
        return validateResponse;
      } else if (response.statusCode == 403) {
        throw Exception('Invalid PIN - Access denied');
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

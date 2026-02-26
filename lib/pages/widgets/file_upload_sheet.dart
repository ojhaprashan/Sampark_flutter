import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/files_service.dart';
import '../../services/auth_service.dart';

enum PinStatus { checking, notSet, set }

class FileUploadSheet extends StatefulWidget {
  final int tagId;

  const FileUploadSheet({super.key, required this.tagId});

  static void show(BuildContext context, {required int tagId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FileUploadSheet(tagId: tagId),
    );
  }

  @override
  State<FileUploadSheet> createState() => _FileUploadSheetState();
}

class _FileUploadSheetState extends State<FileUploadSheet> {
  PinStatus _pinStatus = PinStatus.checking;
  bool _isPinVerified = false;
  bool _isLoading = false;
  bool _isLoadingFiles = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String _uploadStatus = '';
  String _currentFileName = '';
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final ScrollController _uploadScrollController = ScrollController();
  String _pinError = '';
  List<FileResponse> _uploadedFiles = [];
  String? _userPhoneNumber;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      _userPhoneNumber = countryCode.replaceFirst('+', '') + phone;
      await _checkPinStatus();
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _isLoadingFiles = false;
        _errorMessage = 'Failed to load data';
        _pinStatus = PinStatus.notSet;
      });
    }
  }

  Future<void> _checkPinStatus() async {
    if (_userPhoneNumber == null) return;
    try {
      print('🔍 Checking PIN status...');
      final response = await FilesService.checkFilePinSet(
        tagId: widget.tagId.toString(),
        phoneNumber: _userPhoneNumber!,
      );
      if (mounted) {
        setState(() {
          _pinStatus = response.filePinSet ? PinStatus.set : PinStatus.notSet;
        });
        if (_pinStatus == PinStatus.notSet) {
          await _fetchFiles();
        } else {
          setState(() => _isLoadingFiles = false);
        }
      }
    } catch (e) {
      print('❌ Error checking PIN status: $e');
      if (mounted) {
        setState(() {
          _pinStatus = PinStatus.notSet;
          _isLoadingFiles = false;
        });
      }
    }
  }

  Future<void> _fetchFiles() async {
    if (_userPhoneNumber == null) return;
    try {
      final response = await FilesService.listFiles(
        tagId: widget.tagId.toString(),
        phoneNumber: _userPhoneNumber!,
      );
      if (mounted) {
        setState(() {
          _uploadedFiles = response.files;
          _isLoadingFiles = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFiles = false;
          _errorMessage = 'Failed to fetch files';
        });
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _uploadScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_uploadScrollController.hasClients) {
        _uploadScrollController.jumpTo(
          _uploadScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  String _extractErrorMessage(dynamic error) {
    String message = error.toString();
    while (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }
    return message;
  }

  void _handleSetPin() async {
    if (_pinController.text.length != 4) {
      setState(() {
        _pinError = 'Please enter a 4-digit PIN';
      });
      return;
    }
    if (_userPhoneNumber == null) {
      setState(() {
        _pinError = 'Phone number not available';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _pinError = '';
    });
    try {
      final response = await FilesService.setPinAPI(
        tagId: widget.tagId.toString(),
        phoneNumber: _userPhoneNumber!,
        pin: _pinController.text,
      );
      if (mounted) {
        if (response.status == 'success') {
          setState(() {
            _isLoading = false;
            _pinStatus = PinStatus.set;
            _isPinVerified = true;
            _pinError = '';
            _pinController.clear();
          });
          _showSuccessSnackBar('✅ PIN set successfully!');
          await _fetchFiles();
        } else {
          setState(() {
            _isLoading = false;
            _pinError = response.message.isNotEmpty
                ? response.message
                : 'Failed to set PIN';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pinError = _extractErrorMessage(e);
        });
      }
      print('❌ PIN Set Error: $e');
    }
  }

  void _handleVerifyPin() async {
    if (_pinController.text.length != 4) {
      setState(() {
        _pinError = 'Please enter a 4-digit PIN';
      });
      return;
    }
    if (_userPhoneNumber == null) {
      setState(() {
        _pinError = 'Phone number not available';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _pinError = '';
    });
    try {
      final response = await FilesService.validateFilePin(
        tagId: widget.tagId.toString(),
        phoneNumber: _userPhoneNumber!,
        pin: _pinController.text,
      );
      if (mounted) {
        if (response.status == 'success') {
          setState(() {
            _isLoading = false;
            _pinStatus = PinStatus.set;
            _isPinVerified = true;
            _pinError = '';
            _pinController.clear();
          });
          _showSuccessSnackBar('✅ PIN verified! Access granted.');
          await _fetchFiles();
        } else {
          setState(() {
            _isLoading = false;
            _pinError = response.message.isNotEmpty
                ? response.message
                : 'Incorrect PIN';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pinError = _extractErrorMessage(e);
        });
      }
      print('❌ PIN Verification Error: $e');
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upload from',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionItem(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: Colors.pink,
                      onTap: () => _captureAndUpload(true),
                    ),
                    _buildOptionItem(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: Colors.purple,
                      onTap: () => _captureAndUpload(false),
                    ),
                    _buildOptionItem(
                      icon: Icons.folder_open_rounded,
                      label: 'Documents',
                      color: Colors.blue,
                      onTap: () => _pickLocalFile(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX 1: Show error inside sheet instead of snackbar
  Future<void> _captureAndUpload(bool isCamera) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        await _uploadFileToAPI(
          filePath: pickedFile.path,
          fileName: pickedFile.name,
          fileDescription: isCamera ? 'Camera Photo' : 'Gallery Image',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              '❌ Failed to select image\n\n${_extractErrorMessage(e)}';
        });
      }
    }
  }

  // ✅ FIX 2: Show error inside sheet instead of snackbar
  Future<void> _pickLocalFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        await _uploadFileToAPI(
          filePath: file.path!,
          fileName: file.name,
          fileDescription: file.name,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              '❌ Failed to pick file\n\n${_extractErrorMessage(e)}';
        });
      }
    }
  }

  Future<void> _uploadFileToAPI({
    required String filePath,
    required String fileName,
    required String fileDescription,
  }) async {
    if (_userPhoneNumber == null) {
      // ✅ FIX: Show error inside sheet instead of snackbar
      setState(() {
        _errorMessage = '❌ Phone number not available';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparing upload...';
      _currentFileName = fileName;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _uploadProgress = 0.2;
        _uploadStatus = 'Validating file...';
      });
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _uploadProgress = 0.4;
        _uploadStatus = 'Uploading to server...';
      });

      final response = await FilesService.uploadFile(
        tagId: widget.tagId.toString(),
        phoneNumber: _userPhoneNumber!,
        fileName: fileName,
        filePath: filePath,
        fileDescription: fileDescription,
      );

      setState(() {
        _uploadProgress = 0.8;
        _uploadStatus = 'Processing...';
      });

      if (response.status == 'success') {
        await _fetchFiles();
        if (mounted) {
          setState(() {
            _uploadProgress = 1.0;
            _uploadStatus = 'Upload complete!';
          });
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            setState(() {
              _isUploading = false;
              _uploadProgress = 0.0;
              _uploadStatus = '';
              _currentFileName = '';
            });
            _showSuccessSnackBar('✅ File uploaded successfully!');
          }
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      String errorMessage = _extractErrorMessage(e);
      String displayError = '';
      String technicalDetails = '';
      print('❌ Upload Error: $errorMessage');

      if (errorMessage.contains('Unsupported') ||
          errorMessage.contains('does not accept') ||
          errorMessage.contains('file type')) {
        displayError = '❌ File Format Not Supported';
        technicalDetails = errorMessage;
      } else if (errorMessage.contains('timeout') ||
          errorMessage.contains('Timeout')) {
        displayError = '⏱️ Upload Timed Out';
        technicalDetails =
            'The server took too long to respond.\n\nTry uploading a smaller file or check your internet connection.';
      } else if (errorMessage.contains('SocketException') ||
          errorMessage.contains('NetworkException')) {
        displayError = '🌐 Network Error';
        technicalDetails =
            'Unable to connect to the server.\n\nPlease check your internet connection and try again.';
      } else if (errorMessage.contains('File not found')) {
        displayError = '📁 File Not Found';
        technicalDetails =
            'The selected file could not be accessed.\n\nPlease try selecting the file again.';
      } else if (errorMessage.contains('Failed to parse')) {
        displayError = '🔧 Server Response Error';
        technicalDetails =
            'The server returned an unexpected response.\n\nThis might be a temporary issue. Please try again.';
      } else {
        displayError = '❌ Upload Failed';
        technicalDetails = errorMessage.length > 200
            ? '${errorMessage.substring(0, 200)}...'
            : errorMessage;
      }

      String fullErrorMessage = '$displayError\n\n$technicalDetails';
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
          _errorMessage = fullErrorMessage;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _deleteFile(String fileId) async {
    if (_userPhoneNumber == null) return;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete File'),
            content:
                const Text('Are you sure you want to delete this file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final response = await FilesService.deleteFile(
        fileId: fileId,
        phoneNumber: _userPhoneNumber!,
      );
      if (response.status == 'success') {
        await _fetchFiles();
        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessSnackBar('File deleted successfully');
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // ✅ FIX 3: Show delete error inside sheet instead of snackbar
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              '❌ Failed to delete file\n\n${_extractErrorMessage(e)}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: _isUploading
                  ? _buildUploadProgressView()
                  : _pinStatus == PinStatus.checking
                      ? _buildCheckingPinView()
                      : !_isPinVerified
                          ? _buildSetPinView()
                          : _buildUploadFilesView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckingPinView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.activeYellow),
          ),
          const SizedBox(height: 16),
          const Text(
            'Checking PIN status...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgressView() {
    return SingleChildScrollView(
      controller: _uploadScrollController,
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Circle Progress
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.activeYellow),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      if (_uploadProgress < 1.0)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                      if (_uploadProgress >= 1.0)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // File name
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_drive_file,
                      size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _currentFileName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Status text
            Text(
              _uploadStatus,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                minHeight: 8,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.activeYellow),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            // Error message inside progress view
            if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Error Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: SelectableText(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 13,
                          height: 1.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _errorMessage!));
                              _showSuccessSnackBar(
                                  'Error copied to clipboard');
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy Error'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isUploading = false;
                                _errorMessage = null;
                                _uploadProgress = 0.0;
                                _uploadStatus = '';
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetPinView() {
    final isCreatingPin = _pinStatus == PinStatus.notSet;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              isCreatingPin
                  ? Icons.lock_outline_rounded
                  : Icons.lock_open_rounded,
              size: 48,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              isCreatingPin
                  ? 'Secure your Documents'
                  : 'Enter PIN to Access',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isCreatingPin
                  ? 'Set a 4-digit PIN to keep your files safe'
                  : 'Enter the PIN to access your documents',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isCreatingPin ? 'Create PIN' : 'Enter PIN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _pinController,
              focusNode: _pinFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 16,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_pinError.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _pinError,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : isCreatingPin
                      ? _handleSetPin
                      : _handleVerifyPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeYellow,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      isCreatingPin ? 'Set PIN & Continue' : 'Verify PIN',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX 4: Error banner added inside the files view
  Widget _buildUploadFilesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Documents',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // ✅ Error banner visible inside the sheet
        if (_errorMessage != null && _errorMessage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _errorMessage = null),
                        child: Icon(Icons.close,
                            size: 18, color: Colors.red.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _showUploadOptions();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Try Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // File count badge
        if (_uploadedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.activeYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_uploadedFiles.length} ${_uploadedFiles.length == 1 ? "file" : "files"} uploaded',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        Expanded(
          child: _isLoadingFiles
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.activeYellow),
                  ),
                )
              : _uploadedFiles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _uploadedFiles[index];
                        return _buildFileCard(file);
                      },
                    ),
        ),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _showUploadOptions,
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.black),
            label: const Text(
              'Upload New File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(FileResponse file) {
    final isPdf = file.filename.toLowerCase().endsWith('.pdf');
    final isImage = file.filename.toLowerCase().endsWith('.jpg') ||
        file.filename.toLowerCase().endsWith('.jpeg') ||
        file.filename.toLowerCase().endsWith('.png') ||
        file.filename.toLowerCase().endsWith('.gif');

    Color cardColor;
    Color iconColor;
    IconData icon;

    if (isPdf) {
      cardColor = Colors.red.shade50;
      iconColor = Colors.red.shade700;
      icon = Icons.picture_as_pdf;
    } else if (isImage) {
      cardColor = Colors.blue.shade50;
      iconColor = Colors.blue.shade700;
      icon = Icons.image;
    } else {
      cardColor = Colors.grey.shade100;
      iconColor = Colors.grey.shade700;
      icon = Icons.insert_drive_file;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showDownloadDialog(file);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            file.uploadedAt,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteFile(file.fileId);
                    } else if (value == 'download') {
                      _showDownloadDialog(file);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Download'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No files uploaded yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your documents to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDownloadDialog(FileResponse file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Download File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${file.name}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Uploaded: ${file.uploadedAt}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(file.downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              } else {
                _showErrorSnackBar('Cannot open download link');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              foregroundColor: AppColors.black,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}

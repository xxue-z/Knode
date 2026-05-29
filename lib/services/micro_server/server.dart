import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

class UploadRequest {
  final String requestId;
  final String fileName;
  final int fileSize;
  final Completer<bool> completer;
  UploadRequest({required this.requestId, required this.fileName, required this.fileSize}) : completer = Completer<bool>();
}

class MicroServer {
  HttpServer? _server;
  final int port;
  final shelf.Pipeline Function(shelf.Pipeline) pipeline;
  final _uploadController = StreamController<UploadRequest>.broadcast();
  final Map<String, UploadRequest> _pendingUploads = {};

  MicroServer({this.port = 8080, required this.pipeline});

  bool get isRunning => _server != null;
  Stream<UploadRequest> get uploadRequests => _uploadController.stream;

  Future<void> start() async {
    if (_server != null) return;
    final handler = pipeline(const shelf.Pipeline()).call;
    _server = await io.serve(handler, InternetAddress.loopbackIPv4, port);
  }

  Future<void> stop() async {
    final s = _server;
    _server = null;
    await s?.close();
  }

  void confirmUpload(String requestId) {
    _pendingUploads[requestId]?.completer.complete(true);
    _pendingUploads.remove(requestId);
  }

  void rejectUpload(String requestId) {
    _pendingUploads[requestId]?.completer.complete(false);
    _pendingUploads.remove(requestId);
  }

  String addPendingUpload(String fileName, int fileSize) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final req = UploadRequest(requestId: id, fileName: fileName, fileSize: fileSize);
    _pendingUploads[id] = req;
    _uploadController.add(req);
    return id;
  }
}
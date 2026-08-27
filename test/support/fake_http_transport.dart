import 'package:happilab/core/network/http_transport.dart';

/// Scripted transport for tests: no sockets, no timing, fully deterministic.
class FakeHttpTransport implements HttpTransport {
  FakeHttpTransport({this.responses = const <HttpTransportResponse>[]});

  final List<HttpTransportResponse> responses;
  final List<HttpTransportRequest> sentRequests = <HttpTransportRequest>[];
  bool isClosed = false;

  @override
  Future<HttpTransportResponse> send(HttpTransportRequest request) async {
    sentRequests.add(request);
    final index = sentRequests.length - 1;
    return index < responses.length
        ? responses[index]
        : const HttpTransportResponse(statusCode: 200, body: '{}');
  }

  @override
  void close() => isClosed = true;
}

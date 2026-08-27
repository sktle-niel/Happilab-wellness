import 'dart:convert';
import 'dart:io';

import '../errors/app_exception.dart';
import 'http_transport.dart';

/// `dart:io` implementation of [HttpTransport].
///
/// It also translates platform errors into [AppException]s so nothing above
/// this layer has to know what a `SocketException` is.
///
/// The bad-certificate callback is deliberately left at its default: overriding
/// it disables TLS validation and turns every call into a man-in-the-middle
/// opportunity.
final class IoHttpTransport implements HttpTransport {
  IoHttpTransport({this.timeout = const Duration(seconds: 20)})
    : _client = HttpClient()..connectionTimeout = timeout;

  final Duration timeout;
  final HttpClient _client;

  @override
  Future<HttpTransportResponse> send(HttpTransportRequest request) async {
    try {
      final httpRequest = await _client.openUrl(
        request.method.name.toUpperCase(),
        request.url,
      );
      request.headers.forEach(httpRequest.headers.set);

      if (request.body != null) {
        httpRequest.headers.contentType = ContentType.json;
        httpRequest.add(utf8.encode(jsonEncode(request.body)));
      }

      final response = await httpRequest.close();
      final body = await response.transform(utf8.decoder).join();

      return HttpTransportResponse(
        statusCode: response.statusCode,
        body: body,
        headers: _headersOf(response),
      );
    } on HandshakeException {
      throw const NetworkException('Could not establish a secure connection.');
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException('The connection was interrupted.');
    }
  }

  @override
  void close() => _client.close(force: true);

  static Map<String, String> _headersOf(HttpClientResponse response) {
    final headers = <String, String>{};
    response.headers.forEach((name, values) {
      headers[name.toLowerCase()] = values.join(', ');
    });
    return headers;
  }
}

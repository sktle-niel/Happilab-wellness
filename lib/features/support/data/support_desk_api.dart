import 'dart:io';
import 'dart:typed_data';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../domain/support_chat.dart';
import '../domain/support_desk.dart';

/// [SupportDesk] over the API. Nothing is cached: a chat is read for what
/// the desk said since, so every read is live.
final class SupportDeskApi implements SupportDesk {
  const SupportDeskApi(this._client);

  static const Map<String, String> _imageTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  final ApiClient _client;

  @override
  Future<Result<SupportConversation>> open({
    String? topic,
    String? body,
    String? photoUrl,
  }) => _client.post(
    ApiEndpoints.supportConversations,
    body: {'topic': ?topic, 'body': ?body, 'attachment_url': ?photoUrl},
    parse: parseConversation,
  );

  @override
  Future<Result<SupportConversation>> conversation(String id) => _client.get(
    ApiEndpoints.supportConversation(id),
    parse: parseConversation,
  );

  @override
  Future<Result<ChatMessage>> send(
    String id, {
    String? body,
    String? photoUrl,
  }) => _client.post(
    ApiEndpoints.supportMessages(id),
    body: {'body': ?body, 'attachment_url': ?photoUrl},
    parse: parseMessage,
  );

  /// The API signs one address for the picture, the bytes go straight
  /// there, and the public address is what the chat line carries.
  @override
  Future<Result<String>> uploadPhoto(File file, {required int bytes}) async {
    final contentType = _imageTypes[file.path.split('.').last.toLowerCase()];
    if (contentType == null) {
      return const Failure(
        ValidationException('That kind of file cannot be sent here.'),
      );
    }
    final signed = await _client.post(
      ApiEndpoints.supportUploadSign,
      body: {'content_type': contentType, 'content_length': bytes},
      parse: _SignedUpload.parse,
    );
    final ticket = signed.valueOrNull;
    if (ticket == null) return Failure(signed.errorOrNull!);

    final Uint8List data;
    try {
      data = await file.readAsBytes();
    } on FileSystemException {
      return const Failure(UnknownException('Could not read that photo.'));
    }
    final put = await _client.upload(
      ticket.uploadUrl,
      data,
      contentType: contentType,
    );
    return put.map((_) => ticket.publicUrl);
  }

  static SupportConversation parseConversation(Object? json) {
    final reader = JsonReader.of(json);
    return SupportConversation(
      id: reader.string('id'),
      status: _status(reader.string('status')),
      topic: reader.optionalString('topic'),
      agentName: reader.optionalString('agent_name'),
      queuePosition: reader.optionalInteger('queue_position'),
      messages: reader.list('messages', _message),
    );
  }

  static ChatMessage parseMessage(Object? json) =>
      _message(JsonReader.of(json));

  static ChatStatus _status(String wire) {
    for (final status in ChatStatus.values) {
      if (status.wire == wire) return status;
    }
    throw const DataFormatException();
  }

  static ChatMessage _message(JsonReader item) {
    final photo = item.optionalString('attachment_url');
    return ChatMessage(
      id: item.string('id'),
      text: item.string('body'),
      sentAt: item.dateTime('sent_at').toLocal(),
      sender: _sender(item),
      photo: photo == null ? null : ChatPhoto(Uri.parse(photo)),
    );
  }

  static ChatSender _sender(JsonReader item) => switch (item.string('sender')) {
    'member' => const MemberSender(),
    'bot' => const BotSender(),
    'system' => const SystemSender(),
    'agent' => AgentSender(
      SupportAgent(item.optionalString('agent_name') ?? 'Support'),
    ),
    _ => throw const DataFormatException(),
  };
}

/// Where a photo goes and where it will be read from.
final class _SignedUpload {
  const _SignedUpload({required this.uploadUrl, required this.publicUrl});

  final Uri uploadUrl;
  final String publicUrl;

  /// The store's address wants its token as a query; the API hands both
  /// over, joined here when the address does not carry it yet.
  static _SignedUpload parse(Object? json) {
    final reader = JsonReader.of(json);
    final address = Uri.parse(reader.string('upload_url'));
    final token = reader.string('token');
    return _SignedUpload(
      uploadUrl: address.queryParameters.containsKey('token')
          ? address
          : address.replace(
              queryParameters: {...address.queryParameters, 'token': token},
            ),
      publicUrl: reader.string('public_url'),
    );
  }
}

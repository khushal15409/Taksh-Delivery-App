import '../error/failure.dart';

/// Turns technical errors (socket / format / server exceptions, raw backend keys)
/// into short sentences a delivery partner can act on.
class FriendlyMessage {
  static const noInternet =
      'No internet connection. Please check your mobile data or Wi-Fi and try again.';
  static const slowServer =
      'The server is taking too long to respond. Please try again.';
  static const somethingWrong =
      'Something went wrong. Please try again after some time.';
  static const sessionExpired = 'Your login has expired. Please login again.';
  static const notAllowed =
      'You are not allowed to do this. Please login again if this continues.';
  static const tooManyAttempts =
      'Too many attempts. Please wait a minute and try again.';

  static String from(dynamic error, {String? fallback}) {
    var message = error is AppException ? error.message : (error?.toString() ?? '');
    message = message
        .replaceFirst(
            RegExp(
                r'^(Exception|ClientException|FormatException|HttpException|SocketException|HandshakeException|TlsException):\s*'),
            '')
        .trim();
    final lower = message.toLowerCase();

    if (lower.isEmpty) return fallback ?? somethingWrong;

    if (lower.contains('socketexception') ||
        lower.contains('network error') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('connection closed') ||
        lower.contains('connection terminated') ||
        lower.contains('network is unreachable') ||
        lower.contains('no address associated') ||
        lower.contains('handshake')) {
      return noInternet;
    }
    if (lower.contains('timed out') || lower.contains('timeoutexception')) {
      return slowServer;
    }
    if (lower.contains('session_expired') || lower.contains('session expired')) {
      return sessionExpired;
    }
    if (lower.contains('unauthorized') || lower.contains('unauthenticated')) {
      return notAllowed;
    }
    if (lower.contains('too many') || lower.contains('rate limit')) {
      return tooManyAttempts;
    }
    if (lower.contains('invalid server response') ||
        lower.contains('server error') ||
        lower.contains('unexpected error occurred') ||
        lower.contains('formatexception') ||
        lower.contains('is not a subtype') ||
        lower.contains('null check operator') ||
        lower.contains('nosuchmethod') ||
        lower.contains('type \'') ||
        lower.contains('stack trace')) {
      return fallback ?? somethingWrong;
    }
    return message;
  }
}

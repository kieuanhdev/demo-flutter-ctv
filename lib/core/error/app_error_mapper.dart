import 'dart:io';

import 'package:dio/dio.dart';

class AppErrorMapper {
  AppErrorMapper._();

  static String message(Object error) {
    if (error is DioException) return _fromDio(error);
    if (error is FormatException) return 'Dữ liệu trả về không hợp lệ.';
    if (error is SocketException) return 'Không có kết nối mạng.';
    if (error is StateError) return error.message;
    return 'Đã xảy ra lỗi, vui lòng thử lại.';
  }

  static String _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá chậm, vui lòng thử lại.';

      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến máy chủ.';

      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị huỷ.';

      case DioExceptionType.badResponse:
        return _fromStatusCode(e.response?.statusCode, e.response?.data);

      case DioExceptionType.badCertificate:
        return 'Chứng chỉ bảo mật không hợp lệ.';

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'Không có kết nối mạng.';
        }
        return 'Đã xảy ra lỗi, vui lòng thử lại.';
    }
  }

  static String _fromStatusCode(int? statusCode, dynamic data) {
    final serverMessage = _extractServerMessage(data);

    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Yêu cầu không hợp lệ.';
      case 401:
        return serverMessage ??
            'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy dữ liệu yêu cầu.';
      case 409:
        return serverMessage ?? 'Dữ liệu bị xung đột, vui lòng thử lại.';
      case 422:
        return serverMessage ?? 'Dữ liệu gửi lên không hợp lệ.';
      case 429:
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau.';
      case 500:
      case 502:
      case 503:
        return 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.';
      default:
        return serverMessage ?? 'Đã xảy ra lỗi (mã $statusCode).';
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg;

      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) return error;

      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic>) {
          final firstMsg = first['msg'];
          if (firstMsg is String && firstMsg.trim().isNotEmpty) return firstMsg;
        }
        if (first is String && first.trim().isNotEmpty) return first;
      }
    }
    return null;
  }
}

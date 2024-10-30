class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server error occurred'});
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Cache error occurred'});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'Network error occurred'});
}

class ValidationException implements Exception {
  final String message;
  ValidationException({this.message = 'Validation error occurred'});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = 'Unauthorized access'});
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({this.message = 'Resource not found'});
}

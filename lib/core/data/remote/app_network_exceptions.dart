import 'package:retrofit/dio.dart';

class AppNetworkExceptions implements Exception {
  AppNetworkExceptions({
    required HttpResponse response,
  }) : _response = response;

  final HttpResponse _response;

  @override
  String toString() {
    return '''
Network Unknown error occurred, handle by AppNetworkException.
- Request :
  - Code: ${_response.response.statusCode}
  - HEAD : ${_response.response.headers}
  - RequestOption : ${_response.response.requestOptions}
''';
  }
}

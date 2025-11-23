import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

// Generate mocks for HTTP client
@GenerateMocks([http.Client])
void main() {}

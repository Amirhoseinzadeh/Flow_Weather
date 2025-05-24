import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants{
  static const baseUrl = 'https://api.neshan.org';
  static String? apiKey = dotenv.env['apiKey'];
}
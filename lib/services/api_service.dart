import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pawdoct/app.dart';
import 'package:pawdoct/models/buletin_model.dart';
import 'package:pawdoct/models/diagnosis_model.dart';
import 'package:pawdoct/models/user_model.dart';
import 'package:pawdoct/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://ec2-13-229-197-100.ap-southeast-1.compute.amazonaws.com/api',
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService().authToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint(
            '[api-service] [${options.method}] ${options.uri} (token: $token)',
          );
          debugPrint(
            '[data]: '
          );
          print(options.data);

          return handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint('[api-response] error');
          if (error.response != null) {
            if (error.response!.statusCode == 401) {
              await StorageService().clear();
              final currentRoute = ModalRoute.of(navigatorKey.currentContext!)?.settings.name;
              if (currentRoute != '/login') {
                navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
              }
            } else {
              handler.next(error);
            }
          }
        },
      ),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    required String gender,
    required String address,
    required String phone,
  }) async {
    final Map<String, String> body = {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'password_confirmation': password,
      'address': address,
      'gender': gender,
      'phone': phone
    };

    final res = await dio.post('/auth/register', data: body);
    if (res.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });

    final token = res.data['token'];
    final user = UserModel.fromJson(res.data['user']);

    return {
      "user": user,
      "token": token,
    };
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }

  Future<bool> forgotPassword(String email) async {
    final res = await dio.post("/auth/forgot-password", data: {
      "email": email,
    });
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> updatePassword({
    required String email,
    required String token,
    required String password
  }) async {
    final Map<String, String> body = {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': password,
    };

    final res = await dio.post("/auth/reset-password", data: body);
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<UserModel> updateProfile(Map<String, dynamic> update) async {
    final res = await dio.post("/profile/update", data: update);
    final data = res.data;
    final user = UserModel.fromJson(data);

    return user;
  }

  Future<List<BuletinModel>> fetchBulletins({bool refresh = false}) async {
    final res = await dio.get('/buletin/index?refresh=${refresh ? 'force' : 'false'}');
    final data = res.data as List;

    return data.map((json) => BuletinModel.fromJson(json)).toList();
  }

  Future<List<String>> fetchDiagnosisFeatures() async {
    final res = await dio.get('/diagnosis/features');
    final data = res.data;

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    throw Exception('Unexpected response format: $data');
  }

  Future<List<DiagnosisModel>> fetchDiagnosisList() async {
    final res = await dio.get('/diagnosis/list');
    final data = res.data;

    if (data is List) {
      return data.map((e) => DiagnosisModel.fromJson(e)).toList();
    }

    throw Exception('Unexpected response format: $data');
  }

  Future<DiagnosisModel> diagnosisCheck({
    required String petName,
    required String petGender,
    required Set<String> symptom
  }) async {
    final Map<String, String> body = {
      'pet_name': petName,
      'pet_gender': petGender,
    };

    for (var gejala in symptom) {
      body[gejala] = "Yes";
    }

    final res = await dio.post("/diagnosis/check", data: body);
    final rawData = res.data['results'];

    final data = DiagnosisModel.fromJson(rawData);
    return data;
  }

  Future<bool> diagnosisSave({
    required DiagnosisModel diagnosis,
  }) async {
    final res = await dio.post("/diagnosis/save", data: {
      "diagnosis": diagnosis.toJson(),
    });
    if (res.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> diagnosisDelete({
    required int id
  }) async {
    final res = await dio.delete('/diagnosis/delete/$id');
    if (res.statusCode == 204) {
      return true;
    }
    return false;
  }
}

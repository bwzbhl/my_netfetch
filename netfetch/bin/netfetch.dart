import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'dart:convert';
void main() async {
  //....https://dart.cn/tutorials/server/fetch-data#build-a-url
  // Parse the entire URI, including the scheme
  Uri.parse('https://dart.dev/f/packages/http.json');

  // Specifically create a URI with the https scheme
  Uri.https('dart.dev', '/f/packages/http.json');
  
  //......https://dart.cn/tutorials/server/fetch-data#make-a-network-request
  final httpPackageUrl = Uri.https('dart.dev', '/f/packages/http.json');
  final httpPackageInfo = await http.read(httpPackageUrl);
  print(httpPackageInfo);

  //....https://dart.cn/tutorials/server/fetch-data#decode-the-retrieved-data
  final httpPackageJson = json.decode(httpPackageInfo) as Map<String, dynamic>;
  print(httpPackageJson);

  final httpPackageUrl_2 = Uri.https('dart.dev', '/f/packages/http.json');
  final httpPackageResponse = await http.get(httpPackageUrl_2);
  if (httpPackageResponse.statusCode != 200) {
    print('Failed to retrieve the http package!');
    return;
  }
  print(httpPackageResponse.body);

  await http.get(Uri.https('dart.dev', '/f/packages/http.json'),
    headers: {'User-Agent': '<product name>/<product-version>'});

  //....https://dart.cn/tutorials/server/fetch-data#make-multiple-requests
  final client = http.Client();
  try {
    final httpPackageInfo = await client.read(httpPackageUrl);
    print(httpPackageInfo);
  } finally {
    client.close();
  }

  final client_1 = RetryClient(http.Client());
  try {
    final httpPackageInfo = await client_1.read(httpPackageUrl);
    print(httpPackageInfo);
  } finally {
    client.close();
  }

//...https://dart.cn/tutorials/server/fetch-data#utilize-the-converted-data
  await printPackageInformation('http');
  print('');
  await printPackageInformation('path');
  
}

Future<void> printPackageInformation(String packageName) async {
  final PackageInfo packageInfo;

  try {
    packageInfo = await getPackage(packageName);
  } on PackageRetrievalException catch (e) {
    print(e);
    return;
  }

  print('Information about the $packageName package:');
  print('Latest version: ${packageInfo.latestVersion}');
  print('Description: ${packageInfo.description}');
  print('Publisher: ${packageInfo.publisher}');

  final repository = packageInfo.repository;
  if (repository != null) {
    print('Repository: $repository');
  }
}

Future<PackageInfo> getPackage(String packageName) async {
  final packageUrl = Uri.https('dart.dev', '/f/packages/$packageName.json');
  final packageResponse = await http.get(packageUrl);

  // If the request didn't succeed, throw an exception
  if (packageResponse.statusCode != 200) {
    throw PackageRetrievalException(
      packageName: packageName,
      statusCode: packageResponse.statusCode,
    );
  }

  final packageJson = json.decode(packageResponse.body) as Map<String, dynamic>;

  return PackageInfo.fromJson(packageJson);
}

class PackageInfo {
  final String name;
  final String latestVersion;
  final String description;
  final String publisher;
  final Uri? repository;

  PackageInfo({
    required this.name,
    required this.latestVersion,
    required this.description,
    required this.publisher,
    this.repository,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    final repository = json['repository'] as String?;

    return PackageInfo(
      name: json['name'] as String,
      latestVersion: json['latestVersion'] as String,
      description: json['description'] as String,
      publisher: json['publisher'] as String,
      repository: repository != null ? Uri.tryParse(repository) : null,
    );
  }
}

class PackageRetrievalException implements Exception {
  final String packageName;
  final int? statusCode;

  PackageRetrievalException({required this.packageName, this.statusCode});

  @override
  String toString() {
    final buf = StringBuffer();
    buf.write('Failed to retrieve package:$packageName information');

    if (statusCode != null) {
      buf.write(' with a status code of $statusCode');
    }

    buf.write('!');
    return buf.toString();
  }
}

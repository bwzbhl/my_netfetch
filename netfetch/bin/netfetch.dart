import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

void main() async {
  //....https://dart.cn/tutorials/server/fetch-data#build-a-url
  // Parse the entire URI, including the scheme
  Uri.parse('https://dart.dev/f/packages/http.json');

  // Specifically create a URI with the https scheme
  Uri.https('dart.dev', '/f/packages/http.json');
  
  //......https://dart.cn/tutorials/server/fetch-data#make-a-network-request
  test();
/*
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
  */
}

void test() async {
  final httpPackageUrl = Uri.https('dart.dev', '/f/packages/http.json');
  final httpPackageInfo = await http.read(httpPackageUrl);
  print(httpPackageInfo);

  final httpPackageResponse = await http.get(httpPackageUrl);
  if (httpPackageResponse.statusCode != 200) {
    print('Failed to retrieve the http package!');
    return;
  }
  print(httpPackageResponse.body);

  await http.get(Uri.https('dart.dev', '/f/packages/http.json'),
      headers: {'User-Agent': '<product name>/<product-version>'});

}

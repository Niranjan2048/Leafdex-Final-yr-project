// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:nebat/models/models.dart';
import 'package:nebat/secret_keys.dart';

class PlantsAPI {
  final String _endpoint = 'https://api.plant.id/v2/identify';

  Future<List<Plant>> identifyPlant(String base64Image) async {
    List<String> images = [];
    List<Plant> plants = [];

    images.add(base64Image);
    Map<String, dynamic> body = {'images': images};
    try {
      print('sending request...');
      http.Response response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Accept': '*/*',
          'Access-Control-Allow-Origin': '*',
          'Api-Key': apiKey,
        },
        body: jsonEncode(body),
      );
      print('got response ');
      print('parsing response...');
      print(response.body);
      Map<String, dynamic> results =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (results['is_plant']) {
        List<dynamic> suggesstions = results['suggestions'];
        for (var suggesstion in suggesstions) {
          Map<String, dynamic> plant = suggesstion as Map<String, dynamic>;
          String name = plant['plant_name'] as String;
          String plantUrl = await getImageFromWeb(name);
          plants.add(Plant(
              id: plant['id'] as int,
              probability: (plant['probability'] as double) * 100,
              plantName: name,
              imagePath: plantUrl));
        }

        return plants;
      } else {
        print('this is not plant');
        return plants;
      }
    } catch (e) {
      print(e);
      return plants;
    }
  }

  Future<String> getHTMLDoc(String query) async {
    String result = '';
    String url = 'https://www.google.com/search?q=$query&source=lnms&tbm=isch';
    Map<String, String> headers = {
      'Accept': '*/*',
      'Access-Control-Allow-Origin': '*',
      'User-Agent':
          "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36"
    };

    try {
      print('sending request...');
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      result = response.body;
    } catch (e) {
      print(e);
    }

    return result;
  }

  Future<String> getImageFromWeb(String query) async {
    String result = '';
    String html = await getHTMLDoc(query);
    BeautifulSoup bs = BeautifulSoup(html);
    String raw = bs.find('img', class_: 'yWs4tf').toString();
    result = raw.split('src="').last.split(';').first;
    print(result);

    return result;
  }

  Future<MedicinalProperties> getMedicinalProperties(String plantName) async {
    print(plantName);
    var uri = Uri.parse('https://leafdex-api123.onrender.com/leaf-info');
    var client = http.Client();
    print(plantName);
    final http.Response response123 = await client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'scientific_name': plantName,
      }),
    );
    print(response123.statusCode);
    print(response123.body);
    print(json.decode(response123.body).runtimeType);
    if (response123.statusCode == 200) {
      return MedicinalProperties.fromJson(json.decode(response123.body));
    } else {
      throw Exception('Failed to load medicinal properties');
    }
  }
}

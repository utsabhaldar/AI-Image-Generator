import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIImageGenerator {
  final String _apiKey;
  final String _endpoint = "https://api.openai.com/v1/images/generations";

  OpenAIImageGenerator(this._apiKey);

  Future<List<String>> generateImage(String prompt, int numImages) async {
    var response = await http.post(
      Uri.parse(_endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(<String, dynamic>{
        'model': 'image-alpha-001',
        'prompt': prompt,
        'num_images': numImages,
        'size': '512x512',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> urls = [];

      for (final image in data['data']) {
        urls.add(image['url']);
      }

      return urls;
    } else {
      throw Exception('Failed to generate image');
    }
  }
}

class ImageGeneratorApp extends StatefulWidget {
  const ImageGeneratorApp({Key? key}) : super(key: key);

  @override
  _ImageGeneratorAppState createState() => _ImageGeneratorAppState();
}

class _ImageGeneratorAppState extends State<ImageGeneratorApp> {
  final String _apiKey = "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";
  final OpenAIImageGenerator _generator = OpenAIImageGenerator(
      "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");
  List<String> _images = [];
  String _prompt = '';

  void _generateImages() async {
    const numImages = 1;

    final List<String> images =
        await _generator.generateImage(_prompt, numImages);

    setState(() {
      _images = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("AI Image Generator"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter your prompt',
                ),
                onChanged: (value) {
                  setState(() {
                    _prompt = value;
                  });
                },
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: _images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(url),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _generateImages,
              child: const Text("Generate Images"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const ImageGeneratorApp());
}

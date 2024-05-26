import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    const MaterialApp(
      home: NewsPage(),
    ),
  );
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Science'),
            Tab(text: 'Technology'),
            Tab(text: 'History'),
            Tab(text: 'Politics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NewsCategory(apiKey: '34763a1c8d4d4d95b26987a4f8f4deff', category: 'science'),
          NewsCategory(apiKey: '34763a1c8d4d4d95b26987a4f8f4deff', category: 'technology'),
          NewsCategory(apiKey: '34763a1c8d4d4d95b26987a4f8f4deff', category: 'history'),
          NewsCategory(apiKey: '34763a1c8d4d4d95b26987a4f8f4deff', category: 'politics'),
        ],
      ),
    );
  }
}

class NewsCategory extends StatefulWidget {
  final String apiKey;
  final String category;

  const NewsCategory({super.key, required this.apiKey, required this.category});

  @override
  _NewsCategoryState createState() => _NewsCategoryState();
}

class _NewsCategoryState extends State<NewsCategory> {
  late List<Article> articles;

  @override
  void initState() {
    super.initState();
    articles = [];
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final url = 'https://newsapi.org/v2/top-headlines?category=${widget.category}&apiKey=${widget.apiKey}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'ok') {
        setState(() {
          articles = (data['articles'] as List).map((article) => Article.fromJson(article)).toList();
        });
      } else {
        // Handle error
      }
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          title: Text(article.title),
          subtitle: Text(article.description),
          onTap: () {
            // Handle tap on the news article
          },
        );
      },
    );
  }
}

class Article {
  final String title;
  final String description;

  Article({required this.title, required this.description});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

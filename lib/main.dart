import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sport {
  final int id;
  final String name;
  final String image;
  final String description;
  final String popularity;

  Sport({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.popularity,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'popularity': popularity,
    };
  }
}


class AppRoutes {
  static const String sportList = '/';
  static const String sportDetails = '/details';

  static final routes = <String, WidgetBuilder>{
    sportList: (context) => const SportListScreen(), 
    sportDetails: (context) => const SportDetailScreen(), 
  };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Sports',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.sportList,
    );
  }
}


class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  _SportListScreenState createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  List<Sport> _sports = [];
  Sport? _lastViewedSport;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadSports();
    await _loadLastViewed();
  }

  Future<void> _loadSports() async {
    final String jsonString = await rootBundle.loadString('assets/data/sports.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      _sports = jsonList.map((jsonItem) => Sport.fromJson(jsonItem)).toList();
    });
  }

  Future<void> _loadLastViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sportJsonString = prefs.getString('last_viewed_sport');

    if (sportJsonString != null) {
      setState(() {
        _lastViewedSport = Sport.fromJson(json.decode(sportJsonString));
      });
    }
  }

  Future<void> _saveLastViewed(Sport sport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_viewed_sport', json.encode(sport.toJson()));
  }

  void _onSportTapped(Sport sport) {
    setState(() {
      _lastViewedSport = sport;
    });
    _saveLastViewed(sport);

    Navigator.pushNamed(context, AppRoutes.sportDetails, arguments: sport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Esportes Favoritos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Último esporte visto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _lastViewedSport != null
                ? LastViewedCard(sport: _lastViewedSport!)
                : const Text("Nenhum esporte foi visualizado recentemente."),
            const SizedBox(height: 24),
            const Text(
              'Todos os esportes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sports.length,
              itemBuilder: (context, index) {
                final sport = _sports[index];
                return SportCard(
                  sport: sport,
                  onTap: () => _onSportTapped(sport),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SportDetailScreen extends StatelessWidget {
  const SportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sport = ModalRoute.of(context)!.settings.arguments as Sport;

    return Scaffold(
      appBar: AppBar(
        title: Text(sport.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              sport.image,
              height: 150,
              width: 150,
            ),
            Text(
              sport.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              sport.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
                'Popularidade: ${sport.popularity}',
                style: const TextStyle(fontSize: 20),
              ),
            
          ],
        ),
      ),
    );
  }
}

class LastViewedCard extends StatelessWidget {
  final Sport sport;

  const LastViewedCard({super.key, required this.sport});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(sport.image, width: 60, height: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sport.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(sport.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SportCard extends StatelessWidget {
  final Sport sport;
  final VoidCallback onTap;

  const SportCard({super.key, required this.sport, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Image.asset(sport.image, width: 50, height: 50),
        title: Text(sport.name),
        subtitle: Text(sport.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumpro/models/restaurant.dart';
import 'package:yumpro/screens/restaurant_detail_screen.dart';
import 'package:yumpro/services/api_service.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  RestaurantScreenState createState() => RestaurantScreenState();
}

class RestaurantScreenState extends State<RestaurantScreen> with RouteAware {
  final List<Restaurant> restaurants = [];
  final Map<int, String> _cuisines = {
    1: 'Cuisine française',
    2: 'Cuisine coréenne',
    3: 'Cuisine japonaise',
    4: 'Cuisine libanaise',
    5: 'Cuisine asiatique',
    6: 'Cuisine africaine',
    7: 'Boulangerie',
    8: 'Pizzeria',
    9: 'Cuisine US',
    10: 'Cuisine fusion',
    11: 'Café',
    12: 'Cuisine orientale',
    13: 'Cuisine mexicaine',
    14: 'Cuisine chinoise',
    15: 'Fast Food',
    16: 'Cuisine italienne',
    19: 'Cuisine d\'Asie Centrale',
  };

  late ApiService _apiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchRestaurants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route as PageRoute<dynamic>);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when this page is shown again after popping another page
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int workspaceId = prefs.getInt('workspace_id') ?? 0;
      List<Restaurant> fetchedRestaurants =
          await _apiService.getRestaurants(workspaceId);
      setState(() {
        restaurants.clear();
        restaurants.addAll(fetchedRestaurants);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors du chargement des restaurants: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddRestaurantDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    int selectedCuisine = 1;
    bool isDialogLoading = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int workspaceId = prefs.getInt('workspace_id') ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un restaurant'),
              content: isDialogLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du restaurant',
                          ),
                        ),
                        TextField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse',
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<int>(
                          value: selectedCuisine,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCuisine = newValue!;
                            });
                          },
                          items: _cuisines.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final String address = addressController.text.trim();
                    if (name.isNotEmpty && address.isNotEmpty) {
                      setState(() {
                        isDialogLoading = true;
                      });

                      try {
                        await _apiService.addRestaurantToWorkspace(
                          workspaceId: workspaceId,
                          restaurantName: name,
                          address: address,
                          cuisine_id: selectedCuisine,
                        );

                        setState(() {});

                        Fluttertoast.showToast(
                          msg:
                              "Restaurant ajouté avec succès. Actualisez la page",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 2,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );

                        Navigator.of(context).pop();
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Erreur lors de l'ajout du restaurant: $e",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } finally {
                        setState(() {
                          isDialogLoading = false;
                        });
                      }
                    }
                  },
                  child: const Text('Ajouter à la liste'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre liste de recommandation'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddRestaurantDialog,
              child: const Text('Ajouter'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantDetailScreen(
                          restaurant: restaurants[index]),
                    ),
                  );
                  _fetchRestaurants();
                },
                child: Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(restaurants[index].imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurants[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(restaurants[index].address),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

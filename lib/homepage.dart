import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'CategoryPlacesPage.dart';
import 'citypage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QueryDocumentSnapshot> citiesList = [];
  List<QueryDocumentSnapshot> categoriesList = [];
  List<QueryDocumentSnapshot> placesList = [];
  List<QueryDocumentSnapshot> filteredPlacesList = [];
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    getCities();
    getCategories();
    getPlaces();
  }

  Future<void> getCities() async {
    QuerySnapshot citySnapshot = await FirebaseFirestore.instance.collection('cities').get();
    setState(() {
      citiesList = citySnapshot.docs;
      isLoading = false;
    });
  }

  Future<void> getCategories() async {
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categoriesList = categorySnapshot.docs;
    });
  }

  Future<void> getPlaces() async {
    List<QueryDocumentSnapshot> tempPlacesList = [];
    QuerySnapshot citiesSnapshot = await FirebaseFirestore.instance.collection('cities').get();

    for (var cityDoc in citiesSnapshot.docs) {
      QuerySnapshot placesSnapshot = await cityDoc.reference.collection('places').get();
      for (var placeDoc in placesSnapshot.docs) {
        tempPlacesList.add(placeDoc);
      }
    }

    setState(() {
      placesList = tempPlacesList;
      filteredPlacesList = placesList;
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<QueryDocumentSnapshot> tempFilteredPlaces = placesList.where((place) {
        return (place.data() as Map<String, dynamic>)['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredPlacesList = tempFilteredPlaces;
        isSearching = true;
      });
    } else {
      setState(() {
        filteredPlacesList = [];
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Egytick"),
        actions: [
          IconButton(
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 40,
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 30),
                hintText: "Search places by name",
                border: InputBorder.none,
                fillColor: Colors.grey[150],
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            categoriesList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  var category = categoriesList[index].data() as Map<String, dynamic>;
                  return categoryItem(category['title'], category['image']);
                },
              ),
            ),
            const SizedBox(height: 30),
            if (!isSearching)
              const Text(
                "Cities",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (!isSearching)
              ListView.builder(
                itemCount: citiesList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var city = citiesList[index].data() as Map<String, dynamic>;
                  return cityCard(city, citiesList[index].id);
                },
              ),
            if (isSearching)
              const Text(
                "Places",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (isSearching)
              ListView.builder(
                itemCount: filteredPlacesList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var place = filteredPlacesList[index].data() as Map<String, dynamic>;
                  return placeCard(place);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget categoryItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CategoryPlacesPage(categoryName: title),
        ));
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.all(5),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }



  Widget cityCard(Map<String, dynamic> city, String cityId) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CityPage(cityId: cityId),
        ));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              city['image'], // Assuming image path stored in Firestore is an asset path
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    city['description'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget placeCard(Map<String, dynamic> place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            place['image'], // Assuming image path stored in Firestore is an asset path
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  place['description'],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

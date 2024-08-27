import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'ProfilePage.dart';
import 'HomePage.dart';  // Import the HomePage
import 'PlaceDetailsPage.dart';

class CityPage extends StatefulWidget {
  final String cityId;

  const CityPage({super.key, required this.cityId});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  List<QueryDocumentSnapshot> cityData = [];
  List<QueryDocumentSnapshot> categoriesList = [];
  List<QueryDocumentSnapshot> placesList = [];
  String cityName = "";
  int currentImageIndex = 0;

  CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  CollectionReference cities = FirebaseFirestore.instance.collection('cities');

  bool isLoadingCities = true;
  bool isLoadingCategories = true;
  bool isLoadingPlaces = true;

  getCityName() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("cities")
        .doc(widget.cityId)
        .get();
    setState(() {
      cityName = documentSnapshot['name'];
    });
  }

  getCities() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("cities")
        .doc(widget.cityId)
        .collection("citydata")
        .get();
    setState(() {
      cityData = querySnapshot.docs;
      isLoadingCities = false;
    });
  }

  getCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .orderBy("title")
        .get();
    setState(() {
      categoriesList = querySnapshot.docs;
      isLoadingCategories = false;
    });
  }

  getPlaces() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("cities")
        .doc(widget.cityId)
        .collection("places")
        .get();
    setState(() {
      placesList = querySnapshot.docs;
      isLoadingPlaces = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getCityName();
    getCities();
    getCategories();
    getPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
            );
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "City Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoadingCities
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: cityData.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                var city = cityData[index].data() as Map<String, dynamic>;
                List<dynamic> images = city['image']; // Fetch images array
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 5.0,
                          radius: Radius.circular(10),
                          scrollbarOrientation: ScrollbarOrientation.bottom,
                          child: Container(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, imageIndex) {
                                return Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Image.asset(
                                    images[imageIndex],
                                    width: 400,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          city['description'],
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        Container(
                          height: 30,
                          color: Colors.white,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Places",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        isLoadingPlaces
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: placesList.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int placeIndex) {
                            var place = placesList[placeIndex].data() as Map<String, dynamic>;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PlaceDetailsPage(
                                      cityId: widget.cityId,
                                      placeId: placesList[placeIndex].id,
                                    ),
                                  ));
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 400,
                                        height: 300,
                                        child: Image.asset(
                                          place['image'],
                                          width: 400,
                                          height: 300,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        place['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        place['description'],
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

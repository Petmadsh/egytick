import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egytick/citypage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QueryDocumentSnapshot> citiesList = [];
  List<QueryDocumentSnapshot> categoriesList = [];

  CollectionReference categories =
  FirebaseFirestore.instance.collection('categories');
  CollectionReference cities = FirebaseFirestore.instance.collection('cities');



  bool isLoadingCities = true;
  bool isLoadingCategories = true;

  getCities() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("cities")
        .orderBy("name")
        .get();
    setState(() {
      citiesList = querySnapshot.docs;
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

  @override
  void initState() {
    super.initState();

    getCities();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 30),
                      hintText: "Search",
                      border: InputBorder.none,
                      fillColor: Colors.grey[150],
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.menu,
                    size: 40,
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoadingCategories
                ? Center(child: CircularProgressIndicator())
                : Container(
              height: 100,
              child: ListView.builder(
                itemCount: categoriesList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  var category = categoriesList[index].data()
                  as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      // Navigate to category details if needed
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: ClipOval(
                              child: Image.asset(
                                category['image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            category['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Cities",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoadingCities
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              itemCount: citiesList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 280,
              ),
              itemBuilder: (BuildContext context, int index) {
                var city =
                citiesList[index].data() as Map<String, dynamic>;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context)
                    =>
                        CityPage(cityId: citiesList[index].id)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 340,
                            child: Image.asset(
                              city['image'],
                              height: 170,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Text(
                            city['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            city['description'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
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

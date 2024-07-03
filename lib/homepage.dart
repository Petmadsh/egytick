import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QueryDocumentSnapshot> cities = [];
  //List<QueryDocumentSnapshot> categories = [];

  bool isLoading = true;

  getCities() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("cities").orderBy("name").get();
    cities.addAll(querySnapshot.docs);

    isLoading = false;

    setState(() {});
  }

  // getCategories() async {
  //   QuerySnapshot querySnapshot =
  //   await FirebaseFirestore.instance.collection("categories").get();
  //   categories.addAll(querySnapshot.docs);
  //
  //
  //   setState(() {});
  // }

  @override
  void initState() {
    getCities();
   // getCategories();
    super.initState();
  }







  List categories = [
    {"icon": Icons.temple_hindu_outlined, "title": "Temples"},
    {"icon": Icons.museum_outlined, "title": "Museums"},
    {"icon": Icons.church_outlined, "title": "Religious"},
    {"icon": Icons.beach_access_outlined, "title": "Beaches"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text("Homepage"),
              // Spacer(),
              // Image.asset("images/Egyptian_Pyramids_with_Sphinx.png", width: 55,),
              // Spacer(),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  googleSignIn.disconnect();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("login", (route) => false);
                },
                icon: Icon(Icons.exit_to_app))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            iconSize: 40,
            selectedItemColor: Colors.orange,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: ""),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined), label: ""),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), label: ""),
            ]),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 30,
                        ),
                        hintText: "Search",
                        border: InputBorder.none,
                        fillColor: Colors.grey[150],
                        filled: true),
                  )),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.menu,
                      size: 40,
                    ),
                  )
                ],
              ),
              Container(
                height: 30,
              ),
              const Text(
                "Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 20,
              ),
              Container(
                height: 100,
                child: ListView.builder(
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(100)),
                            child: Container(
                              child: Icon(
                                categories[index]['icon'],
                                size: 30,

                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                          ),
                          Text(
                            categories[index]['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  "Cities",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : GridView.builder(
                      itemCount: cities.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1, mainAxisExtent: 280),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemsDetails(data:bestselling[index],)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Card(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 300,
                                        // color: Colors.white,
                                        child: Image.asset(
                                          cities[index]['image'],
                                          height: 170,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Text(
                                        cities[index]['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        cities[index]['description'],
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ]),
                              ),
                            ));
                      },
                    ),
            ],
          ),
        ));
  }
}

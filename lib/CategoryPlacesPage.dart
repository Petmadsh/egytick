import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ProfilePage.dart';
import 'HomePage.dart';
import 'PlaceDetailsPage.dart';  // Import PlaceDetailsPage

class CategoryPlacesPage extends StatefulWidget {
  final String categoryName;

  const CategoryPlacesPage({super.key, required this.categoryName});

  @override
  _CategoryPlacesPageState createState() => _CategoryPlacesPageState();
}

class _CategoryPlacesPageState extends State<CategoryPlacesPage> {
  List<QueryDocumentSnapshot> placesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlacesByCategory();
  }

  Future<void> fetchPlacesByCategory() async {
    List<QueryDocumentSnapshot> tempPlacesList = [];
    QuerySnapshot citiesSnapshot = await FirebaseFirestore.instance.collection('cities').get();

    for (var cityDoc in citiesSnapshot.docs) {
      QuerySnapshot placesSnapshot = await cityDoc.reference
          .collection('places')
          .where('category', isEqualTo: widget.categoryName)
          .get();
      tempPlacesList.addAll(placesSnapshot.docs);
    }

    setState(() {
      placesList = tempPlacesList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 40,
        selectedItemColor: Colors.orange,
        currentIndex: 0, // Update this as needed to reflect the current page index
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
          // Add logic to handle other indexes if necessary
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: placesList.length,
        itemBuilder: (context, index) {
          var place = placesList[index].data() as Map<String, dynamic>;
          var cityId = placesList[index].reference.parent.parent?.id; // Fetch the cityId
          var placeId = placesList[index].id; // Fetch the placeId

          return InkWell(
            onTap: () {
              if (cityId != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PlaceDetailsPage(
                    cityId: cityId,
                    placeId: placeId,
                  ),
                ));
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      place['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
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
            ),
          );
        },
      ),
    );
  }
}

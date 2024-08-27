import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlaceDetailsPage extends StatefulWidget {
  final String cityId;
  final String placeId;

  const PlaceDetailsPage({super.key, required this.cityId, required this.placeId});

  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  Map<String, dynamic>? placeDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  Future<void> fetchPlaceDetails() async {
    try {
      // Fetch the first document from the 'details' subcollection
      QuerySnapshot detailsSnapshot = await FirebaseFirestore.instance
          .collection('cities')
          .doc(widget.cityId)
          .collection('places')
          .doc(widget.placeId)
          .collection('details')
          .limit(1)
          .get();

      if (detailsSnapshot.docs.isNotEmpty) {
        setState(() {
          placeDetails = detailsSnapshot.docs.first.data() as Map<String, dynamic>?;
          isLoading = false;
        });
        print("Place Details Fetched: $placeDetails"); // Debugging
      } else {
        setState(() {
          isLoading = false;
        });
        print("No details found in Firestore");
      }
    } catch (e) {
      print('Error fetching place details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeDetails?['placeDescription'] ?? 'Place Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : placeDetails != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (placeDetails!['images'] != null && placeDetails!['images'] is List<dynamic>)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (placeDetails!['images'] as List<dynamic>).length,
                    itemBuilder: (context, index) {
                      String imageName = (placeDetails!['images'] as List<dynamic>)[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.asset(
                          'images/$imageName.jpg', // Appending .jpg
                          height: 200,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                placeDetails!['placeDescription'] ?? 'No Description Available',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                'Location: ${placeDetails!['location'] ?? 'No Location Available'}',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                'Opening Hours:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (placeDetails!['openingHours'] != null && placeDetails!['openingHours'] is List<dynamic>)
                ...placeDetails!['openingHours'].map<Widget>((openingHour) {
                  return Text(openingHour);
                }).toList(),
              const SizedBox(height: 10),
              if (placeDetails!['ticketPrice'] != null && placeDetails!['ticketPrice'] is List<dynamic>)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ticket Prices:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ...placeDetails!['ticketPrice'].map<Widget>((price) {
                      return Text(price);
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      )
          : Center(child: Text("No details found")),
    );
  }
}

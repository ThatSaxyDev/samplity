import 'package:flutter/material.dart';
import 'package:samplity/collections_list.dart';
import 'package:wetrocloud_sdk/wetrocloud.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  final wetroCloud =
      WetroCloud(apiKey: 'wtc-sk-c3eec76c0106e3480a0d1b7e1574505cef66975f');

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    // Initialize WetroCloud SDK with your API key

    try {
      // Attempt to create a new collection with a custom ID
      final response = await wetroCloud.createCollection();
      setState(() {
        isLoading = false;
      });
      // Print the result: Collection ID and success status
      print(
          'Created collection: ${response.collectionId}, success: ${response.success}');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // If an error occurs, print the error message
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('WetroCloud SDK Example'),
      ),
      body: switch (isLoading) {
              true => CircularProgressIndicator(
        color: Colors.red,
      ),
              false => CollectionListPage(wetroCloud: wetroCloud),
            },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _fetchData();
        },
        label: Text('CREATE COLLECTION'),
      ),
    );
  }
}

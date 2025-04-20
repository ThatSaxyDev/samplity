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

  Future<void> _fetchData({String? collectionId}) async {
    setState(() {
      isLoading = true;
    });
    // Initialize WetroCloud SDK with your API key

    try {
      // Attempt to create a new collection with a custom ID
      final response =
          await wetroCloud.createCollection(collectionId: collectionId);
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
    } finally {
      Navigator.of(context).pop();
      // Hide the loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('WetroCloud Flutter SDK'),
      ),
      body: Center(
        child: switch (isLoading) {
          true => CircularProgressIndicator(),
          false => CollectionListPage(wetroCloud: wetroCloud),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateCollectionBottomSheet();
        },
        label: Text('CREATE COLLECTION'),
      ),
    );
  }

  void _showCreateCollectionBottomSheet() {
    final resourceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      40, // <-- dynamic padding for keyboard
                  left: 16,
                  right: 16,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Collection Name',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: resourceController,
                      decoration: const InputDecoration(
                        labelText: 'Collection Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        _fetchData(
                            collectionId: resourceController.text.trim());

                        // try {
                        //   InsertResourceResponse response =
                        //       await widget.wetroCloud.insertResource(
                        //     collectionId: collection.collectionId,
                        //     resource: resourceController.text,
                        //     type: selectedType!.name,
                        //   );

                        //   if (response.success) {
                        //     _refreshCollections();
                        //     Navigator.pop(context);
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //           content: Text(
                        //               'Resource inserted successfully\nTokens: ${response.tokens}')),
                        //     );
                        //   } else {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(content: Text('Error:')),
                        //     );
                        //   }
                        // } catch (e) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('Error: $e')),
                        //   );
                        // } finally {
                        //   setState(() {
                        //     isLoading = false;
                        //   });
                        // }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

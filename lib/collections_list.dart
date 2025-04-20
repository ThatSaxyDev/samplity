import 'package:flutter/material.dart';
import 'package:wetrocloud_sdk/models/responses.dart';
import 'package:wetrocloud_sdk/utils/enums.dart';
import 'package:wetrocloud_sdk/wetrocloud.dart';

class CollectionListPage extends StatefulWidget {
  final WetroCloud wetroCloud;

  const CollectionListPage({super.key, required this.wetroCloud});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  late Future<ListCollectionsResponse> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = widget.wetroCloud.listCollections();
  }

  void _refreshCollections() {
    setState(() {
      _collectionsFuture = widget.wetroCloud.listCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FutureBuilder<ListCollectionsResponse>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final collections = snapshot.data?.results ?? [];

          if (collections.isEmpty) {
            return const Center(child: Text('No collections found.'));
          }

          return ListView.separated(
            itemCount: collections.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final collection = collections[index];
              return ListTile(
                onTap: () {
                  _showInsertBottomSheet(collection: collection);
                },
                title: Text(collection.collectionId),
                subtitle: Text('ID: ${collection.createdAt}'),
              );
            },
          );
        },
      ),
    );
  }

  void _showInsertBottomSheet({required Collection collection}) {
    final resourceController = TextEditingController();
    WetroResourceType? selectedType;

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
                    Text('Insert Resource',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: collection.collectionId,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Collection ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<WetroResourceType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Resource Type',
                        border: OutlineInputBorder(),
                      ),
                      items: WetroResourceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedType = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: resourceController,
                      decoration: const InputDecoration(
                        labelText: 'Resource',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedType == null ||
                            resourceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please complete all fields')),
                          );
                          'Please complete all fields'.log();
                          return;
                        }

                        try {
                          final response =
                              await widget.wetroCloud.insertResource(
                            collectionId: collection.collectionId,
                            resource: resourceController.text,
                            type: selectedType!.name,
                          );

                          if (response.success) {
                            _refreshCollections();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Resource inserted successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error:')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
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

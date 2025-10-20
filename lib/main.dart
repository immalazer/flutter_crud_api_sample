import 'package:crud_api_sample/api_client.dart';
import 'package:flutter/material.dart';

late Future<List<Data>> futureSongs;

final dataListNotifier = ValueNotifier<DataList>(
  DataList(dataList: List.empty()),
);

final ApiClient _apiClient = ApiClient("http://localhost:8000/api");

void main() async {
  await _apiClient.getAll().then((value) {
    if (value != null) {
      dataListNotifier.value = DataList(dataList: value);
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> dialogUbahData(BuildContext context, int index) async {
    switch (await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Ingin apakan data ini?"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'edit');
              },
              child: const Text('Ubah'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'delete');
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    )) {
      case 'edit':
        await dialogInputData(
          context,
          index,
        ).then((value) async {
          if (value != null) {
            Map<String, String> request = {};
            request['nama'] = value;

            await _apiClient.updateItem(
              request,
              dataListNotifier.value.dataList[index].key,
            );
          }
        });
        break;
      case 'delete':
        _apiClient.deleteItem(dataListNotifier.value.dataList[index].key);
        break;
      case null:
        // dialog dismissed
        break;
    }
  }

  Future<String?> dialogInputData(
    BuildContext context,
    int id,
  ) async {
    final textFieldController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Aksi"),
          content: TextField(
            controller: textFieldController,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, textFieldController.text),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<DataList>(
              valueListenable: dataListNotifier,
              builder: (_, value, _) {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.dataList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ListTile(
                            onTap: () async {
                              await dialogUbahData(context, index).then((
                                _,
                              ) async {
                                await _apiClient.getAll().then((value) {
                                  dataListNotifier.value = DataList(
                                    dataList: value!,
                                  );
                                });
                              });
                            },
                            title: SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(index.toString()),
                                  subtitle: Text(value.dataList[index].data.toString()),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          dialogInputData(
            context,
            -1,
          ).then((value) {
            if (value != null) {
              Map<String, String> mapNilai = {};
              mapNilai['nama'] = value;

              _apiClient.createItem(mapNilai).then((_) async {
                await _apiClient.getAll().then((value) {
                  dataListNotifier.value = DataList(dataList: value!);
                });
              });
            }
          });
        },
        tooltip: 'Tambahkan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Data {
  Data(this.key, this.data);
  final String key;
  final Map<String, dynamic> data;
}

class DataList {
  DataList({required this.dataList});
  final List<Data> dataList;
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:tracker/models/failure_model.dart';

import 'budget_repository.dart';
import 'models/item_model.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notion Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = BudgetRepository().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: FutureBuilder<List<Item>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //show pie chart and list view of items
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: getCategoryColor(item.category),
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.category} * ${DateFormat.yMd().format(item.date)}',
                    ),
                    trailing: Text('-\$${item.price.toStringAsFixed(2)}'),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            // show failure error message
            final failure = snapshot.error as Failure;
            return Center(child: Text(failure.message));
          }
          //show a loading indicator
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case ' Entertainment ':
      return Colors.red[400]!;
    case ' Food ':
      return Colors.green[400]!;
    case ' Personal ':
      return Colors.blue[400]!;
    case ' Transportation ':
      return Colors.purple[400]!;
    default:
      return Colors.orange[400]!;
  }
}

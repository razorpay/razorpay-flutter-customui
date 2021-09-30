import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui_example/payment_slection_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      body: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Container(
                  height: 80.0,
                  color: Colors.grey.shade300,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Order #RZP',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.3) + 80.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        'Razorpay T-Shirt',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'INR 1.00',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'This is a real transaction',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) {
                                return PaymentSelectionPage();
                              },
                            ),
                          );
                        },
                        child: Text('Purchase'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.3) - 30.0,
              child: Container(
                height: 60.0,
                width: 60.0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: Image.asset('images/rzp.png').image,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.8,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.white, width: 1.0)),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Secure Payments by Razorpay',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

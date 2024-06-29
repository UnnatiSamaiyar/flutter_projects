import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Added this import
import 'dart:io'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner and Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title}); // Convert 'key' to a super parameter

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  String? _qrCodeResult;

  void _generateQRCode() {
    setState(() {
      _qrCodeResult = _textController.text;
    });
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRViewExample()),
    );
    if (result != null) {
      setState(() {
        _qrCodeResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text to generate QR code',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateQRCode,
                child: const Text('Generate QR Code'),
              ),
              if (_qrCodeResult != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0), // Add padding
                  child: QrImageView(
                    data: _qrCodeResult!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ElevatedButton(
                onPressed: _scanQRCode,
                child: const Text('Scan QR Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key}); // Convert 'key' to a super parameter

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Barcode Type: ${result!.format}   Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      Navigator.pop(context, scanData.code);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

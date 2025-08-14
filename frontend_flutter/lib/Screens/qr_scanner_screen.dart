import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scanResult;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        _processQRCode(scanData.code!);
      }
    });
  }

  Future<void> _processQRCode(String code) async {
    setState(() {
      _isProcessing = true;
      scanResult = code;
    });

    // Pausa la cámara mientras se procesa
    controller?.pauseCamera();

    try {
      // Aquí iría la lógica para procesar el código QR
      // Por ejemplo, verificar un acceso, registrar entrada, etc.
      await Future.delayed(const Duration(seconds: 2)); // Simulación de procesamiento

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Código QR Escaneado'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Contenido: $code'),
                    const SizedBox(height: 10),
                    const Text('Acceso verificado correctamente.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Continuar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller?.resumeCamera();
                    setState(() {
                      _isProcessing = false;
                      scanResult = null;
                    });
                  },
                ),
                TextButton(
                  child: const Text('Volver al Dashboard'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Volver a la pantalla anterior
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el código: ${e.toString()}')),
        );
        controller?.resumeCamera();
        setState(() {
          _isProcessing = false;
          scanResult = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _isProcessing
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Procesando código QR...'),
                      ],
                    )
                  : const Text('Apunta la cámara al código QR'),
            ),
          )
        ],
      ),
    );
  }
}
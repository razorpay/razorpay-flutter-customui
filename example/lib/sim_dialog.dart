import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui_turbo/model/Sim.dart';
import 'package:razorpay_flutter_customui_turbo/razorpay_flutter_customui_turbo.dart';

class SimDialog extends StatefulWidget {
  final List<Sim> sims;
  final Razorpay razorpay;

  SimDialog({
    required this.sims,
    required this.razorpay,
  });

  @override
  State<SimDialog> createState() => _SimDialogState();
}

class _SimDialogState extends State<SimDialog> {
  bool isLoadingForSim = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            Text(
              "Please Select SIM ",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10,),
            isLoadingForSim
                ? CircularProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
                : SizedBox(height: 2,),
            Container(
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: widget.sims.length,
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                          onPressed: () {
                            widget.razorpay.upiTurbo.register(sim : widget.sims[index]);
                            setState(() {
                              isLoadingForSim = true;
                            });
                          },
                          child: Text("${widget.sims[index].provider}"));
                    })),
          ],
        ),
      ),
    );
  }
}

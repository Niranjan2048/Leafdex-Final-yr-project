import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:nebat/components/home_screen_components.dart';
import 'package:nebat/constants.dart';
import 'package:nebat/services/providers.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        /*actions: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WhoAreWePage(),
                    ));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  FontAwesomeIcons.circleInfo,
                  color: kPrimaryColor,
                  size: 32,
                ),
              ))
        ],*/
      ),
      body: ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(
          color: kPrimaryColor,
        ),
        inAsyncCall: Provider.of<IdentificationProvider>(context).isLoading,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const PlantNameWidget(),
              const CameraWidget(),
              Provider.of<IdentificationProvider>(context).state ==
                      IdentificationState.identified
                  ? const SizedBox()
                  : const IdentificationButton(),
              const SuggestionsWidget(),
              Provider.of<IdentificationProvider>(context).state ==
                      IdentificationState.identified
                  ? const IdentificationButton()
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

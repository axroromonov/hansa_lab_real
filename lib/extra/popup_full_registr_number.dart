import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hansa_lab/api_models.dart/country_model.dart';
import 'package:hansa_lab/blocs/bloc_number_country.dart';
import 'package:hansa_lab/blocs/bloc_popup_drawer.dart';
import 'package:hansa_lab/blocs/hansa_country_api.dart';
import 'package:hansa_lab/classes/number_coubtry.dart';
import 'package:provider/provider.dart';

class PopUpFullRegistrNumber extends StatefulWidget {
  final Color borderColor;
  final Color hintColor;
  final VoidCallback onTap;
  const PopUpFullRegistrNumber(
      {required this.borderColor,
      required this.hintColor,
      required this.onTap,
      super.key});

  @override
  State<PopUpFullRegistrNumber> createState() => _PopUpFullRegistrNumberState();
}

class _PopUpFullRegistrNumberState extends State<PopUpFullRegistrNumber> {
  TextEditingController textEditingController = TextEditingController();
  final streamController = StreamController<List<CountryModelData>>.broadcast();

  final blocPopupDrawer = BlocPopupDrawer();

  List<CountryModelData> allCities = [];
  List<CountryModelData> cities = [];

  List<String> ccs = ['Россия', 'Армения', 'Казахстан'];
  List<EnumCuntryNumber> ecs = [
    EnumCuntryNumber.rus,
    EnumCuntryNumber.armen,
    EnumCuntryNumber.kazak
  ];

  double radius = 54;
  String text = "Номер";

  listen() {
    streamController.stream.listen((event) {
      if (textEditingController.text.isEmpty) {
        allCities = event;
        cities = allCities;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listen();
  }

  @override
  Widget build(BuildContext context) {
    //  final blocNumberCountry = BlocNumberCountry();
    final providerNumberCountry = Provider.of<BlocNumberCountry>(context);
    final isTablet = Provider.of<bool>(context);
    final blocHansaCountry = HansaCountryBloC(1);

    blocHansaCountry.eventSink.add(CityEnum.city);

    final gorodTextEditingContyroller =
        Provider.of<TextEditingController>(context);
    return StreamBuilder<double>(
      initialData: 38,
      stream: blocPopupDrawer.dataStream,
      builder: (context, snapshotSizeDrawer) {
        return InkWell(
          onTap: () {
            widget.onTap();
            blocPopupDrawer.dataSink
                .add(snapshotSizeDrawer.data! == 38 ? 140 : 38);
            radius = radius == 54 ? 10 : 54;
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 11, right: 9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: isTablet
                  ? snapshotSizeDrawer.data!
                  : snapshotSizeDrawer.data!,
              width: isTablet ? double.infinity : 360,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                    width: widget.borderColor ==
                            const Color.fromARGB(255, 213, 0, 50)
                        ? 0.9
                        : 0.1,
                    color: widget.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            text,
                            style: text == "Номер"
                                ? GoogleFonts.montserrat(
                                    fontSize: isTablet ? 13 : 10,
                                    color: widget.hintColor)
                                : GoogleFonts.montserrat(
                                    fontSize: isTablet ? 13 : 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    StreamBuilder<CountryModel>(
                        stream: blocHansaCountry.stream,
                        builder: (context, snapshotCountry) {
                          if (snapshotCountry.hasData) {
                            streamController.sink
                                .add(snapshotCountry.data!.data.list);
                            return Visibility(
                              visible: radius == 54 ? false : true,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 260),
                                        child: Column(
                                            children: List.generate(
                                          3,
                                          (index) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: InkWell(
                                                onTap: () {
                                                  gorodTextEditingContyroller
                                                      .text = ccs[index];
                                                  text = ccs[index];
                                                  blocPopupDrawer.dataSink.add(
                                                      snapshotSizeDrawer
                                                                  .data! ==
                                                              38
                                                          ? 140
                                                          : 38);
                                                  providerNumberCountry.sink
                                                      .add(ecs[index]);
                                                  radius =
                                                      radius == 54 ? 10 : 54;
                                                  setState(() {});
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      ccs[index],
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ))),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
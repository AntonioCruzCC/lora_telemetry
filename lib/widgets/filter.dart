import 'package:flutter/material.dart';
import 'package:lora_telemetry/widgets/districts_combobox.dart';
import 'package:lora_telemetry/widgets/limit_slider.dart';

class Filter extends StatefulWidget {
  const Filter({Key? key}) : super(key: key);

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  //add spaces between the filters
  List<Widget> addSpacers(List<Widget> list) {
    for (int i = 1; i <= (list.length - 1); i += 2) {
      list.insert(
        i,
        const SizedBox(
          height: 20,
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadiusDirectional.circular(2.5),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                'Filtros',
                textAlign: TextAlign.left,
                textScaleFactor: 2,
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 10,
              child: Column(
                children: addSpacers(
                  [
                    const DistrictsComboBox(),
                    const LimitSlider(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

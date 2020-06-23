import 'dart:convert';

import 'package:admin_flutter/plugin/cache.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class CitySelectPlugin extends StatefulWidget {
  final getArea;

  CitySelectPlugin({@required this.getArea});

  @override
  _CitySelectPluginState createState() => _CitySelectPluginState();
}

class _CitySelectPluginState extends State<CitySelectPlugin> {
  Map provinceData = {
    '0': {
      'region_id': "0",
      'region_name': "请选择",
    }
  };
  Map cityData = {
    '0': {
      'region_id': "0",
      'region_name': "请选择",
    }
  };
  Map regionData = {
    '0': {
      'region_id': "0",
      'region_name': "请选择",
    }
  };
  Map selectArea = {'province': '0', 'city': '0', 'region': '0'};
  Cache cache = Cache(
    'area',
  );
  Map areaData = {};

  @override
  void initState() {
    super.initState();
    getArea();
  }

  @override
  void didUpdateWidget(CitySelectPlugin oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  getArea() async {
    var res = await cache.get('Config-area', {});
    setState(() {
      areaData = res;
      getCityData(0);
    });
  }

  getCityData(index) async {
    Map temp = {
      '0': {
        'region_id': "0",
        'region_name': "请选择",
      }
    };
    if (mounted) {
      if (index == 0) {
        temp.addAll(jsonDecode(jsonEncode(areaData)));
        setState(() {
          provinceData = temp;
        });
      } else if (index == 1) {
        temp.addAll(jsonDecode(jsonEncode(areaData[selectArea['province'].toString()]['child'])));
        setState(() {
          cityData = temp;
        });
      } else if (index == 2) {
        temp.addAll(jsonDecode(jsonEncode(cityData[selectArea['city'].toString()]['child'])));
        setState(() {
          regionData = temp;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              height: 34,
              child: DropdownButton<String>(
                isExpanded: true,
                underline: Container(),
                elevation: 1,
                value: selectArea['province'],
                onChanged: (String newValue) {
                  setState(() {
                    selectArea['province'] = newValue;
                    selectArea['city'] = '0';
                    selectArea['region'] = '0';
                    if (newValue != '0') {
                      getCityData(1);
                    }
                    widget.getArea(selectArea);
                  });
                },
                items: provinceData.keys.toList().map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem(
                    value: '$item',
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '${provinceData[item]['region_name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: CFFontSize.content,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              height: 34,
              child: DropdownButton<String>(
                isExpanded: true,
                elevation: 1,
                underline: Container(),
                value: selectArea['city'],
                onChanged: (String newValue) {
                  setState(() {
                    selectArea['city'] = newValue;
                    selectArea['region'] = '0';
                    if (newValue != '0') {
                      getCityData(2);
                    }
                    widget.getArea(selectArea);
                  });
                },
                items: cityData.keys.toList().map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem(
                    value: '$item',
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '${cityData['$item']['region_name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: CFFontSize.content,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              height: 34,
              child: DropdownButton<String>(
                isExpanded: true,
                elevation: 1,
                underline: Container(),
                value: selectArea['region'],
                onChanged: (String newValue) {
                  setState(() {
                    selectArea['region'] = newValue;
                    widget.getArea(selectArea);
                  });
                },
                items: regionData.keys.toList().map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem(
                    value: '$item',
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '${regionData['$item']['region_name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: CFFontSize.content,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

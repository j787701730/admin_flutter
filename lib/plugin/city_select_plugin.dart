import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

class CitySelectPlugin extends StatefulWidget {
  final getArea;

  CitySelectPlugin({@required this.getArea});

  @override
  _CitySelectPluginState createState() => _CitySelectPluginState();
}

class _CitySelectPluginState extends State<CitySelectPlugin> {
  Map provinceData = {'0': '请选择'};
  Map cityData = {'0': '请选择'};
  Map regionData = {'0': '请选择'};
  Map selectArea = {'province': '0', 'city': '0', 'region': '0'};
  Map ajaXData = {'county': 1, 'province': '', 'city': ''};

  @override
  void initState() {
    super.initState();
    getCityData(0);
  }

  getCityData(index) async {
    ajaxSimple('Home-Config-areaConfig', ajaXData, (data) {
      Map temp = {'0': '请选择'};
      temp.addAll(data);
      if (mounted) {
        if (index == 0) {
          setState(() {
            provinceData = temp;
          });
        } else if (index == 1) {
          setState(() {
            cityData = temp;
          });
        } else if (index == 2) {
          setState(() {
            regionData = temp;
          });
        }
      }
    });
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
                    ajaXData['province'] = newValue;
                    ajaXData['city'] = '';
                    selectArea['province'] = newValue;
                    selectArea['city'] = '0';
                    selectArea['region'] = '0';
                    cityData = {'0': '请选择'};
                    regionData = {'0': '请选择'};
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
                        '${provinceData[item.toString()]}',
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
                    ajaXData['city'] = newValue;
                    selectArea['region'] = '0';
                    regionData = {'0': '请选择'};
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
                        '${cityData[item.toString()]}',
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
                        '${regionData[item.toString()]}',
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

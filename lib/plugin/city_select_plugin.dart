import 'dart:convert';

import 'package:admin_flutter/plugin/cache.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class CitySelectPlugin extends StatefulWidget {
  final getArea;
  final linkage;
  final initArea;

  final String label;
  final double labelWidth;
  final bool require; // 是否必填 显示*
  final double marginTop;
  final bool hiddenRegion;

  CitySelectPlugin({
    @required this.getArea,
    this.linkage = false,
    this.initArea,
    this.label = '',
    this.require = false,
    this.marginTop,
    this.labelWidth = 80,
    this.hiddenRegion = false,
  });

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
    if (widget.linkage) {
      provinceData = {};
      cityData = {};
      regionData = {};
      selectArea = {
        'province': widget.initArea['province'],
        'city': widget.initArea['city'],
        'region': widget.initArea['region'],
      };
    }
    getArea();
  }

  @override
  void didUpdateWidget(CitySelectPlugin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.linkage &&
        oldWidget.initArea != null &&
        widget.initArea != null &&
        (oldWidget.initArea['province'] != widget.initArea['province'] ||
            oldWidget.initArea['city'] != widget.initArea['city'] ||
            oldWidget.initArea['region'] != widget.initArea['region'])) {
      selectArea = {
        'province': widget.initArea['province'],
        'city': widget.initArea['city'],
        'region': widget.initArea['region'],
      };
      getCityData(0);
    }
  }

  getArea() async {
    var res = await cache.get('Config-area', {});
    setState(() {
      areaData = res;
      getCityData(0);
    });
  }

  getCityData(index) {
    Map temp = {
      '0': {
        'region_id': "0",
        'region_name': "请选择",
      }
    };
    if (widget.linkage) {
      temp = {};
    }
    if (mounted) {
      if (index == 0) {
        temp.addAll(jsonDecode(jsonEncode(areaData)));
        setState(() {
          provinceData = temp;
          if (selectArea['province'] == null) {
            selectArea['province'] = temp.keys.toList()[0];
          }
        });
        if (widget.linkage) {
          getCityData(1);
        }
      } else if (index == 1) {
        temp.addAll(jsonDecode(jsonEncode(areaData[selectArea['province'].toString()]['child'])));
        setState(() {
          cityData = temp;
          if (selectArea['city'] == null || temp[selectArea['city']] == null) {
            selectArea['city'] = temp.keys.toList()[0];
          }
        });
        if (widget.linkage) {
          getCityData(2);
        }
      } else if (index == 2) {
        temp.addAll(jsonDecode(jsonEncode(cityData[selectArea['city'].toString()]['child'])));
        setState(() {
          regionData = temp;
          if (selectArea['region'] == null || temp[selectArea['region']] == null) {
            selectArea['region'] = temp.keys.toList()[0];
          }
        });
        if (widget.linkage) {
          widget.getArea(selectArea);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: widget.marginTop == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: widget.labelWidth,
            margin: EdgeInsets.only(
              right: widget.label == '' ? 0 : 10,
              top: widget.marginTop ?? 0,
            ),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${widget.require ? '* ' : ''}',
                  style: TextStyle(color: CFColors.danger),
                ),
                Text('${widget.label}'),
              ],
            ),
          ),
          Expanded(
            child: Container(
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
                            if (!widget.linkage) {
                              widget.getArea(selectArea);
                            }
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
                            if (!widget.linkage) {
                              widget.getArea(selectArea);
                            }
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
                    width: widget.hiddenRegion ? 0 : 10,
                  ),
                  widget.hiddenRegion
                      ? Container()
                      : Expanded(
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
            ),
          ),
        ],
      ),
    );
  }
}

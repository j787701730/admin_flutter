import 'package:flutter/material.dart';

class ClassAttributeSelectChild extends StatefulWidget {
  final props;

  ClassAttributeSelectChild(this.props);

  @override
  _ClassAttributeSelectChildState createState() => _ClassAttributeSelectChildState();
}

class _ClassAttributeSelectChildState extends State<ClassAttributeSelectChild> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 20,
            child: DataTable(
              columnSpacing: 10,
              columns: <DataColumn>[
                const DataColumn(
                  label: Text('子级枚举中文名称'),
                ),
                DataColumn(
                  label: const Text('选项图标/图像'),
                ),
                DataColumn(
                  label: const Text('排序'),
                ),
              ],
              rows: widget.props['items'].map<DataRow>((dessert) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Row(
                        children: <Widget>[
                          Text(dessert['attr_option_ch_value']),
                          dessert['children'].isNotEmpty
                              ? InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              : Container(width: 0,)
                        ],
                      ),
                    ),
                    DataCell(
                      Text('${dessert['attr_option_pic_url'] ?? ''}'),
                    ),
                    DataCell(
                      Text('${dessert['attr_option_sort'] ?? ''}'),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

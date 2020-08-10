import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PagePlugin extends StatefulWidget {
  final int current;
  final int total;
  final int pageSize;
  final Function function;

  PagePlugin({@required this.current, @required this.total, @required this.pageSize, @required this.function});

  @override
  _PagePluginState createState() => _PagePluginState();
}

class _PagePluginState extends State<PagePlugin> {
  int current = 1;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    current = widget.current;
  }

  @override
  void didUpdateWidget(PagePlugin oldWidget) {
    super.didUpdateWidget(oldWidget);
    totalPages = (widget.total / widget.pageSize).ceil();
    current = widget.current;
  }

  pages() {
    int totalPages = (widget.total / widget.pageSize).ceil();
    List arr = [];
    if (totalPages > 5 && current >= 5) {
      arr.add('first');
    }
    if (current > 1) {
      arr.add('prev');
    }
    if (totalPages <= 5) {
      for (var i = 1; i < totalPages + 1; ++i) {
        arr.add(i);
      }
    } else {
      if (current < 5) {
        for (var i = 1; i < 6; ++i) {
          arr.add(i);
        }
      } else if (current >= totalPages - 4) {
        for (var i = totalPages - 4; i < totalPages + 1; ++i) {
          arr.add(i);
        }
      } else if (current >= 5 && current < totalPages - 4) {
        for (var i = current - 2; i < current + 3; ++i) {
          arr.add(i);
        }
      }
    }
    if (current < totalPages) {
      arr.add('next');
    }
    if (totalPages > 5 && (current <= totalPages - 4 || current < 5)) {
      arr.add('last');
    }
    return arr.isEmpty || totalPages == 1
        ? SizedBox()
        : Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            spacing: 4,
            children: arr.map<Widget>((item) {
              Widget con = SizedBox();
              if (current == item) {
                con = Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text('$item'),
                );
              } else {
                switch (item) {
                  case 'first':
                    con = Container(
                      width: 40,
                      child: PrimaryButton(
                        onPressed: () {
                          widget.function(1);
                        },
                        child: Icon(Icons.first_page),
                        padding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                    );
                    break;
                  case 'prev':
                    con = Container(
                      width: 40,
                      child: PrimaryButton(
                        onPressed: () {
                          widget.function(current - 1);
                        },
                        child: Icon(Icons.keyboard_arrow_left),
                        padding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                    );
                    break;
                  case 'next':
                    con = Container(
                      width: 40,
                      child: PrimaryButton(
                        onPressed: () {
                          widget.function(current + 1);
                        },
                        child: Icon(Icons.keyboard_arrow_right),
                        padding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                    );
                    break;
                  case 'last':
                    con = Container(
                      width: 40,
                      child: PrimaryButton(
                        onPressed: () {
                          widget.function(totalPages);
                        },
                        child: Icon(Icons.last_page),
                        padding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                    );
                    break;
                  default:
                    con = PrimaryButton(
                      onPressed: () {
                        widget.function(item);
                      },
                      child: Text('$item'),
                    );
                }
              }
              return con;
            }).toList(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return pages();
  }
}

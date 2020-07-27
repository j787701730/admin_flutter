import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class SearchBarPlugin extends StatefulWidget {
  final Widget firstChild;
  final Widget secondChild;

  SearchBarPlugin({
    this.firstChild,
    this.secondChild,
  });

  @override
  _SearchBarPluginState createState() => _SearchBarPluginState();
}

class _SearchBarPluginState extends State<SearchBarPlugin> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedCrossFade(
          duration: const Duration(
            milliseconds: 300,
          ),
          firstChild: widget.firstChild == null
              ? Placeholder(
                  fallbackHeight: 0.1,
                  color: Colors.transparent,
                )
              : widget.firstChild,
          secondChild: widget.secondChild == null
              ? Placeholder(
                  fallbackHeight: 0.1,
                  color: Colors.transparent,
                )
              : widget.secondChild,
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xffEFEBEA),
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffEFEBEA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${isExpanded ? '展开' : '收缩'}选项',
                        style: TextStyle(
                          fontSize: CFFontSize.tabBar,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

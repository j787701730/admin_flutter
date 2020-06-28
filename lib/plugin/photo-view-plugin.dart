import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewPlugin extends StatefulWidget {
  final List urls;

  PhotoViewPlugin(this.urls);

  @override
  _PhotoViewPluginState createState() => _PhotoViewPluginState();
}

class _PhotoViewPluginState extends State<PhotoViewPlugin> {
  PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.urls[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.urls[index]),
                  minScale: 1.0,
                );
              },
              itemCount: widget.urls.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                  ),
                ),
              ),
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              pageController: _pageController,
              onPageChanged: (val) {
                setState(() {
                  currentIndex = val;
                });
              },
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "${widget.urls[currentIndex]}".substring('$baseUrl'.length, "${widget.urls[currentIndex]}".length),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    softWrap: true,
                  ),
                  widget.urls.length > 1
                      ? Container(
                          margin: EdgeInsets.only(top: 6),
                          alignment: Alignment.center,
                          child: Text(
                            '${currentIndex + 1}/${widget.urls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  tooltip: '返回',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

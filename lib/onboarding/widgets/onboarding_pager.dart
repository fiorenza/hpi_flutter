import 'package:flutter/material.dart';
import 'package:hpi_flutter/core/localizations.dart';
import 'package:kt_dart/collection.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class OnboardingPager extends StatefulWidget {
  OnboardingPager({
    Key key,
    @required this.pages,
    @required this.onFinish,
  })  : assert(pages != null),
        assert(onFinish != null),
        super(key: key);

  final KtList<Page> pages;
  final VoidCallback onFinish;

  @override
  _OnboardingPagerState createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  static const double _bottomBarHeight = 64;
  static const double _indicatorSize = 8;
  static const double _indicatorSpacing = 8;

  double _page = 0;
  int get _pageFull => _page.floor();
  double get _pagePart => _page - _pageFull;
  bool get _isLastPage => _page.round() == widget.pages.size - 1;

  KtMutableList<bool> _canContinue;
  int _pageLimit;
  KtList<GlobalKey<FormState>> _formKeys;

  @override
  void initState() {
    super.initState();

    _canContinue = widget.pages.map((p) => p.canContinue).toMutableList();
    _pageLimit ??= widget.pages.size;
    _formKeys ??= widget.pages.map((_) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorTween(
          begin: widget.pages[_pageFull].color,
          end: widget.pages[_page.ceil()].color,
        ).transform(_pagePart),
      ),
      child: Stack(
        children: <Widget>[
          NotificationListener<ScrollUpdateNotification>(
            onNotification: (n) {
              setState(() {
                if (n.metrics is! PageMetrics) return;
                _page = (n.metrics as PageMetrics).page;
              });
              return false;
            },
            child: PageView(
              controller: controller,
              children: widget.pages
                  .take(_canContinue.takeWhile((c) => c).size + 1)
                  .mapIndexed((i, p) => _buildPage(i, p))
                  .asList(),
            ),
          ),
          Opacity(
            opacity: _page.clamp(0.0, 1.0).toDouble(),
            child: _buildNavigationButton(
              alignment: Alignment.bottomLeft,
              onPressed: () => controller.previousPage(
                duration: Duration(milliseconds: 400),
                curve: Curves.ease,
              ),
              icon: OMIcons.chevronLeft,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: _bottomBarHeight,
              child: Center(
                child: _buildPageIndicator(),
              ),
            ),
          ),
          _isLastPage
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: _bottomBarHeight,
                    child: FlatButton(
                      onPressed:
                          _canContinue[_page.round()] ? widget.onFinish : null,
                      child: Text(HpiL11n.get(context, 'onboarding/done')),
                      textColor: Colors.white,
                    ),
                  ),
                )
              : _buildNavigationButton(
                  alignment: Alignment.bottomRight,
                  onPressed: _canContinue[_page.round()]
                      ? () => controller.nextPage(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.ease,
                          )
                      : null,
                  icon: OMIcons.chevronRight,
                ),
        ],
      ),
    );
  }

  Widget _buildPage(int index, Page page) {
    assert(index != null);
    assert(page != null);

    return NotificationListener<PageNotification>(
      onNotification: (n) {
        if (_canContinue[index] != n.canContinue) {
          setState(() {
            _canContinue[index] = n.canContinue;
          });
        }
        return true;
      },
      child: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: _bottomBarHeight) + page.padding,
            child: DefaultTextStyle(
              style: TextStyle(),
              textAlign: TextAlign.center,
              child: page.child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    @required Alignment alignment,
    VoidCallback onPressed,
    @required IconData icon,
  }) {
    assert(alignment != null);
    assert(icon != null);

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: _bottomBarHeight,
        height: _bottomBarHeight,
        child: IconButton(
          iconSize: 32,
          onPressed: onPressed,
          icon: Icon(icon),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    Widget indicatorBox([double width = _indicatorSize]) => SizedBox(
          width: width,
          height: _indicatorSize,
        );

    return Stack(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.pages
              .mapIndexed((i, _) => Material(
                    type: MaterialType.circle,
                    color: Colors.white.withOpacity(0.4),
                    child: indicatorBox(),
                  ))
              .flatMap((i) => KtList.of(i, SizedBox(width: _indicatorSpacing)))
              .dropLast(1)
              .asList(),
        ),
        Positioned(
          left: ((_pageFull + (_pagePart - 0.5).clamp(0.0, 1.0) * 2) *
                  (_indicatorSize + _indicatorSpacing))
              .toDouble(),
          child: Material(
            color: Colors.white,
            shape: StadiumBorder(),
            child: indicatorBox(
              Tween<double>(
                begin: _indicatorSize,
                end: 2 * _indicatorSize + _indicatorSpacing,
              ).transform(1 - (2 * _pagePart - 1).abs()),
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class PageNotification extends Notification {
  PageNotification(this.canContinue) : assert(canContinue != null);

  final bool canContinue;
}

@immutable
class Page {
  Page({
    @required this.color,
    @required this.child,
    this.padding = const EdgeInsets.all(32),
    this.canContinue = true,
  })  : assert(color != null),
        assert(child != null),
        assert(padding != null),
        assert(canContinue != null);

  final Color color;
  final Widget child;
  final EdgeInsets padding;
  final bool canContinue;
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../theme/td_colors.dart';
import '../../theme/td_theme.dart';
import '../icon/td_icons.dart';
import '../image/td_image.dart';
import '../navbar/td_nav_bar.dart';

typedef OnIndexChange = Function(int index);
typedef OnClose = Function(int index);
typedef OnDelete = Function(int index);
typedef OnLongPress = Function(int index);

class TDImageViewerWidget extends StatefulWidget {
  const TDImageViewerWidget({
    Key? key,
    this.closeBtn,
    this.deleteBtn,
    required this.images,
    this.showIndex,
    this.defaultIndex,
    this.onIndexChange,
    this.onClose,
    this.onDelete,
    this.onLongPress,
  }) : super(key: key);

  /// 是否展示关闭按钮
  final bool? closeBtn;

  /// 是否显示删除操作
  final bool? deleteBtn;

  /// 图片数组
  final List<dynamic> images;

  /// 是否显示页码
  final bool? showIndex;

  /// 默认预览图片所在的下标
  final int? defaultIndex;

  /// 预览图片切换回调
  final OnIndexChange? onIndexChange;

  /// 关闭点击
  final OnClose? onClose;

  /// 删除点击
  final OnDelete? onDelete;

  /// 长按图片
  final OnLongPress? onLongPress;

  @override
  State<StatefulWidget> createState() {
    return _TDImageViewerWidgetState();
  }
}

class _TDImageViewerWidgetState extends State<TDImageViewerWidget> {
  int _index = 1;

  @override
  void initState() {
    super.initState();
    _index = widget.defaultIndex ?? 1;
  }

  Widget _getImage(dynamic image) {
    if(image is File) {
      return TDImage(
        imageFile: image,
        type: TDImageType.fitWidth,
      );
    }
    if(image is String) {
      if(image.startsWith('http')) {
        return TDImage(
          imgUrl: image,
          type: TDImageType.fitWidth,
        );
      }
      return TDImage(
        assetUrl: image,
        type: TDImageType.fitWidth,
      );
    }
    throw FlutterError('image ${image} type is not supported');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: TDTheme.of(context).fontGyColor1,
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              var image = widget.images[index];
              return GestureDetector(
                onLongPress: () => widget.onLongPress?.call(index),
                child: _getImage(image),
              );
            },
            itemCount: widget.images.length,
            onIndexChanged: (index) {
              if ((widget.showIndex ?? false)) {
                setState(() {
                  _index = index + 1;
                });
              }
              widget.onIndexChange?.call(index);
            },
          ),
        ),
        SafeArea(
          child: TDNavBar(
            backgroundColor: Colors.transparent,
            useDefaultBack: false,
            title: (widget.showIndex ?? false)
                ? '$_index / ${widget.images.length}'
                : '',
            titleColor: TDTheme.of(context).whiteColor1,
            leftBarItems: [
              TDNavBarItem(
                  icon: TDIcons.close,
                  iconColor: TDTheme.of(context).whiteColor1,
                  action: () {
                    if (widget.onClose != null) {
                      widget.onClose!.call(_index - 1);
                    } else {
                      Navigator.of(context).pop();
                    }
                  })
            ],
            rightBarItems: [
              if (widget.deleteBtn ?? false)
                TDNavBarItem(
                  icon: TDIcons.delete,
                  iconColor: TDTheme.of(context).whiteColor1,
                  action: () {
                    widget.images.removeAt(_index - 1);
                    widget.onDelete?.call(_index - 1);
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

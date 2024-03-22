import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControlledAnimation<T> {
  final AnimationController controller;
  final Animatable<T> animatable;
  final VoidCallback listener;
  final Animation<T> animation;

  ControlledAnimation({
    required this.controller,
    required this.animatable,
    required this.listener,
  }) : animation = animatable.animate(controller)
          ..addListener(listener);
}

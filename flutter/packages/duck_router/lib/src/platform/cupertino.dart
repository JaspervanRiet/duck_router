// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

bool isCupertinoApp(BuildContext context) =>
    context.findAncestorWidgetOfExactType<CupertinoApp>() != null;

HeroController createCupertinoHeroController() =>
    CupertinoApp.createCupertinoHeroController();

CupertinoPage<void> pageBuilderForCupertinoApp({
  required LocalKey key,
  required String? name,
  required Widget child,
}) =>
    CupertinoPage<void>(
      name: name,
      key: key,
      child: child,
    );

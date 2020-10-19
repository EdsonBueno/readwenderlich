/*
 * Copyright (c) 2020 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * This project and source code may use libraries or frameworks that are
 * released under various Open-Source licenses. Use of those libraries and
 * frameworks are governed by their own individual licenses.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:readwenderlich/data/repository.dart';
import 'package:readwenderlich/data/stores/in_memory_store.dart';
import 'package:readwenderlich/data/stores/remote/remote_store.dart';

/// Provider for all data layer dependencies.
class DataDependenciesProvider extends SingleChildStatelessWidget {
  const DataDependenciesProvider({
    Widget child,
    Key key,
  }) : super(
          child: child,
          key: key,
        );

  @override
  Widget buildWithChild(
    BuildContext context,
    Widget child,
  ) =>
      MultiProvider(
        providers: [
          _DioProvider(),
          _RemoteStoreProvider(),
          _InMemoryStoreProvider(),
          _RepositoryProvider(),
        ],
        child: child,
      );
}

class _DioProvider extends SingleChildStatelessWidget {
  @override
  Widget buildWithChild(
    BuildContext context,
    Widget child,
  ) {
    final configuration = BaseOptions(
      baseUrl: 'https://www.raywenderlich.com/api/',
    );

    return Provider<Dio>(
      create: (_) => Dio(
        configuration,
      ),
      child: child,
    );
  }
}

class _RemoteStoreProvider extends SingleChildStatelessWidget {
  @override
  Widget buildWithChild(
    BuildContext context,
    Widget child,
  ) =>
      ProxyProvider<Dio, RemoteStore>(
        update: (_, dio, __) => RemoteStore(
          dio: dio,
        ),
        child: child,
      );
}

class _InMemoryStoreProvider extends SingleChildStatelessWidget {
  @override
  Widget buildWithChild(
    BuildContext context,
    Widget child,
  ) =>
      Provider<InMemoryStore>(
        create: (_) => InMemoryStore(),
        child: child,
      );
}

class _RepositoryProvider extends SingleChildStatelessWidget {
  @override
  Widget buildWithChild(
    BuildContext context,
    Widget child,
  ) =>
      ProxyProvider2<RemoteStore, InMemoryStore, Repository>(
        update: (_, remoteApi, inMemoryStorage, __) => Repository(
          remoteStore: remoteApi,
          inMemoryStore: inMemoryStorage,
        ),
        child: child,
      );
}

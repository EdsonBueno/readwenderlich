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

import 'package:flutter/material.dart';
import 'package:readwenderlich/data/repository.dart';
import 'package:readwenderlich/entities/article.dart';
import 'package:readwenderlich/ui/exception_indicators/empty_list_indicator.dart';
import 'package:readwenderlich/ui/exception_indicators/error_indicator.dart';
import 'package:readwenderlich/ui/list/article_list_item.dart';
import 'package:readwenderlich/ui/preferences/list_preferences.dart';

/// Based on the received preferences, fetches and displays a non-paginated
/// list of articles.
class ArticleListView extends StatefulWidget {
  const ArticleListView({
    @required this.repository,
    this.listPreferences,
    Key key,
  })  : assert(repository != null),
        super(key: key);

  final Repository repository;
  final ListPreferences listPreferences;

  @override
  _ArticleListViewState createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  Repository get _repository => widget.repository;
  bool _isLoading = true;
  List<Article> _articles;
  dynamic _error;

  ListPreferences get _listPreferences => widget.listPreferences;

  @override
  void initState() {
    _fetchArticles();
    super.initState();
  }

  @override
  void didUpdateWidget(ArticleListView oldWidget) {
    // When preferences changes, the widget is rebuilt and we need to re-fetch
    // the articles.
    if (oldWidget.listPreferences != widget.listPreferences) {
      _fetchArticles();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _fetchArticles() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
        _articles = null;
      });
    }

    try {
      final page = await _repository.getArticleListPage(
        filteredPlatformIds: _listPreferences?.filteredPlatformIds,
        filteredDifficulties: _listPreferences?.filteredDifficulties,
        filteredCategoryIds: _listPreferences?.filteredCategoryIds,
        sortMethod: _listPreferences?.sortMethod,
      );

      setState(() {
        _articles = page.itemList;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _isLoading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : _error != null
          ? ErrorIndicator(
              error: _error,
              onTryAgain: _fetchArticles,
            )
          : _articles.isEmpty
              ? EmptyListIndicator()
              : ListView.separated(
                  itemBuilder: (context, index) => ArticleListItem(
                    article: _articles[index],
                  ),
                  itemCount: _articles.length,
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 16,
                  ),
                );
}

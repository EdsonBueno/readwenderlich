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

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:readwenderlich/data/stores/remote/json_structures/query_result.dart';
import 'package:readwenderlich/entities/article.dart';
import 'package:readwenderlich/entities/article_category.dart';
import 'package:readwenderlich/entities/article_difficulty.dart';
import 'package:readwenderlich/entities/article_platform.dart';
import 'package:readwenderlich/entities/list_page.dart';
import 'package:readwenderlich/entities/sort_method.dart';

/// Gets information from the raywenderlich.com API.
class RemoteStore {
  RemoteStore({
    @required this.dio,
  }) : assert(dio != null);

  final Dio dio;

  Future<List<ArticlePlatform>> getPlatformList() => dio.getEntityList(
        _platformsPath,
        (queryItem) => ArticlePlatform.fromQueryItem(queryItem),
      );

  Future<List<ArticleCategory>> getCategoryList() => dio.getEntityList(
        _categoriesPath,
        (queryItem) => ArticleCategory.fromQueryItem(queryItem),
      );

  Future<ListPage<Article>> getArticleListPage({
    int number,
    int size,
    List<int> filteredPlatformIds,
    List<int> filteredCategoryIds,
    List<ArticleDifficulty> filteredDifficulties,
    SortMethod sortMethod,
  }) {
    final filteredDifficultiesNames = filteredDifficulties
        ?.map((difficulty) => difficulty.queryParamValue)
        ?.toList();

    final sortMethodQueryParamValue =
        sortMethod == null ? null : '-${sortMethod.queryParamValue}';

    return dio.getQueryResult<Article, int>(
      _contentsPath,
      (queryItem) => Article.fromQueryItem(queryItem),
      metaDataParser: (json) => json['total_result_count'],
      queryParameters: {
        _contentTypeQueryParam: _articleQueryParamValue,
        _pageNumberQueryParam: number,
        _pageSizeQueryParam: size,
        _platformIdsQueryParam: _formatListToQueryValueArray(
          filteredPlatformIds,
        ),
        _categoryIdsQueryParam: _formatListToQueryValueArray(
          filteredCategoryIds,
        ),
        _difficultiesQueryParam: _formatListToQueryValueArray(
          filteredDifficultiesNames,
        ),
        _sortQueryParam: sortMethodQueryParamValue,
      },
    ).then(
      (responseBody) => ListPage<Article>(
        itemList: responseBody.items,
        grandTotalCount: responseBody.meta,
      ),
    );
  }

  static const _platformsPath = 'domains';
  static const _contentsPath = 'contents';
  static const _categoriesPath = 'categories';

  static const _contentTypeQueryParam = 'filter[content_types][]';
  static const _platformIdsQueryParam = 'filter[domain_ids]';
  static const _categoryIdsQueryParam = 'filter[category_ids]';
  static const _difficultiesQueryParam = 'filter[difficulties]';
  static const _sortQueryParam = 'sort';
  static const _pageNumberQueryParam = 'page[number]';
  static const _pageSizeQueryParam = 'page[size]';
  static const _articleQueryParamValue = 'article';

  static List<T> _formatListToQueryValueArray<T>(List<T> list) {
    final hasItems = list?.isEmpty != false;
    return hasItems ? null : list;
  }
}

extension on Dio {
  Future<List<DataType>> getEntityList<DataType>(
    String path,
    QueryItemParser queryItemParser, {
    Map<String, dynamic> queryParameters,
  }) =>
      getQueryResult<DataType, void>(
        path,
        queryItemParser,
        queryParameters: queryParameters,
      ).then(
        (value) => value.items,
      );

  Future<QueryResult<DataType, MetaDataType>>
      getQueryResult<DataType, MetaDataType>(
    String path,
    QueryItemParser queryItemParser, {
    Map<String, dynamic> queryParameters,
    JsonParser<MetaDataType> metaDataParser,
  }) =>
          get(
            path,
            queryParameters: queryParameters,
          )
              .then(
                (response) => json.decode(response.data),
              )
              .then(
                (responseBody) => QueryResult<DataType, MetaDataType>.fromJson(
                  responseBody,
                  queryItemParser,
                  metaDataParser: metaDataParser,
                ),
              )
              .catchError((error) {
            if (error is DioError && error.error is SocketException) {
              throw error.error;
            }

            throw error;
          });
}

extension on ArticleDifficulty {
  String get queryParamValue => this == ArticleDifficulty.beginner
      ? 'beginner'
      : this == ArticleDifficulty.intermediate ? 'intermediate' : 'advanced';
}

extension on SortMethod {
  String get queryParamValue =>
      this == SortMethod.releaseDate ? 'released_at' : 'popularity';
}

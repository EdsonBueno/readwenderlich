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

import 'package:flutter/foundation.dart';
import 'package:readwenderlich/data/stores/remote/json_structures/query_item.dart';

typedef JsonParser<T> = T Function(Map<String, dynamic> json);
typedef QueryItemParser<T> = T Function(
  QueryItem queryItem,
);

/// Root-level structure returned by raywenderlich.com API endpoints.
class QueryResult<DataType, MetaType> {
  const QueryResult({
    @required this.items,
    this.meta,
  }) : assert(items != null);

  factory QueryResult.fromJson(
    Map<String, dynamic> json,
    QueryItemParser<DataType> dataParser, {
    JsonParser<MetaType> metaDataParser,
  }) =>
      QueryResult<DataType, MetaType>(
        items: _parseDataFromJson(
          json,
          dataParser,
        ),
        meta: _parseMetaDataFromJson(
          json,
          metaDataParser,
        ),
      );

  final List<DataType> items;
  final MetaType meta;

  static List<DataType> _parseDataFromJson<DataType>(
    Map<String, dynamic> json,
    QueryItemParser<DataType> queryItemParser,
  ) =>
      _parseQueryItemListFromJson(
        json,
      )
          .map(
            queryItemParser,
          )
          .toList();

  static List<QueryItem> _parseQueryItemListFromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> dataJsonArray = json['data'];
    return dataJsonArray
        .cast()
        .map(
          (json) => QueryItem.fromJson(
            json,
          ),
        )
        .toList();
  }

  static MetaType _parseMetaDataFromJson<MetaType>(
    Map<String, dynamic> json,
    JsonParser<MetaType> parser,
  ) {
    final hasMetaParser = parser != null;
    return hasMetaParser
        ? parser(
            json['meta'],
          )
        : null;
  }
}

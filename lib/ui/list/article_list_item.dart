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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readwenderlich/entities/article.dart';
import 'package:url_launcher/url_launcher.dart';

/// A list tile for an article.
class ArticleListItem extends StatelessWidget {
  const ArticleListItem({
    @required this.article,
    Key key,
  })  : assert(article != null),
        super(key: key);
  final Article article;

  String get _formattedDurationInMinutes {
    final durationInMinutes = article.duration / 60;
    return '${durationInMinutes.toStringAsFixed(0)} mins';
  }

  String get _formattedReleaseDate =>
      DateFormat('MMM d yyyy').format(article.releaseDate);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: () async => _launchURL(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      article.name,
                      style: textTheme.subtitle1,
                    ),
                  ),
                  if (article.artworkUrl != null)
                    const SizedBox(
                      width: 16,
                    ),
                  if (article.artworkUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        width: 50,
                        height: 50,
                        imageUrl: article.artworkUrl,
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                article.description,
                style: textTheme.bodyText2,
              ),
              Text(
                '$_formattedReleaseDate ($_formattedDurationInMinutes)',
                style: textTheme.bodyText2,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context) async {
    final url = 'https://raywenderlich.com/redirect?uri=${article.uri}';
    if (Platform.isIOS || await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could\'nt launch the article\'s URL.'),
        ),
      );
    }
  }
}

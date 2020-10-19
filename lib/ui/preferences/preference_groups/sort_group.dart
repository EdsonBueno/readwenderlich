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
import 'package:readwenderlich/ui/app_colors.dart';

/// Groups choice chips and assigns a label to the group.
class SortGroup extends StatelessWidget {
  const SortGroup({
    @required this.title,
    @required this.options,
    @required this.selectedOptionId,
    this.onOptionTap,
    Key key,
  })  : assert(title != null),
        assert(options != null),
        assert(selectedOptionId != null),
        super(key: key);

  final String title;
  final List<SortOption> options;
  final dynamic selectedOptionId;
  final ValueChanged<SortOption> onOptionTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sort),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            _OptionList(
              options: options,
              selectedOptionId: selectedOptionId,
              onOptionTap: onOptionTap,
            ),
          ],
        ),
      );
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    @required this.selectedOptionId,
    @required this.onOptionTap,
    this.options,
    Key key,
  })  : assert(selectedOptionId != null),
        assert(onOptionTap != null),
        super(key: key);

  final List<SortOption> options;
  final dynamic selectedOptionId;
  final ValueChanged<SortOption> onOptionTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        children: [
          ...options.map(
            (option) {
              final isItemSelected = selectedOptionId == option.id;
              return ChoiceChip(
                label: Text(
                  option.name,
                  style: TextStyle(
                    color: isItemSelected ? Colors.white : AppColors.black,
                  ),
                ),
                onSelected:
                    onOptionTap != null ? (_) => onOptionTap(option) : null,
                selected: isItemSelected,
                backgroundColor: Colors.white,
                selectedColor: AppColors.green,
              );
            },
          ).toList(),
        ],
      );
}

class SortOption {
  SortOption({
    @required this.id,
    @required this.name,
  })  : assert(id != null),
        assert(name != null);
  final dynamic id;
  final String name;
}

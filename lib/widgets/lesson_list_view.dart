import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/generated/l10n.dart';
import 'package:musicscool/services/api.dart' show AuthenticationFailed;


typedef LessonListItemBuilder = Widget Function(BuildContext context, Lesson item, int index);
typedef LessonListGetter = Future<List<Lesson>> Function(int page, int perPage);
typedef LessonListRefresh = Future<void> Function();

class LessonListView extends StatefulWidget {
  final LessonListItemBuilder itemBuilder;
  final LessonListGetter itemGetter;
  final LessonListRefresh itemRefresh;

  LessonListView({required this.itemBuilder, required this.itemGetter,
                  required this.itemRefresh});

  @override
  _LessonListViewState createState() => _LessonListViewState();
}

class _LessonListViewState extends State<LessonListView> {
  static const _pageSize = 20;

  PagingController<int, Lesson>? _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController!.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<Lesson> lessons = await widget.itemGetter(pageKey, _pageSize);
      if (!mounted || _pagingController == null) return;
      final bool isLastPage = lessons.length < _pageSize;
      if (isLastPage) {
        _pagingController!.appendLastPage(lessons);
      }
      else {
        _pagingController!.appendPage(lessons, pageKey + 1);
      }
    }
    on AuthenticationFailed {
      // AuthModel will trigger a global refresh back to LoginPage.
    }
    catch (error, stacktrace) {
      print(error.toString());
      print(stacktrace);
      if (mounted && _pagingController != null) {
        _pagingController!.error = S.current.unexpectedErrorMessage;
      }
    }
  }

  @override
  Widget build(BuildContext build) =>
    RefreshIndicator(
      onRefresh: () async {
        await widget.itemRefresh();
        _pagingController!.refresh();
      },
      child: PagedListView<int, Lesson>.separated(
        padding: EdgeInsets.all(8),
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        pagingController: _pagingController!,
        builderDelegate: PagedChildBuilderDelegate<Lesson>(
          firstPageErrorIndicatorBuilder: (BuildContext context)
           => FirstPageExceptionIndicator(
             title: S.of(context).unexpectedErrorMessage,
             message: '')
          ,
          noItemsFoundIndicatorBuilder: (BuildContext context) =>
            FirstPageExceptionIndicator(
              title: S.of(context).noLessonsFound,
              message: '')
          ,
          itemBuilder: widget.itemBuilder
        ),
      )
    );

  @override
  void dispose() {
    _pagingController!.dispose();
    _pagingController = null;
    super.dispose();
  }
}

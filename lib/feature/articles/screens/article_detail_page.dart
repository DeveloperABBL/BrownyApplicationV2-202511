import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/articles/models/article_detail_model.dart';
import 'package:browny_applications_new/feature/home/viewmodel/home_page_viewmodel.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({
    super.key,
    required this.viewmodel,
  });

  static final pagePath = '/article_detail_page';
  static final pageName = 'article_detail_page';

  /// util function route to pageName
  static Future<T?> goToPage<T>(
    BuildContext context,
    // ArticleDetailModel article,
    HomePageViewmodel viewmodel,
  ) async {
    return await context.pushNamed(
      ArticleDetailPage.pageName,
      extra: viewmodel,
    );
  }

  final HomePageViewmodel viewmodel;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late ArticleDetailModel _article;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _article = widget.viewmodel.highlighSelected!;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.languageCode;
    final imageUrl = _article.image?.getByLocaleCode(locale) ?? '';
    final title = _article.title?.getByLocaleCode(locale) ?? '';
    final categoryName = _article.category?.name?.getByLocaleCode(locale) ?? '';
    final detail = _article.detail?.getByLocaleCode(locale) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          _article.category!.name!.getByLocaleCode(
            context.languageCode,
          )!,
        ),
        leading: BackButton(
          color: AppColors.darkBrown,
        ),
      ),
      persistentFooterDecoration: _article.hasArticleButton
          ? BoxDecoration()
          : null,
      persistentFooterButtons: _article.hasArticleButton
          ? [
              SafeArea(
                // top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
                  child: ElevatedButton.icon(
                    icon: _article.isExpired
                        ? Assets.svg.icInfoRad.svg()
                        : null,
                    style: _article.isExpired
                        ? ElevatedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            disabledBackgroundColor: AppColors.errorBackground,
                          )
                        : null,
                    onPressed: _article.isClaimable
                        ? () async {
                            AppOverlays.showLoading(context);
                            final result = await widget.viewmodel.collectBanner(
                              bannerId: _article.id ?? -1,
                            );
                            if (!context.mounted) return;
                            AppOverlays.hideLoading();
                            if (result.isEmpty || result.hasError) {
                              AppOverlays.showBrownyDialog(
                                context,
                                title: context.wording.errorOccurred,
                                message: context.wording.errorUi,
                              );
                              return;
                            }

                            AppOverlays.showBrownyDialog(
                              context,
                              imageAsset: Assets.png.brownySuccess1.path,
                              title: context.wording.success,
                              // รับสิทธิ์เรียบร้อยแล้ว
                              message: context.wording.claimSuccessMessage,
                              onConfirm: () {
                                setState(() {
                                  // เอา state ใน Widget มารับค่าใหม่
                                  // จะมีการ assign ใน collectBanner แล้ว
                                  _article = widget.viewmodel.highlighSelected!;
                                });
                              },
                            );
                          }
                        : null,
                    label: AppText(
                      _article.getArticleButtonDisplay(locale),
                      style: _article.isExpired
                          ? context.textTheme.labelLarge!.copyWith(
                              color: AppColors.error,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ]
          : null,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              left: AppDims.size_16.w,
              right: AppDims.size_16.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDims.size_8.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => Center(
                      child: Icon(
                        Icons.image,
                        size: 32.r,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                ),
                AppDims.vericalPadding_8,

                // Title
                AppText(
                  title,
                  style: context.textTheme.titleLarge!.copyWith(
                    fontSize: AppDims.size_16,
                  ),
                ),
                AppDims.vericalPadding_8,

                // Category
                AppText(
                  categoryName,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                AppDims.vericalPadding_8,

                Divider(),
                AppDims.vericalPadding_8,

                Html(
                  data: detail,
                  style: {
                    "body": Style(
                      fontSize: FontSize(14.sp),
                      padding: HtmlPaddings.zero,
                      textAlign: TextAlign.start,
                      margin: Margins.all(0),
                      fontWeight: FontWeight.w300,
                      color: AppColors.darkBrown,
                      fontFamily: GoogleFonts.prompt().fontFamily,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/articles/models/article_detail_model.dart';
import 'package:flutter_html/flutter_html.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({
    super.key,
    required this.article,
  });

  static final pagePath = '/article_detail_page';
  static final pageName = 'article_detail_page';

  final ArticleDetailModel article;

  @override
  Widget build(BuildContext context) {
    final locale = context.languageCode;
    final imageUrl = article.image?.getByLocaleCode(locale) ?? '';
    final title = article.title?.getByLocaleCode(locale) ?? '';
    final categoryName = article.category?.name?.getByLocaleCode(locale) ?? '';
    final subtitle = article.subtitle?.getByLocaleCode(locale) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          article.category!.name!.getByLocaleCode(context.languageCode)!,
        ),
        leading: BackButton(
          color: AppColors.darkBrown,
        ),
      ),
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
                  data: subtitle,
                  style: {
                    "body": Style(
                      fontSize: FontSize(14.sp),
                      padding: HtmlPaddings.zero,

                      textAlign: TextAlign.start,
                      margin: Margins.all(0),
                      fontWeight: FontWeight.w300,
                      color: AppColors.darkBrown,
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

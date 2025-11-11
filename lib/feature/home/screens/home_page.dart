import 'package:browny_applications_new/core/res/colors/app_colors.dart';
import 'package:browny_applications_new/core/res/dims/app_dims.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/browny_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static final pagePath = '/home_page';
  static final pageName = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,

            backgroundColor: AppColors.primary.withAlpha(2),
            stretch: true,
            expandedHeight: 206,
            flexibleSpace: FlexibleSpaceBar(
              // FlexibleSpaceBar: ส่วนที่ยืด-หดได้ของ AppBar
              // background: Container(color: AppColors.primary),
              background: Image.network(
                'https://dev.abgroup.co.th/storage/uploads/app_images/store_1757391567.jpg',
                fit: BoxFit.cover,
              ),
              stretchModes: [
                StretchMode.zoomBackground,
              ],
            ),
            actionsPadding: EdgeInsets.symmetric(
              horizontal: AppDims.size_16.w,
            ),
            actions: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.notifications,
                      color: AppColors.primary,
                    ),
                  ),
                  AppDims.horizonPadding_10,
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(20.h),
              child: AppContainerRadius(
                height: 26.h,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text('${index + 1}'),
                  ),
                  title: Text('List Item ${index + 1}'),
                  subtitle: Text('Description for item ${index + 1}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
              childCount: 20,
            ),
          ),
          // SliverToBoxAdapter(
          //   child: AppContainerRadius(
          //     height: 100,
          //     color: Colors.blue,
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: BrownyBottomNav(
        currentIndex: 0,
        onTap: (index) {
          print(index.toString());
        },
        onCenterTap: () {
          print('onCenterTap');
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'category_page.dart';
import 'cart_page.dart';
import 'member_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<BottomNavigationBarItem> bottomTabs=[
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),//IOS风格的
      title: Text('首页')
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.search),
      title: Text('分类')
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.shopping_cart),
      title: Text('购物车')
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.profile_circled),
      title: Text('会员中心')
    )
  ];
  final List tabBodied=[
    HomePage(),
    CategoryPage(),
    CartPage(),
    MemberPage()
  ];
  int currentIndex=0;//当前索引
  var currentPage;
  @override
  void initState() { 
    currentPage=tabBodied[currentIndex];//默认页面数组内索引值为0的页面
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {

     ScreenUtil.instance=ScreenUtil(width: 750,height: 1334)..init(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),//颜色固定死，比白色稍微灰一点
      bottomNavigationBar: BottomNavigationBar(
        type:BottomNavigationBarType.fixed, 
        currentIndex: currentIndex,
        items:bottomTabs,
        onTap: (index){
          setState(() {
            currentIndex=index;
            currentPage=tabBodied[currentIndex];
          });
        },
      ),
      body: currentPage,
    );
  }
}
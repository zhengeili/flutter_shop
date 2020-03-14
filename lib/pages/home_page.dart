import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String homePageContent='正在获取数据';

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title:Text('百兴生活+')),
      body: FutureBuilder(
        future: getHomePageContent(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            var data=json.decode(snapshot.data.toString());
            List<Map> swiper=(data['data']['slides'] as List).cast();
            List<Map> navigatorList=(data['data']['category'] as List).cast();
            String picture=data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String leaderImage=data['data']['shopInfo']['leaderImage'];
            String leaderPhone=data['data']['shopInfo']['leaderPhone'];
            return Column(
              children: <Widget>[
                SwiperDiy(swiperDateList: swiper),
                TopNavigator(navigatorList: navigatorList),
                AdBanner(adPicture:picture),
                LeaderPhone(leaderImage:leaderImage,leaderPhone:leaderPhone)
              ],
            );
          }
        }
      )
    );
  }
  
}

class SwiperDiy extends StatelessWidget {
  final List swiperDateList;
  SwiperDiy({this.swiperDateList});

  @override
  Widget build(BuildContext context) {
   
    print('设备的像素密度：${ScreenUtil.pixelRatio}');
    print('设备的高：${ScreenUtil.screenWidth}');
    print('设备的宽：${ScreenUtil.screenHeight}');
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          return Image.network("${swiperDateList[index]['image']}",fit: BoxFit.fill);
        },
        itemCount: swiperDateList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}
class TopNavigator extends StatelessWidget {
  final List navigatorList;
  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context,item){
    return InkWell(
      onTap: (){print('点击了导航');},
      child: Column(
        children: <Widget>[
          Image.network(item['image'],width:ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(this.navigatorList.length>10){
      this.navigatorList.removeRange(10, this.navigatorList.length);//从第十个截取，后面都截取掉
    }
    return Container(
      height: ScreenUtil().setHeight(320),//只是自己大概预估的一个高度，后续可以再调整
      padding: EdgeInsets.all(3.0),//为了不让它贴着屏幕的边缘，我们给它一个padding
      child: GridView.count(
        crossAxisCount: 5,//每行显示5个元素
        padding: EdgeInsets.all(5),//每一项都设置一个padding,这样就不挨着了
        children: navigatorList.map((item){
            return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
  
}
class AdBanner extends StatelessWidget {
  final String adPicture;
  const AdBanner({Key key,this.adPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicture),
    );
  }
}
//店长电话模块
class LeaderPhone extends StatelessWidget {
  final String leaderImage;//店长图片
  final String leaderPhone;//店长电话
  const LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }
  void _launchURL() async {
    String url='tel:'+leaderPhone;
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'url不能进行访问，异常';
    }
  }
}
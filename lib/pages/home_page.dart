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

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int page=1;
  List<Map> hotGoodsList=[];//火爆专区数据
  String homePageContent='正在获取数据';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHotGoods();//获取火爆专区的数据
    print('111111');
  }

  @override
  Widget build(BuildContext context) {
    var formData={'lon':'115.02932','lat':'35.76189'};//传一个经纬度过去，防止恶意下单
    return Scaffold(
      appBar: AppBar(title:Text('百兴生活+')),
      body: FutureBuilder(
        future: request('homePageContent', formData:formData),
        builder: (context,snapshot){
          if(snapshot.hasData){
            var data=json.decode(snapshot.data.toString());
            List<Map> swiper=(data['data']['slides'] as List).cast();
            List<Map> navigatorList=(data['data']['category'] as List).cast();
            String picture=data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String leaderImage=data['data']['shopInfo']['leaderImage'];
            String leaderPhone=data['data']['shopInfo']['leaderPhone'];
            List<Map> recommendList=(data['data']['recommend'] as List).cast();
            String floor1Title=data['data']['floor1Pic']['PICTURE_ADDRESS'];
            String floor2Title=data['data']['floor1Pic']['PICTURE_ADDRESS'];
            String floor3Title=data['data']['floor1Pic']['PICTURE_ADDRESS'];
            List<Map> floor1=(data['data']['floor1'] as List).cast();
            List<Map> floor2=(data['data']['floor2'] as List).cast();
            List<Map> floor3=(data['data']['floor3'] as List).cast();
            return SingleChildScrollView(
              child:Column(
                children: <Widget>[
                  SwiperDiy(swiperDateList: swiper),
                  TopNavigator(navigatorList: navigatorList),
                  AdBanner(adPicture:picture),
                  LeaderPhone(leaderImage:leaderImage,leaderPhone:leaderPhone),
                  Recommend(recommendList: recommendList,),
                  FloorTitle(picture_address: floor1Title,),
                  FloorContent(floorGoodsList:floor1),
                  FloorTitle(picture_address: floor2Title,),
                  FloorContent(floorGoodsList:floor2),
                  FloorTitle(picture_address: floor3Title,),
                  FloorContent(floorGoodsList:floor3),
                  _hotGoods()
                ],
              )
            );
          }
        }
      )
    );
  }
  void _getHotGoods(){
    var formData={'page':page};
    request('homePageBelowConten',formData: formData).then((val){
      var data=json.decode(val.toString());
      List<Map> newGoodsList=(data['data'] as List).cast();
      //把新的列表加到老的列表里面
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }
  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),//上边距
    alignment: Alignment.center,//居中对齐
    color: Colors.transparent,
    padding: EdgeInsets.all(5.0),//外边距
    child: Text('火爆专区'),
  );
  //流布局列表数据
  Widget _wrapList(){
    if(hotGoodsList.length!=0){
      List<Widget> listWidget=hotGoodsList.map((val){
        return InkWell(
          onTap: (){},
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),//内边距
            margin: EdgeInsets.only(bottom:3.0),//外边距
            child: Column(
              children: <Widget>[
                Image.network(val['image'],width: ScreenUtil().setWidth(370),),//设置宽度防止超出边界
                Text(
                  val['name'],
                  maxLines: 1,//只有一行
                  overflow: TextOverflow.ellipsis,//超出显示省略号
                  style: TextStyle(color: Colors.pink,fontSize: ScreenUtil().setSp(26)),
                ),
                Row(
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),//商品价格
                    Text(
                      '￥${val['price']}',
                      style:TextStyle(color: Colors.black26,decoration: TextDecoration.lineThrough),//
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    }else{
      return Text('');
    }
  }
  //组装标题 流式布局
  Widget _hotGoods(){
    return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _wrapList()
        ],
      ),
    );
  }
}
//首页轮播插件
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
//商品推荐
class Recommend extends StatelessWidget {

  final List recommendList;

  const Recommend({Key key, this.recommendList}) : super(key: key);

  Widget _titleWidget(){
    return Container(
      alignment: Alignment.centerLeft,//局部靠左对齐
      padding: EdgeInsets.fromLTRB(10, 2.0, 0, 5.0),//左上右下
      decoration: BoxDecoration(
        color:Colors.white,
        border:Border(
          bottom:BorderSide(width: 1,color:Colors.black12)//设置底部hottom边框，Black12是浅灰色
        )
      ),
      child: Text(
        '商品推荐',
        style: TextStyle(color:Colors.pink),
      ),
    );
  }
  Widget _item(index){
    return InkWell(
      onTap: (){},
      child: Container(
        height:ScreenUtil().setHeight(380),//兼容性的高度，用了screenUtil
        width:ScreenUtil().setWidth(250),//750除以3所以是250
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color:Colors.white,
          border:Border(
            left:BorderSide(width: 1,color:Colors.black12)//左侧的边线样式和宽度
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,//删除线的样式
                color: Colors.grey//浅灰色
              ),
            )
          ],
        ),
      ),
    );
  }
  //横向列表组件
  Widget _recommendList(){
    return Container(
      height:ScreenUtil().setHeight(380),
      child:ListView.builder(
        scrollDirection:Axis.horizontal,//横向的
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
        return _item(index);
       },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height:ScreenUtil().setHeight(438),//里被哦按已经设置了330了因为还有上面的标题，所以要比330高，这里先设置为380
      margin: EdgeInsets.only(top:10.0),//设置外边距
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommendList()
        ],
      ),
    );
  }
}
//楼层标题
class FloorTitle extends StatelessWidget {
  final String picture_address;

  FloorTitle({Key key, this.picture_address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),//设置内边距是8
      child: Image.network(picture_address),
    );
  }
}
//楼层商品列表
class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods()
        ],
      ),
    );
  }

  Widget _goodsItem(Map goods){
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: (){print('点击了楼层商品');},
        child: Image.network(goods['image']),
      ),
    );
  }

  Widget _firstRow(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[0]),//第一行左边一个大的图片
        Column(
          children: <Widget>[
            _goodsItem(floorGoodsList[1]),//第一行 左右 上下两个图的 上
            _goodsItem(floorGoodsList[2])//第一行 左右 上下两个图的 下
          ],
        )
      ],
    );
  }

  Widget _otherGoods(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[2]),
        _goodsItem(floorGoodsList[3])
      ],
    );
  }
}
////火爆专区，定义为动态的类
//class HotGoods extends StatefulWidget {
//  @override
//  _HotGoodsState createState() => _HotGoodsState();
//}
//
//class _HotGoodsState extends State<HotGoods> {
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//    print('火爆专区数据加载中.......');
//    request('homePageBelowConten',formData:1).then((val){
//      print(val);
//    });
//  }
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      child: Text('1111'),
//    );
//  }
//}


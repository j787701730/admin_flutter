import 'package:admin_flutter/activity/activity_list.dart';
import 'package:admin_flutter/activity/coupon.dart';
import 'package:admin_flutter/activity/draw_type.dart';
import 'package:admin_flutter/activity/user_prizes.dart';
import 'package:admin_flutter/article/list.dart';
import 'package:admin_flutter/balance/accum_flow.dart';
import 'package:admin_flutter/balance/balance_charge.dart';
import 'package:admin_flutter/balance/balance_manual.dart';
import 'package:admin_flutter/balance/balance_transfer.dart';
import 'package:admin_flutter/balance/charge_card.dart';
import 'package:admin_flutter/balance/charge_present.dart';
import 'package:admin_flutter/balance/charge_summary.dart';
import 'package:admin_flutter/balance/extract.dart';
import 'package:admin_flutter/balance/extract_config.dart';
import 'package:admin_flutter/balance/list.dart';
import 'package:admin_flutter/balance/payment_plan.dart';
import 'package:admin_flutter/balance/pricing.dart';
import 'package:admin_flutter/balance/red_packet.dart';
import 'package:admin_flutter/base/agreement.dart';
import 'package:admin_flutter/base/base_monitor.dart';
import 'package:admin_flutter/base/base_wxreply.dart';
import 'package:admin_flutter/base/cache.dart';
import 'package:admin_flutter/base/maintain.dart';
import 'package:admin_flutter/base/sitemap.dart';
import 'package:admin_flutter/erp/added_services.dart';
import 'package:admin_flutter/erp/erp_config.dart';
import 'package:admin_flutter/erp/erp_crm.dart';
import 'package:admin_flutter/erp/erp_orders.dart';
import 'package:admin_flutter/erp/erp_payment.dart';
import 'package:admin_flutter/erp/erp_payout.dart';
import 'package:admin_flutter/erp/erp_software.dart';
import 'package:admin_flutter/erp/payout_summary.dart';
import 'package:admin_flutter/error.dart';
import 'package:admin_flutter/financial/financialDetail.dart';
import 'package:admin_flutter/financial/financial_loan.dart';
import 'package:admin_flutter/financial/system_config.dart';
import 'package:admin_flutter/goods/attr.dart';
import 'package:admin_flutter/goods/class.dart';
import 'package:admin_flutter/invoice/acctitem.dart';
import 'package:admin_flutter/invoice/invoice_list.dart';
import 'package:admin_flutter/localizations.dart';
import 'package:admin_flutter/log/admin_logs.dart';
import 'package:admin_flutter/log/analysis_logs.dart';
import 'package:admin_flutter/log/cad_logs.dart';
import 'package:admin_flutter/log/charge_logs.dart';
import 'package:admin_flutter/log/cs.dart';
import 'package:admin_flutter/log/erp_logs.dart';
import 'package:admin_flutter/log/mq_logs.dart';
import 'package:admin_flutter/log/opt_logs.dart';
import 'package:admin_flutter/log/phone_logs.dart';
import 'package:admin_flutter/log/redpacket_logs.dart';
import 'package:admin_flutter/log/sms_logs.dart';
import 'package:admin_flutter/log/wx_logs.dart';
import 'package:admin_flutter/login.dart';
import 'package:admin_flutter/my_home_page.dart';
import 'package:admin_flutter/rebate/rebate_authorize.dart';
import 'package:admin_flutter/rebate/rebate_city_sales.dart';
import 'package:admin_flutter/rebate/cad_distributor.dart';
import 'package:admin_flutter/rebate/rebate_distributor.dart';
import 'package:admin_flutter/rebate/rebate_list.dart';
import 'package:admin_flutter/rebate/rebate_rates.dart';
import 'package:admin_flutter/rebate/rebate_rule.dart';
import 'package:admin_flutter/rebate/rebate_sale_man.dart';
import 'package:admin_flutter/shop/cad_admins.dart';
import 'package:admin_flutter/shop/cad_drawing.dart';
import 'package:admin_flutter/shop/cad_user_relation.dart';
import 'package:admin_flutter/shop/industry_class.dart';
import 'package:admin_flutter/shop/shop_list.dart';
import 'package:admin_flutter/shop/supply_class.dart';
import 'package:admin_flutter/task/task_pricing.dart';
import 'package:admin_flutter/users/add.dart';
import 'package:admin_flutter/users/manager.dart';
import 'package:admin_flutter/users/users__cert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '后台管理系统',
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        textTheme: TextTheme(
          subhead: TextStyle(textBaseline: TextBaseline.alphabetic), // TextField hintText 居中
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/home': (_) => MyHomePage(),
        '/login': (_) => Login(),
        '/articleList': (_) => ArticleList(), // 文章列表
        '/csLogs': (_) => CsLogs(), // 软件日志
        '/erpLogs': (_) => ErpLogs(), // Erp日志
        '/mqLogs': (_) => MQLogs(), // 消息日志
        '/wxLogs': (_) => WXLogs(), // 微信日志
        '/smsLogs': (_) => SmsLogs(), // 短信日志
        '/adminLogs': (_) => AdminLogs(), // 后台操作日志
        '/optLogs': (_) => OPTLogs(), // 软件优化日志
        '/chargeLogs': (_) => ChargeLogs(), // 对账日志
        '/redpacketLogs': (_) => RedPacketLogs(), // 红包日志
        '/cadLogs': (_) => CADLogs(), // CAD日志
        '/phoneLogs': (_) => PhoneLogs(), // 通话日志
        '/analysisLogs': (_) => AnalysisLogs(), // 日志分析日志
        '/usersAdd': (_) => UsersAdd(), // 用户添加
        '/usersCert': (_) => UsersCert(), // 实名认证
        '/usersManager': (_) => UsersManager(), // 用户管理
        '/balanceList': (_) => BalanceList(), // 资金账本
        '/balancePricing': (_) => BalancePricing(), // 定价计划
        '/chargePresent': (_) => ChargePresent(), // 充值赠送
        '/paymentPlan': (_) => PaymentPlan(), // 支付方案
        '/extractConfig': (_) => ExtractConfig(), // 提现配置
        '/accumulateFlow': (_) => AccumulateFlow(), // 积量汇总
        '/shopList': (_) => ShopList(), // 店铺列表
        '/cadUserRelation': (_) => CadUserRelation(), // CAD用户关系
        '/cadDrawing': (_) => CadDrawing(), // 效果图制作
        '/cadAdmins': (_) => CadAdmins(), // WEB_CAD管理员
        '/industryClass': (_) => IndustryClass(), // 行业分类
        '/supplyClass': (_) => SupplyClass(), // 供应商分类
        '/chargeCard': (_) => ChargeCard(), // 充值卡
        '/invoiceList': (_) => InvoiceList(), // 开票管理
        '/accountItem': (_) => AccountItem(), // 出账日志
        '/baseMonitor': (_) => BaseMonitor(), // 主机监控
        '/maintain': (_) => Maintain(), // 网站维护
        '/agreement': (_) => Agreement(), // 网站协议
        '/cadDistributor': (_) => CADDistributor(), // CAD经销商
        '/rebateList': (_) => RebateList(), // 返利流水
        '/rebateRates': (_) => RebateRates(), // 返利比例
        '/rebateRule': (_) => RebateRule(), // 经销商规则
        '/rebateDistributor': (_) => RebateDistributor(), // 经销商
        '/rebateCitySales': (_) => RebateCitySales(), // 城市分销
        '/rebateAuthorize': (_) => RebateAuthorize(), // 门店授权
        '/rebateSaleMan': (_) => RebateSaleMan(), // 业务员返利
        '/erpOrders': (_) => ErpOrders(), // ERP订单
        '/erpCrm': (_) => ErpCrm(), // 门店客户
        '/erpPayment': (_) => ErpPayment(), // 收款记录
        '/erpConfig': (_) => ErpConfig(), // ERP配置
        '/goodsClass': (_) => GoodsClass(), // 商品类目
        '/goodsAttr': (_) => GoodsAttribute(), // 类目属性
        '/baseCache': (_) => BaseCache(), // 缓存管理
        '/baseWxreply': (_) => BaseWxreply(), // 缓存管理
        '/baseSitemap': (_) => BaseSitemap(), // 网站导航
        '/balanceCharge': (_) => BalanceCharge(), // 充值流水
        '/chargeSummary': (_) => ChargeSummary(), // 充值汇总
        '/balanceManual': (_) => BalanceManual(), // 手工帐
        '/balanceTransfer': (_) => BalanceTransfer(), // 转账管理
        '/balanceExtract': (_) => BalanceExtract(), // 提现管理
        '/redPacket': (_) => RedPacket(), // 红包管理
        '/erpPayout': (_) => ErpPayout(), // 拆单流水
        '/payoutSummary': (_) => PayoutSummary(), // 拆单汇总
        '/erpSoftware': (_) => ErpSoftware(), // 软件包月
        '/addedServices': (_) => AddedServices(), // 增值服务
        '/financialLoan': (_) => FinancialLoan(), // 丰收贷
        '/systemConfig': (_) => SystemConfig(), // 金融配置
        '/financialDetail': (_) => FinancialDetail(), // 金融明细
        '/activityList': (_) => ActivityList(), // 活动列表
        '/userPrizes': (_) => UserPrizes(), // 中奖列表
        '/drawType': (_) => DrawType(), // 抽奖方式
        '/coupon': (_) => Coupon(), // 优惠券
        '/taskPricing': (_) => TaskPricing(), // 任务定价
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // 自己要补个文件 localizations.dart
        ChineseCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('zh', 'CH'),
      ],
      onUnknownRoute: (RouteSettings settings) =>
          MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => ErrorPage()),
    );
  }
}

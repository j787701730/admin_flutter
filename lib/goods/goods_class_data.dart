List goodsClassData = [
//  {"class_id": "0", "class_name": "供应类目", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "1", "class_name": "设计模板", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "2", "class_name": "人工服务", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "3", "class_name": "整体家居", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "5", "class_name": "装修材料", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "8", "class_name": "电器设备", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "9", "class_name": "生产设备", "parent_class_id": "0", "class_level": "1"},
  {"class_id": "101", "class_name": "全屋定制", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "102", "class_name": "定制部件", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "103", "class_name": "成品家具", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "104", "class_name": "门", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "105", "class_name": "电器", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "106", "class_name": "整装设计", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "107", "class_name": "五金", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "108", "class_name": "其它", "parent_class_id": "1", "class_level": "2"},
  {"class_id": "201", "class_name": "设计", "parent_class_id": "2", "class_level": "2"},
  {"class_id": "202", "class_name": "施工", "parent_class_id": "2", "class_level": "2"},
  {"class_id": "203", "class_name": "物流", "parent_class_id": "2", "class_level": "2"},
  {"class_id": "204", "class_name": "培训", "parent_class_id": "2", "class_level": "2"},
  {"class_id": "301", "class_name": "定制家具", "parent_class_id": "3", "class_level": "2"},
  {"class_id": "302", "class_name": "成品家具", "parent_class_id": "3", "class_level": "2"},
  {"class_id": "303", "class_name": "办公家具", "parent_class_id": "3", "class_level": "2"},
  {"class_id": "307", "class_name": "其它家具", "parent_class_id": "3", "class_level": "2"},
  {"class_id": "501", "class_name": "基础材料", "parent_class_id": "5", "class_level": "2"},
  {"class_id": "502", "class_name": "装饰材料", "parent_class_id": "5", "class_level": "2"},
  {"class_id": "503", "class_name": "五金", "parent_class_id": "5", "class_level": "2"},
  {"class_id": "504", "class_name": "洁具", "parent_class_id": "5", "class_level": "2"},
  {"class_id": "505", "class_name": "灯具", "parent_class_id": "5", "class_level": "2"},
  {"class_id": "506", "class_name": "软装", "parent_class_id": "5", "class_level": "2"},
  {"class_id": "801", "class_name": "橱房电器", "parent_class_id": "8", "class_level": "2"},
  {"class_id": "802", "class_name": "家用电器", "parent_class_id": "8", "class_level": "2"},
  {"class_id": "803", "class_name": "小家电", "parent_class_id": "8", "class_level": "2"},
  {"class_id": "804", "class_name": "办公电器", "parent_class_id": "8", "class_level": "2"},
  {"class_id": "805", "class_name": "其它", "parent_class_id": "8", "class_level": "2"},
  {"class_id": "901", "class_name": "板式家具生产设备", "parent_class_id": "9", "class_level": "2"},
  {"class_id": "902", "class_name": "实木具生产设备", "parent_class_id": "9", "class_level": "2"},
  {"class_id": "903", "class_name": "通用设备", "parent_class_id": "9", "class_level": "2"},
  {"class_id": "10101", "class_name": "橱柜", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10102", "class_name": "衣柜", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10103", "class_name": "更衣室", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10104", "class_name": "书柜", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10105", "class_name": "精品柜", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10106", "class_name": "装饰柜", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10107", "class_name": "护墙板", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10108", "class_name": "酒窖", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10109", "class_name": "其它", "parent_class_id": "101", "class_level": "3"},
  {"class_id": "10201", "class_name": "橱柜外框", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10202", "class_name": "衣柜外框", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10203", "class_name": "基础部件", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10204", "class_name": "抽屉", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10205", "class_name": "顶线", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10206", "class_name": "罗马柱", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10207", "class_name": "烟机罩", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10208", "class_name": "装饰件", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10209", "class_name": "其它", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10210", "class_name": "梁柱", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10211", "class_name": "榻榻米", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10212", "class_name": "书桌", "parent_class_id": "102", "class_level": "3"},
  {"class_id": "10301", "class_name": "沙发", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10302", "class_name": "床铺", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10303", "class_name": "床头柜", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10304", "class_name": "茶几", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10305", "class_name": "电视柜", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10306", "class_name": "餐桌", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10307", "class_name": "椅子", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10308", "class_name": "斗柜", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10309", "class_name": "其它", "parent_class_id": "103", "class_level": "3"},
  {"class_id": "10401", "class_name": "移门", "parent_class_id": "104", "class_level": "3"},
  {"class_id": "10402", "class_name": "柜门", "parent_class_id": "104", "class_level": "3"},
  {"class_id": "10403", "class_name": "房门", "parent_class_id": "104", "class_level": "3"},
  {"class_id": "10501", "class_name": "橱房电器", "parent_class_id": "105", "class_level": "3"},
  {"class_id": "10502", "class_name": "家用电器", "parent_class_id": "105", "class_level": "3"},
  {"class_id": "10503", "class_name": "小家电", "parent_class_id": "105", "class_level": "3"},
  {"class_id": "10601", "class_name": "家装", "parent_class_id": "106", "class_level": "3"},
  {"class_id": "10602", "class_name": "公装", "parent_class_id": "106", "class_level": "3"},
  {"class_id": "10701", "class_name": "拉手", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10702", "class_name": "铰链", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10703", "class_name": "轨道", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10704", "class_name": "水槽", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10705", "class_name": "收纳", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10706", "class_name": "挂件", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10707", "class_name": "装饰", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10708", "class_name": "其它", "parent_class_id": "107", "class_level": "3"},
  {"class_id": "10801", "class_name": "餐具", "parent_class_id": "108", "class_level": "3"},
  {"class_id": "20101", "class_name": "定制设计", "parent_class_id": "201", "class_level": "3"},
  {"class_id": "20102", "class_name": "家装设计", "parent_class_id": "201", "class_level": "3"},
  {"class_id": "20103", "class_name": "产品设计", "parent_class_id": "201", "class_level": "3"},
  {"class_id": "20201", "class_name": "泥工", "parent_class_id": "202", "class_level": "3"},
  {"class_id": "20202", "class_name": "水电工", "parent_class_id": "202", "class_level": "3"},
  {"class_id": "20203", "class_name": "木工", "parent_class_id": "202", "class_level": "3"},
  {"class_id": "20204", "class_name": "油漆工", "parent_class_id": "202", "class_level": "3"},
  {"class_id": "20205", "class_name": "安装工", "parent_class_id": "202", "class_level": "3"},
  {"class_id": "20206", "class_name": "杂工", "parent_class_id": "202", "class_level": "3"},
  {"class_id": "20301", "class_name": "配送", "parent_class_id": "203", "class_level": "3"},
  {"class_id": "20302", "class_name": "搬运", "parent_class_id": "203", "class_level": "3"},
  {"class_id": "20401", "class_name": "设计师", "parent_class_id": "204", "class_level": "3"},
  {"class_id": "20402", "class_name": "技术工", "parent_class_id": "204", "class_level": "3"},
  {"class_id": "20403", "class_name": "销售", "parent_class_id": "204", "class_level": "3"},
  {"class_id": "20404", "class_name": "管理", "parent_class_id": "204", "class_level": "3"},
  {"class_id": "20405", "class_name": "其它", "parent_class_id": "204", "class_level": "3"},
  {"class_id": "30101", "class_name": "橱柜", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30102", "class_name": "衣柜", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30103", "class_name": "书柜", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30104", "class_name": "更衣室", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30105", "class_name": "精品柜", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30106", "class_name": "护墙板", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30107", "class_name": "酒窖", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30108", "class_name": "其它", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30109", "class_name": "移门", "parent_class_id": "301", "class_level": "3"},
  {"class_id": "30201", "class_name": "沙发", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30202", "class_name": "床铺", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30203", "class_name": "茶几", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30204", "class_name": "电视柜", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30205", "class_name": "餐椅", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30206", "class_name": "斗柜", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30207", "class_name": "其它", "parent_class_id": "302", "class_level": "3"},
  {"class_id": "30301", "class_name": "办公桌椅", "parent_class_id": "303", "class_level": "3"},
  {"class_id": "30302", "class_name": "文件柜", "parent_class_id": "303", "class_level": "3"},
  {"class_id": "30303", "class_name": "办公沙发", "parent_class_id": "303", "class_level": "3"},
  {"class_id": "30304", "class_name": "屏风隔断", "parent_class_id": "303", "class_level": "3"},
  {"class_id": "30305", "class_name": "其它", "parent_class_id": "303", "class_level": "3"},
  {"class_id": "50101", "class_name": "泥水", "parent_class_id": "501", "class_level": "3"},
  {"class_id": "50102", "class_name": "水路", "parent_class_id": "501", "class_level": "3"},
  {"class_id": "50103", "class_name": "电路", "parent_class_id": "501", "class_level": "3"},
  {"class_id": "50104", "class_name": "板材", "parent_class_id": "501", "class_level": "3"},
  {"class_id": "50105", "class_name": "油漆", "parent_class_id": "501", "class_level": "3"},
  {"class_id": "50106", "class_name": "辅材", "parent_class_id": "501", "class_level": "3"},
  {"class_id": "50201", "class_name": "磁砖", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50202", "class_name": "大理石", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50203", "class_name": "地板", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50204", "class_name": "墙纸", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50205", "class_name": "集成吊顶", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50207", "class_name": "门窗", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50208", "class_name": "其它", "parent_class_id": "502", "class_level": "3"},
  {"class_id": "50301", "class_name": "拉手", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50302", "class_name": "铰链", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50303", "class_name": "轨道", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50304", "class_name": "水槽", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50305", "class_name": "收纳", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50306", "class_name": "挂件", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50307", "class_name": "装饰", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50308", "class_name": "其它", "parent_class_id": "503", "class_level": "3"},
  {"class_id": "50401", "class_name": "马桶", "parent_class_id": "504", "class_level": "3"},
  {"class_id": "50402", "class_name": "沐浴房", "parent_class_id": "504", "class_level": "3"},
  {"class_id": "50403", "class_name": "洗衣池", "parent_class_id": "504", "class_level": "3"},
  {"class_id": "50404", "class_name": "龙头", "parent_class_id": "504", "class_level": "3"},
  {"class_id": "50405", "class_name": "挂件", "parent_class_id": "504", "class_level": "3"},
  {"class_id": "50406", "class_name": "其它", "parent_class_id": "504", "class_level": "3"},
  {"class_id": "50501", "class_name": "开关面板", "parent_class_id": "505", "class_level": "3"},
  {"class_id": "50502", "class_name": "吊灯", "parent_class_id": "505", "class_level": "3"},
  {"class_id": "50503", "class_name": "台灯", "parent_class_id": "505", "class_level": "3"},
  {"class_id": "50504", "class_name": "其他", "parent_class_id": "505", "class_level": "3"},
  {"class_id": "50601", "class_name": "布艺", "parent_class_id": "506", "class_level": "3"},
  {"class_id": "50602", "class_name": "摆饰", "parent_class_id": "506", "class_level": "3"},
  {"class_id": "50603", "class_name": "其它", "parent_class_id": "506", "class_level": "3"},
  {"class_id": "80101", "class_name": "油烟机", "parent_class_id": "801", "class_level": "3"},
  {"class_id": "80102", "class_name": "灶具", "parent_class_id": "801", "class_level": "3"},
  {"class_id": "80103", "class_name": "消毒柜", "parent_class_id": "801", "class_level": "3"},
  {"class_id": "80104", "class_name": "烤箱", "parent_class_id": "801", "class_level": "3"},
  {"class_id": "80105", "class_name": "其它电器", "parent_class_id": "801", "class_level": "3"},
  {"class_id": "80201", "class_name": "电视", "parent_class_id": "802", "class_level": "3"},
  {"class_id": "80202", "class_name": "音响", "parent_class_id": "802", "class_level": "3"},
  {"class_id": "80203", "class_name": "冰箱", "parent_class_id": "802", "class_level": "3"},
  {"class_id": "80204", "class_name": "热水器", "parent_class_id": "802", "class_level": "3"},
  {"class_id": "80205", "class_name": "空调", "parent_class_id": "802", "class_level": "3"},
  {"class_id": "80206", "class_name": "洗衣机", "parent_class_id": "802", "class_level": "3"},
  {"class_id": "80301", "class_name": "风扇", "parent_class_id": "803", "class_level": "3"},
  {"class_id": "80302", "class_name": "净化器", "parent_class_id": "803", "class_level": "3"},
  {"class_id": "80303", "class_name": "播放器", "parent_class_id": "803", "class_level": "3"},
  {"class_id": "80304", "class_name": "其它", "parent_class_id": "803", "class_level": "3"},
  {"class_id": "90101", "class_name": "开料机", "parent_class_id": "901", "class_level": "3"},
  {"class_id": "90102", "class_name": "封边机", "parent_class_id": "901", "class_level": "3"},
  {"class_id": "90103", "class_name": "侧孔钻", "parent_class_id": "901", "class_level": "3"},
  {"class_id": "90104", "class_name": "CNC", "parent_class_id": "901", "class_level": "3"},
  {"class_id": "90201", "class_name": "造型工具", "parent_class_id": "902", "class_level": "3"},
  {"class_id": "90301", "class_name": "推台锯", "parent_class_id": "903", "class_level": "3"},
  {"class_id": "90302", "class_name": "空压机", "parent_class_id": "903", "class_level": "3"},
  {"class_id": "90303", "class_name": "叉车", "parent_class_id": "903", "class_level": "3"}
];

Map attrObject = {
  "6": {
    "resource_attr_object_id": "6",
    "resource_attr_object_name": "商品规格",
    "map_table": "goods_class",
    "map_column": "goods_class_id",
    "comments": null,
    "resource_attr_object_level": "2"
  },
  "7": {
    "resource_attr_object_id": "7",
    "resource_attr_object_name": "商品参数",
    "map_table": "goods_class",
    "map_column": "goods_class_id",
    "comments": null,
    "resource_attr_object_level": "2"
  }
};

Map attrValuesUnit = {
  "1": {
    "attr_unit_id": "1",
    "attr_unit_class": "1",
    "attr_unit_en_name": "g",
    "attr_unit_ch_name": "克",
    "state": "1",
    "comments": "重量单位"
  },
  "2": {
    "attr_unit_id": "2",
    "attr_unit_class": "1",
    "attr_unit_en_name": "kg",
    "attr_unit_ch_name": "千克",
    "state": "1",
    "comments": "重量单位"
  },
  "3": {
    "attr_unit_id": "3",
    "attr_unit_class": "1",
    "attr_unit_en_name": "T",
    "attr_unit_ch_name": "吨",
    "state": "1",
    "comments": "重量单位"
  },
  "5": {
    "attr_unit_id": "5",
    "attr_unit_class": "4",
    "attr_unit_en_name": "nm",
    "attr_unit_ch_name": "纳米",
    "state": "1",
    "comments": ""
  },
  "7": {
    "attr_unit_id": "7",
    "attr_unit_class": "4",
    "attr_unit_en_name": "um",
    "attr_unit_ch_name": "微米",
    "state": "1",
    "comments": null
  },
  "8": {
    "attr_unit_id": "8",
    "attr_unit_class": "4",
    "attr_unit_en_name": "mm",
    "attr_unit_ch_name": "毫米",
    "state": "1",
    "comments": null
  },
  "9": {
    "attr_unit_id": "9",
    "attr_unit_class": "4",
    "attr_unit_en_name": "cm",
    "attr_unit_ch_name": "厘米",
    "state": "1",
    "comments": null
  },
  "10": {
    "attr_unit_id": "10",
    "attr_unit_class": "4",
    "attr_unit_en_name": "fm",
    "attr_unit_ch_name": "分米",
    "state": "1",
    "comments": null
  },
  "11": {
    "attr_unit_id": "11",
    "attr_unit_class": "4",
    "attr_unit_en_name": "m",
    "attr_unit_ch_name": "米",
    "state": "1",
    "comments": null
  },
  "12": {
    "attr_unit_id": "12",
    "attr_unit_class": "2",
    "attr_unit_en_name": "㎡",
    "attr_unit_ch_name": "平方米",
    "state": "1",
    "comments": null
  },
  "13": {
    "attr_unit_id": "13",
    "attr_unit_class": "7",
    "attr_unit_en_name": "h",
    "attr_unit_ch_name": "时",
    "state": "1",
    "comments": null
  },
  "14": {
    "attr_unit_id": "14",
    "attr_unit_class": "7",
    "attr_unit_en_name": "m",
    "attr_unit_ch_name": "分",
    "state": "1",
    "comments": null
  },
  "15": {
    "attr_unit_id": "15",
    "attr_unit_class": "7",
    "attr_unit_en_name": "s",
    "attr_unit_ch_name": "秒",
    "state": "1",
    "comments": null
  },
  "16": {
    "attr_unit_id": "16",
    "attr_unit_class": "9",
    "attr_unit_en_name": "Yuan",
    "attr_unit_ch_name": "元",
    "state": "1",
    "comments": null
  },
  "17": {
    "attr_unit_id": "17",
    "attr_unit_class": "9",
    "attr_unit_en_name": "",
    "attr_unit_ch_name": "千元",
    "state": "1",
    "comments": null
  },
  "18": {
    "attr_unit_id": "18",
    "attr_unit_class": "9",
    "attr_unit_en_name": "",
    "attr_unit_ch_name": "万元",
    "state": "1",
    "comments": null
  },
  "19": {
    "attr_unit_id": "19",
    "attr_unit_class": "8",
    "attr_unit_en_name": "yuan/h",
    "attr_unit_ch_name": "元/时",
    "state": "1",
    "comments": null
  },
  "20": {
    "attr_unit_id": "20",
    "attr_unit_class": "7",
    "attr_unit_en_name": "d",
    "attr_unit_ch_name": "日",
    "state": "1",
    "comments": null
  },
  "21": {
    "attr_unit_id": "21",
    "attr_unit_class": "7",
    "attr_unit_en_name": "w",
    "attr_unit_ch_name": "周",
    "state": "1",
    "comments": null
  },
  "22": {
    "attr_unit_id": "22",
    "attr_unit_class": "7",
    "attr_unit_en_name": "m",
    "attr_unit_ch_name": "月",
    "state": "1",
    "comments": null
  },
  "23": {
    "attr_unit_id": "23",
    "attr_unit_class": "7",
    "attr_unit_en_name": "s",
    "attr_unit_ch_name": "季",
    "state": "1",
    "comments": null
  },
  "24": {
    "attr_unit_id": "24",
    "attr_unit_class": "7",
    "attr_unit_en_name": "y",
    "attr_unit_ch_name": "年",
    "state": "1",
    "comments": null
  }
};

List attrValuesType = [
  {
    "resource_attr_value_type_id": "0",
    "resource_attr_value_type_en_name": "ATTR_TYPE_NODE",
    "resource_attr_value_type_ch_name": "节点",
    "comments": "节点作为目录使用，不存放具体值"
  },
  {
    "resource_attr_value_type_id": "1",
    "resource_attr_value_type_en_name": "ATTR_TYPE_ENUM",
    "resource_attr_value_type_ch_name": "枚举",
    "comments": "枚举的具体值存放在资源属性选项表"
  },
  {
    "resource_attr_value_type_id": "2",
    "resource_attr_value_type_en_name": "ATTR_TYPE_STRING",
    "resource_attr_value_type_ch_name": "字符串",
    "comments": null
  },
  {
    "resource_attr_value_type_id": "3",
    "resource_attr_value_type_en_name": "ATTR_TYPE_INT",
    "resource_attr_value_type_ch_name": "整数",
    "comments": null
  },
  {
    "resource_attr_value_type_id": "4",
    "resource_attr_value_type_en_name": "ATTR_TYPE_FLOAT",
    "resource_attr_value_type_ch_name": "小数",
    "comments": null
  },
  {
    "resource_attr_value_type_id": "5",
    "resource_attr_value_type_en_name": "ATTR_TYPE_DATE",
    "resource_attr_value_type_ch_name": "日期",
    "comments": null
  },
  {
    "resource_attr_value_type_id": "6",
    "resource_attr_value_type_en_name": "ATTR_TYPE_TIME",
    "resource_attr_value_type_ch_name": "时间",
    "comments": null
  },
  {
    "resource_attr_value_type_id": "7",
    "resource_attr_value_type_en_name": "ATTR_TYPE_DATETIME",
    "resource_attr_value_type_ch_name": "日期时间",
    "comments": null
  },
  {
    "resource_attr_value_type_id": "8",
    "resource_attr_value_type_en_name": "ATTR_TYPE_FILE",
    "resource_attr_value_type_ch_name": "文件",
    "comments": null
  }
];

Map attrSearch = {
  "1": {"val": 1, "desc": "是"},
  "2": {"val": 0, "desc": "否"}
};

Map attrHtml = {
  "1": {"html_id": "1", "html_type": "1", "if_choice": "1", "html_desc": "必选输入框", "html_icon": null},
  "2": {"html_id": "2", "html_type": "1", "if_choice": "0", "html_desc": "可选输入框", "html_icon": null},
  "3": {"html_id": "3", "html_type": "2", "if_choice": "1", "html_desc": "必选选择框", "html_icon": null},
  "4": {"html_id": "4", "html_type": "2", "if_choice": "0", "html_desc": "可选选择框", "html_icon": null},
  "5": {"html_id": "5", "html_type": "3", "if_choice": "1", "html_desc": "必选文本域", "html_icon": null},
  "6": {"html_id": "6", "html_type": "3", "if_choice": "0", "html_desc": "可选文本域", "html_icon": null},
  "7": {"html_id": "7", "html_type": "4", "if_choice": "1", "html_desc": "必选文件上传", "html_icon": null},
  "8": {"html_id": "8", "html_type": "4", "if_choice": "0", "html_desc": "可选文件上传", "html_icon": null},
  "9": {"html_id": "9", "html_type": "5", "if_choice": "1", "html_desc": "必选日期选择框", "html_icon": null},
  "10": {"html_id": "10", "html_type": "5", "if_choice": "0", "html_desc": "可选日期选择框", "html_icon": null},
  "11": {"html_id": "11", "html_type": "6", "if_choice": "1", "html_desc": "必选复合枚举", "html_icon": null},
  "12": {"html_id": "12", "html_type": "6", "if_choice": "0", "html_desc": "可选复合枚举", "html_icon": null},
  "13": {"html_id": "13", "html_type": "7", "if_choice": "1", "html_desc": "必选单列枚举", "html_icon": null},
  "14": {"html_id": "14", "html_type": "7", "if_choice": "0", "html_desc": "可选单列枚举", "html_icon": null}
};

Map attrState = {
  "0": {"val": 0, "desc": "注销"},
  "1": {"val": 1, "desc": "在用"}
};

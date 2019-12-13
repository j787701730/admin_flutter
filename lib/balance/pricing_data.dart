Map pricingStrategy = {
  "1": {
    "en_name": "ERP_PRICING_STRATEGY_QUOTA",
    "ch_name": "定额计价",
    "pricing_strategy": {"pricing_amount": "2.00", "pricing_nums": "1", "pricing_unit": "12"},
    "limit_fee": "3000.00",
    "create_date": "2017-06-19 09:51:49",
    "monthly_flag": "0",
    "pricing_strategy_id": "1"
  },
  "2": {
    "en_name": "ERP_PRICING_STRATEGY_LADDER_MONTH",
    "ch_name": "阶梯计价(月)",
    "pricing_strategy": [
      {"lower_limit": "0", "upper_limit": "1000", "pricing_amount": "2.00", "pricing_nums": "1", "pricing_unit": "12"},
      {
        "lower_limit": "1000",
        "upper_limit": "2000",
        "pricing_amount": "1.00",
        "pricing_nums": "1",
        "pricing_unit": "12"
      },
      {
        "lower_limit": "2000",
        "upper_limit": "99999999",
        "pricing_amount": "0.50",
        "pricing_nums": "1",
        "pricing_unit": "12"
      }
    ],
    "limit_fee": "0.00",
    "create_date": "2017-06-19 10:02:40",
    "monthly_flag": "0",
    "pricing_strategy_id": "2"
  },
  "3": {
    "en_name": "ERP_PRICING_STRATEGY_ONETIME",
    "ch_name": "一次买断",
    "pricing_strategy": "",
    "limit_fee": "0.00",
    "create_date": "2017-08-30 10:43:20",
    "monthly_flag": "0",
    "pricing_strategy_id": "3"
  },
  "4": {
    "en_name": "ERP_PRICING_STRATEGY_MONTHLY",
    "ch_name": "包月计价(CAD-客户端)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2017-08-30 10:42:39",
    "monthly_flag": "1",
    "pricing_strategy_id": "4"
  },
  "5": {
    "en_name": "ERP_PRICING_STRATEGY_WX_MSG",
    "ch_name": "包月计价(微信推送)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 10, "discount": 0},
      "2": {"name": "两个月", "price": 20, "discount": 0},
      "3": {"name": "3个月", "price": 30, "discount": 0},
      "4": {"name": "4个月", "price": 40, "discount": 0},
      "5": {"name": "5个月", "price": 50, "discount": 0},
      "6": {"name": "6个月", "price": 60, "discount": 0},
      "7": {"name": "7个月", "price": 70, "discount": 0},
      "8": {"name": "8个月", "price": 80, "discount": 0},
      "9": {"name": "9个月", "price": 90, "discount": 0},
      "10": {"name": "10个月", "price": 100, "discount": 0},
      "12": {"name": "一年", "price": 100, "discount": 20},
      "24": {"name": "两年", "price": 200, "discount": 40},
      "36": {"name": "三年", "price": 300, "discount": 60}
    },
    "limit_fee": "0.00",
    "create_date": "2017-09-21 14:56:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "5"
  },
  "6": {
    "en_name": "ERP_PRICING_STRATEGY_PROCESS",
    "ch_name": "包月计价(生产执行)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2017-10-19 09:00:45",
    "monthly_flag": "1",
    "pricing_strategy_id": "6"
  },
  "7": {
    "en_name": "ERP_PRICING_STRATEGY_FINANCE",
    "ch_name": "包月计价(财务管理)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2017-10-19 09:00:45",
    "monthly_flag": "1",
    "pricing_strategy_id": "7"
  },
  "8": {
    "en_name": "ERP_PRICING_STRATEGY_STORAGE",
    "ch_name": "包月计价(仓库管理)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2017-10-19 09:00:45",
    "monthly_flag": "1",
    "pricing_strategy_id": "8"
  },
  "9": {
    "en_name": "ERP_PRICING_STRATEGY_STAFF",
    "ch_name": "包月计价(员工管理)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2018-08-08 10:06:53",
    "monthly_flag": "0",
    "pricing_strategy_id": "9"
  },
  "10": {
    "en_name": "ERP_PRICING_STRATEGY_KAILIAO",
    "ch_name": "包月计价(WEB开料)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2018-08-23 17:37:14",
    "monthly_flag": "1",
    "pricing_strategy_id": "10"
  },
  "11": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ZONE_1",
    "ch_name": "1G扩展包",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 20, "discount": 0},
      "2": {"name": "两个月", "price": 40, "discount": 0},
      "3": {"name": "3个月", "price": 60, "discount": 0},
      "4": {"name": "4个月", "price": 80, "discount": 0},
      "5": {"name": "5个月", "price": 100, "discount": 0},
      "6": {"name": "6个月", "price": 120, "discount": 0},
      "7": {"name": "7个月", "price": 140, "discount": 0},
      "8": {"name": "8个月", "price": 160, "discount": 0},
      "9": {"name": "9个月", "price": 180, "discount": 0},
      "10": {"name": "10个月", "price": 200, "discount": 0},
      "12": {"name": "一年", "price": 200, "discount": 40},
      "24": {"name": "两年", "price": 400, "discount": 80},
      "36": {"name": "三年", "price": 600, "discount": 120}
    },
    "limit_fee": "1.00",
    "create_date": "2019-07-01 17:57:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "11"
  },
  "12": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ZONE_5",
    "ch_name": "5G扩展包",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "5.00",
    "create_date": "2019-07-01 17:57:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "12"
  },
  "13": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ZONE_10",
    "ch_name": "10G扩展包",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 200, "discount": 0},
      "2": {"name": "两个月", "price": 400, "discount": 0},
      "3": {"name": "3个月", "price": 600, "discount": 0},
      "4": {"name": "4个月", "price": 800, "discount": 0},
      "5": {"name": "5个月", "price": 1000, "discount": 0},
      "6": {"name": "6个月", "price": 1200, "discount": 0},
      "7": {"name": "7个月", "price": 1400, "discount": 0},
      "8": {"name": "8个月", "price": 1600, "discount": 0},
      "9": {"name": "9个月", "price": 1800, "discount": 0},
      "10": {"name": "10个月", "price": 2000, "discount": 0},
      "12": {"name": "一年", "price": 2000, "discount": 400},
      "24": {"name": "两年", "price": 4000, "discount": 800},
      "36": {"name": "三年", "price": 6000, "discount": 1200}
    },
    "limit_fee": "10.00",
    "create_date": "2019-07-01 17:57:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "13"
  },
  "14": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ZONE_20",
    "ch_name": "20G扩展包",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 400, "discount": 0},
      "2": {"name": "两个月", "price": 800, "discount": 0},
      "3": {"name": "3个月", "price": 1200, "discount": 0},
      "4": {"name": "4个月", "price": 1600, "discount": 0},
      "5": {"name": "5个月", "price": 2000, "discount": 0},
      "6": {"name": "6个月", "price": 2400, "discount": 0},
      "7": {"name": "7个月", "price": 2800, "discount": 0},
      "8": {"name": "8个月", "price": 3200, "discount": 0},
      "9": {"name": "9个月", "price": 3600, "discount": 0},
      "10": {"name": "10个月", "price": 4000, "discount": 0},
      "12": {"name": "一年", "price": 4000, "discount": 800},
      "24": {"name": "两年", "price": 8000, "discount": 1600},
      "36": {"name": "三年", "price": 12000, "discount": 2400}
    },
    "limit_fee": "20.00",
    "create_date": "2019-07-01 17:57:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "14"
  },
  "15": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ZONE_50",
    "ch_name": "50G扩展包",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 1000, "discount": 0},
      "2": {"name": "两个月", "price": 2000, "discount": 0},
      "3": {"name": "3个月", "price": 3000, "discount": 0},
      "4": {"name": "4个月", "price": 4000, "discount": 0},
      "5": {"name": "5个月", "price": 5000, "discount": 0},
      "6": {"name": "6个月", "price": 6000, "discount": 0},
      "7": {"name": "7个月", "price": 7000, "discount": 0},
      "8": {"name": "8个月", "price": 8000, "discount": 0},
      "9": {"name": "9个月", "price": 9000, "discount": 0},
      "10": {"name": "10个月", "price": 10000, "discount": 0},
      "12": {"name": "一年", "price": 10000, "discount": 2000},
      "24": {"name": "两年", "price": 20000, "discount": 4000},
      "36": {"name": "三年", "price": 30000, "discount": 6000}
    },
    "limit_fee": "50.00",
    "create_date": "2019-07-01 17:57:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "15"
  },
  "16": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ZONE_100",
    "ch_name": "100G扩展包",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 2000, "discount": 0},
      "2": {"name": "两个月", "price": 4000, "discount": 0},
      "3": {"name": "3个月", "price": 6000, "discount": 0},
      "4": {"name": "4个月", "price": 8000, "discount": 0},
      "5": {"name": "5个月", "price": 10000, "discount": 0},
      "6": {"name": "6个月", "price": 12000, "discount": 0},
      "7": {"name": "7个月", "price": 14000, "discount": 0},
      "8": {"name": "8个月", "price": 16000, "discount": 0},
      "9": {"name": "9个月", "price": 18000, "discount": 0},
      "10": {"name": "10个月", "price": 20000, "discount": 0},
      "12": {"name": "一年", "price": 20000, "discount": 4000},
      "24": {"name": "两年", "price": 40000, "discount": 8000},
      "36": {"name": "三年", "price": 60000, "discount": 12000}
    },
    "limit_fee": "100.00",
    "create_date": "2019-07-01 17:57:12",
    "monthly_flag": "1",
    "pricing_strategy_id": "16"
  },
  "17": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD",
    "ch_name": "包月计价(CAD-Web端)",
    "pricing_strategy": {
      "1": {"name": "1个月", "price": 100, "discount": 0},
      "2": {"name": "两个月", "price": 200, "discount": 0},
      "3": {"name": "3个月", "price": 300, "discount": 0},
      "4": {"name": "4个月", "price": 400, "discount": 0},
      "5": {"name": "5个月", "price": 500, "discount": 0},
      "6": {"name": "6个月", "price": 600, "discount": 0},
      "7": {"name": "7个月", "price": 700, "discount": 0},
      "8": {"name": "8个月", "price": 800, "discount": 0},
      "9": {"name": "9个月", "price": 900, "discount": 0},
      "10": {"name": "10个月", "price": 1000, "discount": 0},
      "12": {"name": "一年", "price": 1000, "discount": 200},
      "24": {"name": "两年", "price": 2000, "discount": 400},
      "36": {"name": "三年", "price": 3000, "discount": 600}
    },
    "limit_fee": "0.00",
    "create_date": "2019-07-08 09:09:50",
    "monthly_flag": "1",
    "pricing_strategy_id": "17"
  },
  "18": {
    "en_name": "ERP_PRICING_STRATEGY_WEBCAD_ADDED_PRO",
    "ch_name": "单机生产(WebCAD)",
    "pricing_strategy": {
      "600": {"name": "终身买断", "price": 9800, "discount": 10200}
    },
    "limit_fee": "0.00",
    "create_date": "2019-07-18 10:27:51",
    "monthly_flag": "1",
    "pricing_strategy_id": "18"
  }
};

Map unit = {
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

Map pricingClass = {
  "1": {
    "class_id": "1",
    "business_type": "1",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_DESIGN_SOFTWARE",
    "class_ch_name": "设计软件(客户端)",
    "added_service": "0",
    "pricing_strategy_ids": "[3,4]",
    "pre_class_id": "0",
    "sort": "0",
    "state": "1",
    "comments": null
  },
  "2": {
    "class_id": "2",
    "business_type": "1",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_CLOUD_BILL",
    "class_ch_name": "云拆单",
    "added_service": "0",
    "pricing_strategy_ids": "[1,2,3]",
    "pre_class_id": "0",
    "sort": "0",
    "state": "1",
    "comments": null
  },
  "3": {
    "class_id": "3",
    "business_type": "2",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_ERP_WX_MSG",
    "class_ch_name": "微信推送",
    "added_service": "1",
    "pricing_strategy_ids": "[5]",
    "pre_class_id": "0",
    "sort": "1",
    "state": "1",
    "comments": "新增订单，订单流程变更相关的微信公众号消息推送服务"
  },
  "4": {
    "class_id": "4",
    "business_type": "1",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_ERP_PROCESS",
    "class_ch_name": "生产执行",
    "added_service": "1",
    "pricing_strategy_ids": "[6]",
    "pre_class_id": "0",
    "sort": "2",
    "state": "1",
    "comments": "生产执行管理增值包服务"
  },
  "5": {
    "class_id": "5",
    "business_type": "2",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_ERP_FINANCE",
    "class_ch_name": "财务管理",
    "added_service": "1",
    "pricing_strategy_ids": "[7]",
    "pre_class_id": "0",
    "sort": "3",
    "state": "1",
    "comments": "财务管理增值包服务"
  },
  "6": {
    "class_id": "6",
    "business_type": "1",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_ERP_STORAGE",
    "class_ch_name": "仓库管理",
    "added_service": "1",
    "pricing_strategy_ids": "[8]",
    "pre_class_id": "0",
    "sort": "4",
    "state": "1",
    "comments": "仓库管理增值包服务"
  },
  "8": {
    "class_id": "8",
    "business_type": "1",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_KAILIAO",
    "class_ch_name": "WEB开料",
    "added_service": "1",
    "pricing_strategy_ids": "[10]",
    "pre_class_id": "0",
    "sort": "5",
    "state": "1",
    "comments": "WEB开料"
  },
  "9": {
    "class_id": "9",
    "business_type": "4",
    "mutex_type": "2",
    "class_en_name": "PRICING_CLASS_WEBCAD_ZONE",
    "class_ch_name": "WebCAD云盘",
    "added_service": "1",
    "pricing_strategy_ids": "[11,12,13,14,15,16]",
    "pre_class_id": "0",
    "sort": "6",
    "state": "1",
    "comments": "开通WebCAD云盘存储空间包"
  },
  "10": {
    "class_id": "10",
    "business_type": "4",
    "mutex_type": "1",
    "class_en_name": "PRICING_CLASS_WEBCAD",
    "class_ch_name": "设计软件(Web端)",
    "added_service": "0",
    "pricing_strategy_ids": "[17]",
    "pre_class_id": "0",
    "sort": "0",
    "state": "1",
    "comments": "开通WebCAD登录及拆单"
  },
  "11": {
    "class_id": "11",
    "business_type": "4",
    "mutex_type": "2",
    "class_en_name": "PRICING_CLASS_WEBCAD_ADDED",
    "class_ch_name": "增值包(WebCAD)",
    "added_service": "1",
    "pricing_strategy_ids": "[18]",
    "pre_class_id": "0",
    "sort": "7",
    "state": "1",
    "comments": "开通WebCAD相关增值包服务"
  }
};

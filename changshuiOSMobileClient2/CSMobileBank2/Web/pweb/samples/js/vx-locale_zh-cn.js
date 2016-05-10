/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/

(function() {
	var locales = {};
	vx.module("vLocale", []).value('$locale', locales);

	locales.id = "zh-cn";

	// data-time formats
	locales.DATETIME_FORMATS = {
		"TITLE" : ["年", "月", "日"],
		"MONTH" : ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
		"SHORTMONTH" : ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
		"DAY" : ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
		"SHORTDAY" : ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
		"AMPMS" : ["上午", "下午"],
		"medium" : "yyyy-M-d ah:mm:ss",
		"short" : "yy-M-d ah:mm",
		"fullDate" : "y年M月d日EEEE",
		"longDate" : "y年M月d日",
		"mediumDate" : "yyyy-M-d",
		"shortDate" : "yy-M-d",
		"mediumTime" : "ah:mm:ss",
		"shortTime" : "ah:mm"
	};

	// number formats
	locales.NUMBER_FORMATS = {
		"DECIMAL_SEP" : ".",
		"GROUP_SEP" : ",",
		"PATTERNS" : [{
			"minInt" : 1,
			"minFrac" : 0,
			"maxFrac" : 3,
			"posPre" : "",
			"posSuf" : "",
			"negPre" : "-",
			"negSuf" : "",
			"gSize" : 3,
			"lgSize" : 3
		}, {
			"minInt" : 1,
			"minFrac" : 2,
			"maxFrac" : 2,
			"posPre" : "\u00A4",
			"posSuf" : "",
			"negPre" : "\u00A4-",
			"negSuf" : "",
			"gSize" : 3,
			"lgSize" : 3
		}],
		"CURRENCY_SYM" : "¥"
	};
	
	locales.LimiteTime = {
		"SMSTime": 59,
		"PasswordTime": 60,
		"PasswordTime1": 120
	};

	var fields = {}, messages = {};
	locales.FIELDS = fields;
	locales.MESSAGES = messages;
	messages['uibs.both_user_and_bankid_is_null'] = '登录超时';

	
	messages.defaultLanguage={
		"Language" : "zh_CN"
	};
})();

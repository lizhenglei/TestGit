/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
/**
 * @author
 * filter template
 */

(function(window, vx) {'use strict';
	/**
	 * 乐盈宝交易类型滤器（仅适用于常熟农商-乐盈宝交易查询）
	 */
	function lybTransClassFilter(){
		return function(input){
			var newchar;
			if(input==0){
				newchar="转入";
			}else if(input==1){
				newchar="转出";
			}else if(input==2){
				newchar="分红";
			}else{
				newchar="全部";
			}
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('lybTransClassFilter', lybTransClassFilter);
	
	/**
	 * 天天利交易类型滤器（仅适用于常熟农商-天天利交易查询）
	 */
	function ttlTransClassFilter(){
		return function(input){
			var newchar;
			if(input==12||input==22){
				newchar="购买";
			}else if(input==11||input==21){
				newchar="撤销";
			}else if(input==30){
				newchar="赎回";
			}else if(input==42){
				newchar="结息";
			}
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('ttlTransClassFilter', ttlTransClassFilter);
	/**
	 * 理财产品状态过滤器（仅适用于常熟农商-天天利理财）
	 */
	function ttstatusFilter(){
		return function(input){
			var newchar;
			if(input==0){
				newchar="募集";
			}else if(input==1){
				newchar="开放";
			}else if(input==2){
				newchar="关闭/撤销";
			}else{
				newchar="";
			}
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('ttstatusFilter', ttstatusFilter);
	/**
	 * 理财产品状态过滤器（仅适用于常熟农商-粒金理财）
	 */
	function statusFilter(){
		return function(input){
			var newchar;
			if(input==0){
				newchar="开放期";
			}else if(input==1){
				newchar="募集期";
			}else if(input==2){
				newchar="发行成功";
			}else if(input=='a'){
				newchar="产品终止";
			}else{
				newchar="";
			}
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('statusFilter', statusFilter);
	/**
	 * 风险等级过滤器（仅适用于常熟农商）
	 */
	function riskFilter(){
		return function(input){
			var newchar;
			if(input==0){
				newchar="未评定";
			}else if(input==1){
				newchar="保守型";
			}else if(input==2){
				newchar="谨慎型";
			}else if(input==3){
				newchar="稳健型";
			}else if(input==4){
				newchar="进取型";
			}else if(input==5){
				newchar="积极进取型";
			}else{
				newchar="";
			}
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('riskFilter', riskFilter);
	/**
	 * 天天利产品查询，保本型标志0-是，其他-不是
	 */
	function IsBBXFilter(){
			return function(input){
				if(input !== undefined){
					if(input==0){
						return "保守型";
					}else{
						return "非保守型";
					}
				}
				return input;
			}
		}
	vx.module('ui.libraries').filter('IsBBXFilter', IsBBXFilter);
	/**
	 * 基金分类过滤器（仅适用于常熟农商）
	 */
	function financFilter(){
		return function(input){
			var newchar;
			if(input==0){
				newchar="基金";
			}else if(input==1){
				newchar="行内理财";
			}else if(input==2){
				newchar="境外理财产品";
			}else{
				newchar="";
			}
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('financFilter', financFilter);
	/**
	 * 获取后四位
	 */
	function getTail(){
		return function(input){
			var newchar=input.substring(input.length-4);
			return newchar;
		}
	}
	vx.module('ui.libraries').filter('getTail', getTail);
	/**
	 * 过滤器，四位加空格
	 */
	function accountNo() {
		return function(input) {
			if(input)
				return input.replace(/(.{4})/g,"$1 ");
			else
				return "--";
		};
	}

	vx.module('ui.libraries').filter('accountNo', accountNo);
	/**
	 * 过滤器，三位加逗号
	 */
//	function numberNo() {
//		return function(input) {
//			if(input){
//				input=input.substring(0,input.indexOf(".")-1);
//				var i=(input.length)%3;
//				for(i;i<input.length;i+3){
//					if(i!=0){
//						input=input.substring(0,i)+","+input.substring()
//					}
//				}
//				return input;
//			}
//			else{
//				return "--";
//			}
//		};
//	}
//
//	vx.module('ui.libraries').filter('numberNo', numberNo);
	/**
	 * 
	 */
	function accountStar() {
		return function(input) {
			if(input)
				if(input.length<18){
					return input;
				}else{
					return input.substr(0,17)+".....";
				}
			else
				return "--";
		};
	}

	vx.module('ui.libraries').filter('accountStar', accountStar);
	/**
	 * @author
	 * filter template
	 * 大写金额转换
	 */
	function amount() {
		return function(input) {
			if (input) {
				var strOutput = "", strUnit = '仟佰拾亿仟佰拾万仟佰拾元角分';
				input += "00";
				input = input.replace(/,/g,'');
				var intPos = input.indexOf('.');
				if (intPos >= 0){
					input = input.substring(0, intPos) + input.substr(intPos + 1, 2);
				}
				input = parseFloat(input).toString();
				strUnit = strUnit.substr(strUnit.length - input.length);
				for (var i = 0; i < input.length; i++) {
					strOutput += '零壹贰叁肆伍陆柒捌玖'.substr(input.substr(i, 1), 1) + strUnit.substr(i, 1);
				}
				return strOutput.replace(/^零角零分$/, '')
						.replace(/零角零分$/, '整')
						.replace(/^零元零角/, '')
						.replace(/零[仟佰拾]/g, '零')
						.replace(/零{2,}/g, '零')
						.replace(/零([亿|万])/g, '$1')
						.replace(/零+元/, '元')
						.replace(/亿零{0,3}万/, '亿')
						.replace(/^元/, "零元")
						.replace(/零角/, '零')
						.replace(/零元/, '')
						.replace(/零分$/,"")
						.replace(/^整$/,"零元整");
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('amount', amount);

	/**
	 * @author
	 * filter 加密账号    1234****5678
	 */
	function encryptAcNo() {
		return function(input,param) {
			if(input !== undefined){
				if(param){
					return input.substring(0,4)+"***********"+ input.substring(input.length-4);
				}else{
					return input.substring(0,4) + "****" + input.substring(input.length-4);
				}
				
			}
				
		}
	}

	vx.module('ui.libraries').filter('encryptAcNo', encryptAcNo);
	/*
	 * 账号加密  4个****
	 */
	function encryptAcNof() {
		return function(input) {
			if(input !== undefined){
					return input.substring(0,3)+"****"+ input.substring(input.length-4);
			}
				
		}
	}

	
	vx.module('ui.libraries').filter('encryptAcNof', encryptAcNof);
	/*
	 * 格式化日期: yyyy-mm-dd
	 */
	function formatDate() {
		return function(input) {
			if(input !== undefined){
				var y=input.substr(0,4);
				var m=input.substr(4,2);
				var date=y+"-"+m+"-"+input.substr(6,2);
				return date;
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatDate', formatDate);
	
	/*
	 * 格式化日期：yyyy.mm.dd
	 */
	function formatDatept() {
		return function(input) {
			if(input !== undefined){
				var y=input.substr(0,4);
				var m=input.substr(4,2);
				var date=y+"."+m+"."+input.substr(6,2);
				return date;
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatDatept', formatDatept);
	
	/*
	 * 格式化日期：yyyy.mm
	 */
	function yymmDate() {
		return function(input) {
			if(input !== undefined){
				var y=input.substr(0,4);
				var m=input.substr(4,2);
				var date=y+"."+m;
				return date;
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('yymmDate', yymmDate);
	
	/*
	 * 格式化日期: yyyy年mm月dd日
	 */

	function formatDateLocal() {
		return function(input) {
			if(input !== undefined){
				return input.replace("-","年").replace("-","月") + "日";
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatDateLocal', formatDateLocal);
	
	/*
	 * 格式化日期: yy年mm月
	 */
	function formatShortDate() {
		return function(input) {
			if(input !== undefined){
				var y=input.substr(0,2);
				var m=input.substr(2,2);
				var date=y+"年"+m+"月";
				return date;
			}
			return input;
		};
	}
	
	vx.module('ui.libraries').filter('formatShortDate', formatShortDate);
	/*
	 * 格式化日期: yyyymmdd
	 */
	
	function formatDateShort() {
		return function(input) {
			if(input !== undefined){
				return input.replace(/\-/g,"");
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatDateShort', formatDateShort);
	
	/*
	 * 格式化日期: yyyy-mm-dd hh:mm:ss
	 */
	
	function formatDateTime() {
		return function(input) {
			if(input !== undefined){
				var Y=input.substr(0,4);
				var M=input.substr(4,2);
				var D=input.substr(6,2);
				var h=input.substr(8,2);
				var m=input.substr(10,2);
				var date=Y+"-"+M+"-"+D+" "+h+":"+m;
				return date;
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatDateTime', formatDateTime);

	/*
	 * 格式化日期: yyyy-mm-dd
	 */
	function formatDate1() {
		return function(input) {
			if(input !== undefined){
				return input.substr(0,10);
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatDate1', formatDate1);


	function RolloverFlag() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '自动转存';
				}
				if(input == '0'){
					return '不转存';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('RolloverFlag', RolloverFlag);
	
	function ActivityPay() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '未付款';
				}
				else if(input == '1'){
					return '已付款';
				}
				else if(input=='2')
				{
					return '关闭';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('ActivityPay', ActivityPay);

	function RollProfile() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '本息转存';
				}
				if(input == '2'){
					return '本金转存利息转活期';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('RollProfile', RollProfile);
	
	function BusinessType() {
		return function(input) {
			if(input !== undefined){
				if(input == '8000'){
					return '余额变动(无余额)';
				}
				if(input == '8001'){
					return '余额变动(带余额)';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('BusinessType', BusinessType);
	
	function SMSSignFlag() {
		return function(input) {
			if(input !== undefined){
				if(input == 'Y'){
					return '已签约';
				}
				if(input == 'N'){
					return '未签约';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('SMSSignFlag', SMSSignFlag);
	
	function ZFBSignFlag() {
		return function(input) {
			if(input !== undefined){
				if(input == 'X'){
					return '未签约';
				}
				if(input == '0'){
					return '正常';
				}
				if(input == '9'){
					return '开通';
				}				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('ZFBSignFlag', ZFBSignFlag);	

	function YINLIANSignFlag() {
		return function(input) {
			if(input !== undefined){
				if(input == 'X'){
					return '未签约';
				}				
				if(input == '1'){
					return '开通';
				}
				if(input == '2'){
					return '关闭';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('YINLIANSignFlag', YINLIANSignFlag);	
	
	function PersonPaySignFlag() {
		return function(input) {
			if(input !== undefined){
				if(input == 'X'){
					return '未签约';
				}				
				if(input == '0'){
					return '已签约';
				}
				if(input == '1'){
					return '已解约';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('PersonPaySignFlag', PersonPaySignFlag);	
	
	//Term
	function Term() {
		return function(input) {
			if(input !== undefined){
				switch(input){
				case 'M3': 
					return '整存整取三个月';
				case 'M6': 
					return '整存整取六个月';
				case 'Y1': 
					return '整存整取一年';
				case 'Y2': 
					return '整存整取二年';
				case 'Y3': 
					return '整存整取三年';
				case 'Y5': 
					return '整存整取五年';
				default:;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('Term', Term);
	
	function TotalTimes() {
		return function(input) {
			if(input !== undefined){
				switch(input){
				case '': 
					return '无限次';
				case '1': 
					return '1';
				case '2': 
					return '2';
				case '3': 
					return '3';
				case '4': 
					return '4';
				case '5': 
					return '5';
				case '6': 
					return '6';
				default:
					return input;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('TotalTimes', TotalTimes);

	function PayeeSysFlagName() {
		return function(input) {
			if(input !== undefined){
				switch(input){
				case 'P': 
					return '实时跨行转账';
				case 'I': 
					return '行内转账';
				case 'C': 
					return '行外转账';
				case 'A': 
					return '全部';
				default:;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('PayeeSysFlagName', PayeeSysFlagName);
	
	//巨额赎回方式过滤器
	function LargRedFlagFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '下一工作日赎回';
				}
				if(input == '0'){
					return '取消赎回';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('LargRedFlagFilter', LargRedFlagFilter);


	//基金分红方式过滤器
	function DivModeFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '现金分红';
				}
				if(input == '0'){
					return '红利再投资';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('DivModeFilter', DivModeFilter);

	//基金状态（Status）过滤器
	function FundStatusFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '开放期';
				}
				if(input == '1'){
					return '募集期';
				}
				if(input == '2'){
					return '发行成功';
				}
				if(input == '3'){
					return '发行失败';
				}
				if(input == '4'){
					return '停止交易';
				}
				if(input == '5'){
					return '停止申购';
				}
				if(input == '6'){
					return '停止赎回';
				}
				if(input == '7'){
					return '权益登记';
				}
				if(input == '8'){
					return '红利发放';
				}
				if(input == '9'){
					return '产品封闭';
				}
				if(input == 'a'){
					return '产品终止';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('FundStatusFilter', FundStatusFilter);

	//定投终止模式过滤器
	function OverFlagFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '投资期数';
				}
				if(input == '1'){
					return '结束日期';
				}
				if(input == '2'){
					return '成功期数';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('OverFlagFilter', OverFlagFilter);

	//贵金属签约/签约，未签约/过滤器
	function paperGoldFlagFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '已签约';
				}
				if(input == '0'){
					return '未签约';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('paperGoldFlagFilter', paperGoldFlagFilter);
	
	//贵金属风险评估
	function RisklevelFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '谨慎型';
				}
				if(input == '2'){
					return '稳健型';
				}
				if(input == '3'){
					return '平衡型';
				}
				if(input == '4'){
					return '进取型';
				}
				if(input == '5'){
					return '激进型';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('RisklevelFilter', RisklevelFilter);

	//定投投资周期
	function PeriodFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '月';
				}
				if(input == '1'){
					return '周';
				}
				if(input == '2'){
					return '日';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('PeriodFilter', PeriodFilter);

	//智能定投模式
	function IvtModelFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '推荐模式';
				}
				if(input == '1'){
					return '自定义';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('IvtModelFilter', IvtModelFilter);

	//取小数点后三位
	function FloatNum(){
		return function(input) {
			if(input !== undefined){
				return  parseFloat(input).toFixed(3);
			}
		}
	}
	vx.module('ui.libraries').filter('FloatNum', FloatNum);
	//取小数点后俩位
	function FloatTwo(){
		return function(input) {
			if(input !== undefined){
				return  parseFloat(input).toFixed(2);
			}
		}
	}
	vx.module('ui.libraries').filter('FloatTwo', FloatTwo);
	//只取小数点后俩位
	function FloatOnlyTwo(){
		return function(input) {
			if(input !== undefined){
				return  parseInt(input*100)/100;
			}
		}
	}
	vx.module('ui.libraries').filter('FloatOnlyTwo', FloatOnlyTwo);
	//常熟农商货币类型
	function CurrenyFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return 'CNY';
				}
				if(input == '01'){
					return '人民币';
				}
				if(input == '12'){
					return '英镑';
				}
				if(input == '13'){
					return '港币';
				}
				if(input == '14'){
					return '美元';
				}
				if(input == '27'){
					return '日元';
				}
				if(input == '29'){
					return '澳大利亚元';
				}
				if(input == '38'){
					return '欧元';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('CurrenyFilter', CurrenyFilter);

	//纸黄金 白银GOLD
	function twoGoldFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '人民币纸黄金';
				}
				if(input == '1'){
					return '人民币纸白银';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('twoGoldFilter', twoGoldFilter);
	
	//纸黄金  最多  买入或者最多卖出
	function moreBuyTypeFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '00'){
					return '最多买入';
				}
				if(input == '11'){
					return '最多卖出';
				}
				if(input == '0'){
					return '买入';
				}
				if(input == '1'){
					return '卖出';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('moreBuyTypeFilter', moreBuyTypeFilter);

	//纸黄金  最多  买入或者最多卖出
	function AgencyTrsFilter() {
		return function(input) {
			if(input !== undefined){
				
				if(input == '1'){
					return '盈利委托';
				}
				if(input == '2'){
					return '止损委托';
				}
				if(input == '3'){
					return '双重委托';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('AgencyTrsFilter', AgencyTrsFilter);
	
	//纸黄金涨跌幅
	function RateRFlagFilter() {
		return function(input) {
			if(input !== undefined){
				
				if(input == '0'){
					return '↓';
				}
				if(input == '1'){
					return '↑';
				}
				if(input == '2'){
					return '↔';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('RateRFlagFilter', RateRFlagFilter);

	//贵金属成交方式
	function TransTypeFilter() {
		return function(input) {
			if(input !== undefined){
				
				if(input == '0'){
					return '即时交易';
				}
				if(input == '1'){
					return '委托交易';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('TransTypeFilter', TransTypeFilter);

	//贵金属交易渠道
	function ChanelFilter() {
		return function(input) {
			if(input !== undefined){
				
				if(input == '16'){
					return '电话银行';
				}
				if(input == '17'){
					return '网上银行';
				}
				if(input == '48'){
					return '手机银行';
				}
				if(input == '18'){
					return '手机银行(wap)';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('ChanelFilter', ChanelFilter);

	//盈利止损委托价格
	function RateFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == ""){
					return '--';
				}
			}
			return input+" CNY";
		};
	}
	vx.module('ui.libraries').filter('RateFilter', RateFilter);
	
	//当前委托撤销，交易渠道ChannelFilter
	function ChannelFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '柜台交易';
				}
				if(input == '1'){
					return '网上银行';
				}
				if(input == '2'){
					return '自助查询终端';
				}
				if(input == '3'){
					return '电话银行';
				}
				if(input == '4'){
					return 'ATM';
				}
				if(input == '5'){
					return 'TA发起 ';
				}
				if(input == '6'){
					return '低柜';
				}
				if(input == '7'){
					return '手机银行';
				}
				if(input == '9'){
					return '基金管理台';
				}
				
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('ChannelFilter', ChannelFilter);
	
	//交易明细查询结果页
	function PayMoneyFilter() {
		return function(input) {
				if(input!==undefined){
					if(input.indexOf('-')>-1){
						return input.replace('-','');;
					}else{
						return input;
					}
				}else{
					return input;
				}
			}				
		};
	vx.module('ui.libraries').filter('PayMoneyFilter', PayMoneyFilter);
	
	/**
	 * 转账模式
	 */
	function TrsWayFilter() {
		return function(input) {
			switch(input){
				case "1": return "最快";
				case "2": return "最省";
				default: return input;
			}
		};				
	}
	vx.module('ui.libraries').filter('TrsWayFilter', TrsWayFilter);
	
	/**
	 * 定时频率
	 */
	function ScheduleTypeFilter() {
		return function(input) {
			switch(input){
				case "D": return "按日";
				case "W": return "按周";
				case "M": return "按月";
				default: return input;
			}
		};				
	}
	vx.module('ui.libraries').filter('ScheduleType', ScheduleTypeFilter);
	
	/**
	 *省市联动 
	 */
	function shengFilter(){
		return function(data,parent){
			var filterData=[];
			vx.forEach(data,function(obj){
				if(obj.parent===parent){
					filterData.push(obj);
				}
			});
			return filterData;
		}
	}
	vx.module('ui.libraries').filter('shengFilter', shengFilter);
	/**
	 *产品按品牌分类
	 */
	function fenleiFilter() {
		return function(input,param) {
			if(input !== undefined) {
				var filterData = [];
				vx.forEach(input,function(obj) {
					if(obj.templatetypename == param) {
						filterData.push(obj);
					}
				});
				return filterData;
			}
		};
	}
	vx.module('ui.libraries').filter('fenleiFilter', fenleiFilter);
	
	//发货状态，已发货/过滤器
	function goodsFlagFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '1'){
					return '成功';
				}
				if(input == '0'){
					return '失败';
				}
				if(input == '2'){
					return '已提交'
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('goodsFlagFilter', goodsFlagFilter);
	
	/**
	 *值为null，返回0
	 */
	function checkValueFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == null){
					return 0;
				}else {
					return input;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('checkValueFilter', checkValueFilter);
	
	/*
	 * 格式化时间: hh-mm-ss
	 */
	function formatTime() {
		return function(input) {
			if(input !== undefined){
				if(input==""){
					var time=""
					return time;
				}else{
					var y=input.substr(0,2);
					var m=input.substr(2,2);
					var time=y+":"+m+":"+input.substr(4,2);
					return time;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('formatTime', formatTime);
	
	/**
	 *值为null，返回--
	 */
	function noCharFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == ""){
					return "--";
				}else {
					return input;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('noCharFilter', noCharFilter);
	/**
	 *账单交易类型，返回--
	 */
	function BillTransType() {
		return function(input) {
			if(input !== undefined){
				if(input == "FEE"){
					return "费用交易";
				}else if(input == "BDT"){
					return "坏账处理";
				}else if(input == "PMT"){
					return "还款交易";
				}else if(input == "INT"){
					return "利息交易";
				}else if(input == "CSH"){
					return "取现交易";
				}else if(input == "RET"){
					return "消费交易";
				}else if(input == "EXP"){
					return "异常交易";
				}else if(input == "IPP"){
					return "分期交易";
				}else if(input == "CSM"){
					return "卡服务";
				}else if(input == "MNT"){
					return "卡维护";
				}else{
					return input;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('BillTransType', BillTransType);
	/**
	 *账户状态：正常、挂失或者未激活3种
	 */
	function AccStateFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == "0"){
					return "正常";
				}else if(input == "6"){
					return "挂失";
				}else if(input == "A"){
					return "未激活";
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('AccStateFilter', AccStateFilter);
	
	//信用卡账单寄送方式，LT-纸质账单，EM-电子账单
	function BillStmCodeFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == 'LT'){
					return '纸质账单';
				}
				if(input == 'EM'){
					return '电子账单';
				}
				if(input == 'LE'){
					return '纸质账单和电子账单';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('BillStmCodeFilter', BillStmCodeFilter);
	
	//信用卡自动还款方式，T-全额，M-最低还款额
	function repayCodeFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == 'T'){
					return '全额还款';
				}
				if(input == 'M'){
					return '最低额还款';
				}
				if(input == ''){
					return '未设置';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('repayCodeFilter', repayCodeFilter);
	
	//粒金理财产品类别，0 :基金,1 :国内理财,2 :境外理财产品
	function LJPrdTypeFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == '0'){
					return '基金';
				}
				if(input == '1'){
					return '国内理财';
				}
				if(input == '2'){
					return '境外理财产品';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('LJPrdTypeFilter', LJPrdTypeFilter);
	
	//粒金理财产品投资期限单位转化，D:天,M:月,Y:年
	function LJDateUnitFilter() {
		return function(input) {
			if(input !== undefined){
				if(input == 'D'){
					return '天';
				}
				if(input == 'M'){
					return '月';
				}
				if(input == 'Y'){
					return '年';
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('LJDateUnitFilter', LJDateUnitFilter);
	
	//为交易明细的金额添加正负符号：+、-;若param为真，添加正号，反之为负
	function AddFlagFilter() {
		return function(input,param) {
			if(input !== undefined){
				if(param == true){
					return "+"+input;
				}
				if(param == false){
					return "-"+input;
				}
			}
			return input;
		};
	}
	vx.module('ui.libraries').filter('AddFlagFilter', AddFlagFilter);
	
	/*
	 * 中文含义粒金理财“投资期限单位”，                          D:天，M:月，Y:年
	 */
	function investTermUnit(){
		return function(input) {
			if(input !== undefined){
				if(input=="D"){
					return "天";
				}else if(input=="M"){
					return "月";
				}else if(input=="Y"){
					return "年";
				}
			}
			return input;
		};
		
	}
	vx.module('ui.libraries').filter('investTermUnit', investTermUnit);
})(window, window.vx);

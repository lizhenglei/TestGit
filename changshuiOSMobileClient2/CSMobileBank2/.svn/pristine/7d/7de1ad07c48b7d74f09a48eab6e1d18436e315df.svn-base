/**
 * @author kongxiangxu
 */
(function(window, vx, undefined) {'use strict';

	var service = {};
	service.Util = ['$filter',
	function($filter) {
		return {
			/**
	         * description:还回时间格式类似为"2012-05-16"字符串, format指定字符串格式， 默认yyyy-MM-dd。
	         * example:getDate()还回当前时间的，getDate("3d")三天前时间，getDate("3w")三周前的，getDate("3m")三个月前的
	         * getDate("-3d")三天后时间，getDate("-3w")三周后的时间，getDate("-3m")三个月后的时间
	         */
			getDate : function(days, format) {
				// TODO 添加函数过程
				format = format || 'yyyy-MM-dd';
				if (days) {
					var group = days.match(/(\d+)([dDMmWw])/);
					var value = group[1], type = group[2].toUpperCase();
					if(days.match(/^-/)!=null){
						if (type === 'D')
							return $filter('date')(new Date(new Date().getTime() + (value * 24 * 3600 * 1000)), format);
						else if (type === 'W')
							return $filter('date')(new Date(new Date().getTime() + (value * 7 * 24 * 3600 * 1000)), format);
						else if (type === 'M') {
							var date = new Date();
							date.setMonth(date.getMonth() + parseInt(value));
							return $filter('date')(date, format);
						}
					} 
					if (type === 'D')
						return $filter('date')(new Date(new Date().getTime() - (value * 24 * 3600 * 1000)), format);
					else if (type === 'W')
						return $filter('date')(new Date(new Date().getTime() - (value * 7 * 24 * 3600 * 1000)), format);
					else if (type === 'M') {
						var date = new Date();
						date.setMonth(date.getMonth() - value);
						return $filter('date')(date, format);
					}
				} else
					return $filter('date')(new Date(), format);
			},
			getDate1 : function(days, format, sysTimestamp) {
				format = format || 'yyyy-MM-dd';
				var sysDate = sysTimestamp ? new Date(parseInt(sysTimestamp)) : new Date();
				if (days) {
					var group = days.match(/(\d+)([dDMmWw])/);
					var value = group[1], type = group[2].toUpperCase();
					if (type === 'D')
						return $filter('date')(sysDate.setDate(sysDate.getDate() - value), format);
					else if (type === 'W')
						return $filter('date')(sysDate.setDate(sysDate.getDate() - value * 7), format);
					else if (type === 'M') {
						return $filter('date')(sysDate.setMonth(sysDate.getMonth() - value), format);
					}
				} else
					return $filter('date')(sysDate, format);
			},
			/**
			 * 加密账号 加密后形式1234****5678
			 */
			encryptAcNo: function(acno){
				var length = acno.length;
				return acno.substring(0,4) + "****" + acno.substring(length-4, length);
			},
			daysBetween: function(beginDate,endDate){
				var OneMonth = beginDate.substring(5,beginDate.lastIndexOf ('-'));  
				var OneDay = beginDate.substring(beginDate.length,beginDate.lastIndexOf ('-')+1);  
				var OneYear = beginDate.substring(0,beginDate.indexOf ('-'));  
				var TwoMonth = endDate.substring(5,endDate.lastIndexOf ('-'));  
				var TwoDay = endDate.substring(endDate.length,endDate.lastIndexOf ('-')+1);  
				var TwoYear = endDate.substring(0,endDate.indexOf ('-'));  
				var difference=((Date.parse(TwoMonth+'/'+TwoDay+'/'+TwoYear)- Date.parse(OneMonth+'/'+OneDay+'/'+OneYear))/86400000);
				return difference;
			}
		};
	}];

	vx.module('mapp.libraries').service(service);

})(window, window.vx);
/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/

(function(window, vx) {
	'use strict';
	/**
	 * @description 预期年化收益率及其他收益率格式化
	 */
	function rate() {
		return function(input) {
			if (input) {
				return (parseInt(parseFloat(input) * 100000) / 1000).toFixed(3)
						+ "%";
			}
		};
	}
	vx.module('ui.libraries').filter('rate', rate);
})(window, window.vx);
(function(window, vx) {
	'use strict';
	/**
	 * @description 每万份收益，发过来的不到1的数据".4567",格式化显示为"0.4567"
	 */
	function dayRate() {
		return function(input) {
			if (input) {
				if (input.split(".")[0] == "") {
					return "0" + input;
				}
				return input;
			}
		};
	}
	vx.module('ui.libraries').filter('dayRate', dayRate);
})(window, window.vx);
(function(window, vx) {
	'use strict';
	/**
	 * @description 过滤天数，超过一年时显示具体的年数
	 */
	function year() {
		return function(input) {
			if (input) {
				if (input >= 365) {
					var year = parseInt(parseInt(input) / 365);
					return year + "年";
				}
				return input + "天";
			}
		};
	}
	vx.module('ui.libraries').filter('year', year);
})(window, window.vx);

(function(window, vx) {

	'use strict';
	/**
	 * @description 超过万时显示单位为万元
	 */
	wan.$inject = [ '$locale' ];
	function wan($locale) {
		return function(input, param) {
			if (input) {
				if(!param){
					param = 2;
				}
				var formats = $locale.NUMBER_FORMATS;
				if (parseInt(input) / 10000 >= 1) {
					return (input / 10000) + "万";
				} else {
					return formatNumber(input, formats.PATTERNS[0],
							formats.GROUP_SEP, formats.DECIMAL_SEP, param);
				}
			}
		};
	}
	var DECIMAL_SEP = '.';
	function formatNumber(number, pattern, groupSep, decimalSep, fractionSize) {
		if (isNaN(number) || !isFinite(number))
			return '';
		
		var isNegative = number < 0;
		number = Math.abs(number);
		var numStr = number + '', formatedText = '', parts = [];

		var hasExponent = false;
		if (numStr.indexOf('e') !== -1) {
			var match = numStr.match(/([\d\.]+)e(-?)(\d+)/);
			if (match && match[2] == '-' && match[3] > fractionSize + 1) {
				numStr = '0';
			} else {
				formatedText = numStr;
				hasExponent = true;
			}
		}

		if (!hasExponent) {
			var fractionLen = (numStr.split(DECIMAL_SEP)[1] || '').length;

			// determine fractionSize if it is not specified
			if (vx.isUndefined(fractionSize)) {
				fractionSize = Math.min(Math.max(pattern.minFrac, fractionLen),
						pattern.maxFrac);
			}

			var pow = Math.pow(10, fractionSize);
			number = Math.round(number * pow) / pow;
			var fraction = ('' + number).split(DECIMAL_SEP);
			var whole = fraction[0];
			fraction = fraction[1] || '';

			var pos = 0, lgroup = pattern.lgSize, group = pattern.gSize;

			if (whole.length >= (lgroup + group)) {
				pos = whole.length - lgroup;
				for ( var i = 0; i < pos; i++) {
					if ((pos - i) % group === 0 && i !== 0) {
						formatedText += groupSep;
					}
					formatedText += whole.charAt(i);
				}
			}

			for (i = pos; i < whole.length; i++) {
				if ((whole.length - i) % lgroup === 0 && i !== 0) {
					formatedText += groupSep;
				}
				formatedText += whole.charAt(i);
			}

			// format fraction part.
			while (fraction.length < fractionSize) {
				fraction += '0';
			}

			if (fractionSize && fractionSize !== "0")
				formatedText += decimalSep + fraction.substr(0, fractionSize);
		}

		parts.push(isNegative ? pattern.negPre : pattern.posPre);
		parts.push(formatedText);
		parts.push(isNegative ? pattern.negSuf : pattern.posSuf);
		return parts.join('');
	}
	vx.module('ui.libraries').filter('wan', wan);

})(window, window.vx);
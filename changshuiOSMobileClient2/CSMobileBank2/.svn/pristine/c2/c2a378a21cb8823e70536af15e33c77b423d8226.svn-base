/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true */
/**
 * @author liuyoucai
 */

(function(window, vx, undefined) {'use strict';
	/*
	 * [skipAt,skipEndAt) 从 skipAt 开始（包括 skipAt）到 skipEndAt 结束（不包括 skipEndAt）
	 * example:
	 * {{exa|skip:1:2}}
	 */
	var filter = {};
	filter.skipFilter = function() {
		return function(input, skipAt, skipEndAt, appendStr) {
			if (!vx.isArray(input) && !vx.isString(input))
				return input;
			else if (skipEndAt && !appendStr)	
				return input.slice(skipAt, skipEndAt);
			else if (appendStr){
				if(vx.isString(input) && (input.length-1)>skipEndAt){
					return input.slice(skipAt, skipEndAt)+appendStr;
				}else if(vx.isString(input)){
					return input.slice(skipAt, skipEndAt);
				}
			}else
				return input.slice(skipAt);		

		};
	};
	
	vx.module('ui.libraries').filter('skip', filter.skipFilter);

})(window, window.vx);

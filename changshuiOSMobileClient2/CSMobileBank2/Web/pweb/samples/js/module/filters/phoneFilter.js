/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
(function(window, vx) {
	'use strict';
	/**
	 * @description 预期年化收益率及其他收益率格式化
	 */
	function phone() {
		return function(input) {
			if (input){
				input=input+"";
				var pre=input.substring(0,3);
				var rel=input.substring(input.length-4);
				input=pre+"****"+rel;
				return input;
			}else{
				return "非法登陆";
			}
		};
	}
	vx.module('ui.libraries').filter('phone', phone);
})(window, window.vx);
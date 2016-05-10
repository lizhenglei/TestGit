/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/

(function(window, vx) {'use strict';
	/**
	 * @author
	 * filter 加密账号    1234****5678
	 * param 判断是否为身份证号码加密
	 */
	function encryptAcNo() {
		return function(input,param) {
			if (input !== undefined){
				if(param){
					return input.substring(0, 10) + "****" + input.substring(input.length - 4);
				}else{
					return input.substring(0, 4) + "****" + input.substring(input.length - 4);
				}
			}		
		}
	}


	vx.module('ui.libraries').filter('encryptAcNo', encryptAcNo);
})(window, window.vx);

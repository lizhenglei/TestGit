/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/

(function(window, vx) {'use strict';
	/**
	 * @author
	 * filter template
	 */
	//accountNo.$inject = ['$locale'];
	function accountNo() {
		return function(input) {
			if (input)
				return input.replace(/(.{4})/g, "$1 ");
			else
				return "--";
		};
	}


	vx.module('ui.libraries').filter('accountNo', accountNo);
})(window, window.vx);

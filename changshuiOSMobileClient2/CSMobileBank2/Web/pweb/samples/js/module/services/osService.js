/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
/**
 * @author kongxiangxu
 * to obtain equipment services
 */
(function(window, vx, userAgent) {
	'use strict';
	
	var service = {};
	service.$os = [ function() {
		var os = {
			webkit : userAgent.match(/WebKit\/([\d.]+)/) ? true : false,
			android : userAgent.match(/(Android)\s+([\d.]+)/) || userAgent.match(/Silk-Accelerated/) ? true : false,
			androidICS : this.android && userAgent.match(/(Android)\s4/) ? true : false,
			ipad : userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false,
			iphone : !(userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) && userAgent.match(/(iPhone\sOS)\s([\d_]+)/) ? true : false,
			ios : (userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) || (!(userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) && userAgent.match(/(iPhone\sOS)\s([\d_]+)/) ? true : false),
			ios5 : (userAgent.match(/(iPad).*OS\s([5_]+)/) ? true : false) || (!(userAgent.match(/(iPad).*OS\s([5_]+)/) ? true : false) && userAgent.match(/(iPhone\sOS)\s([5_]+)/) ? true : false),
			iphone4 :(!(userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) && userAgent.match(/(iPhone\sOS)\s([\d_]+)/) ? true : false) && window.screen.height==480?true:false,
			wphone : userAgent.match(/Windows Phone/i)?true:false
		};
		return os;
	} ];

	vx.module('mapp.libraries').service(service);

})(window, window.vx,navigator.userAgent);
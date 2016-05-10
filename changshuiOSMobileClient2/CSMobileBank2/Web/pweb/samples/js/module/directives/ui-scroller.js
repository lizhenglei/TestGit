/**
 * this directive only use for Guangda bank
 * @author
 * 
 */
vx.module('ui.libraries').directive('uiScroller', ["$timeout", "$compile",
function($timeout, $compile) {
	return {
		   restrict : 'A',
		   link : function(scope, element, attrs) {
			   var defaults = {
					    only:true,//监听周期内函数仅执行一次
						callback:function(){
							return false;
						}
				};
			   var settings = vx.extend(defaults, vx.fromJson(attrs.uiScroller||{}));
		       $(window).scroll(function(){
		         if(($(document).scrollTop()+$(window).height())/$(document).height()>=0.98 && (window.location.hash.indexOf("ActivitiesQry")!=-1||window.location.hash.indexOf("ActivSharedQry")!=-1)&&scope[settings.only]){
		        	 scope[settings.callback]();
		          }
		       })
		   }
	   };
}]);

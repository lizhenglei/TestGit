/**
 * 用户输入的限制
 * @author soda-lu
 * 
 */
vx.module('ui.libraries').directive('uiNum', ["$timeout", "$compile",
function($timeout, $compile) {
	return {
		   restrict : 'CA',
		   link : function(scope, element, attrs) {
			   var defaults = {"maxlength":"11","hasDot":true,"tip":null};
			   var params = $.extend({}, defaults, vx.fromJson(attrs.uiNum || {}));
			   element.bind({
                   'blur' : function(e) {
                       if($(this).val() >= 0 && $(this).val() != '') {
                       } else {
                    	   if($(this).val() != ''&&params.tip){
                    		   scope.toast(params.tip+"只能输入数字");
                    	   }
                           scope[attrs.vModel] = undefined;
                           $(this).val("");
                           scope.$apply(scope);
                       }
                   },
                   'paste':function(e) {
                       return true;
                   },'keydown' : function(e, value) {
                       var theEvent = window.event || e;
                       //释放tab back enter键
                       if ((theEvent.ctrlKey || theEvent.shiftKey || $(this).val().toString().split(".")[0].length==params.maxlength)) {
                           if(theEvent.keyCode != 13 && theEvent.keyCode != 9 && theEvent.keyCode != 8) {
                               if (window.event) {
                                   code = 0;
                                   theEvent.returnValue = false;
                               } else {
                                   theEvent.preventDefault();
                               }
                           }
                       }
                       
                       var code = theEvent.keyCode || theEvent.which;
                       if(params.hasDot){
                    	 //如首位是0,其后必跟"."
                           if($(this).val() == '0'&&(code!=190&&code!==13&&code!=9&&code!=8)){
                        	   if (window.event) {
                                   code = 0;
                                   theEvent.returnValue = false;
                               } else {
                                   theEvent.preventDefault();
                               }
                           }
                           //禁止"."在首位
                           if($(this).val() == ''&&code==190){
                        	   if (window.event) {
                                   code = 0;
                                   theEvent.returnValue = false;
                               } else {
                                   theEvent.preventDefault();
                               }
                           }
                           //"."后仅保留两位有效数字
                           if(scope[attrs.vModel]){
                        	   var str=scope[attrs.vModel]+"";
                        	   var xiaoshudian=str.indexOf(".");
                               var valueLength=str.length;
                               if(valueLength>=4&&(xiaoshudian==(valueLength-3))&&(code!=190&&code!==13&&code!=9&&code!=8)){
                            		if (window.event) {
                                       code = 0;
                                       theEvent.returnValue = false;
                                     } else {
                                       theEvent.preventDefault();
                                     }
                            	}
                           }
                       }else{
                    	   if(code==190){
                        	   if (window.event) {
                                   code = 0;
                                   theEvent.returnValue = false;
                               } else {
                                   theEvent.preventDefault();
                               }
                           }
                       }
                       
                       
                       //禁止数字外的其他键
                       if (code < 48 || (code > 57 && code < 96) || code > 105) {
                           if (code == 229 || code == 110 || code == 37 || code == 39 || code == 46 || code == 8 || code == 180 || code == 190 || code == 9) {
                        	   if ((code == 110 || code == 190) && scope[attrs.vModel].indexOf('.') > 0) {
                                   if (window.event) {
                                       code = 0;
                                       theEvent.returnValue = false;
                                   } else {
                                       theEvent.preventDefault();
                                   }
                               }
                           } else {
                               if (window.event) {
                                   code = 0;
                                   theEvent.returnValue = false;
                               } else {
                                   theEvent.preventDefault();
                               }
                           }
                       }
                   }
			   });
		   }
	   };
}]);

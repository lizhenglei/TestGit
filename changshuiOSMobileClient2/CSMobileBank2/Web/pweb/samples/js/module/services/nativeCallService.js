/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
/**
 * @author kongxiangxu
 * Interact with native application services
 */
(function(window, vx, undefined) {'use strict';

	var service = {};
	service.$nativeCall = ["$os", "$log", '$rootScope', '$targets',
	function($os, $log, $rootScope, $targets) {
		var tNative = {
			csii__index : 1,
			csii__start : 1,
			csii__data : [],		//params transfer to native
			csii__callback : [],	//callback function transfer to native
			history:[],
			pages : [],
			viewPort:'content',
			rootScope : $rootScope,
			isHideBackButton: false,
			isCloseSplashScreen: false,
			noPushHistory: false,
			hideMaskTimes: 0,
			ShowMasking: false,
            isiosdevice: $os.ios,
			timer: null

		};
		/**
		 * call native fn
		 */
		var loadUrl = function(url){
			var iFrame = document.createElement("iframe");
		    iFrame.setAttribute("src", url);
		    iFrame.setAttribute("style", "display:none;");
		    iFrame.setAttribute("height", "0px");
		    iFrame.setAttribute("width", "0px");
		    iFrame.setAttribute("frameborder", "0");
		    /*注释为浏览器测试*/
		    document.body.appendChild(iFrame);
		    iFrame.parentNode.removeChild(iFrame);
		    iFrame = null;

		};
		
		var nativeCall = function(msg, callback) {
			$log.debug("init native call " + msg);
			var params, url;
			if( typeof callback === "undefined" || callback === undefined) {
				if($os.android) {
					CSII.NativeCall(msg);
				} else if($os.ios) {
					//url = "file://localhost/LocalActions/"+ msg;
					url = "http://192.168.1.101/bweb/LocalActions/"+ msg;
					loadUrl(url);
				} else if($os.wphone){
					params = {
						"command" : msg
					};
					window.external.notify(vx.toJson(params));
				}
			} else if(arguments.length < 3) {
				tNative.csii__callback[tNative.csii__index] = callback;
				if($os.android) {
					CSII.NativeCall(msg, tNative.csii__index);
					tNative.csii__index++;
				} else if($os.ios) {
					// 本地使用
					//url = "file://localhost/LocalActions/"+ msg + '___' + tNative.csii__index;
					// 服务器
					url = "http://192.168.1.101/bweb/LocalActions/"+ msg+ '___' + tNative.csii__index;
					tNative.csii__index++;
					loadUrl(url);
				} else if($os.wphone){
					params = {
						"command" : msg,
						"index" : tNative.csii__index
					};
					window.external.notify(vx.toJson(params));
					tNative.csii__index++;
				}
			} else {
				var start = tNative.csii__start, i;
				for(i = 2; i < arguments.length; i++) {
					tNative.csii__data[tNative.csii__start++] = arguments[i];
				}
				tNative.csii__callback[tNative.csii__index] = callback;
				if($os.android) {
					CSII.NativeCall(msg, tNative.csii__index, start);
					tNative.csii__index++;
				} else if($os.ios) {
					// 本地使用
					//url = "file://localhost/LocalActions/"+ msg + '___' + tNative.csii__index + '___' + start;
					//服务器
					url = "http://192.168.1.101/bweb/LocalActions/"+ msg + '___' + tNative.csii__index + '___' + start;
					tNative.csii__index++;
					loadUrl(url);
				} else if($os.wphone){
					var tmp, tmpIndex;
					if(msg === "SendRequest") {
						tmp = arguments[3];
						tmpIndex = start;
					} else {
						tmp = arguments[2];
						tmpIndex = tNative.csii__index;
					}
					if(tmp.match(/^{.+}$/) || tmp.match(/^[.+]$/)) {
						params = {
							"command" : msg,
							"index" : tmpIndex,
							"data" : vx.fromJson(tmp)
						};
					} else {
						params = {
							"command" : msg,
							"index" : tmpIndex,
							"data" : tmp
						};
					}
					tNative.csii__index++;
					window.external.notify(vx.toJson(params));
				}else{
					if(arguments[0]==="Toast"){
						$log.debug("error-message："+arguments[2]);
					}
				}
			}
		};
		/**
		 * android call javascript interface
		 */
		tNative.androidGetValue = function(str){
			eval(str);
		};
		//ios密码键盘
		tNative.csii__InputContent = function(str,inputId){			
			var target = $($.ui.activeDiv).find("#"+inputId)[0];
			target.value=str;
			$(target).trigger("input");
		};
		/**
		 * set the native app whil title
		 */
		tNative.setTitle = function(title) {
			//var title = this.activePage.attr("title");
			if(title){
				//nativeCall("SetTitle", null, title);
				//浏览器测试用
				vx.element(".header .imglogo").hide();
				vx.element(".header .title").show().html(title);
			}
		};
		/**
		 * set the native app back of button show or hide
		 */
		tNative.setBackButtonVisibility = function(flag) {
			//flag为true,隐藏按钮
			if (flag) {
				vx.element("#backButton").hide();
				//vx.element("#footer").show();
			} else if (flag === undefined) {				
				if (tNative.history.length <= 1 && tNative.pages.length <= 0) {
					vx.element("#backButton").hide();
					vx.element("#footer").show();					
					$(".screen").hasClass("mbottom0") && $(".screen").removeClass("mbottom0");
				} else {
					vx.element("#backButton").show();					
					vx.element("#footer").hide();
					$(".screen").addClass("mbottom0");
				}
			}
		};
		/**
		 * call back native app show loading window
		 */
		tNative.showMask = function() {
			nativeCall("ShowMask");
		};
		/**
		 * call back native app hide loading window
		 */
		tNative.hideMask = function() {
			nativeCall("HideMask");
		};
		/**
		 * close native app splash screen
		 */
		tNative.closeSplashScreen = function() {
			nativeCall("CloseSplashScreen");
		};
		tNative.alert = function(message) {
			nativeCall("Alert", null, message);
		};

		tNative.confirm = function(callback, message) {
			if($os.android || $os.ios || $os.wphone){
				nativeCall("Confirm", function(yes) {
					if($rootScope.$$phase) {
						callback(yes);
					} else {
						$rootScope.$apply(function() {
							callback(yes);
						});
					}
				}, message);
			}else{
				window.confirm(message);
			}
		};
		
		tNative.callphone = function(message) {
			nativeCall("ConfirmCallPhone",null, message);
		};
		
		tNative.confirmOK = function(callback, message) {
			nativeCall("ConfirmOK", function(yes) {
				if($rootScope.$$phase) {
					callback(yes);
				} else {
					$rootScope.$apply(function() {
						callback(yes);
					});
				}
			}, message);
		};
		
		tNative.toast = function(errMessage) {
			if($os.android || $os.ios || $os.wphone){
				nativeCall("Toast", null, errMessage);
			}else{
				window.alert(errMessage);
			}
		};
		tNative.getUserPhone = function(callback) {
			nativeCall("GetUserPhone",callback);
		};
		tNative.postUserPhone = function(phone) {
			nativeCall("PostUserPhone", null, phone);
		};
		
		tNative.getLoginStatu = function(callback) {
			nativeCall("GetLoginStatu",callback);
		};
		tNative.postLoginStatu = function(loginstatu) {
			nativeCall("PostLoginStatu", null, loginstatu);
			
		};
		/*
		 * open a website
		 */
		tNative.openWebsite = function(url){
			nativeCall("OpenWebsite",null, url);
		};
		
		tNative.datePicker = function(callback,date) {
			nativeCall("DatePicker", callback,date);
		};

		/**
		 * call native app authenticate module
		 */
		tNative.authenticate = function(callback) {
			if($os.ios || $os.android || $os.wphone){
				nativeCall("Authenticate", callback);
			}else{
				callback(vx.toJson({"toker":"622452","Token":""}));
			}
		};
		/**
		 * close native app webview
		 */
		tNative.finishWeb = function() {
			nativeCall("FinishWeb");
		};		
		tNative.finishWebWithMessage = function(message) {
			nativeCall("FinishWebWithMessage",null,message);
		};
       tNative.toshowred = function(message) {
       nativeCall("toshowred",null,message);
       };
		//模拟alert
		tNative.showTransptView = function(){
			nativeCall("ShowTransptView");
		}
		/**
		 * close native app webview
		 */
		tNative.gotoMenu = function(menuName){
			nativeCall("gotoMenu",null,menuName);
		};
		//银行公告根据图片拉取信息
		tNative.getNoticeInfo = function(callback){
			if($os.ios || $os.android || $os.wphone){
				nativeCall("getNoticeInfo", callback);
			}else{
				callback(vx.toJson({"NoticeSeq":"","Token":""}));
			}
		};
		//通讯录,紫金农商
		tNative.OpenPhoneNote = function(callback){
			nativeCall("OpenPhoneNote",function(data){
				$rootScope.$apply(callback(data));
			});
		};
		//获取大额预约网点地图返回信息,紫金农商
		tNative.GetBigOrder = function(callback){
			nativeCall("GetBigOrder",function(data){
				$rootScope.$apply(callback(data));
			});
		};
		tNative.OpenMapBig = function(message) {
			nativeCall("OpenMapBig", null, message);
		};
		
		//调地图，message是一个json,优惠商户用（名称，地点，经度，纬度）
		//var formData = {};
		//NativeCall.OpenMap(vx.toJson(formData));
		tNative.OpenMap = function(message) {
			nativeCall("OpenMap", null, message);
		};

		/**
		 * notice native app will transit forward
		 */
		tNative.forWardTransition = function() {
			nativeCall("ForWardTransition");
		};

		/**
		 * notice native app will transit back
		 */
		tNative.backTransition = function() {
			nativeCall("BackTransition");
		};
		/**
		 * invoke login view
		 */
		tNative.NeedLogin = function() {
			nativeCall("NeedLogin");
		};

		/**
		 * notice native app do transition animation
		 */
		tNative.startTransition = function() {
			nativeCall("StartTransition");
		};
		
		/**
		 * invoke iphone custom keyboard 
		 */
		tNative.changeKeyboard = function() {
			nativeCall("ChangeKeyboard");
		};

		/**
		 * setting viewport name 
		 */
		tNative.setViewPortName = function(name) {
			tNative.viewPort = name || 'content';
		};
		
		/**
		 * native app call html app goback fn
		 */
		tNative.goBack = function() {
			if(tNative.history.length <= 1){
				if(tNative.pages.length > 0){
					var targets = tNative.pages.pop();
					// add by lss
					tNative.history=[];
					$targets("content",targets);					
					return "true";
				}
				return "false";
			} else if( typeof tNative.history[tNative.history.length -1] !== 'function'){
				var vLength = tNative.history.length;
				var vLast = tNative.history[vLength-1];
				var vPenult = tNative.history[vLength-2];
				$targets(tNative.viewPort, "#" + (vPenult-vLast));
				return "true";
			} else if(typeof tNative.history[tNative.history.length -1] === 'function'){	//回调函数
				var callback = tNative.history.pop();
				callback();
				return "true";
			}
		};
		
		/**
		 * native app call html app,open transfer 
		 */
		tNative.loadTransfer=function(url){
			//$rootScope.$apply(function(){
				$targets(tNative.viewPort,url);
			//});
		};
		
		tNative.getUserInfo = function(callback){
			nativeCall("GetUserInfo", callback);
		};
		
		tNative.sendRequest = function(request, params){
			nativeCall("SendRequest", null, request, params);
		};
		
		tNative.getActionId = function(callback){
			nativeCall("GetActionId",callback);
		};
		
		tNative.csii__InputContent = function(str, inputId){
			var target = vx.element("#" + inputId);
			target.val(str);
			target.trigger("input");
		};
		
		tNative.csii__InputData = function(inputStr) {
		    //TODO:Keyboard
		    if (inputStr === "delete") {
		        if (document.activeElement.selectionStart - document.activeElement.selectionEnd == 0) {
		            var valueStr = document.getElementById(document.activeElement.id).value;
		            valueStr = valueStr.substring(0, document.activeElement.selectionStart - 1) + valueStr.substring(document.activeElement.selectionStart, valueStr.length);
		            var selectionStart = document.activeElement.selectionStart;
		            document.getElementById(document.activeElement.id).value = valueStr;
		            document.activeElement.selectionStart = selectionStart - 1;
		            document.activeElement.selectionEnd = selectionStart - 1;
		        } else {
		            var valueStr = document.getElementById(document.activeElement.id).value;
		            valueStr = valueStr.substring(0, document.activeElement.selectionStart) + valueStr.substring(document.activeElement.selectionEnd, valueStr.length);
		            var selectionStart = document.activeElement.selectionStart;
		            document.getElementById(document.activeElement.id).value = valueStr;
		            if (selectionStart == 0) {
		                document.activeElement.selectionEnd = 0;
		            }else{
		                document.activeElement.selectionEnd = document.activeElement.selectionStart;
		            }
		        }
		    } else {
		        if (document.activeElement.selectionStart - document.activeElement.selectionEnd == 0) {
		            var valueStr = document.getElementById(document.activeElement.id).value;
		            valueStr = valueStr.substring(0, document.activeElement.selectionStart) + inputStr + valueStr.substring(document.activeElement.selectionStart, valueStr.length);
		            var selectionStart = document.activeElement.selectionStart;
		            document.getElementById(document.activeElement.id).value = valueStr;
		            document.activeElement.selectionStart = selectionStart + 1;
		            document.activeElement.selectionEnd = selectionStart + 1;
		        } else {
		            var valueStr = document.getElementById(document.activeElement.id).value;
		            valueStr = valueStr.substring(0, document.activeElement.selectionStart) + inputStr + valueStr.substring(document.activeElement.selectionEnd, valueStr.length);
		            var selectionStart = document.activeElement.selectionStart;
		            document.getElementById(document.activeElement.id).value = valueStr;
		            document.activeElement.selectionStart = selectionStart + 1;
		            document.activeElement.selectionEnd = document.activeElement.selectionStart;
		        }
		    }
		    var target = document.getElementById(document.activeElement.id);
		    vx.element(target).trigger("input");
		};
		
		return tNative;
	}];


	vx.module('mapp.libraries').service(service);

})(window, window.vx);
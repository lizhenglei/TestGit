/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/

/**
 * uicahrt
 * 
 * @author json liu
 */
(function(window, vx, undefined) {'use strict';
	vx.module('mapp.libraries').factory('$chartService', ['$log', '$timeout',
	function($log, $timeout) {
		for (var temp in window._Chart) {
			window._Chart[temp].call(window);
		}
		return {
			line : function(dom, params) {
				var data=params.data;
				var keys = [], values = [], key;
				for (key in data) {
					keys.push(key);
					values.push(data[key]);
				}
				var lineChartData = {
					labels : keys,
					datasets : [{
						label : "My dataset",
						fillColor : params.fillColor,
					strokeColor : params.strokeColor,
					pointColor :  params.pointColor,// 节点颜色
					pointStrokeColor :  params.pointStrokeColor,// 节点边框颜色
					pointHighlightFill :  params.pointHighlightFill,// 选中节点颜色
					pointHighlightStroke :  params.pointHighlightStroke,// 选中节点边框颜色
						data : values
					}]
				}
				
				$timeout(function() {
						var ctx = dom.getContext("2d");
						window.myLine = new Chart(ctx).Line(lineChartData, {
							showTooltips:params.showTooltips,
							// String - Tooltip background colour
							tooltipFillColor: params.tooltipFillColor,
							// String - Template string for single tooltips
							tooltipTemplate: "<%if (label){%><%}%><%= value %>",
							responsive : true,
							pointDot:params.pointDot,
							pointDotRadius:params.pointDotRadius,
							// Boolean - If we want to override with a hard
							// coded scale
							scaleOverride : true,
							// ** Required if scaleOverride is true **
							// Number - The number of steps in a hard coded
							// scale
							scaleSteps : params.scaleSteps,
							// Number - The value jump in the hard coded scale
							scaleStepWidth : params.scaleStepWidth,
							// Y 轴的起始值
							scaleStartValue : params.scaleStartValue,
							onAnimationComplete : function() {
								this.activeElements=[{saved: Object,controlPoints: Object,datasetLabel: "My dataset",fillColor: "#fff",highlightFill: "#fff",highlightStroke: "rgba(151,187,205,1)",label: "5/26",strokeColor: "rgba(151,187,205,1)",value: 4.3,x: 598,y: 132.3458333333333}];
								// var params=[];
								// params[0]=this.datasets[0].points[this.datasets[0].points.length-1];
								Chart.Type.prototype.showTooltip.call(this,this.datasets[0].points.slice(-1));
							}
						});
					}, 100); 
			}
		};
	}]);

})(window, window.vx); 

/**
 * 识别当前设备
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
/**
 * 全局文本域
 */
(function(window, vx, undefined) { 'use strict';
var service = {};
service.$context = [ function() {
	/**
	 * init context
	 */
		var context = (function() {
			var c = {};
			c._data = {};
			c.setData = function(key, value) {
				c._data[key] = value;
			};
			c.setJson = function(obj) {
				// c._data = obj;
				c.pushJson(obj);
			};
			c.pushJson = function(obj) {
				vx.extend(c._data,obj);
			};
			c.getData = function(key) {
				return c._data[key];
			};
			c.getJson = function() {
				return c._data;
			};
			c.removeData = function(key) {
				delete c._data[key];
			};
			c.clear = function() {
				c._data = {};
			};
			c.containsKey = function(key) {
				if (c._data[key])
					return true;
				else
					return false;
			};
			c.construct = {
				"setData" : c.setData,
				"setJson" : c.setJson,
				"getData" : c.getData,
				"getJson" : c.getJson,
				"removeData" : c.removeData,
				"clear" : c.clear,
				"containsKey" : c.containsKey
			};
			return c;
		})();
		return context;
} ];

vx.module('mapp.libraries').service(service);

})(window, window.vx);
/**
 * @author kongxiangxu Interact with native application services
 */
(function(window, vx, undefined) {'use strict';

	var service = {};
	service.$nativeCall = ["$os", "$log", '$rootScope', '$targets',"$timeout",
	function($os, $log, $rootScope, $targets, $timeout) {
		
		var tNative = {
				csii__index : 1,
				csii__start : 1,
				csii__data : [],		// params transfer to native
				csii__callback : [],	// callback function transfer to native
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
			    /* 注释为浏览器测试 */
			    document.body.appendChild(iFrame);
			    iFrame.parentNode.removeChild(iFrame);
			    iFrame = null;
			};
			/**
			 * android call javascript interface
			 */
			tNative.androidGetValue = function(str){
				eval(str);
			};
			var nativeCall = function(msg, callback) {
				$log.debug("init native call " + msg);
				var params, url;
				if( typeof callback === "undefined" || callback === undefined) {
					if($os.android) {
						CSII.NativeCall(msg);
					} else if($os.ios) {
						// url = "file://localhost/LocalActions/"+ msg;
						url = "http://10.44.51.1:8082/pmobile/LocalActions/"+ msg;
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
						// url = "file://localhost/LocalActions/"+ msg + '___' +
						// tNative.csii__index;
						// 服务器
						url = "http://10.44.51.1:8082/pmobile/LocalActions/"+ msg+ '___' + tNative.csii__index;
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
						// url = "file://localhost/LocalActions/"+ msg + '___' +
						// tNative.csii__index + '___' + start;
						// 服务器
						url = "http://10.44.51.1:8082/pmobile/LocalActions/"+ msg + '___' + tNative.csii__index + '___' + start;
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
		// close native app webview
		tNative.finishWeb = function() {
			nativeCall("FinishWeb");
		};
		tNative.finishWebWithMessage = function(message) {
			nativeCall("FinishWebWithMessage",null,message);
		};
                   
                           
       tNative.toshowred = function(message) {
       nativeCall("toshowred",null,message);
       };
		// 回显信息
		tNative.toast = function(message) {
			nativeCall("Toast",null,message);
		};
		tNative.onLoadURL = function(url) {
			nativeCall("onLoadURL",null,url);
		};
		//摇奖
		tNative.ShakeMobile = function(callback) {
			nativeCall("ShakeMobile",callback);
		};
		//获取html页面
		tNative.OpenHTML = function(message) {
			nativeCall("OpenHTML",null,message);
		};
                           
       tNative.getFundCollectData = function(callback,message) {
       nativeCall("getFundCollectData",callback,message);
       };
		/**
		 * close native app splash screen
		 */
		tNative.closeSplashScreen = function() {
			nativeCall("CloseSplashScreen");
		};
		// 调用原生的 alert
		tNative.alert = function(message) {
			nativeCall("Alert", null, message);
		};
		// 调用密码控件
		tNative.getPassword = function(callback,message) {
			nativeCall("ShowPassword",callback,message);
		};
		//允许复制的弹框
		tNative.alertAllow = function(callback,message) {
			nativeCall("alertAllow",callback,message);
		};
		// 获取短信验证码
		tNative.getMseCode = function(callback) {
			nativeCall("ShowMessage",callback);
		};
		
		///获取二维码转账信息
		tNative.ewmShow = function(callback,message) {
			nativeCall("ewmShow",callback,message);
		}; 
		
		///我要分期展示交易明细信息
		tNative.imtShow = function(callback,message) {
			nativeCall("imtShow",callback,message);
		}; 
		//在线预约获得网点信息
		tNative.getBranch = function(callback,message) {
			nativeCall("getBranch",callback,message);
		}; 
		//摇一摇对话框
		tNative.alertK = function(callback,message) {
			nativeCall("alertK",callback,message);
		}; 
		
		//关闭摇一摇
		tNative.closeShake = function(callback) {
			nativeCall("closeShake",callback);
		}; 
		
		//放开摇一摇
		tNative.openShake = function(callback) {
			nativeCall("openShake",callback);
		}; 
		
		//获取客户端的登录状态以及登录信息
		tNative.getClientState = function(callback){
			nativeCall("ClientState",callback);
		}
		//更新客户端登录信息
		tNative.changeClientInfo = function(message){
			nativeCall("ChangeClientInfo",null,message);
		}
		
		/**
		 * set the native app whil title
		 */
		tNative.setTitle = function(title) {
			// var title = this.activePage.attr("title");
			if(title){
				nativeCall("SetTitle", null, title);
			}
		};
		/**
		 * set the native app back of button show or hide
		 */
		tNative.setBackButtonVisibility = function(flag) {
			if(flag){
				if(!tNative.isHideBackButton){
					tNative.isHideBackButton = true;
					nativeCall("HideBackButton");
				}
			}else if(tNative.isHideBackButton){
				nativeCall("ShowBackButton");
				tNative.isHideBackButton = false;
			}
		};
		/**
		 * 跳转碎片页
		 */
		tNative.loadTransfer=function(url){
			$rootScope.$apply(function(){
				$targets(tNative.viewPort,url);
			});
		};
		/**
		 * call back native app show loading window
		 */
		tNative.showMask = function() {
			// 浏览器测试时，需要注释掉以下代码
			nativeCall("ShowMask");
		};
		/**
		 * call back native app hide loading window
		 */
		tNative.hideMask = function() {
			// 浏览器测试时，需要注释掉以下代码
			nativeCall("HideMask");
		};
		/**
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
				callback(vx.toJson({"TrsPassword":"000000","Token":""}));
			}
			
		};

		/**
		 * getPhoneNumber
		 */
		tNative.getPhoneNumber = function(callback) {
			nativeCall("GetPhoneNumber", callback);
		};
		/**
		 * serveTelPhone
		 */
		tNative.serveTelPhone = function(url) {
			nativeCall("ServeTelPhone",null, url);
		};
		/**
		 * close native app goto login
		 */
		tNative.goToLoginHTML = function() {
			nativeCall("GoToLoginHTML");
		};
		/**
		 * close native app webview Yolen 2013-9-25
		 */
		tNative.gotoMenu = function(menuName){
			nativeCall("gotoMenu",null,menuName);
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
		 * notice native app do transition animation
		 */
		tNative.startTransition = function() {
			nativeCall("StartTransition");
		};
		/**
		 * 
		 */
		tNative.blueTooth = function(callback,message) {
			nativeCall("blueTooth",callback,message);
		};
		/**
		 * 获取交易名字
		 */
		tNative.getRewardTransName = function(callback,message) {
			nativeCall("getRewardTransName",callback,message);
		};
		/**
		 * invoke iphone custom keyboard
		 */
		tNative.changeKeyboard = function() {
			nativeCall("ChangeKeyboard");
		};
		/**
		 * 调用app确认框 --两个参数
		 */
		tNative.confirm = function(callback, message) {
			nativeCall("Confirm", function(yes) {
				if($rootScope.$$phase) {
					callback(yes);
				} else {
					$rootScope.$apply(function() {
						callback(yes);
					});
				}
			}, message);
		};
		/**
		 * 调用app确认框
		 */
		tNative.confirmOK = function(callback, message) {
			nativeCall("confirmOK", function(yes) {
				if($rootScope.$$phase) {
					callback(yes);
				}
			}, message);
		};
		/**
		 * 调用app的确认框 ---三个参数
		 */
		/*
		 * tNative.confirm = function(callback, message,cancel) { var tmp =
		 * confirm(message); if(tmp){ if($rootScope.$$phase){ callback(); } else {
		 * $rootScope.$apply(function(){ callback(); }); } }else
		 * if(typeof(cancel)=="function"){ if($rootScope.$$phase){ cancel(); }
		 * else { $rootScope.$apply(function(){ cancel(); }); } } };
		 */
		/**
		 * 从app获取用户信息
		 */
		tNative.getUserInfo = function(callback){
			nativeCall("GetUserInfo", callback);
		};

		/**
		 * 获取二维码转账的账号和用户名
		 */
		
		tNative.getErWeiMaInfo = function(callback){
			nativeCall("GetErWeiMaInfo", callback);
		};
		
		/**
		 * 获取音频Key签名
		 */
		tNative.getSignData = function(callback,message) {
			nativeCall("GetSignData",callback,message);
		};
		
		tNative.sendRequest = function(request, type, url, data){
			var requestData = "";
			try{
				requestData = JSON.parse(data);
			}catch(e){
				requestData = data;
			}
			if(type==="POST" || (type==="GET" && url.indexOf(".do") > -1)){
				url.replace("/pmobile/", "");
			} else if(type==="GET"){
				url = "samples/" + url;
			}
			var param = {
				"Method" : type,
				"Url" : url,
				"Data" : requestData
			};
			nativeCall("SendRequest", null, request, JSON.stringify(param));
		};
		/**
		 * 从app获取碎片页名称
		 */
		tNative.getActionId = function(callback){
			nativeCall("GetActionId",callback);
		};
		
		tNative.csii__InputContent = function(str, inputId){
			var target = vx.element("#" + inputId);
			target.val(str);
			target.trigger("input");
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
				// call native goback fn
				if(tNative.pages.length > 0){
					var targets = tNative.pages.pop();
					$targets("content",targets);
					// window.location.hash=targets;//liuyoucai
					return "true";
				}
				return "false";
			} else if( typeof tNative.history[tNative.history.length -1] !== 'function'){
				var vLength = tNative.history.length;
				var vPenult = tNative.history[vLength-2];
				$targets(tNative.viewPort, "#" + vPenult);
				return "true";
			} else if(typeof tNative.history[tNative.history.length -1] === 'function'){	// 回调函数
				var callback = tNative.history.pop();
				callback();
				return "true";
			}
		};
		
		tNative.csii__InputData = function(inputStr) {
		    // TODO:Keyboard
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

/* jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true */
/**
 * @author kongxiangxu to obtain equipment services
 */
(function(window, vx, userAgent) {
	'use strict';
	
	var service = {};
	service.$os = [ function() {
		var os = {
			webkit : userAgent.match(/WebKit\/([\d.]+)/) ? true : false,
			android : userAgent.match(/(Android)\s+([\d.]+)/) || userAgent.match(/Silk-Accelerated/)||userAgent.match(/Android/)? true : false,
			androidICS : this.android && userAgent.match(/(Android)\s4/) ? true : false,
			ipad : userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false,
			iphone : !(userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) && userAgent.match(/(iPhone\sOS)\s([\d_]+)/) ? true : false,
			ios : (userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) || (!(userAgent.match(/(iPad).*OS\s([\d_]+)/) ? true : false) && userAgent.match(/(iPhone\sOS)\s([\d_]+)/) ? true : false),
			wphone : userAgent.match(/Windows Phone/i)?true:false,
			IE : userAgent.match(/MSIE/)?true:false,
			ucweb : userAgent.match(/UCBrowser/)?true:false,
			samsung : userAgent.match(/SAMSUNG/)? true : false,
			weixin : userAgent.match(/MicroMessenger/) ? true : false
		};
		return os;
	} ];

	vx.module('mapp.libraries').service(service);

})(window, window.vx,navigator.userAgent);
/* jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true */
/**
 * @author kongxiangxu transition services
 */
(function(window, vx, userAgent) {
	'use strict';
	
	var service = {};
	service.$transitions = ["$nativeCall","$os","$timeout", function($nativeCall,$os,$timeout) {
		var transitionProvider = {
			types : {
				'native' : 'native',
				'default' : 'default',
				'none' : 'none'
			},
			runTransition :　runTransition,
			availableTransitions:{}
		};
		
		function runTransition(transition, oldDiv, currWhat, remove,back) {
			
			if(!transitionProvider.availableTransitions[transition])
				transition = 'default';
			transitionProvider.availableTransitions[transition].call(this, oldDiv, currWhat, remove,back);
		}
		
		(function(transitionProvider,$nativeCall){
			
			function nativeTransition(oldEl, newEl, remove, back) {
				
				/**
				 * get vx viewport active index value
				 */
				var controller = newEl.controller("vViewport");
				var activeIndex = controller.$pages.activeIndex;
				
				// show or hide header
				/*
				 * if(newEl.attr("data-header")==="none"){
				 * vx.element("#header").hide(); } else { var header =
				 * vx.element("#header")[0]; if(header.style.display ===
				 * "none"){ header.style.display="block"; } }
				 */
				if(newEl.attr("data-back")==="false") {// 跳转到结果页
					$nativeCall.history = [];
					// $nativeCall.pages = [];
				} else {
					for(var ii in $nativeCall.history){
						if($nativeCall.history[ii] === activeIndex){
							$nativeCall.history = $nativeCall.history.slice(0,ii);
							break;
						}
					}
					if(newEl.attr("history")!=="false"){
						if($nativeCall.noPushHistory){
							$nativeCall.history[$nativeCall.history.length] = activeIndex;
							$nativeCall.noPushHistory = false;
						}else
							$nativeCall.history.push(activeIndex);
					}else{
						$nativeCall.history.push(activeIndex);
						$nativeCall.noPushHistory = true;
					}
				}
				$nativeCall.setBackButtonVisibility();
				if(oldEl !== null){
					$timeout(function(){
						if(newEl && newEl.length) {
							if(oldEl && oldEl.length) {
								oldEl.css('display', 'none');
								if(remove)
									oldEl.remove();
							}
							newEl.css('display', 'block');
						}
					},200);
					// clear password
					newEl.find("input[type='password']").each(function(){
						var $sef = vx.element(this);
						$sef.scope()[this.id] = null;
					});
				}else {
					newEl.css("display","block");
				}
				finishTransition(oldEl, newEl, remove, back);
			}
			
			function finishTransition(oldEl, newEl, remove, back) {
				// set title
				var otpBtn = newEl.find('button.OTPPassword-btn');	// fix
																	// 动态密码发送按钮
				if(otpBtn && otpBtn.length > 0 && $os.android){
					var inputTop = otpBtn.prev();
					otpBtn.css("top",inputTop[0].offsetTop + "px");
				}
				var title = newEl.attr("title");
				if(!vx.isEmpty(title)){
					$nativeCall.setTitle(title);
				}
				if($os.android){
					newEl.find("select").each(function(){
						var slf = vx.element(this);
						if(!slf.hasClass("select-arrow")){
							slf.addClass("select-arrow");
						}
					});
				}
				scrollToTop();
			}

			function scrollToTop() {
				window.scrollTo(0, 0);
			}

			transitionProvider.availableTransitions['native'] = nativeTransition;
		})(transitionProvider,$nativeCall);

		return transitionProvider;
	} ];

	vx.module('mapp.libraries').service(service);

})(window, window.vx);


/**
 * @author kongxiangxu
 */
(function(window, vx, undefined) {'use strict';

	var service = {};
	service.Util = ['$filter','sessionService',
	function($filter,sessionService) {

		return {
			/**
			 * description:还回时间格式类似为"2012-05-16"字符串, format指定字符串格式，
			 * 默认yyyy-MM-dd, timestamp时间戳。
			 * example:getDate()还回当前时间的，getDate("3d")三天前时间，getDate("3w")三周前的，getDate("3m")三个月前的
			 */
			getDate : function(days, format, timestamp) {
				// TODO 添加函数过程
				format = format || 'yyyy-MM-dd';
				timestamp = timestamp || sessionService.params.timestamp;
				timestamp = timestamp ? Number(timestamp) : new Date().getTime();
				if (days) {
					var group = days.match(/(\d+)([dDMmWw])/);
					var value = group[1], type = group[2].toUpperCase();
					if (type === 'D')
						return $filter('date')(new Date(timestamp - (value * 24 * 3600 * 1000)), format);
					else if (type === 'W')
						return $filter('date')(new Date(timestamp - (value * 7 * 24 * 3600 * 1000)), format);
					else if (type === 'M') {
						var date = new Date(timestamp);
						date.setMonth(date.getMonth() - value);
						return $filter('date')(date, format);
					}
				} else
					return $filter('date')(new Date(timestamp), format);
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
			},
// jsEncrypt: function(password, key1, key2, key3){
// return strEnc(password, key1, key2, key3);
// },
			/**
			 * 比较金额前格式化金额
			 */
			parseAmount: function(amount){
				amount = amount ? ("" + amount).replace(/,/g, "") : 0;
				return parseFloat(amount);
			}
		};
	}];
	vx.module('mapp.libraries').service(service);

})(window, window.vx);


/*
 * sessionService
 */
(function(window, vx, undefined) { 'use strict';

var service = {};
service.sessionService = [ function() {
	return {
		params : {}
	};
} ];

vx.module('mapp.libraries').service(service);

})(window, window.vx);


/**
 * page service fetchFunction 获取数据方法 pageSize 页面大小（默认10） targets 是否跳转 0-不跳转
 * type:string "+1" type 分页方式 0-显示更多（默认） 1-上下分页按钮
 * 
 * @author ljw
 */
(function(window, vx, undefined) {
	'use strict';
	vx.module('mapp.libraries')
		.factory('Paginator', ['$targets', function ($targets) {
		return function(fetchFunction, pageSize, targets, type) {
			var paginator = {
				_load: function(){
					var self = this;
					// window.scrollTo(0, 0);
					fetchFunction(this.currentPage, function(data){
// self.currentPageItems = self.currentPageItems || [];
						if(self.type==0){
							if(!vx.isEmpty(data.List)){
								self.currentPageItems = self.currentPageItems || [];
								self.currentPageItems = self.currentPageItems.concat(data.List);
							}
							// vx.extend(self.currentPageItems,self.currentPageItems,
							// data.List);
						} else {
							self.currentPageItems = data.List;
						}
						self.totalPage = Math.ceil(data.TotalNum/self.pageSize);
						self.currentPage = data.PageNo || 0;
						self.recordNumber = data.TotalNum || 0;
						if(self.currentPage == self.totalPage || self.totalPage==0){
							self.showButton = "false";
						} else {
							self.showButton = "true";
						}
						if(self.targeted){
							$targets("content","#" + self.steps);
							self.targeted = false;
						}
					},pageSize);
				},
				prevPage: function(){
					this.currentPage =  parseInt(this.currentPage)-1;
					this._load();
				},
				nextPage: function(){
					this.currentPage = parseInt(this.currentPage)+1;
					this._load();
				},
				topPage: function(){
					this.currentPage = 1;
					this._load();
				},
				bottomPage: function(){
					this.currentPage = this.totalPage;
					this._load();
				},
				currentPageItems: null,
				currentIndex: 0,
				totalPage: 0,
				currentPage: 1,
				recordNumber: 0,
				pageSize: pageSize || 10,	
				targeted: false,	// 是否跳转页面
				steps: 0,	// 跳转页数
				type: 0,		// 分页按钮还是更多
				showButton: "false"			// 显示更多按钮
			};
			paginator.pageSize = pageSize || 10;
			paginator.type = type || 0;
			if(vx.isUndefined(targets) || targets==0){
				paginator.targeted = false;
			} else {
				paginator.targeted = true;
			}
			// paginator.targeted = targets ? false : true;
			paginator.steps = targets || 0;
			paginator._load();
			
			return paginator;
		};
	}]);

})(window, window.vx);
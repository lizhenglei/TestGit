/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/

/**
 * mobile app config
 */
vx.module('mapp.config',[]).value('mapp.config', {});
vx.module('mapp.libraries', ['mapp.config']);
vx.module('mapp', ['mapp.libraries','ui','vTouch']);

/**
 * mobile ui config
 */
vx.module('ui.config', []).value('ui.config', {});
vx.module('ui.libraries', ['ui.config']);
vx.module('ui', ['ui.libraries','ui.config']);


/**
 *  Example Source Code Config
 */
(function(window, vx, $) {
	'use strict';

	// this block is module config, if you want do some module management, please use vx-plugins.js
	// and manage module by following methods:
	// **  module.provider(...) / module.factory(...) / module.service(...) / module.value(...) / module.constant(...)
	// **  module.filter(...)
	// **  module.directive(...)
	// **  module.controller(...)

	//### Configuration Entry
	var mod = vx.module('mapp.config');

	/************************************************
	 * config service factory function
	 ************************************************/
	//Log
	configLog.$inject = ['$logProvider'];
	function configLog($logProvider) {
		/**
		 * log level config, support 'debug', 'info', 'warn', 'error'
		 *  note: $log === window.console
		 *  if IE 6/7, include blackbird.js and blackbird.css will emulate window.console for you
		 *  default is 'debug'
		 */
		$logProvider.setLevel('debug');
	}

	//Browser
	configBrowser.$inject = ['$browserProvider'];
	function configBrowser($browserProvider) {

		/**
		 * if E2ETest (end to end test), you should disable browser.debounce function
		 * so setE2ETest(true), debounce used to combind events handle for performance
		 * default is false
		 */
		//$browserProvider.setE2ETest(false);
		
		/**
		 * config Low version of the browser returns no refresh,setting iframe history href initial value.
		 * default file name by blank.html
		 */
		//$browserProvider.setBlankPage("empty.html");
	}

	//Targets
	configTargets.$inject = ['$targetsProvider'];
	function configTargets($targetsProvider) {
		/**
		 *  lets $targets service use window.History for browser forward and backward.
		 *  default is false
		 */
		$targetsProvider.useLocation(false);

		/**
		 * register transition function to $targets service,
		 *  transition function signature is function(oldEl, newEl, remove, back)
		 */
		//$targetsProvider.transition('transition-name', function(oldEl, newEl, remove, back){});

	}

	//Compile
	configCompile.$inject = ['$compileProvider'];
	function configCompile($compileProvider) {
		/**
		 *  when vx set <a href='...' />, it will sanitize for avoid XSS attack
		 *  default is /^\s*(https?|ftp|mailto|file):/
		 */
		//$compileProvider.urlSanitizationWhitelist(/^\s*(https?|ftp|mailto|file):/);
	}

	//RootScope
	configRootScope.$inject = ['$rootScopeProvider'];
	function configRootScope($rootScopeProvider) {
		/**
		 * scope's digest is dirty loop, until now modification found, so loop count(TTL)
		 * is fatal for performance, it means loop count over TTL, the digest will exit
		 * even if has more modifications
		 *  default is 10
		 */
		//$rootScopeProvider.digestTtl(10);

		/**
		 * for scope digest analysis, $rootScope service will use log.debug tracing
		 *  digest processing,
		 *  default is false
		 */
		$rootScopeProvider.traceDigest(false);
	}
	
	//Remote
	configRemote.$inject = ['$$remoteProvider'];
	function configRemote($$remoteProvider) {
		/**
		 * $remote will use this name for scope, for example, scope.$error will get error object
		 *  default is '$error'
		 */
		$$remoteProvider.setErrorTag('jsonError');

		/**
		 * $remote will use this callback analysis error, for examples
		 *  1.  status not in [200, 300), return 'http error'
		 *  2.  application data include $jsonError property will means application error
		 *
		 *  NOTE: application should provide this callback
		 */
		$$remoteProvider.setErrorCallback(function(data, status, headers, config) {
			// if error return error object, otherwise return null
			//防重复提交
			if(!vx.isEmpty(data._tokenName)){
				config.$scope.$parent._tokenName = data._tokenName;
			}
			//流水号
			if(!vx.isEmpty(data._JnlNo)){
				config.$scope.$parent.jnlNoRCB = data._JnlNo;
			}
			var $S = config.$scope, errorList = [], msg = "",msgCode="";
			if (!vx.isEmpty(status) && status != 200 && status !== 0) {
				switch(status) {
					case 404 :
						console.log("404.html");
						break;
					case 500 :
						console.log("500.html");
						break;
					default :
						console.log("default.html");
				}
			} else if (data && !vx.isEmpty(data.jsonError)) {
					if (vx.isArray(data.jsonError)) {
						errorList = data.jsonError;
					} else {
						msg = data.jsonError;
					}
			}
			if (errorList) {
				for (var i = 0; i < errorList.length; i++) {
					if (errorList[i]._exceptionMessage) {
						msg = msg.concat(errorList[i]._exceptionMessage);
						msgCode = errorList[i]._exceptionMessageCode;
					} else {
						msg = msg.concat(errorList[i]);
					}
				}
			}
			if (msg) {
				config.$scope.setInitFlagJN();
				// 当session超时的时候，返回码是：uibs.both_user_and_bankid_is_null
				if ('uibs.both_user_and_bankid_is_null' == msg) {
					NativeCall.toast("您已经登录超时，请重新登录");
					NativeCall.loadTransfer("htmls/Login/Login.html");
					return;
				}
				if('uibs.validation_user_not_login' == msg){
					NativeCall.toast("您还未登陆，登陆后可以操作");
					NativeCall.loadTransfer("htmls/Login/Login.html");
					return data.jsonError;
				}
				
				//NativeCall.toast(msg);	      //----原生使用
				NativeCall.alert(msg);		  //----原生使用
//				alert(msg);				  //----浏览器使用
				//防重复提交，暂时注释
				config.$scope.getToken();
				return data.jsonError;
			}
		});

	}
	

	//Http
	configHttp.$inject = ['$httpProvider'];
	function configHttp($httpProvider) {
		/**
		 * config $http service if use inner cache(not HTTP cache), if use inner cache
		 * all same url GET will just submit server only once
		 * default is false
		 */
		//$httpProvider.useCache(false);

		/**
		 * config $http if use json request type, if not, use form encoding, for examples
		 *  abc=a&aaa=23
		 *  defautl is true
		 */
		//$httpProvider.useJsonRequest(true);

		/**
		 * config $http service default callback, if return true, it will disable all success and error callback
		 *  typically, this callback could use for session control
		 *  but in application use $remote is recommend, so you could use $remoteProvider.setErrorCallback for
		 *  same situation
		 */
		$httpProvider.setDefaultCallback(function(data, status, headers, config) {
			// if return true, means no need further process, all others success(...) and error(...) will not invoke
			return false;
		});

		/**
		 * config $http service defaults, you could:
		 * 1. $httpProvicer.defautls.transformResponse(array) override default json convert or add your function
		 * 2. $httpProvicer.defautls.transformRequest(array) override default json convert or add your function
		 * 3. $httpProvicer.defautls.headers define default HTTP Headers, default is
		 * {
		 *   common : {
		 *     'Accept' : 'application/json, text/plain, *\/*'
		 *   },
		 *   post : {
		 *     'Content-Type' : 'application/json;charset=utf-8'
		 *   },
		 *   put : {
		 *     'Content-Type' : 'application/json;charset=utf-8'
		 *   },
		 *   xsrfCookieName : 'XSRF-TOKEN',
		 *   xsrfHeaderName : 'X-XSRF-TOKEN'
		 * }
		 */
		//$httpProvider.defaults

		/**
		 * config $http service response interceptors, default is empty array
		 *  you could use  $httpProvider.responseInterceptors.push(fn(promise)) for add interceptor
		 *  promise is $q.defer.promise object, use then(success(...), error(...)) for register callback
		 */
		//$httpProvider.responseInterceptors

	}

	//HttpBackend
	configHttpBackend.$inject = ['$httpBackendProvider'];
	function configHttpBackend($httpBackendProvider) {
		
		/**
		 * config $httpBackend use anti-cache policy for HTTP cache
		 * 0-none, 1-use load timestamp, 2-use request timestamp
		 *  defautl is 0
		 */
		$httpBackendProvider.useAntiCache(0);

		/**
		 * config $httpBackend use external ajax function
		 * if true will use jQuery's ajax, otherwise use vx internal ajax
		 * default is false
		 */
		$httpBackendProvider.useExternalAjax(false);

		// config ajax default port
		$httpBackendProvider.config({
			/**
			 * config $httpBackend default ajax timeout(in millisecond)
			 *  default is 30000
			 */
			ajaxTimeout : 30000,
			
			/**
			 * config $httpBackend use ajax queue mode, in queue mode
			 * all ajax request will execute one by one
			 *  ajaxQueueSize is queue max length, 0 means no queue
			 *  ajaxAborted use for ajax abort or not if duplicated request
			 * default is (5, false)
			 */
			ajaxQueueSize : 5,
			ajaxAborted : false,
			/**
			 * config $httpBackend beforSend and afterReceived callback
			 * typically use for ajax indicator
			 * NOTE: you should config it for ajax indicator
			 */
			/*beforeSend : function() {
				// beforeSend
				NativeCall.showMask();
			},
			afterReceived : function() {
				// afterReceived
				NativeCall.hideMask();
			}*/
			beforeSend : function() {
				// beforeSend
		        if(NativeCall.isiosdevice){
		            NativeCall.showMask();
		        }else{
		            if(NativeCall.timer){
		                clearTimeout(NativeCall.timer);
		                NativeCall.timer = null;
		            }
		                            
		            if(!NativeCall.ShowMasking){
		                NativeCall.ShowMasking = true;
		                NativeCall.showMask();
		            }
		        }
			},
			afterReceived : function() {
				// afterReceived
		        if(NativeCall.isiosdevice){
		            if(NativeCall.isCloseSplashScreen){
		               NativeCall.hideMask();
		                }
		            else{
		                NativeCall.hideMask();
		                NativeCall.isCloseSplashScreen=true;
		                NativeCall.closeSplashScreen();
		            }
		        
		        }else{
		            if(!NativeCall.timer)
		            NativeCall.timer = setTimeout(function(){
		            NativeCall.timer = null;
		            NativeCall.ShowMasking = false;
		            NativeCall.hideMask();
		            },1000);
		            NativeCall.closeSplashScreen();
		        }
			}
		});
	}
	
	
	/*beforeSend : function() {
		// beforeSend
        if(NativeCall.isiosdevice){
            NativeCall.showMask();
        }else{
            if(NativeCall.timer){
                clearTimeout(NativeCall.timer);
                NativeCall.timer = null;
            }
                            
            if(!NativeCall.ShowMasking){
                NativeCall.ShowMasking = true;
                NativeCall.showMask();
            }
        }
	},
	afterReceived : function() {
		// afterReceived
        if(NativeCall.isiosdevice){
            if(NativeCall.isCloseSplashScreen){
               NativeCall.hideMask();
                }
            else{
                NativeCall.hideMask();
                NativeCall.isCloseSplashScreen=true;
                NativeCall.closeSplashScreen();
            }
        
        }else{
            if(!NativeCall.timer)
            NativeCall.timer = setTimeout(function(){
            NativeCall.timer = null;
            NativeCall.ShowMasking = false;
            NativeCall.hideMask();
            },1000);
            NativeCall.closeSplashScreen();
        }
	}*/
	
	//Validation
	configValidation.$inject = ['$validationProvider'];
	function configValidation($validationProvider) {
		/**
		 * register validation type, validation is use in data-binding, so it is
		 * bi-direction include parse and format, so validation function could
		 * registerred in 2 modes:
		 * 1.
		 *  $validationProvider.register('validator', function(value) {
		 *	  // return converted value, or undefined for invalid value
		 *  });
		 * 2.
		 *  $validationProvider.register('validator', {
		 *	  parse : function(value) {
		 *		// return converted value, or undefined for invalid value
		 *	  },
		 *	  format : function(value) {
		 *		// return converted value, or undefined for invalid value
		 *	  }
		 *  });
		 */

	}


	mod.config(configLog);
	mod.config(configBrowser);
	mod.config(configTargets);
	mod.config(configCompile);
	mod.config(configRootScope);
	mod.config(configRemote);
	mod.config(configHttp);
	mod.config(configHttpBackend);
	mod.config(configValidation);
	
	
	
	
	
	/************************************************
	 * config service instance function
	 ************************************************/
	runTargets.$inject = ['$targets', '$rootScope','$transitions'];
	function runTargets($targets,$rootScope,$transitions) {
		
		vx.forEach($transitions.types,function(value,key){
			$targets.transition(value, (function() {
				var type = $transitions.types[value];
				return function(oldEl, newEl, remove, back) {
					/*if($('button')[0]!=undefined ||$('button')[0]!=null){
					 $('button')[0].disabled=true;
					 setTimeout(function(){
					 $('button')[0].disabled=false;
					 },1000);
					 }*/
					$transitions.runTransition(type, oldEl, newEl, remove, back);
				};

			})());
		});
	}
	
	
	runRootScope.$inject = ["$rootScope", "$nativeCall", "$timeout", "$http", "$targets"];
	function runRootScope($rootScope, $nativeCall, $timeout, $http, $targets) {

		$rootScope.setInitFlagJN = function() {
			var scope = this;
			scope.initFlagJN = true;
		};

		$rootScope.getTokenJNRCB = function(id, transcode, acno, acname, amount) {
			var scope = this;
			vx.element("#content").find("#" + id).attr("disabled", "true");
			vx.element("#content").find("#" + id).attr("width", "100px");
			$rootScope.setTimer(60, id);
			$http.post("/pmobile/getNewTokenNameV1Name.do", {
				"SMSTransCode" : transcode,
				"PayeeAcNo" : acno,
				"PayeeAcName" : acname,
				"Amount" : amount
			}).success(function(data, status, headers, config) {
				//    		scope.alert("该短信验证码已发送，请注意查收");
				//scope.testNo = data.MSGToken;
			}).error(function(data, status, headers, config) {
				scope.toast(vx.toJson(data));
			});
		};
		$rootScope.getTokenJNRCBV1 = function(id, transcode, acno, acname, amount, mobile) {
			var scope = this;
			if (mobile == null || "" == mobile) {
				scope.toast("手机号不能为空");
			}
			vx.element("#content #" + id).attr("disabled", "true");
			vx.element("#content #" + id).attr("width", "100px");
			$rootScope.setTimer(60, id);
			$http.post("/bweb/getNewTokenNameV1NameV1.do", {
				"SMSTransCode" : transcode,
				"PayeeAcNo" : acno,
				"PayeeAcName" : acname,
				"Amount" : amount,
				"MobilePhone" : mobile
			}).success(function(data, status, headers, config) {
				//    		scope.alert("该短信验证码已发送，请注意查收");
				//scope.testNo = data.MSGToken;
			}).error(function(data, status, headers, config) {
				scope.toast(vx.toJson(data));
			});
		};

		$rootScope.setTimer = function(value, id) {
			value = value - 1;
			var showText = value + "秒后";
			$("#content").find("#" + id).text(showText);
			if (value >= 0) {
				$rootScope.timerFlag = true;
				$rootScope.timer = window.setTimeout(function() {
					$rootScope.setTimer(value, id);
				}, 1000);
			} else {
				$rootScope.clearTimeouts(id);
			}
		};

		$rootScope.timer = null;
		$rootScope.timerFlag = false;
		$rootScope.clearTimeouts = function(id) {
			if ($rootScope.timer != null) {
				window.clearTimeout($rootScope.timer);
				$rootScope.timerFlag = false;
				$("#content").find("#" + id).removeAttr("disabled");
				$("#content").find("#" + id).text("点击获取");
			}
			$rootScope.timer = null;
		};
		//防重复提交
		$rootScope.getToken = function() {
			var scope = this;
			$http.post("/pmobile/getNewTokenName.do", {}).success(function(data, status, headers, config) {
				if (!vx.isEmpty(data._tokenName)) {
					scope._tokenName = data._tokenName;
				}
			}).error(function(data, status, headers, config) {
				$nativeCall.toast(vx.toJson(data));
			});
		};
		//调用原生的alert
		$rootScope.alert = function(message) {
			$nativeCall.alert(message);
		};

		/*$rootScope.confirm = function(message, okBack, cancleBack,positiveText,negativeText) {
			var scope = this;
			// pc浏览
			if(window.confirm(message)){
				okBack();
			}else{
				cancelBack();
			}
			
			// 手机浏览
			var cfmMessage = {
				"title" : "提示",
				"message" : message,
				"positiveText" : arguments[3]?arguments[3]:"确定",
				"negativeText" : arguments[4]?arguments[4]:"取消"
			};
			$nativeCall.confirm.call(this, function(confirm) {
				if (confirm == "Yes") {
					if ( typeof okBack === "function") {
						scope.$apply(okBack());
					}
				} else {
					if ( typeof cancleBack === "function") {
						scope.$apply(cancleBack());
					}
				}
			}, vx.toJson(cfmMessage));
		};*/
		
		$rootScope.callphone = function(message) {
			var scope = this;
			// 手机浏览
			var cfmMessage = {
				"title" : "提示",
				"message" : message,
				"positiveText" : "拨号",
				"negativeText" : "取消"
			};
			$nativeCall.callphone.call(this,vx.toJson(cfmMessage));
		};
		
		$rootScope.confirmOK = function(message, okBack) {
			var scope = this;
			var cfmMessage = {
				"title" : "提示",
				"message" : message,
			};
			$nativeCall.confirmOK.call(this, function(confirm) {
				if (confirm == "Yes") {
					if ( typeof okBack === "function") {
						scope.$apply(okBack());
					}
				}
			}, vx.toJson(cfmMessage));
		};
		$rootScope.confirm = function(message, okBack, cancleBack) {
			var scope = this;
			var cfmMessage = {
				"title": "确认",
				"message": message,
				"positiveText": "确定",
				"negativeText": "取消"
			};
			$nativeCall.confirm.call(this,function(confirm){
				if(confirm=="Yes"){
					if(typeof okBack === "function"){
						scope.$apply(okBack());
					}
				}
				else {
					if(typeof cancleBack === "function"){
						scope.$apply(cancleBack());
					}
				}
			},vx.toJson(cfmMessage));
		};
		$rootScope.toast = function(errMessage){
			$nativeCall.toast(errMessage);
		};
         $rootScope.toshowred = function(message){
         $nativeCall.toshowred(message);
         };
		$rootScope.onLoadURL = function(url){
			$nativeCall.onLoadURL(url);
		};
		$rootScope.authenticate = function(callback){
			$nativeCall.authenticate(callback);
		};
		
		$rootScope.getPhoneNumber = function(callback){
			$nativeCall.getPhoneNumber(callback);
		};
		
		$rootScope.ewmShow = function(callback,message){
			$nativeCall.ewmShow(callback,message);
		};
		
		$rootScope.imtShow = function(callback,message){
			$nativeCall.imtShow(callback,message);
		};
		
		$rootScope.getBranch = function(callback,message){
			$nativeCall.getBranch(callback,message);
		};
		
		$rootScope.alertK = function(callback,message){
			$nativeCall.alertK(callback,message);
		};
		
		$rootScope.openShake = function(callback){
			$nativeCall.openShake(callback);
		};
		
		$rootScope.closeShake = function(callback){
			$nativeCall.closeShake(callback);
		};
		
		$rootScope.serveTelPhone = function(url){
			$nativeCall.serveTelPhone(url);
		};
		
		$rootScope.finishWeb = function() {
			$nativeCall.finishWeb();
		};
		
		$rootScope.finishWebWithMessage = function(message) {
			$nativeCall.finishWebWithMessage(message);
		};
		
		$rootScope.ShakeMobile = function(callback) {
			$nativeCall.ShakeMobile(callback);
		};
		
		$rootScope.OpenHTML = function(message) {
			$nativeCall.OpenHTML(message);
		};
 
         $rootScope.getFundCollectData = function(callback,message) {
            $nativeCall.getFundCollectData(callback,message);
         };
 
		$rootScope.getPassword = function(callback,message) {
			$nativeCall.getPassword(callback,message);
		};
		
		$rootScope.getMseCode = function(callback) {
			$nativeCall.getMseCode(callback);
		};
		
		$rootScope.alertAllow = function(callback,message) {
			$nativeCall.alertAllow(callback,message);
		};
		
		$rootScope.blueTooth = function(callback,message) {
			$nativeCall.blueTooth(callback,message);
		};
		
		$rootScope.getRewardTransName = function(callback,message) {
			$nativeCall.getRewardTransName(callback,message);
		};
		
		$rootScope.goToLoginHTML = function() {
			$nativeCall.goToLoginHTML();
		};
		
		$rootScope.gotoUrl = function(url){
			$goto(url);
		};
		
		$rootScope.openWebsite = function(url){
			$nativeCall.openWebsite(url);
		};

		$rootScope.loadPage = function(sourse, targets) {
			$nativeCall.pages.push(sourse);
			$nativeCall.history = [];
			$targets("content", targets);
		};
		$rootScope.getErWeiMaInfo = function(callback){
			$nativeCall.getErWeiMaInfo(callback);
		}
		$rootScope.getClientState = function(callback){
			$nativeCall.getClientState(callback);
		}
		$rootScope.changeClientInfo = function(message){
			$nativeCall.changeClientInfo(message);
		}
		$rootScope.getSignData = function(callback,message){
			$nativeCall.getSignData(callback,message);
		}
		/**
		 *页面统一跳转
		 */
		$rootScope.goto = function(param1, param2) {
			var targetURL, flag = /[#]+/.test(arguments[arguments.length - 1]);
			switch (arguments.length) {
				case 1:
					flag && ( targetURL = param1);
					!flag &&($nativeCall.pages=[])&&($nativeCall.history = [])&&( targetURL = "htmls/" + param1 + "/" + param1 + ".html");
					break;
				case 2:
					flag && ( targetURL = "htmls/" + param1 + "/" + param1 + ".html") ;
					!flag && $nativeCall.pages.push("htmls/" + param1 + "/" + param1 + ".html") && ($nativeCall.history = []) && ( targetURL = "htmls/" + param2 + "/" + param2 + ".html");
					break;
			}
			$nativeCall.loadTransfer(targetURL);
		};
		$rootScope.finishWeb = function() {
			// 购买完成删除详情页的title
			//$rootScope.title=undefined;
			$nativeCall.finishWeb();
			//$rootScope.goto("welcome");
		};

		$rootScope.openWebsite = function(url) {
			$nativeCall.openWebsite(url);
		};
		/**显示或隐藏产品特点*/
		$rootScope.toggleTrait= function(){
	        if($(".prod_trait").css("display")=="none"){
	            $(".prod_trait").show();
	        }else{
	            $(".prod_trait").hide();
	        }
	    };
	    /**
		 * 处理日期
		 * param--负数往前  正数往后
		 */
	    $rootScope.getDate=function(today,param,splitFlag){
	    	splitFlag?splitFlag:splitFlag="";
			today.setDate(today.getDate()+param);
			var yyyy=today.getFullYear();
			var mm=today.getMonth()+1;
			var dd=today.getDate();
			if(mm<=9){
				mm="0"+mm;
			}
			if(dd<=9){
				dd="0"+dd;
			}
			return yyyy+splitFlag+mm+splitFlag+dd;
		}
	    /**
	     * 把string封装为Date：20100102封装成data类型
	     */
	    $rootScope.formartDate=function(str,param,splitFlag){
	    	var year,mm,dd;
			if(str.indexOf("-")<0){
				year=str.substring(0,4);
				if(str.charAt(4)=='0'){
					mm=str.charAt(5);
				}else{
					mm=str.substring(4,6);
				}
				if(str.charAt(6)=='0'){
					dd=str.charAt(7);
				}else{
					dd=str.substring(6,8);
				}
			}else{
				var temp=str.split("-");
				year=temp[0];
				mm=temp[1];
				dd=temp[2]
			}
			var newDate=new Date(year,mm-1,dd);
			return $rootScope.getDate(newDate,param,splitFlag);
	    }
	    
		$rootScope.showHelp = function() {
			var childdiv = document.getElementById("content").getElementsByTagName("div");
			var inLoadDivId = childdiv[1].getAttribute("v-view-setup");
			if (inLoadDivId == null || inLoadDivId == "") {
				inLoadDivId = childdiv[1].getAttribute("v-controller");
			}
			var scope = this;
			$http.post("/bweb/HelpContentQry.do", {
				"id" : inLoadDivId
			}).success(function(data, status, headers, config) {
				scope.helpContentList = data.List;
				$nativeCall.history.push(function() {
					$nativeCall.backTransition();
					$timeout(function() {
						$('#Help').hide();
						$("#HelpImg").show();
						$('#content').css("display", "block");
						$nativeCall.startTransition();
					}, 50);
				});
				$nativeCall.forWardTransition();
				$timeout(function() {
					$('#content').css("display", "none");
					$('#Help').show();
					$("#HelpImg").hide();
					window.scrollTo(0, 0);
					$nativeCall.startTransition();
				}, 50);
			}).error(function(data, status, headers, config) {
				$nativeCall.toast(vx.toJson(data));
			});

		};
		
		/**
		 * 音频KEY所需要的字段转换为xml报文格式（后发送给客户端）
		 */
		$rootScope.getSignSourceValue=function(KeyMessage,sourceFieldHidden){
			var td = "<T><D>";
			var mk = "<M><k>";
			var km = "</k></M>";;
			var d = "</D>";
			var t = "</T>";
			var e1 = "<E>";
			var e2 = "</E>";
			var getKeyMessage="";
			var keyM = KeyMessage.split("|");
			for(var i=0;i<keyM.length;i++){
				var keyMM = keyM[i];
				var tempMsg =keyMM.split("#");
				getKeyMessage+= "<M><k>" + tempMsg[0]  + "：</k><v>" + tempMsg[1] + "</v></M>";
			}	
			if(sourceFieldHidden != ""){
				getKeyMessage =getKeyMessage  + d + e1;
			  	var keyH = sourceFieldHidden.split("|");
			  	for(var i=0;i<keyH.length;i++){
						var keyHH = keyH[i];
						var tempMsg =keyHH.split("#");
						getKeyMessage+= "<M><k>" + tempMsg[0]  + "：</k><v>" + tempMsg[1] + "</v></M>";
					}
					getKeyMessage = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>'+td+getKeyMessage +e2+t;
			  }else{
			  	getKeyMessage = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>'+td+getKeyMessage +d+t;
			  }
			return getKeyMessage;
		};
		/**
		 * 币种转换字典：
		 * 人民币-01
		 * 英镑-12
		 * 港币-13
		 * 美元-14
		 * 日元-27
		 * 澳大利亚元=29
		 * 欧元-38
		 */
		$rootScope.RMBChange=function(item){
			if(item=="人民币"){
				return "01";
			}else if(item=="英镑"){
				return "12";
			}else if(item=="港币"){
				return "13";
			}else if(item=="美元"){
				return "14";
			}else if(item=="日元"){
				return "27";
			}else if(item=="澳大利亚元"){
				return "29";
			}else if(item=="欧元"){
				return "38";
			}
		};
		/**
		 * 迭代获取密码输入栏的位置
		 */
		$rootScope.getPWPosition=function(e){
			var y=0;
			while(e!=null){
				y+=e.offsetTop;
				e=e.offsetParent;
			}
			return y;
		};
		/**
		 * windowScroll,解决因原生键盘收缩导致的页眉出现空白
		 */
		$rootScope.windowScroll=function(){
			window.scroll(0,0);
		};
		/**
		 * float型字符型数字,保留n位小数
		 * @param 保留的小数点后位数
		 */
		$rootScope.FloatPrecision=function(input,param){
			if(input!==undefined){
				if(param==0){
					input=parseInt(input);
				}else if(param>0){
					input=Math.round(input*Math.pow(10,param))/Math.pow(10,param);
				}
				return input;
			}
		}
	}

	
	runNativeCall.$inject = ['$nativeCall'];
	function runNativeCall($nativeCall) {
		window.NativeCall = $nativeCall;
	}
	
	runOS.$inject = ['$os'];
	function runOS($os){
		window.OS = $os;
	}

	mod.run(runTargets);
	mod.run(runOS);
	mod.run(runRootScope);
	mod.run(runNativeCall);

})(window, window.vx, window.jQuery);

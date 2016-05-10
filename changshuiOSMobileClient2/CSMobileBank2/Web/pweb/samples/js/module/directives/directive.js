/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
/**
 * @author
 * directive template
 */
(function(window, vx, undefined) {'use strict';

	var mod = vx.module("ui.libraries");
	mod.directive("*vSubmit", ['$timeout',function($timeout) {
		return function(scope, element, attrs) {
			element.bind('submit', function(event) {
				window.BHButton = $(event.target).find("button[type=submit],input[type=submit][type=button]");
				var form = scope[attrs.name];
				var inputCtrls = attrs.$$element[0];
				for(var i = 0; i < inputCtrls.length; i++) {
					var ctrl = inputCtrls[i];
					if(['input', 'select'].indexOf(ctrl.tagName.toLowerCase()) !== -1) {
						ctrl.blur();
					}
					var validateAttr = ctrl.getAttribute("validate") || true;
					//默认原输入域的验证属性
					if((ctrl.nodeName === "BUTTON") || (validateAttr === 'false')) {
						continue;
					}
					var message = {
						required : ctrl.getAttribute("required-message") || "不能为空",
						min : ctrl.getAttribute("min-message") || "最小值:" + ctrl.getAttribute("min"),
						max : ctrl.getAttribute("max-message") || "最大值:" + ctrl.getAttribute("max"),
						minlength : ctrl.getAttribute("minlength-message") || "最小长度:" + ctrl.getAttribute("v-minlength"),
						maxlength : ctrl.getAttribute("maxlength-message") || "最大长度:" + ctrl.getAttribute("v-maxlength"),
						pattern : ctrl.getAttribute("pattern-message") || "格式不正确",
						email : "格式不正确"
					};
					var ctrlName = ctrl['name'] || ctrl['id'];
					var ctrlComment = ctrl.parentNode.previousElementSibling ? ctrl.parentNode.previousElementSibling.innerText + " " : ctrl.placeholder;
					//var ctrlComment = "[" + ctrl.parentNode.previousElementSibling.innerText + "]  ";
					for(var key in form.$error) {
						for(var j = 0; j < form.$error[key].length; j++) {
							if(ctrlName == form.$error[key][j].$name) {
								if(ctrlComment === ctrl.placeholder){
									 if(key=="pattern"){
										 alert(message[key]);
									 }else{
										 alert(ctrlComment);
									 }
									
								} else {
									alert(ctrlComment.replace(":","").replace("：","") + message[key]);
								}
								return;
							}
						}
					}
				}
				scope.$apply(attrs.vSubmit);
				event.stopPropagation();
				event.preventDefault();
			});
		};
	}]);
})(window, window.vx);


/**
 * input directive
 * Call native keyboard program
 * @auther
 */

(function(window,vx,$){
	'use strict';
	
	var mod = vx.module("ui.libraries");
	
	mod.directive("input", ["$os", "$nativeCall", function($os, $nativeCall){
		return {
			restrict: 'E',
			compile: function(element, attr, transclude){
				var type = element.attr("type"),button;
				// handle input number.
				if(type === "number"){
					// default number length's 12.
//					var maxlength = element.attr("maxlength")|| 22;
//					maxlength = parseFloat(maxlength) > 22 ? 22 : maxlength;
					element.bind("input", function(){
						this.value = "" + this.value;
						// repalce UNSUPPORT
						var reg = /[-\/]?/g;
						if(reg.test(this.value))
							this.value = this.value.replace(reg, "");
						
						// substring "."
						if(this.value.indexOf('.')!=-1){
							var index = this.value.indexOf('.');
							this.value = this.value.substring(0,index+3);
							
						}
						// if value's length over maxlength
						if(this.value && this.value.length > maxlength){
							this.value = this.value.substring(0, maxlength);
						}
					});
				}else if(type === "text" && !attr.maxlength){
					var maxlength = element.attr("maxlength") || 30;
					element.bind("input", function(){
						// if value's length over maxlength
						if(this.value && this.value.length > maxlength){
							this.value = this.value.substring(0, maxlength);
						}
					});
				}else if(($os.iphone||$os.android || $os.wphone) && type==="date"){
					var date=element[0];
					var ediv=document.createElement("div");
					ediv.id="mapp_"+date.id;
					ediv.className="mapp_date"+date.className;
					ediv.style.marginleft="0";
					ediv.innerHTML=date.value?date.value:date.placeholder;
					vx.element(ediv).attr("v-bind",attr.vModel);
					vx.element(ediv).bind("click",function(e){
						var that=this;
						$nativeCall.datePicker(function(value){
							that.innerHTML=value;
							vx.element(that).trigger("input");
						},date.value);
					});
					vx.element(ediv).bind("input",function(){
						date.value=this.innerHTML;
						vx.element(date).trigger("input");
					});
					element[0].parentNode.appendChild(ediv);
					element[0].style.display="none";
					
				}		
			}
		}
	}]);
	
	/**
	 *  directive 	key-allow 
	 *  value 	symbol(default)  允许输入数字、字母、特殊字符
	 *  value 	number	允许输入数字
	 *  value	word	允许输入数字、字母
	 *  value   tel     允许输入数字、-
	 *  value   amount  允许输入数字和小数点
	 *  usage    key-allow   key-allow="number|word|symbol"
	 */
	
	mod.directive("keyAllow", function(){
		return {
			require: "^?vModel",
			link: function(scope, element, attr, ctrl){
				var keyAllow = attr.keyAllow || "symbol";
				ctrl.$render = function(){
					element.val(ctrl.$modelValue);
				}
				element.bind("input", function(event){
					scope.$apply(function(){
						var value = element.val();
						if(keyAllow === "number"){
							value = value.match(/^[0-9]*/);
						} else if(keyAllow === "word"){
							value = value.match(/^[0-9a-zA-Z]*/);
						} else if(keyAllow === "symbol"){
							value = value.match(/^[!-~]*/);
						} else if(keyAllow === "tel"){
							value = value.match(/^[0-9-]*/);
						} else if(keyAllow === "amount"){
							value = value.match(/^[0-9.]*/);
						}
						element.val(value ? value[0] : null);
					});
				});
			}
		}
	});
	
	/**
	 * @doc directive
	 * @name acformat
	 * @description
	 *  输入域失去焦点时格式化账号 "1111222233334444" -> "1111 2222 3333 4444"
	 * @example
	 	<input type="text" v-model="AcNo" acformat />
	 */
	mod.directive("acformat", function(){
		return {
			restrict: 'A',
			require: "?vModel",
			link: function(scope, element, attr, ctrl){
				function formatAcNo(value){
					if(vx.isEmpty(value)){
						return value;
					} else {
						return value.replace(/(.{4})/g,"$1 ");
					}
				}
				
				ctrl.$render = function() {
					element.val(formatAcNo(ctrl.$modelValue));
				};
				
				element.bind('blur', function() {
					scope.$apply(function(){
						var value = formatAcNo(ctrl.$modelValue);
						//ctrl.$setViewValue(value);
						ctrl.$viewValue = value;
						element.val(ctrl.$viewValue);
					});
				});
				
				element.bind('focus', function(){
					scope.$apply(function(){
						ctrl.$setViewValue(ctrl.$modelValue);
						element.val(ctrl.$viewValue);
					});
				});
			}
		}
	});
	
	mod.directive("maxlength",["$os", function($os){
		return {
			restrict: 'A',
			link: function(scope, element, attr){
				if($os.android && $os.weixin){
					var length = parseInt(attr.maxlength);
					element.removeAttr("maxlength");
					element.bind("input", function(){
						scope.$apply(function(){
							var value = element.val();
							if(value.length > length){
								element.val(value.substr(0,length));
							}
						});
					});
				}
			}
		}
	}]);
	
})(window,window.vx,window.$);


/*
 * restore samsung mobile input[type=date] value repeat
 */
(function(window, vx, undefined) {'use strict';

var mod = vx.module("ui.libraries");
mod.directive("vDate", ["$os","Util", function($os, Util) {
	function isSupportDate(){
		var inputElem = document.createElement("input"),smile = ':)';
		inputElem.setAttribute('type', "date");
        var bool = inputElem.type === 'date';
        if(bool){
        	inputElem.value = smile;
            inputElem.style.cssText = 'position:absolute;visibility:hidden;';
            bool = inputElem.value != smile;
        }
        inputElem = null;
		return !!bool;
	}
	return function(scope, element, attrs) {
		if($os.android && isSupportDate()){
			element.bind("input", function(){
				var value = element.val();
				if(value.length > 10){
					element.val(value.substring(0,10));
				}
			});
			element.bind("focus", function(){
				var value = element.val();
				if(vx.isEmpty(value)){
					element.val(Util.getDate());
				}
			});
		}
	};
}]);
})(window, window.vx);

/**
 * 获取短信验证码按钮倒计时指令，该指令暂时适用于button控件
 * <button class="btn btn-small" v-Sms="getToken()">获取验证码</button>
 */
(function(window,vx,$){
	'use strict';
	var mod = vx.module("ui.libraries");
	mod.directive("vSms",["$timeout",function($timeout){
		return{
			restrict:'A',
			scope:false,
			link:function(scope,element,attrs){
				var fnName = element.attr("v-Sms");
				if(fnName.indexOf('(') != -1){
					fnName = fnName.substring(0,fnName.indexOf('('));
				}				
				var SECEND = 60;
				var count = SECEND;
				var timeid;
				var history = 0;
				var text = "";
				element.bind("click",function(){
					text = "点击重发"
					element.text(text+"("+SECEND+")");
					element.attr("disabled","disabled");
					decrement();
					scope.$on("$remoteError", function(event,url,error){
						//if(error.indexOf("动态密码错误") >= 0){
							element.css("background-color","#0084ff");
							$timeout.cancel(timeid);
							$timeout.cancel(closeId);
							element.text(text+"("+count+")");
							element.text(text);
							count = SECEND;
							element.removeAttr("disabled");
							scope["OTPPassword"] = null;
							scope["OTPSeq"] = null;
						//}
					});
					history = NativeCall.history.length;
					closeTimeout();
					scope[fnName]();
				});
				
				function decrement(){
					element.css("background-color","#afafaf");
					timeid = $timeout(function(){
						count = count - 1;
						if(count == 0){
							$timeout.cancel(timeid);
							element.text(text+"("+count+")");
							element.text("点击重发");
							count = SECEND;
							element.removeAttr("disabled");
							element.css("background-color","#0084ff");
						}else{
							element.text(text+"("+count+")");
							decrement();
						}
						
					},1000);
				}
				
				//监听页面是否跳转
				var closeId;
				function closeTimeout(){
					closeId = $timeout(function(){
						if(history != NativeCall.history.length){
							$timeout.cancel(timeid);
							$timeout.cancel(closeId);
							element.text(text+"("+count+")");
							element.text(text);
							count = SECEND;
							element.removeAttr("disabled");
						}else{
							closeTimeout();
						}
					},100);
				}
			}
		}
		
	}]);
})(window,window.vx,window.$);


/**
 * pager directive
 * 如果element包含"FilterWatch"属性，则会将结果列表用"FilterWatch"属性值进行过滤，将过滤结果展示到页面，"FilterExp"为过滤事件。
 * </div>和{{}}数据绑定之间留空格或换行
 * @auther
 */

(function(window, vx, $) {'use strict';

	var mod = vx.module("ui.libraries");

	mod.directive('vPager', ['$compile', '$filter',function($compile, $filter) {
		var vPagerDefinition = {
			compile : function compile(element, attr, transclude) {
				var PAGE_NAME = element.attr('PageName') || element.attr('pageName') || element.attr('pagename') || 'PAGE';
				var PAGE_SIZE = element.attr('PageSize') || element.attr('pageSize') || element.attr('pagesize') || 10;
				PAGE_SIZE = parseInt(PAGE_SIZE);
				var PAGE_ATTR = element.attr('v-pager');
				var FILTER_WATCH = element.attr('FilterWatch') || element.attr('filterWatch') || element.attr('filterwatch');
				var FILTER_EXP = element.attr('FilterExp') || element.attr('filterExp') || element.attr('filterexp') || FILTER_WATCH;
				var LIST_NAME = PAGE_ATTR.match(/in\s*(\w*)$/)[1];
				element.removeAttr('v-pager');
				element.attr('v-repeat', PAGE_ATTR.replace(/in\s*(\w*)$/, 'in ' + 
						PAGE_NAME + '.' + LIST_NAME));
				return {
					post : function postLink(scope, element, attrs) {
						var NewPage = function(page, list) {
							page.$_pageInit = function() {
								page.PageIndex = 0;
								page.RecordNumber = list.length;
								page.CurrentPage = list.length == 0 ? 0 : 1;
								page.PageNumber = Math.ceil(list.length / PAGE_SIZE);
								page.$_pageSize = PAGE_SIZE;
								page[LIST_NAME] = list.slice(0, PAGE_SIZE);
							};
							page.moreNextPage = function() {
								page.PageIndex = page.PageIndex + page.$_pageSize;
								var nextStart = page.PageIndex;
								page.CurrentPage++;
								page[LIST_NAME] = page[LIST_NAME].concat(list.slice(nextStart, nextStart + PAGE_SIZE));
							};
							page.nextPage = function() {
								page.PageIndex = page.PageIndex + page.$_pageSize;
								page.CurrentPage++;
								changePage();
							};
							page.prevPage = function() {
								page.PageIndex = page.PageIndex - page.$_pageSize;
								page.CurrentPage--;
								changePage();
							};
							page.topPage = function() {
								page.PageIndex = 0;
								page.CurrentPage = 1;
								changePage();
							};
							page.bottomPage = function() {
								page.PageIndex = PAGE_SIZE * (page.PageNumber - 1);
								page.CurrentPage = page.PageNumber;
								changePage();
							};
							function changePage() {
								page[LIST_NAME] = list.slice(page.PageIndex, page.PageIndex + PAGE_SIZE);
								window.scrollTo(0, 0);
							}
							page.$_pageInit();
						};
						$compile(element)(scope);
						scope.$watch(LIST_NAME, function() {
							scope[PAGE_NAME] = scope[PAGE_NAME] || {};
							NewPage(scope[PAGE_NAME], scope[LIST_NAME]||[]);
						});
						FILTER_WATCH && scope.$watch(FILTER_WATCH, function(){
							scope[PAGE_NAME] = {};
							NewPage(scope[PAGE_NAME], $filter('filter')(scope[LIST_NAME]||[], scope[FILTER_EXP]));
						});
					}
				};
			}
		};
		return vPagerDefinition;
	}]);
})(window, window.vx, window.$);


/**
 * vSwitch directive
 * @auther
 */

(function(window,vx,$){
	'use strict';
	var mod = vx.module("ui.libraries");
	mod.directive("vSwitch", [function(){
		return {
			restrict: 'A',
			link: function(scope, element, attr){
					var el = element[0];
					if(el.type!=="checkbox"){
						return;
					}
					element.hide();
					element.after('<label id="switch_'+ el.id +'" for="' + el.id +'" class="switch"></label>');
					scope.$watch(attr.vModel, function(value){
						if(value){
							element.siblings('#switch_' + el.id).removeClass("switch-off");
							element.siblings('#switch_' + el.id).addClass("switch");
						} else{
							element.siblings('#switch_' + el.id).removeClass("switch");
							element.siblings('#switch_' + el.id).addClass("switch-off");
						}
					});
				}
		}
	}]);
	mod.directive("vHeight", [function(){
		return {
			restrict: 'A',
			link: function(scope, element, attr){
				//var height = document.body.scrollHeight - 40;
				///window.devicePixelRatio
				var height = window.screen.height/window.devicePixelRatio -80;
				element.css("height",height+"px");
				alert(height);
			}
		}
	}]);
	
})(window,window.vx,window.$);

/**
 * pager directive
 * 1、每次查看更多都是从服务端获取数据，js端不做缓存，所以默认的pageSize大小应该与
 *    服务端的默认页大小一致，或者web每次查询都上送pageSize参数
 * 2、需要query.mobile-x.x.x.js插件支持
 * 3、scope.totalnumber 总记录数是必要条件
 * @auther zhoujg
 */

(function(window, vx, $) {'use strict';

	var mod = vx.module("ui.libraries");

	mod.directive('vMorePage', ['$compile', function($compile) {
		var vPageDefinition = {
			compile : function compile(element, attr, transclude) {
				var PAGE_NAME = element.attr('PageName')|| element.attr('pageName') || element.attr('pagename')|| 'PAGE';
				var PAGE_SIZE = element.attr('PageSize')|| element.attr('pageSize') || element.attr('pagesize')|| 10;
				PAGE_SIZE = parseInt(PAGE_SIZE);
				var PAGE_ATTR = element.attr('v-more-page');
				var LIST_NAME = PAGE_ATTR.match(/in\s*(\w*)$/)[1];
		    	element.removeAttr('v-more-page');
				element.attr('v-repeat', PAGE_ATTR.replace(/in\s*(\w*)$/, 'in '+ PAGE_NAME + '.' + LIST_NAME));
//                var nextButton = $('<a class="button_1" id="nextButton" v-click="'
//                    + PAGE_NAME + '.moreNextPage()">查看更多</a>');
//	    		element.after(nextButton);
				return {
					post : function postLink(scope, element, attrs) {
						scope[PAGE_NAME] = scope[PAGE_NAME] || {};
						scope[PAGE_NAME].$_pageIndex=0;
						scope[PAGE_NAME].$_pageEndIndex=PAGE_SIZE;
						scope[PAGE_NAME].$_pageSize=PAGE_SIZE;
						scope[PAGE_NAME].$_isConcat = true;
						
						var oldX = 0,oldY = 0,newX = 0,newY = 0;
						
						var NewPage = function(page, list) {
							page.$_pageInit = function(){
								if(scope.$_resetData){
									page.$_pageIndex = 0;
									page.$_pageEndIndex=PAGE_SIZE;
									scope.$_totalList = [];
                                    if(scope.totalnumber <= scope.$_totalList.length) {
                                        $(nextButton).hide();
                                    }
                                    else
                                        $(nextButton).show();
									
								}
								if(scope.$_totalList == null || scope.$_totalList == undefined){
									scope.$_totalList = [];
									 $(nextButton).hide();
								}
								if(page.$_isConcat){
									scope.$_totalList = scope.$_totalList.concat(list);
								}
								page[LIST_NAME] = scope.$_totalList.slice(0, page.$_pageEndIndex);
								if(scope.totalnumber <= scope.$_totalList.length) {
									$(nextButton).hide();
								}
								if(!scope.totalnumber) {
									$(nextButton).hide();
								}
								/*else
									$(nextButton).show();*/
								scope.$_resetData = true;
							};
							page.moreNextPage = function() {
								page.$_pageIndex = page.$_pageIndex + page.$_pageSize;
								page.$_pageEndIndex = page.$_pageIndex + page.$_pageSize;
								if(/*page.$_pageEndIndex > scope.$_totalList.length && */scope.$_totalList.length < scope.totalnumber){
									scope.morepage(scope.$_totalList.length,page.$_pageEndIndex,page.$_pageSize);
									page.$_isConcat = true;
									scope.$_resetData = false;
                                }else{
                                    $(nextButton).hide();
									scope.$_resetData = true;
								}
								
							};
							page.$_pageInit();
						};
						
						$compile(element)(scope);
						scope.$watch(LIST_NAME, function(list) {
							scope[PAGE_NAME] = scope[PAGE_NAME] || {};
							NewPage(scope[PAGE_NAME], scope[LIST_NAME] || []);
						});
					}
				};
			}
		};
		return vPageDefinition;
	}]);
})(window, window.vx, window.$);

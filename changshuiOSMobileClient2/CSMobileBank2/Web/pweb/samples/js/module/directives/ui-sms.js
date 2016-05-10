/**
	 * 获取短信验证码按钮倒计时指令，该指令暂时适用于button控件
	 * <button class="btn btn-small" v-sms="getToken()">获取验证码</button>
	 */

	vx.module("ui.libraries").directive("uiSms",["$timeout",'$parse',function($timeout,$parse){
		return{
			restrict:'A',
			scope:false,
			link:function(scope,element,attrs){
				var fnName = attrs.uiSms;
				if(fnName.indexOf('(') != -1){
					fnName = fnName.substring(0,fnName.indexOf('('));
				}				
				var SECEND = 60;
				var count = SECEND;
				var timeid;
				var history = 0;
				var text = "";
				element.bind("click",function(){
					text = element.text();
					element.text(text+"("+SECEND+")");
					element.attr("disabled","disabled");
					decrement();
					scope.$on("$remoteError", function(event,url,error){
						$timeout.cancel(timeid);
						$timeout.cancel(closeId);
						element.text(text+"("+count+")");
						element.text(text);
						count = SECEND;
						element.removeAttr("disabled");
						//scope["OTPPassword"] = null;
					});
					history = NativeCall.history.length;
					closeTimeout();
					scope[fnName]();
				});
				
				function decrement(){
					timeid = $timeout(function(){
						count = count - 1;
						if(count == 0){
							$timeout.cancel(timeid);
							element.text(text+"("+count+")");
							element.text(text);
							count = SECEND;
							element.removeAttr("disabled");
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
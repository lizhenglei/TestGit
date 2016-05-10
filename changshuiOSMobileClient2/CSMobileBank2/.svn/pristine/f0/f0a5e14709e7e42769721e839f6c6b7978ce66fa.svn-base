/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
/**
 * @author kongxiangxu
 * transition services
 */
(function(window, vx, userAgent) {
	'use strict';
	
	var service = {};
	service.$transitions = ["$nativeCall","$os",function($nativeCall,$os) {
		var transitionProvider = {
			types : {
				'native' : 'native',
				'default' : 'default',
				'none' : 'none'
			},
			runTransition :runTransition,
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
				
				/*if($os.iphone4){
					$("input[type='text'],input[type='number']").bind("focus",function(){
						$('#header').addClass('pos-rel');
						$('#footer').addClass('pos-rel');
						$("#content").css("margin-top","0");
					});
					$("input[type='text'],input[type='number']").bind("focusout",function(){
						if($('#footer').css("display")!=="none"){
							NativeCall.showTransptView();
							$("#content").css("min-height",window.screen.height-44-53-6);
							$('#header').css("top","0");
							$('#footer').css("bottom","0");
						}
						if($('#footer').css("display")=="none"){
							NativeCall.showTransptView();
							$("#content").css("min-height",window.innerHeight-44-6);
							$('#header').css("top","0");
						}
						
					});
				}*/
				if(newEl.attr("data-back")==="false") {//跳转到结果页
					$nativeCall.history = [];
					$nativeCall.setBackButtonVisibility(true);
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
					//display backbutton
					//if($nativeCall.isHideBackButton){
						$nativeCall.setBackButtonVisibility();
					//}
				}
				if(oldEl !== null){
					if(!back) {
						$nativeCall.forWardTransition();
					} else {
						$nativeCall.backTransition();
					}
					if(newEl && newEl.length) {
						if(oldEl && oldEl.length) {
							oldEl.css('display', 'none');
							if(remove)
								oldEl.remove();
						}
						newEl.css('display', 'block');
					}
					
				}else {
					newEl.css("display","block");
				}
				finishTransition(oldEl, newEl, remove, back);
			}
			
			function finishTransition(oldEl, newEl, remove, back) {				
				/*if($os.iphone4){
					if($('#footer').hasClass("pos-rel")){
						$('#footer').removeClass('pos-rel');
						$("#content").css("margin-top","44px");
					}
					if($('#header').hasClass('pos-rel')){
						$('#header').removeClass('pos-rel');
						$("#content").css("margin-top","44px");
					}
				}*/
				//this.activePage = newEl;
				$nativeCall.setTitle(newEl.attr("title"));
				// 导航栏右边的help
				var rightIcon = vx.element(".help");
				if(vx.isEmpty(newEl.attr("help"))){
					rightIcon.text("").unbind("click");
				} else {
					var scope = newEl.scope(),obj= scope[newEl.attr("help")];
					rightIcon.append(obj.text).addClass(obj.css)
						.bind("click",function(){
							scope.$apply(function(){
								obj.click();
							});
						});
				}
				// 根据title的内容多少来定义字体及行高
				if(window.innerHeight>1490){
					$(".topesttitle").css({"font-size":42,"line-height":44});
					for(var x=42; $(".topesttitle").height()+35>$(".topestH").height(); x--){
						$(".topesttitle").css("font-size",x);
						$(".topesttitle").css("line-height",1+0.05*(x-10));
						$(".topesttitle").css("padding-top",10);	
					}
				}else if (window.innerHeight>749){
					$(".topesttitle").css({"font-size":22,"line-height":24});
					for(var x=22; $(".topesttitle").height()+15>$(".topestH").height(); x--){
						$(".topesttitle").css("font-size",x);
						$(".topesttitle").css("line-height",1+0.05*(x-10));
						$(".topesttitle").css("padding-top",10);	
					}
				}else{
					$(".topesttitle").css({"font-size":18,"line-height":20});
					for(var x=18; $(".topesttitle").height()+10>$(".topestH").height(); x--){
						$(".topesttitle").css("font-size",x);
						$(".topesttitle").css("line-height",1+0.05*(x-10));
						$(".topesttitle").css("padding-top",8);			
					}
				}
				scrollToTop();
				$nativeCall.startTransition();
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
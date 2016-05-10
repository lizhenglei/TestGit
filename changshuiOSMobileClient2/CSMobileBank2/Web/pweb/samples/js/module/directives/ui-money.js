/**
 * this directive only use for Guangda bank
 * @author
 * 
 */
vx.module('ui.libraries').directive('uiMoney', ["$timeout", "$compile",
function($timeout, $compile) {
	return {
		   restrict : 'A',
		   link : function(scope, element, attrs) {
			   var params=vx.fromJson(attrs.uiMoney||{});
			   scope.$watch(params.amounts,function(){
				   if(scope[params.amounts]){
					   var amounts=scope[params.amounts]+"";
					   var charat=amounts.indexOf(".");
					   var prev,rel;
					   if(charat<0){
						   prev=amounts;
						   rel=".00元";
					   }else{
						   prev=amounts.substring(0,charat);
						   var tempRel=amounts.substring(charat);
						   rel=tempRel.length<=2?tempRel+"0元":tempRel+"元";
					   }
					   
					   var str="<strong class='prev'>"+prev+"</strong><strong class='rel'>"+rel+"</strong>"
					   $(element).empty();
					   $(element).append(str);
				   }
			   });
		   }
	   };
}]);

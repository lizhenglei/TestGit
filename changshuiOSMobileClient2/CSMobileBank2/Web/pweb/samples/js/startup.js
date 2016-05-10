/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true*/
/**
 * @author kongxiangxu
 * Manually start the vx and open trasfer
 */
var init = function() {
	vx.bootstrap(document.body, ["mapp"]);
	function getQueryString(name) {
	    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
	    var r = window.location.search.substr(1).match(reg);
	    if (r != null) return unescape(r[2]); 
	    return null;
    }
    //手机使用  配合moke.js
	if(window.NativeCall){
		 NativeCall.getActionId(function(data){
			 //data = vx.fromJson(data);
			 //var actionId = data.ActionId;
			 var actionId = data;
			 var url = "htmls/"+actionId+"/"+actionId+".html";
			 if(window.NativeCall){
				 window.NativeCall.loadTransfer(url);
			 }
		 });
	 }

	
};
if(document.addEventListener){
	document.addEventListener("DOMContentLoaded", init, false);
}else if(document.attachEvent){//for ie
	document.attachEvent( "onreadystatechange", init );
}


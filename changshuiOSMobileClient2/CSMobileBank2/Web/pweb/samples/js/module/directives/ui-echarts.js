/*jshint smarttabs:true, eqeqeq:false, eqnull:true, laxbreak:true */
//echarts包括12种图形：
//line-折线图\scatter-散点图、气泡图\k-k线图\pie-饼图\radar-雷达图\chord-和弦图\force-力导布局图
//map-地图\evnetRiver-河流图\gauge-仪表图\funnel-漏斗图
/**
 * @author cuishoujia
 */
(function(window, vx, undefined) {'use strict';
	var directive = {};
	directive.uiEcharts = [
	function() {
		return {
			restrict : 'A',
			link : function(scope, element, attrs) {
				var options = vx.fromJson(attrs.uiEcharts || {});
				 scope.$watch(options.param,function(){
					 if(scope[options.param]){
						 options=scope[options.param];
						 drawChart(options);
					 }
                 });
				
				function drawChart(param){
					var etype = param.etype;
					//因为echarts入口方法init只接受Dom对象参数，所以在此先转换对象成Dom对象
					var domElement = element[0];
					var _setChart = function() {
					// Step:1为模块加载器配置echarts的路径，从当前页面链接到echarts.js，定义所需图表路径
					require.config({
						paths : {
							echarts : 'js/echarts'
						}
					});
					// Step:2 动态加载echarts然后在回调函数中开始使用，注意保持按需加载结构定义图表路径
					require(['echarts', 'echarts/chart/' + etype], function(ec) {
						var myChart = ec.init(domElement);
						myChart.setOption(param);
					});
					}
					_setChart();
					/*窗口分辨率改变重新画图*/
					$(window).resize(function() {
						param = vx.fromJson(attrs.uiEcharts || {});
						_setChart();
					});
				}
			}
		};
	}];
	vx.module('ui.libraries').directive(directive);
})(window, window.vx);

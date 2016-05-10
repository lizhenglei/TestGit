/**
 * @author QinChan WangBaoRen
 * @create time 2013.10.31 10:50
 */
(function(window, vx, undefined) {'use strict';
	var factory = {};
	factory.chartService = [
	function() {
		return {
			/**饼(环)形图参数
			 * _container：必填，显示图形的div
			 * _data：必填，需要显示的数据
			 * _param:必填，内容为该饼图的参数。其中：radius：可选，默认1 pie图的半径。0<_radius<=1时，表示图形占容器div的百分比，>1表示实际显示的像素数；
			 *        innerRadius：可选，默认0 pie图内圈的半径。0<_innerRadius<=1时，表示图形占容器div的百分比，>1表示实际显示的像素数
			 **/
			pie : function(_container, _data, _param) {
				$.plot(_container, _data, {
					series : {
						pie : {
							radius : _param.radius ? _param.radius : 0.5,
							innerRadius : _param.innerRadius ? _param.innerRadius : null,
							show : true
						}
					},
					grid : {
						hoverable : (_param.hoverable || _param.hoverable === false) ? _param.hoverable : true,
						clickable : (_param.clickable || _param.clickable === false) ? _param.clickable : true
					},
					colors : _param.colors ? _param.colors : undefined
				});
				this.hoverEvent(_container, "pie");

			},
			/**线形图参数
			 * _container：必填，显示图形的div
			 * _data：必填，需要显示的数据
			 * _param:必填，该线性图的参数。其中：categories：可选，是否自定义x轴显示内容。传入参数只要不为空，就用数据中的x值作为x轴坐标
			 *				不写则flot根据数据中x轴坐标自动生成坐标系
			 **/
			line : function(_container, _data, _param) {
				$.plot(_container, _data, {
					series : {
						lines : {
							//color:'black',
							show : true,
							fill : _param.fill ? _param.fill : false, //是否填充
							fillColor : _param.fillColor ? _param.fillColor : null //填充色
						},
						points : {
							show : (_param.showPoints || _param.showPoints === false) ? _param.showPoints : true
						}
					},
					grid : {
						hoverable : (_param.hoverable || _param.hoverable === false) ? _param.hoverable : true,
						clickable : (_param.clickable || _param.clickable === false) ? _param.clickable : true
					},
					xaxis : {
						mode : _param.mode ? _param.mode : null
					},
					legend : {
						margin : [_param.legendMarginX ? _param.legendMarginX : 0, _param.legendMarginY ? _param.legendMarginY : 0]
					},
					colors : _param.colors ? _param.colors : undefined
				});
				this.hoverEvent(_container, "line");
				//设置轴文字说明
				this.setXYIntro(_container, _param);
			},
			/**柱形图参数
			 * _container：必填，显示图形的div
			 * _data：必填，需要显示的数据
			 * _param:必填，该柱状图的参数。其中：categories：可选，是否自定义x轴显示内容。传入参数只要不为空，就用数据中的x值作为x轴坐标
			 *				不写则flot根据数据中x轴坐标自动生成坐标系
			 **/
			bar : function(_container, _data, _param) {
				$.plot(_container, _data, {
					series : {
						stack : true,
						lines : {
							show : false,
							fill : true,
							steps : false
						},
						bars : {
							show : true,
							barWidth : _param.barWidth ? _param.barWidth : 0.3,
							fillColor : _param.fillColor ? _param.fillColor : null,
							align : _param.align ? _param.align : 'center',
							lineWidth : _param.lineWidth ? _param.lineWidth : null
						}
					},
					xaxis : {
						mode : _param.mode ? _param.mode : null,
						max : _param.max ? _param.max : null,
						min : _param.min ? _param.min : null,
						tickLength : (_param.tickLength || _param.tickLength === 0) ? _param.tickLength : null
					},
					grid : {
					}
				});
				//this.hoverEvent(_container, "bar");
				//设置轴文字说明
				this.setXYIntro(_container, _param);
			},

			/**轴文字说明
			 * _container:必填，显示图形的div
			 */
			setXYIntro : function(_container, _param) {
				if (_param.xIntro) {
					$(_container).append("<p id='XIntro' style='font-size:10px;position:absolute'>" + _param.xIntro + "</p>");
				}
				if (_param.yIntro) {
					$(_container).append("<p id='YIntro' style='font-size:10px;position:absolute'>" + _param.yIntro + "</p>");
				}
				$("#YIntro").css({
					"top" : 0,
					"left" : 0
				});
				$("#XIntro").css({
					"top" : $(_container).height(),
					"left" : $(_container).width() - 30
				});
			},
			/**鼠标移上显示数据信息事件
			 * _container:必填，显示图形的div
			 * _style:图形的类型，如饼图，线性图等
			 */
			hoverEvent : function(_container, _style) {
				$(_container).bind("plothover", function(event, pos, obj) {
					if (obj !== null) {
						if ($("#imgTip").length === 0) {
							$("body").append("<div id='imgTip' style='position: absolute;display:inline;background-color: white;width:auto;height:28px;padding:5px;color:grey;border:1px solid grey;text-align:center;line-height:18px;z-index:9999;-webkit-box-shadow: #ccc 0px 0px 20px;-moz-box-shadow: #ccc 0px 0px 20px;box-shadow:#ccc 0px 0px 20px;opacity: 1;-moz-opacity: 0.9;-khtml-opacity: 0.9;border-radius: 8px;-webkit-border-radius: 8px;-moz-border-radius: 8px;'></div>");
						}
						$("#imgTip").css("left", pos.pageX);
						$("#imgTip").css("top", pos.pageY - 20);
						if (_style == "pie") {
							var percent = parseFloat(obj.series.percent).toFixed(2);
							$("#imgTip").text(obj.series.label+":"+percent + "%");
						} else if (_style == "line") {
							$("#imgTip").css("width", "36px");
							$("#imgTip").css("height", "14px");
							$("#imgTip").css("line-height", "14px");
							$("#imgTip").text(obj.datapoint[1]);
						}
					} else {
						if ($("#imgTip").length !== 0) {
							var imgTipLeftPx = $("#imgTip").css("left");
							var imgTipTopPx = $("#imgTip").css("top");
							var imgTipLeft = parseInt(imgTipLeftPx.substring(0, imgTipLeftPx.length), 10);
							var imgTipTop = parseInt(imgTipTopPx.substring(0, imgTipTopPx.length), 10);
							if ((pos.pageX - imgTipLeft) > 20 || (pos.pageX - imgTipLeft) < -20 || (pos.pageY - imgTipTop) > 20 || (pos.pageY - imgTipTop) < -20) {
								$("#imgTip").remove();
							}
						}
					}
				});
			}
		};
	}];

	vx.module('ui.libraries').factory(factory);
})(window, window.vx);

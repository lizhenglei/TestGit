/**
 * add vBlur even for VX 
 * @author yoyo
 */
(function(window, vx, undefined) {
	'use strict';
	function injectRemote(el, locals, expr, submit, $$remote) {
		locals = locals || {};
		if (/\$remote\./.test(expr)) {
			var $remote = el.data('$remote');
			if (!$remote) {
				$remote = $$remote(el, submit);
				el.data('$remote', $remote);
			}
			locals.$remote = $remote;
		}
		return locals;
	}
	// var EVENTS = 'click dblclick mousedown mouseup mouseover mouseout
	// mousemove mouseenter mouseleave keydown keyup keypress';
	var EVENTS = 'blur focus';
	var vEventDirectives = {};
	vx.forEach((EVENTS).split(' '), function(name) {
		var directiveName = 'v' + name.charAt(0).toUpperCase()+name.slice(1);
		vEventDirectives[directiveName] = ['$parse','$$remote','$browser',
				function($parse, $$remote, $browser) {
					return function(scope, element, attr) {
						var fn = $parse(attr[directiveName]), eventName = vx.lowercase(name);
						var await = attr.await ? int(attr.await) : 0;
						var eventhandler = function(event) {
							scope.$apply(function() {
								fn(scope, injectRemote(element, {
									$event : event
								}, attr[directiveName], false, $$remote));
							}, directiveName);
						};
						if (await)
							eventhandler = $browser.debounce(eventhandler, await);
						element.bind(eventName, function handler(event) {
							var target = event.target;
							// XXX maybe need more justify it ???
							if (target !== element[0]) {// process Propagated
														// event
								var tname = _nodeName(target);
								// skip input elements bubbles
								if (tname === 'INPUT' || tname === 'TEXTAREA' || tname === 'BUTTON'
										|| tname === 'SELECT' || tname === 'OPTION')
									return;
							}

							eventhandler(event);

							// TODO: how to deal with $locationProvider's
							// $document.bind('click', function(event)...)
							// in Chrome 7.0.xxxx.0, click in form lead reload
							var nn = vx._nodeName(element);
							if (nn == 'A') {
								// event.stopPropagation();
								event.preventDefault();
							}
						});
					};
				} ];

	});
	vx.module('v').directive(vEventDirectives);
})(window, window.vx);
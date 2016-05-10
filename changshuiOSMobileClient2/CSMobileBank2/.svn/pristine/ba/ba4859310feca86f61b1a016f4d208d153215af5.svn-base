/*
 * sessionService
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
				c._data = obj;
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
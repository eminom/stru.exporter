

//Authored by eminem
//July.2o14

//This script intends to load struct from JSON representation
//And translate struct info into C++ for Lua exporting

var fs = require('fs');
var loadFromStream = require('./loader');	//
var loadJsonObj = require('./jloader');


var dispatchHandler = {
	integer: function(field, conf){
		console.log(conf.GetterIntImpl + '(' + field + ')');
	},
	string: function(field, conf){
		console.log(conf.GetterStringImpl + '(' + field + ')');
	}
};


function typeDispatcher(type, field, conf){
	if('function' == typeof(dispatchHandler[type])){
		dispatchHandler[type](field, conf);
	}
}


function printFields(stru, conf){
	for(var i in stru){
		typeDispatcher(stru[i], i, conf);
	}
}

function printLibs(stru, conf){
	console.log('static const luaL_reg '+conf.LibName+'[]={');
	for(var i in stru){
		console.log('  ' + conf.Entry + '(' + i + ')');
	}
	console.log('  {NULL, NULL}');
	console.log('};');
}

function testConf(conf){
	if( !conf.Entry ||
	    !conf.GetterIntImpl ||
			!conf.GetterStringImpl ||
			!conf.LibName){
			console.error('configure error');
			process.exit();
	}
	try{
		if(printConf){
			console.log('-------Configuration-----');
			for(var i in conf){
				console.log(i);
			}
			console.log('------Configuration Done-----');
			console.log();
			console.log();
		}
	}catch(err){
		//console.error(err);
	}
}


function main(){
	var conf = loadJsonObj('./conf');
	testConf(conf);
	//var source = process.argv.splice(2)[0];
	//var arch = loadJsonObj(source);
	var arch = JSON.parse(loadFromStream());
	arch = arch[''];

	console.log('//');
	console.log('//This code-snippet is generated automatically.');
	console.log('//Do not modify this manually');
	console.log('');
	console.log('');
	
	for(var i in arch){
		var tobj = arch[i];
 		printFields(tobj, conf);
		printLibs(tobj, conf);
	}
}

//Startup
main();

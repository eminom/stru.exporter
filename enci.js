

//Authored by eminem
//July.2o14

//This script intends to load struct from JSON representation
//And translate struct info into C++ for Lua exporting

var fs = require('fs');

function readIntermediate(){
	var args = process.argv.splice(2);
	var buf = fs.readFileSync(args[0]);
	var str = new String(buf);
	var arch = JSON.parse(str);
	return arch;
}

function printFields(stru){
	for(var i in stru){
		if('integer' === stru[i]){
			console.log('_BattleStr(' + i);
		} else if('string' === stru[i]){
			console.log('_BattleInt(' + i + ')');
		} else {
			throw "Invalid type for " + stru[i];
		}
	}
}

function printLibs(stru){
	console.log('static const luaL_reg battleConfigLib[]={');
	for(var i in stru){
		console.log('  _Entry(' + i + ')');
	}
	console.log('  {NULL, NULL}');
	console.log('};');
}

function main(){
	var arch = readIntermediate();
	printFields(arch.struct);
	printLibs(arch.struct);
}

//Startup
main();

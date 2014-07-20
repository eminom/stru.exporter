
var fs = require('fs');

function loadJsonObj(name){
	var buf = fs.readFileSync(name);
	var str = new String(buf);
	var arch = JSON.parse(str);
	return arch;
}

module.exports = loadJsonObj;

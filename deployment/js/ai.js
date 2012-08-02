$(document).ready(init); // Inicia a AI.

var query = jQuery.parseQuery();
console.log("a = " + query.a + " | b = " + query.b + " | c = " + query.c);
  
var aiNumber = "0115";
var x;


/*
 * Inicia a Atividade Interativa (AI)
 */
function init () {

  // Insere o filme Flash na página HTML
  // ATENÇÃO: os callbacks registrados via ExternalInterface no Main.swf levam algum tempo para ficarem disponíveis para o Javascript. Por isso não é possível chamá-los imediatamente após a inserção do filme Flash na página HTML.  
	var flashvars = {};
	flashvars.ai = "swf/AI-" + aiNumber + ".swf";
	flashvars.width = "640";
	flashvars.height = "480";
	flashvars.a = query.a;
	flashvars.b = query.b;
	flashvars.c = query.c;
	
	var params = {};
	params.menu = "false";
	params.scale = "noscale";

	var attributes = {};
	attributes.id = "ai";
	attributes.align = "middle";

	swfobject.embedSWF(flashvars.ai, "ai-container", flashvars.width, flashvars.height, "10.0.0", "expressInstall.swf", flashvars, params, attributes);
}

function thisMovie(movieName) {
	if (navigator.appName.indexOf("Microsoft") != -1) {
		return window[movieName];
	} else {
		return document[movieName];
	}
}

function f() {
	thisMovie("ai").f(x);
}

function reset() {
	thisMovie("ai").reseta();
}

function update() {
	thisMovie("ai").update();
}

function setA(a, _update) {
	thisMovie("ai").setA(a, _update);
}

function setB(b, _update) {
	thisMovie("ai").setB(b, _update);
}

function setC(c, _update) {
	thisMovie("ai").setC(c, _update);
}

function getA() {
	return thisMovie("ai").getA();
}

function getB() {
	return thisMovie("ai").getB();
}

function getC() {
	return thisMovie("ai").getC();
}

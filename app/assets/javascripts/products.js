var ready;
ready = function() {

// ex registration.js
var opts = {
  lines: 10, // The number of lines to draw
  length: 7, // The length of each line
  width: 3, // The line thickness
  radius: 5, // The radius of the inner circle
  corners: 1, // Corner roundness (0..1)
  rotate: 0, // The rotation offset
  direction: 1, // 1: clockwise, -1: counterclockwise
  color: '#000', // #rgb or #rrggbb or array of colors
  speed: 1, // Rounds per second
  trail: 50, // Afterglow percentage
  shadow: false, // Whether to render a shadow
  hwaccel: false, // Whether to use hardware acceleration
  className: 'spinner', // The CSS class to assign to the spinner
  zIndex: 2e9, // The z-index (defaults to 2000000000)
  top: '50%', // Top position relative to parent
  left: '50%' // Left position relative to parent
};
var target = document.getElementById('spinner');
// var spinner = new Spinner(opts).spin(target);
var increment = 2000;  // check database value every increment milliseconds
var myVar = setInterval(function(){ myTimer() }, increment);
var duration = 0;
var durationLimit = 900; // up to 15 minutes to pay by default

var value = 0;
var pc = "0%";
var email = $('#timer').data('email');


var orderId = $('#timer').data('orderid');
var pwd = $('#timer').data('pwd');
var expiry = $('#timer').data('expiry');  // time between order creation and expiry, in seconds
var paid = false;
durationLimit = parseInt(expiry)*1000/increment;  // in cycles
var temps = 15; // duration left in minutes

function myTimer() {

	if ((duration < durationLimit) && (paid == false)) {
	    var d = new Date();
	    var t = d.toLocaleTimeString().substring(0,8);  // keep only leftmost 8 characters
	    document.getElementById("timer").innerHTML = t;
		temps = (durationLimit-duration)*increment/60000 ;  // time left in minutes
		document.getElementById('temps').innerHTML = Math.round( temps ).toString();
		
		value = (duration/durationLimit)*100;
		pc = "width:" + Math.round( value ).toString() + "%";
		var progressBar = document.getElementsByClassName("progress-bar");
		progressBar[0].setAttribute('aria-valuenow', value); // set value where value is between 0-100
		progressBar[0].setAttribute("style",pc);
		var response = "non";
		
		var xmlhttp = new XMLHttpRequest();
		
		var url = "<%= $ORDERS_URL %>" + orderId; // calls show action in orders controller to fetch the status attribute

		xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		    response = JSON.parse(xmlhttp.responseText);
		    }
		}

		xmlhttp.open("GET", url, false);  // false means synchronous, wait for the response; true means asynchronous, don't wait
		xmlhttp.send();
		if (response.status == "&quot;paid&quot;") {
			paid = true;
		}
		console.log(temps);
		console.log(value);
	
	    duration = duration + (increment/1250) ; // tweaked to match the actual time, too slow with +1 ?

	}
	else {
		myStopFunction();
		
	}
}

function myStopFunction() {
	if (paid == true) {

		var element = document.getElementById("my-buttons");		
		
		function post(path, params, method) {
		    method = method || "post"; // Set method to post by default if not specified.

		    var form = document.createElement("form");
		    form.setAttribute("method", method);
		    form.setAttribute("action", path);

		    for(var key in params) {
		        if(params.hasOwnProperty(key)) {
		            var hiddenField = document.createElement("input");
		            hiddenField.setAttribute("type", "hidden");
		            hiddenField.setAttribute("name", key);
		            hiddenField.setAttribute("value", params[key]);

		            form.appendChild(hiddenField);
		         }
		    }

		    document.body.appendChild(form);
		    form.submit();
		}
		
		var url = '<%= $MAIN_URL %>' + "users"
		var bitcoin = true;
		
		post(url, { "email":email, "password":pwd,"password_confirmation":pwd, "bitcoin":bitcoin });
		
		}
	else {  // Bitcoin invoice expired
		
		var element = document.getElementById("qrcodeCanvas");
		element.parentNode.removeChild(element);
		element = document.getElementById("label-bitcoin");
		element.parentNode.removeChild(element);
		element = document.getElementById("bitcoin-address");
		element.parentNode.removeChild(element);
		element = document.getElementById("paybycard");
		element.parentNode.removeChild(element);
		element = document.getElementById("pay-bitcoin");
		element.parentNode.removeChild(element);
		
		var elements = document.getElementsByClassName("progress");
		elements[0].parentNode.removeChild(elements[0]);
		
		}
		
    clearInterval(myVar);
	// spinner.stop(target);	
}
//

};

	$(document).ready(ready);
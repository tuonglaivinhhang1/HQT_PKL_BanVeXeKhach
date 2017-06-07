

var path=require("path");
var exphbs  = require('express-handlebars');

var helpers=require("../app/helpers");

module.exports=function(app){
		app.engine('hbs', exphbs({
		extname: ".hbs",
		defaultLayout: "application",
		layoutsDir:path.resolve('app/views/layouts'),
		helpers:helpers,

		
	}));//khai báo template engine handel
	app.set('view engine', 'hbs');

	app.set('views',path.resolve('app/views'));

}



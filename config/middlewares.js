var express=require('express');
var bodyParser=require('body-parser');
var fileUpload = require('express-fileupload');
var passport=require('passport');
var flash=require("connect-flash");

var cookieParser=require('cookie-parser');
var session=require('express-session');



module.exports=function(app)
{
	app.use(express.static("public"));
	app.use(bodyParser.urlencoded({
		extended:true,
		
	}));
	app.use(bodyParser.json());

	app.use(fileUpload());
	app.use(cookieParser());

	app.use(session({
	  secret: 'my secret key',
	  resave: true,
	  saveUninitialized: true
	}));
	app.use(passport.initialize());
	app.use(passport.session());
	app.use(flash());
}

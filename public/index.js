var express=require('express');
var app=express();

require('../config')(app);


// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.status(404).end();
});
//chạy server

app.listen(3000,function(){
	console.log("Successfull port 3000");
});




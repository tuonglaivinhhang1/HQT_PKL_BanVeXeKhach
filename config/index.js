module.exports=function(app){//export hàm với tham số app

require('./middlewares')(app);

require('./views')(app);


require('./routers')(app);


}
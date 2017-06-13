var User=require('../app/models/nhanvien');

var passport = require('./passport');

var bcrypt = require('bcryptjs');

var Router=require('express').Router;

var controllers=require('../app/controllers');

module.exports=function(app)
{
	function isloginedIn(req,res,next)//nếu đã đăng nhập thì thực hiện các công việc đã đăng nhập.
	{
		if(req.isAuthenticated())
		{
			return next();
		}
		else{
			res.redirect('/admin/login');
		}

		
	}
	function isloginedIn2(req,res,next)//nếu đã đăng nhập thì không được request login hay đăng ký nữa
	{
		if(req.isAuthenticated())
		{
			res.redirect('/admin/dashboard');
		}
		else{
			return next();
		}
		
	}

	var dashboardRouter=Router()
		.get('/',controllers.dashboard.index)
		.post('/',controllers.dashboard.index);
	
	var profileRouter=Router()
		.get('/',controllers.profile.index);

	var listNhanVien=Router()
		.get('/',controllers.nhanvien.index)

		// call by Ajax
		.get('/finnvbycmnd',controllers.nhanvien.findNVbyCMND)
		// .get('/addnhanvien',controllers.nhanvien.add)
		// .get('/detail-nhanvien/sp=:id',controllers.nhanvien.detail)
	
		.get('/update/nv=:id',controllers.nhanvien.update)
		// .post('/delete/success',controllers.nhanvien.delete)
		// .post('/addnhanvien/success',controllers.nhanvien.addSuccess)
		.post('/update/success',controllers.nhanvien.updateSuccess);

	var login=Router()
		.get('/',controllers.login.index);
	


	app.use('/admin/dashboard',isloginedIn,dashboardRouter);
	app.use('/profile',isloginedIn,profileRouter);
	app.use('/admin/listnhanvien',isloginedIn,listNhanVien);
	app.use('/admin/login',isloginedIn2,login);
	

	
	
	

	app.post('/admin/login',passport.authenticate('local.login', {
				

				successRedirect :'/admin/dashboard',
				failureRedirect:'/admin/login',
				failureFlash:true
			}));

	app.get('/admin/logout',function(req,res)
	{
		req.logout();
		res.redirect('/admin/login');

	});

	app.post('/admin/logout',function(req,res)
	{
		req.logout();
		res.redirect('/admin/login');

	});
}
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
		.get('/addnhanvien',controllers.nhanvien.add)

		.post('/addnhanvien/submit',controllers.nhanvien.addsubmit)
	
	
		.get('/update/nv=:id',controllers.nhanvien.update)
		
		
		.post('/update/submit',controllers.nhanvien.updateSuccess)

		.get('/tangluong/nv=:id',controllers.nhanvien.tangluong)
		
		.post('/tangluong/submit',controllers.nhanvien.tangluongsubmit);

	var login=Router()
		.get('/',controllers.login.index);
	

	app.use('/admin/dashboard',isloginedIn,dashboardRouter);
	app.use('/profile',isloginedIn,profileRouter);
	app.use('/admin/listnhanvien',isloginedIn,listNhanVien);
	app.use('/admin/login',isloginedIn2,login);
	

	var QuanTriTuyenDuong = Router()
        .get('/', controllers.QuanTriTuyenDuong.index)
        .get('/XemTuyenDuong', controllers.QuanTriTuyenDuong.xemTuyenDuong)
        .post('/XoaTuyenDuong', controllers.QuanTriTuyenDuong.xoaTuyenDuong)
        .post('/ThemTuyenDuong', controllers.QuanTriTuyenDuong.themTuyenDuong)
        .post('/CapNhatTuyenDuong', controllers.QuanTriTuyenDuong.capNhatTuyenDuong);

    var QuanTriChuyenDi = Router()
        .get('/', controllers.QuanTriChuyenDi.index)
        .get('/XemTatCaChuyenDi', controllers.QuanTriChuyenDi.xemTatCaChuyenDi)
        .get('/XemChuyenDiChuaXuatPhat', controllers.QuanTriChuyenDi.xemChuyenDiChuaXuatPhat)
        .get('/XemChuyenDiDaXuatPhat', controllers.QuanTriChuyenDi.xemChuyenDiDaXuatPhat)
        .post('/XoaChuyenDi', controllers.QuanTriChuyenDi.xoaChuyenDi)
        .post('/ThemChuyenDi', controllers.QuanTriChuyenDi.themChuyenDi)
        .post('/CapNhatChuyenDi', controllers.QuanTriChuyenDi.capNhatChuyenDi);

    var QuanTriLoaiNhanVien = Router()
        .get('/', controllers.QuanTriLoaiNhanVien.index)
        .get('/XemLoaiNhanVien', controllers.QuanTriLoaiNhanVien.xemLoaiNhanVien)
        .post('/XoaLoaiNhanVien', controllers.QuanTriLoaiNhanVien.xoaLoaiNhanVien)
        .post('/ThemLoaiNhanVien', controllers.QuanTriLoaiNhanVien.themLoaiNhanVien)
        .post('/CapNhatLoaiNhanVien', controllers.QuanTriLoaiNhanVien.capNhatLoaiNhanVien);

    var PhanCongTaiXeLaiChuyenDi = Router()
        .get('/', controllers.PhanCongTaiXeLaiChuyenDi.index)
        .post('/submit', controllers.PhanCongTaiXeLaiChuyenDi.phanCongTaiXeLaiChuyenDi);

    var PhanCongPhuTrachXe= Router()
    	.get('/',controllers.PhanCongPhuTrachXe.index)
    	.post('/submit',controllers.PhanCongPhuTrachXe.phancong);


    var ThongKe = Router()
        .get('/DoanhThu', controllers.ThongKe.index)
        .get('/DoanhThu/XemTatCaChuyenDi', controllers.QuanTriChuyenDi.xemTatCaChuyenDi)
        .get('/DoanhThu/XemChuyenDiChuaXuatPhat', controllers.QuanTriChuyenDi.xemChuyenDiChuaXuatPhat)
        .get('/DoanhThu/XemChuyenDiDaXuatPhat', controllers.QuanTriChuyenDi.xemChuyenDiDaXuatPhat)
        .get('/DoanhThu/XemTuyenDuong', controllers.QuanTriTuyenDuong.xemTuyenDuong)
        .post('/DoanhThu', controllers.ThongKe.thongKeDoanhThu)
        .get('/LuongNhanVien',controllers.ThongKe.thongkeLuong);

    var TaiKhoan=Router()
    	.get('/',controllers.taikhoan.index)
    	.get('/findtk',controllers.taikhoan.findTKbyLTK)
    	.get('/update/mtk=:id',controllers.taikhoan.update)
    	.post('/update/submit',controllers.taikhoan.updatesubmit);



    
   app.use('/QuanTriTuyenDuong', isloginedIn,QuanTriTuyenDuong);
    app.use('/QuanTriChuyenDi', isloginedIn,QuanTriChuyenDi);
    app.use('/QuanTriLoaiNhanVien',isloginedIn, QuanTriLoaiNhanVien);
    app.use('/PhanCongTaiXeLaiChuyenDi', isloginedIn,PhanCongTaiXeLaiChuyenDi);
    app.use('/admin/phancong-taixe/phutrachxe',isloginedIn,PhanCongPhuTrachXe);

    app.use('/ThongKe', isloginedIn,ThongKe);
	app.use('/admin/listtaikhoan',isloginedIn,TaiKhoan);




	

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
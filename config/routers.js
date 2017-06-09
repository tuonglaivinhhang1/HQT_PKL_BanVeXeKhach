var User = require('../app/models/nhanvien');

var passport = require('./passport');

var bcrypt = require('bcryptjs');

var Router = require('express').Router;

var controllers = require('../app/controllers');

module.exports = function(app) {
    function isloginedIn(req, res, next) //nếu đã đăng nhập thì thực hiện các công việc đã đăng nhập.
    {
        if (req.isAuthenticated()) {
            return next();
        } else {
            res.redirect('/admin/login');
        }


    }

    function isloginedIn2(req, res, next) //nếu đã đăng nhập thì không được request login hay đăng ký nữa
    {
        if (req.isAuthenticated()) {
            res.redirect('/admin/dashboard');
        } else {
            return next();
        }

    }

    var dashboardRouter = Router()
        .get('/', controllers.dashboard.index)
        .post('/', controllers.dashboard.index);

    var profileRouter = Router()
        .get('/', controllers.profile.index);

    var listNhanVien = Router()
        .get('/', controllers.nhanvien.index);
    // .get('/addnhanvien',controllers.nhanvien.add)
    // .get('/detail-nhanvien/sp=:id',controllers.nhanvien.detail)

    // .get('/update/sp=:id',controllers.nhanvien.update)
    // .post('/delete/success',controllers.nhanvien.delete)
    // .post('/addnhanvien/success',controllers.nhanvien.addSuccess)
    // .post('/update/success',controllers.nhanvien.updateSuccess);

    var login = Router()
        .get('/', controllers.login.index);

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
        .post('/', controllers.PhanCongTaiXeLaiChuyenDi.phanCongTaiXeLaiChuyenDi);

    var ThongKe = Router()
        .get('/DoanhThu', controllers.ThongKe.index)
        .get('/DoanhThu/XemTatCaChuyenDi', controllers.QuanTriChuyenDi.xemTatCaChuyenDi)
        .get('/DoanhThu/XemChuyenDiChuaXuatPhat', controllers.QuanTriChuyenDi.xemChuyenDiChuaXuatPhat)
        .get('/DoanhThu/XemChuyenDiDaXuatPhat', controllers.QuanTriChuyenDi.xemChuyenDiDaXuatPhat)
        .get('/DoanhThu/XemTuyenDuong', controllers.QuanTriTuyenDuong.xemTuyenDuong)
        .post('/DoanhThu', controllers.ThongKe.thongKeDoanhThu);

    app.use('/admin/dashboard', isloginedIn, dashboardRouter);
    app.use('/profile', isloginedIn, profileRouter);
    app.use('/admin/listnhanvien', isloginedIn, listNhanVien);
    app.use('/admin/login', isloginedIn2, login);
    app.use('/QuanTriTuyenDuong', QuanTriTuyenDuong);
    app.use('/QuanTriChuyenDi', QuanTriChuyenDi);
    app.use('/QuanTriLoaiNhanVien', QuanTriLoaiNhanVien);
    app.use('/PhanCongTaiXeLaiChuyenDi', PhanCongTaiXeLaiChuyenDi);
    app.use('/ThongKe', ThongKe);

    app.post('/admin/login', passport.authenticate('local.login', {


        successRedirect: '/admin/dashboard',
        failureRedirect: '/admin/login',
        failureFlash: true
    }));

    app.get('/admin/logout', function(req, res) {
        req.logout();
        res.redirect('/admin/login');

    });

    app.post('/admin/logout', function(req, res) {
        req.logout();
        res.redirect('/admin/login');

    });
}

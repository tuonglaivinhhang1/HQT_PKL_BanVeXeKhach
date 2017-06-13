var QuanTriChuyenDi = require('../models/QuanTriChuyenDi');

var QuanTriChuyenDiController = {
    index: function(req, res) {
        res.render('QuanTriChuyenDi/QuanTriChuyenDi', {
            title: 'Quản lý chuyến đi'
        });
    },
    xemTatCaChuyenDi: function(req, res) {
        QuanTriChuyenDi.xemTatCaChuyenDi(function(error, result) {
            if (error) {
                console.log('error here');
                res.send({
                    error: 'error',
                    result: null
                });
            } else {
                console.log('-------------here----------------');
                console.log(result);
                res.send({
                    error: '',
                    result: result
                });
            }
        });
    },
    xemChuyenDiChuaXuatPhat: function(req, res) {
        QuanTriChuyenDi.xemChuyenDiChuaXuatPhat(function(error, result) {
            if (error) {
                console.log('error here');
                res.send({
                    error: 'error',
                    result: null
                });
            } else {
                console.log('-------------here----------------');
                console.log(result);
                res.send({
                    error: '',
                    result: result
                });
            }
        });
    },
    xemChuyenDiDaXuatPhat: function(req, res) {
        QuanTriChuyenDi.xemChuyenDiDaXuatPhat(function(error, result) {
            if (error) {
                console.log('error here');
                res.send({
                    error: 'error',
                    result: null
                });
            } else {
                console.log('-------------here----------------');
                console.log(result);
                res.send({
                    error: '',
                    result: result
                });
            }
        });
    },
    xoaChuyenDi: function(req, res) {
        QuanTriChuyenDi.xoaChuyenDi(req.body["Mã chuyến đi"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
    themChuyenDi: function(req, res) {
        QuanTriChuyenDi.themChuyenDi(req.body["Mã tuyến đường"], req.body["Ngày giờ xuất phát"], req.body["Ngày giờ đến"], req.body["Mã xe"], req.body["Giá mỗi quảng đường"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
    capNhatChuyenDi: function(req, res) {
        QuanTriChuyenDi.capNhatChuyenDi(req.body["Mã chuyến đi"], req.body["Mã tuyến đường"], req.body["Ngày giờ xuất phát"], req.body["Ngày giờ đến"], req.body["Mã xe"], req.body["Giá mỗi quảng đường"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
};

module.exports = QuanTriChuyenDiController;

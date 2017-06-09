var QuanTriTuyenDuong = require('../models/QuanTriTuyenDuong');

var QuanTriTuyenDuongController = {
    index: function(req, res) {
        res.render('QuanTriTuyenDuong/QuanTriTuyenDuong', {
            title: 'Quản lý tuyến đường'
        });
    },
    xemTuyenDuong: function(req, res) {
        QuanTriTuyenDuong.xemTuyenDuong(function(error, result) {
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
    xoaTuyenDuong: function(req, res) {
        QuanTriTuyenDuong.xoaTuyenDuong(req.body["Mã tuyến đường"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
    themTuyenDuong: function(req, res) {
        QuanTriTuyenDuong.themTuyenDuong(req.body["Nơi xuất phát"], req.body["Nơi đến"], req.body["Bến đi"], req.body["Bến đến"], req.body["Quảng đường"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
    capNhatTuyenDuong: function(req, res) {
        QuanTriTuyenDuong.capNhatTuyenDuong(req.body["Mã tuyến đường"], req.body["Nơi xuất phát"], req.body["Nơi đến"], req.body["Bến đi"], req.body["Bến đến"], req.body["Quảng đường"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
};

module.exports = QuanTriTuyenDuongController;

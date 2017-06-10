var QuanTriLoaiNhanVien = require('../models/QuanTriLoaiNhanVien');

var QuanTriLoaiNhanVienController = {
    index: function(req, res) {
        res.render('QuanTriLoaiNhanVien/QuanTriLoaiNhanVien');
    },
    xemLoaiNhanVien: function(req, res) {
        QuanTriLoaiNhanVien.xemLoaiNhanVien(function(error, result) {
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
    xoaLoaiNhanVien: function(req, res) {
        QuanTriLoaiNhanVien.xoaLoaiNhanVien(req.body["Mã loại nhân viên"], function(result) {
            if (result) {
                res.send(result);
            } else {
                res.send(null);
            }
        });
    },
    themLoaiNhanVien: function(req, res) {
        QuanTriLoaiNhanVien.themLoaiNhanVien(req.body["Tên loại nhân viên"], function(result) {
          if (result) {
              res.send(result);
          } else {
              res.send(null);
          }
        });
    },
    capNhatLoaiNhanVien: function(req, res) {
        QuanTriLoaiNhanVien.capNhatLoaiNhanVien(req.body["Mã loại nhân viên"], req.body["Tên loại nhân viên"], function(result) {
          if (result) {
              res.send(result);
          } else {
              res.send(null);
          }
        });
    },
};

module.exports = QuanTriLoaiNhanVienController;

var QuanTriLoaiNhanVien = require('../models/QuanTriLoaiNhanVien');

var QuanTriLoaiNhanVienController = {
    index: function(req, res) {
        res.render('QuanTriLoaiNhanVien/QuanTriLoaiNhanVien', {
            title: 'Quản lý loại nhân viên'
        });
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
        QuanTriLoaiNhanVien.xoaLoaiNhanVien(req.body["Mã loại nhân viên"], function(error, errorMessage) {
            var data = {
                error: {},
                errorMessage: ''
            };
            if (error) {
                data.error = error;
                res.send(data);
            } else {
                if (errorMessage) {
                    data.errorMessage = errorMessage;
                    res.send(data);
                } else {
                    res.send(data);
                }
            }
        });
    },
    themLoaiNhanVien: function(req, res) {
        QuanTriLoaiNhanVien.themLoaiNhanVien(req.body["Tên loại nhân viên"], function(error, errorMessage, result) {
          var data = {
              error: {},
              errorMessage: '',
              data: {}
          };

          if (error) {
              data.error = error;
              res.send(data);
          } else {
              if (errorMessage) {
                  data.errorMessage = errorMessage;
                  res.send(data);
              } else {
                  data.data = result;
                  res.send(data);
              }
          }
        });
    },
    capNhatLoaiNhanVien: function(req, res) {
        QuanTriLoaiNhanVien.capNhatLoaiNhanVien(req.body["Mã loại nhân viên"], req.body["Tên loại nhân viên"], function(error, errorMessage, result) {
          var data = {
              error: {},
              errorMessage: '',
              data: []
          };

          if (error) {
              data.error = error;
              res.send(data);
          } else {
              if (errorMessage) {
                  data.errorMessage = errorMessage;
                  res.send(data);
              } else {
                  data.data = result;
                  res.send(data);
              }
          }
        });
    },
};

module.exports = QuanTriLoaiNhanVienController;

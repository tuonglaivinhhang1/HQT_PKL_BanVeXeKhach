var ThongKe = require('../models/ThongKe');
var QuanTriTuyenDuong = require('../models/QuanTriTuyenDuong');

var ThongKeController = {
    index: function(req, res) {
      QuanTriTuyenDuong.xemTuyenDuong(function (error, result) {
        if (!error) {
          res.render('ThongKe/ThongKe', {
            title: 'Thống kê'
          });
        }
      });
    },
    thongKeDoanhThu: function(req, res) {
      ThongKe.thongKeDoanhThu(req.body.ChuyenDi, req.body.TuyenDuong, req.body.NgayBatDau, req.body.NgayKetThuc, function(error, result) {
        if (error) {
          res.render('ThongKe/ThongKe', {
            error: 'error',
            title: 'Thống kê'
          });
        }
        else {
          if (result.error) {
            res.render('ThongKe/ThongKe', {
              errorMessage: result.error,
              title: 'Thống kê'
            });
          }
          else {
            res.render('ThongKe/ThongKe', {
              TongDoanhThu: result.TongDoanhThu,
              title: 'Thống kê'
            });
          }
        }
      });
    },
   thongkeLuong:function(req,res) 
   {
       ThongKe.thongkeLuongNhanVien(function(err,result) 
       {
             res.render('ThongKe/ThongKeLuong',{
            title:"Thống Kê Lương Nhân Viên",
            ListNhanVien:result.recordset,
            TongLuong:result.output.tongluong,
            
          });
       });
    }
};

module.exports = ThongKeController;

var ThanhToanVeNhanVien = require('../models/ThanhToanVeNhanVien');

var ThanhToanVeNhanVienController = {
    index: function(req, res) {
        console.log('I\'m here');
        res.render('ThanhToanVeNhanVien/ThanhToanVeNhanVien', {
            title: 'Thanh toán vé nhân viên'
        });
    },
    xemVe: function(req, res) {
        console.log(req.body.MaVe);
        ThanhToanVeNhanVien.xemVe(req.body.MaVe, function(error, errorMessage, data) {
            var sentBackError = {
                error: null,
                errorMessage: '',
                data: {}
            };

            if (error) {
                sentBackError.error = error;
                res.send(sentBackError);
            } else {
                if (errorMessage) {
                    sentBackError.errorMessage = errorMessage;
                    res.send(sentBackError);
                } else {
                    sentBackError.data = data[0].GiaVeThuc;
                    res.send(sentBackError);
                }
            }
        });
    },
    thanhToanVeNhanVien: function(req, res) {
        var MaNV = 'NV006';
        ThanhToanVeNhanVien.thanhToanVeNhanVien(req.body.MaVe, req.body.GiaVeThuc, MaNV, function(error, errorMessage, result) {
            if (error) {
                res.render('ThanhToanVeNhanVien/ThanhToanVeNhanVien', {
                    title: 'Thanh toán vé nhân viên',
                    error: error
                });
            } else {
                if (errorMessage) {
                    res.render('ThanhToanVeNhanVien/ThanhToanVeNhanVien', {
                        title: 'Thanh toán vé nhân viên',
                        errorMessage: errorMessage
                    });
                } else {
                    res.render('ThanhToanVeNhanVien/ThanhToanVeNhanVien', {
                        title: 'Thanh toán vé nhân viên',
                        success: 'successfully'
                    });
                }
            }
        });
    }
};

module.exports = ThanhToanVeNhanVienController;

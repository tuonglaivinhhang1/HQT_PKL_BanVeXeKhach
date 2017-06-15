var QuanTriTuyenDuong = require('../models/QuanTriTuyenDuongRepeatableRead');

var QuanTriTuyenDuongController = {
    index: function(req, res) {
        res.render('QuanTriTuyenDuong/QuanTriTuyenDuongRepeatableRead', {
            title: 'Quản lý tuyến đường RepeatableRead'
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
        QuanTriTuyenDuong.xoaTuyenDuong(req.body["Mã tuyến đường"], function(error, errorMessage) {
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
    themTuyenDuong: function(req, res) {
        QuanTriTuyenDuong.themTuyenDuong(req.body["Nơi xuất phát"], req.body["Nơi đến"], req.body["Bến đi"], req.body["Bến đến"], req.body["Quảng đường"], function(error, errorMessage, result) {
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
    capNhatTuyenDuong: function(req, res) {
        QuanTriTuyenDuong.capNhatTuyenDuong(req.body["Mã tuyến đường"], req.body["Nơi xuất phát"], req.body["Nơi đến"], req.body["Bến đi"], req.body["Bến đến"], req.body["Quảng đường"], function(error, errorMessage, result) {
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

module.exports = QuanTriTuyenDuongController;

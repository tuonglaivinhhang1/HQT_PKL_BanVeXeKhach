var sql = require('mssql');

var config = require('../../config/database');

var ThanhToanVeNhanVien = {
    xemVe: function(MaVe, callback) {

        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null, null);
            }
            pool.request()
                .input('MaVe', sql.VarChar, MaVe)
                .output('error', sql.VarChar)
                .execute('xemve', function(error, result) {
                    console.log(result);
                    if (error) {
                        callback(error, null, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error, null);
                        } else {

                            var data = [];

                            for (i = 0; i < result.recordsets[0].length; i++) {
                                data[i] = {
                                    GiaVeThuc: result.recordset[i].GiaVeThuc,
                                };
                            }

                            console.log(data);
                            callback(null, null, data);
                        }
                    }
                });
        });
    },
    thanhToanVeNhanVien: function(MaVe, GiaVeThuc, MaNV, callback) {
        var GiaVeThucInt = parseInt(GiaVeThuc);
        var PhuongThucThanhToan = "PTTT005";
        console.log(GiaVeThucInt);
        console.log(MaNV);
        console.log(PhuongThucThanhToan);
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            console.log('HERE');
            pool.request()
                .input('MaVe', sql.VarChar, MaVe)
                .input('PhuongThucThanhToan', sql.VarChar, PhuongThucThanhToan)
                .input('MaNV', sql.VarChar, MaNV)
                .input('SoTien', sql.Int, GiaVeThucInt)
                .output('error', sql.NVarChar)
                .execute('thanhToanVeNhanVien', function(error, result) {
                    console.log(error);
                    if (error) {
                        callback(error, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error);
                        } else {
                            callback(null, null);
                        }
                    }
                });
        });
    },
    thanhToanVeNhanVienWaitforDelayXLock: function(MaVe, GiaVeThuc, MaNV, callback) {
        var GiaVeThucInt = parseInt(GiaVeThuc);
        var PhuongThucThanhToan = "PTTT005";
        console.log(GiaVeThucInt);
        console.log(MaNV);
        console.log(PhuongThucThanhToan);
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            console.log('HERE');
            pool.request()
                .input('MaVe', sql.VarChar, MaVe)
                .input('PhuongThucThanhToan', sql.VarChar, PhuongThucThanhToan)
                .input('MaNV', sql.VarChar, MaNV)
                .input('SoTien', sql.Int, GiaVeThucInt)
                .output('error', sql.NVarChar)
                .execute('thanhToanVeNhanVienWaitforDelayXLock', function(error, result) {
                    console.log(error);
                    if (error) {
                        callback(error, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error);
                        } else {
                            callback(null, null);
                        }
                    }
                });
        });
    },

    thanhToanVeNhanVienWaitforDelayRepeatableRead: function(MaVe, GiaVeThuc, MaNV, callback) {
        var GiaVeThucInt = parseInt(GiaVeThuc);
        var PhuongThucThanhToan = "PTTT005";
        console.log(GiaVeThucInt);
        console.log(MaNV);
        console.log(PhuongThucThanhToan);
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            console.log('HERE');
            pool.request()
                .input('MaVe', sql.VarChar, MaVe)
                .input('PhuongThucThanhToan', sql.VarChar, PhuongThucThanhToan)
                .input('MaNV', sql.VarChar, MaNV)
                .input('SoTien', sql.Int, GiaVeThucInt)
                .output('error', sql.NVarChar)
                .execute('thanhToanVeNhanVienWaitforDelayRepeatableRead', function(error, result) {
                    console.log(error);
                    if (error) {
                        callback(error, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error);
                        } else {
                            callback(null, null);
                        }
                    }
                });
        });
    },

    thanhToanVeNhanVienWaitforDelay: function(MaVe, GiaVeThuc, MaNV, callback) {
        var GiaVeThucInt = parseInt(GiaVeThuc);
        var PhuongThucThanhToan = "PTTT005";
        console.log(GiaVeThucInt);
        console.log(MaNV);
        console.log(PhuongThucThanhToan);
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            console.log('HERE');
            pool.request()
                .input('MaVe', sql.VarChar, MaVe)
                .input('PhuongThucThanhToan', sql.VarChar, PhuongThucThanhToan)
                .input('MaNV', sql.VarChar, MaNV)
                .input('SoTien', sql.Int, GiaVeThucInt)
                .output('error', sql.NVarChar)
                .execute('thanhToanVeNhanVienWaitforDelay', function(error, result) {
                    console.log(error);
                    if (error) {
                        callback(error, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error);
                        } else {
                            callback(null, null);
                        }
                    }
                });
        });
    },
};

module.exports = ThanhToanVeNhanVien;

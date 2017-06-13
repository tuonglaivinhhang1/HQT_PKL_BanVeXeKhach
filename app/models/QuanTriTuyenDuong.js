var sql = require('mssql');

var config = require('../../config/database');

var QuanTriTuyenDuong = {
    xemTuyenDuong: function(callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            pool.request()
                .execute('xemTuyenDuong', function(error, result) {
                    if (error) {
                        callback(error, null);
                    }

                    var data = [];

                    for (i = 0; i < result.recordsets[0].length; i++) {
                        data[i] = {
                            "Mã tuyến đường": result.recordset[i].MaTuyenDuong,
                            "Nơi xuất phát": result.recordset[i].NoiXuatPhat,
                            "Nơi đến": result.recordset[i].NoiDen,
                            "Bến đi": result.recordset[i].BenDi,
                            "Bến đến": result.recordset[i].BenDen,
                            "Quảng đường": result.recordset[i].QuangDuong
                        };
                    }

                    console.log(data);
                    callback(error, data);
                });
        });
    },
    xoaTuyenDuong: function(MaTuyenDuong, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                .execute('xoaTuyenDuong', function(error, result) {
                    if (error) {
                        callback(error, null);
                    }
                    else {
                      if (result.output.error) {
                        callback(null, result.output.error);
                      }
                    }
                });
        });
    },
    themTuyenDuong: function(NoiXuatPhat, NoiDen, BenDi, BenDen, QuangDuong, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('NoiXuatPhat', sql.NVarChar, NoiXuatPhat)
                .input('NoiDen', sql.NVarChar, NoiDen)
                .input('BenDi', sql.NVarChar, BenDi)
                .input('BenDen', sql.NVarChar, BenDen)
                .input('QuangDuong', sql.Int, QuangDuong)
                .execute('themTuyenDuong', function(error, result) {
                    if (error) {
                        callback(error, null, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error, null);
                        } else {
                            console.log(result);
                            var data = [];

                            for (i = 0; i < result.recordsets[0].length; i++) {
                                data[i] = {
                                    "Mã tuyến đường": result.recordset[i].MaTuyenDuong,
                                    "Nơi xuất phát": result.recordset[i].NoiXuatPhat,
                                    "Nơi đến": result.recordset[i].NoiDen,
                                    "Bến đi": result.recordset[i].BenDi,
                                    "Bến đến": result.recordset[i].BenDen,
                                    "Quảng đường": result.recordset[i].QuangDuong
                                };
                            }

                            console.log(data);
                            callback(null, null, data);
                        }
                    }
                });
        });
    },
    capNhatTuyenDuong: function(MaTuyenDuong, NoiXuatPhat, NoiDen, BenDi, BenDen, QuangDuong, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                .input('NoiXuatPhat', sql.NVarChar, NoiXuatPhat)
                .input('NoiDen', sql.NVarChar, NoiDen)
                .input('BenDi', sql.NVarChar, BenDi)
                .input('BenDen', sql.NVarChar, BenDen)
                .input('QuangDuong', sql.Int, QuangDuong)
                .execute('capNhatTuyenDuong', function(error, result) {
                    if (error) {
                        callback(error, null, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error, null);
                        } else {
                            console.log(result);
                            var data = [];

                            for (i = 0; i < result.recordsets[0].length; i++) {
                                data[i] = {
                                    "Mã tuyến đường": result.recordset[i].MaTuyenDuong,
                                    "Nơi xuất phát": result.recordset[i].NoiXuatPhat,
                                    "Nơi đến": result.recordset[i].NoiDen,
                                    "Bến đi": result.recordset[i].BenDi,
                                    "Bến đến": result.recordset[i].BenDen,
                                    "Quảng đường": result.recordset[i].QuangDuong
                                };
                            }

                            console.log(data);
                            callback(null, null, data);
                        }
                    }
                });
        });
    }
};

module.exports = QuanTriTuyenDuong;

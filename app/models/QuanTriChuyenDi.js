var sql = require('mssql');

var config=require('../../config/database');

var QuanTriChuyenDi = {
    xemTatCaChuyenDi: function(callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            pool.request()
                .execute('xemTatCaChuyenDi', function(error, result) {
                    if (error) {
                        callback(error, null);
                    }

                    var data = [];

                    for (i = 0; i < result.recordsets[0].length; i++) {
                        data[i] = {
                            "Mã chuyến đi": result.recordset[i].MaChuyenDi,
                            "Mã tuyến đường": result.recordset[i].TuyenDuong,
                            "Ngày giờ xuất phát": result.recordset[i].NgayGioXuatPhat,
                            "Ngày giờ đến": result.recordset[i].NgayGioDen,
                            "Mã xe": result.recordset[i].Xe,
                            "Giá dự kiến": result.recordset[i].GiaDuKien,
                            "Giá mỗi quảng đường": 0,
                        };
                    }

                    console.log(data);
                    callback(error, data);
                });
        });
    },
    xemChuyenDiChuaXuatPhat: function(callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            pool.request()
                .execute('xemChuyenDiChuaXuatPhat', function(error, result) {
                    if (error) {
                        callback(error, null);
                    }

                    var data = [];

                    for (i = 0; i < result.recordsets[0].length; i++) {
                        data[i] = {
                            "Mã chuyến đi": result.recordset[i].MaChuyenDi,
                            "Mã tuyến đường": result.recordset[i].TuyenDuong,
                            "Ngày giờ xuất phát": result.recordset[i].NgayGioXuatPhat,
                            "Ngày giờ đến": result.recordset[i].NgayGioDen,
                            "Mã xe": result.recordset[i].Xe,
                            "Giá dự kiến": result.recordset[i].GiaDuKien,
                            "Giá mỗi quảng đường": 0,
                        };
                    }

                    console.log(data);
                    callback(error, data);
                });
        });
    },
    xemChuyenDiDaXuatPhat: function(callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            pool.request()
                .execute('xemChuyenDiDaXuatPhat', function(error, result) {
                    if (error) {
                        callback(error, null);
                    }

                    var data = [];

                    for (i = 0; i < result.recordsets[0].length; i++) {
                        data[i] = {
                            "Mã chuyến đi": result.recordset[i].MaChuyenDi,
                            "Mã tuyến đường": result.recordset[i].TuyenDuong,
                            "Ngày giờ xuất phát": result.recordset[i].NgayGioXuatPhat,
                            "Ngày giờ đến": result.recordset[i].NgayGioDen,
                            "Mã xe": result.recordset[i].Xe,
                            "Giá dự kiến": result.recordset[i].GiaDuKien,
                            "Giá mỗi quảng đường": 0,
                        };
                    }

                    console.log(data);
                    callback(error, data);
                });
        });
    },
    xoaChuyenDi: function(MaChuyenDi, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('MaChuyenDi', sql.VarChar, MaChuyenDi)
                .execute('xoaChuyenDi', function(error, result) {
                    if (error) {
                        callback(error);
                    }

                    if (result.output.error !== '') {
                        callback(result.output);
                    }
                });
        });
    },
    themChuyenDi: function(MaTuyenDuong, NgayGioXuatPhat, NgayGioDen, MaXe, GiaMoiQuangDuong, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }
            console.log(MaTuyenDuong);
            pool.request()
                .output('error', sql.NVarChar)
                .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                .input('NgayGioXuatPhat', sql.VarChar, NgayGioXuatPhat)
                .input('NgayGioDen', sql.VarChar, NgayGioDen)
                .input('MaXe', sql.VarChar, MaXe)
                .input('GiaMoiQuangDuong', sql.Int, GiaMoiQuangDuong)
                .execute('themChuyenDi', function(error, result) {
                    if (error) {
                        callback(error);
                    }

                    if (result.output.error !== '') {
                        callback(result.output);
                    }
                });
        });
    },
    capNhatChuyenDi: function(MaChuyenDi, MaTuyenDuong, NgayGioXuatPhat, NgayGioDen, MaXe, GiaMoiQuangDuong, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('MaChuyenDi', sql.VarChar, MaChuyenDi)
                .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                .input('NgayGioXuatPhat', sql.VarChar, NgayGioXuatPhat)
                .input('NgayGioDen', sql.VarChar, NgayGioDen)
                .input('MaXe', sql.VarChar, MaXe)
                .input('GiaMoiQuangDuong', sql.Int, GiaMoiQuangDuong)
                .execute('capNhatChuyenDi', function(error, result) {
                    if (error) {
                        callback(error);
                    }

                    if (result.output.error !== '') {
                        callback(result.output);
                    }
                });
        });
    }
};

module.exports = QuanTriChuyenDi;

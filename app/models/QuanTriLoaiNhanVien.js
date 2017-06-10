var sql = require('mssql');

var config = require('../../config/database');

var QuanTriLoaiNhanVien = {
    xemLoaiNhanVien: function(callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(err, null);
            }
            pool.request()
                .execute('xemLoaiNhanVien', function(error, result) {
                    if (error) {
                        callback(error, null);
                    }

                    var data = [];

                    for (i = 0; i < result.recordsets[0].length; i++) {
                        data[i] = {
                            "Mã loại nhân viên": result.recordset[i].MaLoaiNV,
                            "Tên loại nhân viên": result.recordset[i].TenLoaiNV
                        };
                    }

                    console.log(data);
                    callback(error, data);
                });
        });
    },
    xoaLoaiNhanVien: function(MaLoaiNV, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('MaLoaiNV', sql.VarChar, MaLoaiNV)
                .execute('xoaLoaiNhanVien', function(error, result) {
                    if (error) {
                        callback(error, null);
                    } else {
                        if (result.output.error) {
                            callback(null, result.output.error);
                        }
                    }
                });
        });
    },
    themLoaiNhanVien: function(TenLoaiNV, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }
            pool.request()
                .output('error', sql.NVarChar)
                .input('TenLoaiNV', sql.NVarChar, TenLoaiNV)
                .execute('themLoaiNhanVien', function(error, result) {
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
                                    "Mã loại nhân viên": result.recordset[i].MaLoaiNV,
                                    "Tên loại nhân viên": result.recordset[i].TenLoaiNV
                                };
                            }

                            console.log(data);
                            callback(null, null, data);
                        }
                    }
                });
        });
    },
    capNhatLoaiNhanVien: function(MaLoaiNV, TenLoaiNV, callback) {
        var pool = new sql.ConnectionPool(config, function(err) {
            if (err) {
                callback(error);
            }

            pool.request()
                .output('error', sql.NVarChar)
                .input('MaLoaiNV', sql.VarChar, MaLoaiNV)
                .input('TenLoaiNV', sql.NVarChar, TenLoaiNV)
                .execute('capNhatLoaiNhanVien', function(error, result) {
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
                                    "Mã loại nhân viên": result.recordset[i].MaLoaiNV,
                                    "Tên loại nhân viên": result.recordset[i].TenLoaiNV
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

module.exports = QuanTriLoaiNhanVien;

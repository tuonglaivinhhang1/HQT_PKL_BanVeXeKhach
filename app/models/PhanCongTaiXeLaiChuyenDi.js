var sql = require('mssql');

var config=require('../../config/database');

var PhanCongTaiXeLaiChuyenDi = {
  phanCongTaiXeLaiChuyenDi: function(MaChuyenDi, TaiXe, LoaiTaiXe, callback) {
    var pool = new sql.ConnectionPool(config, function(err) {
        if (err) {
            callback(error, null);
        }

        pool.request()
            .output('error', sql.NVarChar)
            .input('MaChuyenDi', sql.VarChar, MaChuyenDi)
            .input('TaiXe', sql.VarChar, TaiXe)
            .input('LoaiTaiXe', sql.NVarChar, LoaiTaiXe)
            .execute('phanCongTaiXeLaiCD', function(error, result) {
                if (error) {
                    callback(error, null);
                }
              console.log(result);
                callback(null, result.output);
            });
    });
  },
  xemTaiXe: function(callback) {
    var pool = new sql.ConnectionPool(config, function(err) {
        if (err) {
            callback(error, null);
        }

        pool.request()
            .execute('xemTaiXe', function(error, result) {
                if (error) {
                    callback(error, null);
                }
              console.log(result.recordset);
              callback(null, result.recordset);
            });
    });
  }
};

module.exports = PhanCongTaiXeLaiChuyenDi;

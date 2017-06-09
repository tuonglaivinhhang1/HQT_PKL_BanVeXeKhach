var sql = require('mssql');

var config=require('../../config/database');

var ThongKe = {
    thongKeDoanhThu: function(ChuyenDi, TuyenDuong, NgayBatDau, NgayKetThuc, callback) {
        var pool;

        if (ChuyenDi) {
            pool = new sql.ConnectionPool(config, function(err) {
                if (err) {
                    callback(err, null);
                }

                pool.request()
                    .input('MaChuyenDi', sql.VarChar, ChuyenDi)
                    .output('TongDoanhThu', sql.Int)
                    .output('error', sql.NVarChar)
                    .execute('thongKeDoanhThuTheoChuyenDi', function(error, result) {
                        if (error) {
                            callback(error, null);
                        }

                        callback(null, result.output);
                    });
            });
        } else {
            if (TuyenDuong) {
              pool = new sql.ConnectionPool(config, function(err) {
                  if (err) {
                      callback(err, null);
                  }

                  var MaTuyenDuong = TuyenDuong.slice(0, 9);

                  if (NgayBatDau && NgayKetThuc) {
                    pool.request()
                        .input('NgayBatDau', sql.VarChar, NgayBatDau)
                        .input('NgayKetThuc', sql.VarChar, NgayKetThuc)
                        .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                        .output('TongDoanhThu', sql.Int)
                        .output('error', sql.NVarChar)
                        .execute('thongKeDoanhThuTheoThoiGianTuyenDuong', function(error, result) {
                            if (error) {
                                callback(error, null);
                            }

                            callback(null, result.output);
                        });
                  }
                  else {
                    if (NgayBatDau) {
                      pool.request()
                          .input('NgayBatDau', sql.VarChar, NgayBatDau)
                          .input('NgayKetThuc', sql.VarChar, null)
                          .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                          .output('TongDoanhThu', sql.Int)
                          .output('error', sql.NVarChar)
                          .execute('thongKeDoanhThuTheoThoiGianTuyenDuong', function(error, result) {
                              if (error) {
                                  callback(error, null);
                              }

                              callback(null, result.output);
                          });
                    }
                    else {
                      if (NgayKetThuc) {
                        pool.request()
                            .input('NgayBatDau', sql.VarChar, null)
                            .input('NgayKetThuc', sql.VarChar, NgayKetThuc)
                            .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                            .output('TongDoanhThu', sql.Int)
                            .output('error', sql.NVarChar)
                            .execute('thongKeDoanhThuTheoThoiGianTuyenDuong', function(error, result) {
                                if (error) {
                                    callback(error, null);
                                }

                                callback(null, result.output);
                            });
                      }
                      else {
                        pool.request()
                            .input('NgayBatDau', sql.VarChar, null)
                            .input('NgayKetThuc', sql.VarChar, null)
                            .input('MaTuyenDuong', sql.VarChar, MaTuyenDuong)
                            .output('TongDoanhThu', sql.Int)
                            .output('error', sql.NVarChar)
                            .execute('thongKeDoanhThuTheoThoiGianTuyenDuong', function(error, result) {
                                if (error) {
                                    callback(error, null);
                                }

                                callback(null, result.output);
                            });
                      }
                    }
                  }
              });
            } else {
                pool = new sql.ConnectionPool(config, function(err) {
                    if (err) {
                        callback(err, null);
                    }

                    if (NgayBatDau && NgayKetThuc) {
                      pool.request()
                          .input('NgayBatDau', sql.VarChar, NgayBatDau)
                          .input('NgayKetThuc', sql.VarChar, NgayKetThuc)
                          .output('TongDoanhThu', sql.Int)
                          .output('error', sql.NVarChar)
                          .execute('thongKeDoanhThuTheoThoiGian', function(error, result) {
                              if (error) {
                                  callback(error, null);
                              }

                              callback(null, result.output);
                          });
                    }
                    else {
                      if (NgayBatDau) {
                        pool.request()
                            .input('NgayBatDau', sql.VarChar, NgayBatDau)
                            .input('NgayKetThuc', sql.VarChar, null)
                            .output('TongDoanhThu', sql.Int)
                            .output('error', sql.NVarChar)
                            .execute('thongKeDoanhThuTheoThoiGian', function(error, result) {
                                if (error) {
                                    callback(error, null);
                                }

                                callback(null, result.output);
                            });
                      }
                      else {
                        if (NgayKetThuc) {
                          pool.request()
                              .input('NgayBatDau', sql.VarChar, null)
                              .input('NgayKetThuc', sql.VarChar, NgayKetThuc)
                              .output('TongDoanhThu', sql.Int)
                              .output('error', sql.NVarChar)
                              .execute('thongKeDoanhThuTheoThoiGian', function(error, result) {
                                  if (error) {
                                      callback(error, null);
                                  }

                                  callback(null, result.output);
                              });
                        }
                        else {
                          pool.request()
                              .input('NgayBatDau', sql.VarChar, null)
                              .input('NgayKetThuc', sql.VarChar, null)
                              .output('TongDoanhThu', sql.Int)
                              .output('error', sql.NVarChar)
                              .execute('thongKeDoanhThuTheoThoiGian', function(error, result) {
                                  if (error) {
                                      callback(error, null);
                                  }
                                  
                                  callback(null, result.output);
                              });
                        }
                      }
                    }
                });
            }
        }
    }
};

module.exports = ThongKe;

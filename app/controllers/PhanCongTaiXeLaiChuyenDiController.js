var PhanCongTaiXeLaiChuyenDi = require('../models/PhanCongTaiXeLaiChuyenDi');
var QuanTriChuyenDi = require('../models/QuanTriChuyenDi');

var PhanCongTaiXeLaiChuyenDiController = {
    index: function(req, res) {
        QuanTriChuyenDi.xemChuyenDiChuaXuatPhat(function(error, data) {
            if (error) {
                res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                    error: 'error',
                    title: 'Phân công tài xế lái chuyến đi'
                });
            } else {
                PhanCongTaiXeLaiChuyenDi.xemTaiXe(function(error, result) {
                    if (error) {
                        res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                            error: 'error',
                            title: 'Phân công tài xế lái chuyến đi'
                        });
                    } else {
                      res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                          chuyenDi: function(data) {
                              var out = "";
                              for (var i = 0; i < data.length; i++) {
                                  out = out + "<option>" + data[i]["Mã chuyến đi"] + "</option>";
                              }
                              return out;
                          },
                          dataChuyenDi: data,
                          dataTaiXe: result,
                          taiXe: function(data) {
                              var out = "";
                              for (var i = 0; i < data.length; i++) {
                                  out = out + "<option>" + data[i].MaNhanVien + "</option>";
                              }
                              return out;
                          },
                          title: 'Phân công tài xế lái chuyến đi'
                      });
                    }
                });
            }
        });
    },
    phanCongTaiXeLaiChuyenDi: function(req, res) {
      console.log(req);
        PhanCongTaiXeLaiChuyenDi.phanCongTaiXeLaiChuyenDi(req.body.ChuyenDi, req.body.TaiXe, req.body.LoaiTaiXe, function(error, resultPC) {
            if (error) {
                QuanTriChuyenDi.xemChuyenDiChuaXuatPhat(function(error, data) {
                    if (error) {
                        res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                            error: 'error',
                            title: 'Phân công tài xế lái chuyến đi'
                        });
                    } else {
                        PhanCongTaiXeLaiChuyenDi.xemTaiXe(function(error, result) {
                            if (error) {
                                res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                    error: 'error',
                                    title: 'Phân công tài xế lái chuyến đi'
                                });
                            } else {
                              res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                  error: 'error',
                                  chuyenDi: function(data) {
                                      var out = "";
                                      for (var i = 0; i < data.length; i++) {
                                          out = out + "<option>" + data[i]["Mã chuyến đi"] + "</option>";
                                      }
                                      return out;
                                  },
                                  dataChuyenDi: data,
                                  dataTaiXe: result,
                                  taiXe: function(data) {
                                      var out = "";
                                      for (var i = 0; i < data.length; i++) {
                                          out = out + "<option>" + data[i].MaNhanVien + "</option>";
                                      }
                                      return out;
                                  },
                                  title: 'Phân công tài xế lái chuyến đi'
                              });
                            }
                        });
                    }
                });
            } else {
                if (resultPC.error) {
                    QuanTriChuyenDi.xemChuyenDiChuaXuatPhat(function(error, data) {
                        if (error) {
                            res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                error: 'error',
                                title: 'Phân công tài xế lái chuyến đi'
                            });
                        } else {
                            PhanCongTaiXeLaiChuyenDi.xemTaiXe(function(error, result) {
                                if (error) {
                                    res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                        error: 'error',
                                        title: 'Phân công tài xế lái chuyến đi'
                                    });
                                } else {
                                  console.log(resultPC.error);
                                  res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                      chuyenDi: function(data) {
                                          var out = "";
                                          for (var i = 0; i < data.length; i++) {
                                              out = out + "<option>" + data[i]["Mã chuyến đi"] + "</option>";
                                          }
                                          return out;
                                      },
                                      dataChuyenDi: data,
                                      dataTaiXe: result,
                                      errorMessage: resultPC.error,
                                      taiXe: function(data) {
                                          var out = "";
                                          for (var i = 0; i < data.length; i++) {
                                              out = out + "<option>" + data[i].MaNhanVien + "</option>";
                                          }
                                          return out;
                                      },
                                      title: 'Phân công tài xế lái chuyến đi'
                                  });
                                }
                            });
                        }
                    });
                } else {
                    QuanTriChuyenDi.xemChuyenDiChuaXuatPhat(function(error, data) {
                        if (error) {
                            res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                error: 'error',
                                title: 'Phân công tài xế lái chuyến đi'
                            });
                        } else {
                            PhanCongTaiXeLaiChuyenDi.xemTaiXe(function(error, result) {
                                if (error) {
                                    res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                        error: 'error',
                                        title: 'Phân công tài xế lái chuyến đi'
                                    });
                                } else {
                                  res.render('PhanCongTaiXeLaiChuyenDi/PhanCongTaiXeLaiChuyenDi', {
                                      chuyenDi: function(data) {
                                          var out = "";
                                          for (var i = 0; i < data.length; i++) {
                                              out = out + "<option>" + data[i]["Mã chuyến đi"] + "</option>";
                                          }
                                          return out;
                                      },
                                      dataChuyenDi: data,
                                      dataTaiXe: result,
                                      success: 'successfully!!!',
                                      taiXe: function(data) {
                                          var out = "";
                                          for (var i = 0; i < data.length; i++) {
                                              out = out + "<option>" + data[i].MaNhanVien + "</option>";
                                          }
                                          return out;
                                      },
                                      title: 'Phân công tài xế lái chuyến đi'
                                  });
                                }
                            });
                        }
                    });
                }
            }
        });
    }
};

module.exports = PhanCongTaiXeLaiChuyenDiController;

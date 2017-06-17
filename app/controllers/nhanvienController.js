function checkEmptyForm(name,category,price,DateAdd,status,quantity)
{
	if(name==null||name.length==0||category.length==0||price==null||price.length==0||DateAdd==null||status==null||status.length==0||quantity==null||quantity.length==0)
	{
		return true;//empty
	}
	else{
		return false;
	}


}


var fs = require('fs');

var listnhanvien = require('../models/nhanvien');


var listnhanvienAll={
	index:function(req,res)
	{
		listnhanvien.getAll(function(err,ListNhanVien)
		{

			for(var i=0;i<ListNhanVien.recordset.length;i++)
			{
				ListNhanVien.recordset[i].NgaySinhNV=((ListNhanVien.recordset[i].NgaySinhNV).toString()).substring(0,15);
				if(ListNhanVien.recordset[i].LoaiNhanVien=='LNV001')
				{
					ListNhanVien.recordset[i].LoaiNhanVien='Tài xế';
				}
				else if(ListNhanVien.recordset[i].LoaiNhanVien=='LNV002')
				{
					ListNhanVien.recordset[i].LoaiNhanVien='Nhân Viên Quản Lý';
				}
				else if(ListNhanVien.recordset[i].LoaiNhanVien=='LNV003')
				{
					ListNhanVien.recordset[i].LoaiNhanVien='Nhân Viên Đặt Vé';
				}
				else if(ListNhanVien.recordset[i].LoaiNhanVien=='LNV004')
				{
					ListNhanVien.recordset[i].LoaiNhanVien='Nhân Viên Thanh Toán';
				}
			}
			res.render('nhanvien/index',{
				title:"Danh sách nhân viên",
				ListNhanVien:ListNhanVien.recordset,

			});
		});


	},
	findNVbyCMND:function(req,res)
	{

		listnhanvien.getoneCMND(req.query['tbcmnd'],function(err,NhanVien)
		{


			if(NhanVien[0]==null)
			{
				res.end(JSON.stringify(null));
			}
			else{
					NhanVien[0].NgaySinhNV=((NhanVien[0].NgaySinhNV).toString()).substring(0,15);
					if(NhanVien[0].LoaiNhanVien=='LNV001')
					{
						NhanVien[0].LoaiNhanVien='Tài xế';
					}
					else if(NhanVien[0].LoaiNhanVien=='LNV002')
					{
						NhanVien[0].LoaiNhanVien='Nhân Viên Quản Lý';
					}
					else if(NhanVien[0].LoaiNhanVien=='LNV003')
					{
						NhanVien[0].LoaiNhanVien='Nhân Viên Đặt Vé';
					}
					else if(NhanVien[0].LoaiNhanVien=='LNV004')
					{
						NhanVien[0].LoaiNhanVien='Nhân Viên Thanh Toán';
					}

				res.end(JSON.stringify(NhanVien[0]));
			}


			// res.render('nhanvien/index',{
			// 	title:"Danh sách nhân viên",
			// 	NhanVien:NhanVien.recordset,

			// });
		});
	},
	// add:function(req,res)
	// {

	// 	res.render('Product/add',{
	// 		title:"Thêm sản phẩm",

	// 	});
	// },
	// addSuccess:function(req,res)
	// {


	// 	if(checkEmptyForm(req.body.name,req.body.Category,req.body.price,req.body.DateAdd,req.body.status,req.body.quantity))
	// 		{

	// 				res.render('Product/add',{
	// 				title:"Thêm Sản Phẩm",
	// 				messageDetail:"Vui lòng nhập đầy đủ thông tin theo yêu cầu"

	// 			});
	// 		}
	// 	else
	// 	{
	// 		var StatusGet;
	// 		var CategoryGet;
	// 		if(req.body.status=="CH")
	// 		{
	// 			StatusGet=1;
	// 		}
	// 		else if(req.body.status=="SCH")
	// 		{
	// 			StatusGet=2;
	// 		}
	// 		else if(req.body.status=="NKD")
	// 		{
	// 			StatusGet=3;
	// 		}

	// 		if(req.body.Category=="La")
	// 		{
	// 			CategoryGet=3;
	// 		}
	// 		else if(req.body.Category=="Ka")
	// 		{
	// 			CategoryGet=2;
	// 		}
	// 		else if(req.body.Category=="Mo")
	// 		{
	// 			CategoryGet=1;
	// 		}
	// 		//get url file upload
	// 		var file=req.files.hinhanh;
	// 		var namefile;
	// 		if(file==null)
	// 		{
	// 			namefile='imdefault.png';
	// 		}
	// 		else{
	// 			namefile=file.name;

	// 			file.mv('public/images/'+namefile, function(err) {
	// 		    if (err)
	// 		      return res.status(500).send(err);
	// 		});

	// 	 }


	// 		listProduct.insert({
	// 			name:req.body.name,
	// 			categoryID:CategoryGet,
	// 			description:req.body.description,
	// 			price:parseFloat(req.body.price),
	// 			dateadd:req.body.DateAdd,
	// 			quantity:req.body.quantity,
	// 			statusID:StatusGet,
	// 			urlImage:'/images/'+namefile
	// 		},function(err)
	// 		{
	// 			if(err)
	// 			{
	// 				//console.log(err);

	// 				res.render('Product/add',{
	// 				title:"Thêm Sản Phẩm",
	// 				messageDetail:"Thêm thất bại. Vui lòng thử lại"});
	// 			}
	// 			else
	// 			{
	// 				res.render('Product/addSuccess',{
	// 						title:"Thêm Thành Công",
	// 						messageDetail:"Sản phẩm đã được thêm thành công"
	// 					});
	// 				}//end else
	// 			});
	// 		}
	// },
	// detail:function(req,res)
	// {
	// 	var id=req.params.id;
	// 	var CurrentProduct;

	// 	listProduct.findAll(function(err,ListProduct)
	// 	{
	// 		for(var i=0;i<ListProduct.length;i++)
	// 		{
	// 			if(ListProduct[i].id==id)
	// 			{

	// 				CurrentProduct=ListProduct[i];

	// 				break;
	// 			}
	// 		}
	// 		var Ngay=CurrentProduct.dateadd.getDate();
	// 		var Thang=CurrentProduct.dateadd.getMonth()+1;
	// 		var Nam=CurrentProduct.dateadd.getFullYear();
	// 		var datestring=Ngay+"/"+Thang+"/"+Nam;



	// 		CurrentProduct.dateadd=datestring;
	// 		res.render('Product/detailitem',{
	// 		title:"Chi Tiết Sản Phẩm",
	// 		CurrentProduct:CurrentProduct



	// 		});
	// 	});


	// },
	// delete:function(req,res)
	// {
	// 	//get id từ client
	// 	var id=req.body.masanpham;

	// 	var urlimageItemdeleted;
	// 	var itemdeleted;
	// 	listProduct.findAll(function(err,ListProduct)
	// 	{
	// 		for(var i=0;i<ListProduct.length;i++)
	// 		{
	// 			if(ListProduct[i].id==id)
	// 			{

	// 				itemdeleted=ListProduct[i];

	// 				break;
	// 			}
	// 		}

	// 		urlimageItemdeleted=itemdeleted.urlimage;
	// 		listProduct.delete(id,function(err)
	// 	{

	// 		if(err)
	// 		{
	// 			res.status(404).send("Có lỗi xảy ra khi xóa. Vui lòng kiểm tra lại và thử lại. ");
	// 		}
	// 		else{
	// 			listProduct.findAll(function(err,ListProduct)
	// 			{
	// 				if(urlimageItemdeleted=='/images/imdefault.png')//không xóa hình mặc định
	// 				{
	// 					res.render('Product/delete',{
	// 					title:"Xóa thành công",
	// 					messageDetail:"Đã xóa sản phẩm thành công",
	// 						});

	// 				}
	// 				else
	// 				{
	// 					fs.unlink("public"+urlimageItemdeleted, function(err)
	// 					{
	// 						if(err)
	// 						{
	// 							res.status(404).send(err);
	// 						}
	// 						else{
	// 							res.render('Product/delete',{
	// 							title:"Xóa thành công",
	// 							messageDetail:"Đã xóa sản phẩm thành công",
	// 								});

	// 						}
	// 					});

	// 				}

	// 			});
	// 		}
	// 	});

	// 	});



	// },
	update:function(req,res)
	{
		//truyền tham số tương ứng với sp tới client

		var id=req.params.id;


		var CurrentNhanVien;
		listnhanvien.getoneNVID(id,function(err,nhanvien)
		{

			if(nhanvien.recordset[0].LoaiNhanVien=='LNV001')
			{
				nhanvien.recordset.recordset[0].LoaiNhanVien='Tài xế';
			}
			else if(nhanvien.recordset[0].LoaiNhanVien=='LNV002')
			{
				nhanvien.recordset[0].LoaiNhanVien='Nhân Viên Quản Lý';
			}
			else if(nhanvien.recordset[0].LoaiNhanVien=='LNV003')
			{
				nhanvien.recordset.recordset[0].LoaiNhanVien='Nhân Viên Đặt Vé';
			}
			else if(nhanvien.recordset[0].LoaiNhanVien=='LNV004')
			{
				nhanvien.recordset[0].LoaiNhanVien='Nhân Viên Thanh Toán';
			}


			var Ngay=nhanvien.recordset[0].NgaySinhNV.getDate();
			var Thang=nhanvien.recordset[0].NgaySinhNV.getMonth()+1;
			var Nam=nhanvien.recordset[0].NgaySinhNV.getFullYear();
			var datestring=Thang+"/"+Ngay+"/"+Nam;



				nhanvien.recordset[0].NgaySinhNV=datestring;



				res.render('nhanvien/update',{
				title:"Cập nhật thông tin nhân vien",
				CurrentNhanVien:nhanvien.recordset[0],
				SelectedValue:
				{
					message: nhanvien.recordset[0].LoaiNhanVien


				}

			});

		});



	},
	updateSuccess:function(req,res)
	{

			var id=req.body.manhanvien;

		var CategoryGet;

				if(req.body.Category=="tx")
				{
					CategoryGet='LNV001';
				}
				else if(req.body.Category=="dv")
				{
					CategoryGet='LNV003';
				}
				else if(req.body.Category=="tt")
				{
					CategoryGet='LNV004';
				}
				else if(req.body.Category=="ql")
				{
					CategoryGet='LNV002';
				}

				listnhanvien.updateNV({
					name:req.body.name,
					loainhanvien:CategoryGet,
					gioitinh:req.body.gioitinh,
					diachi: req.body.diachi,
					cmnd:req.body.cmnd,
					dienthoai:req.body.dienthoai,
					ngaysinh:req.body.ngaysinh,
					matkhau:req.body.mk,

					luong:parseInt(req.body.luong),
					banglai: req.body.banglai,
					khanang:parseInt(req.body.khanang),
					manhanvien:id
				},function(err,nhanvien)
				{
					if(err)
					{

						res.status(404).send("Cập nhật thất bại. Vui lòng thử lại. Lỗi: "+err);
					}
					else
					{

						res.render('nhanvien/updateSuccess',{
							title:"Cập nhật thành công",
							messageDetail:"Đã cập nhật thông tin nhân viên thành công",
						});
					}
				});


	}
};

module.exports=listnhanvienAll;

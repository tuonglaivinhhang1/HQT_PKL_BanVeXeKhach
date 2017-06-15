
function checkEmptyForm(name,gioitinh,diachi,cmnd,dienthoai,
			ngaysinh,tdn,mk,Category,luong)
{
	if(name==null||name.length==0||gioitinh.length==0||diachi==null||diachi.length==0||cmnd.length==0||dienthoai==null
		||ngaysinh==null||tdn.length==0||mk.length==0||Category==null||Category.length==0||luong.length==0)
	{
		return true;//empty
	}
	else{
		return false;
	}


}


var listtaikhoan=require('../models/taikhoan');


var listtaikhoanGetAll={
	index:function(req,res)
	{
		listtaikhoan.getAll(function(err,ListTaiKhoan)
		{

			
			res.render('taikhoan/index',{
				title:"Danh sách tài khoản khách hàng",
				ListTaiKhoan:ListTaiKhoan.recordset,

			});
		});

		
	},
	findTKbyLTK:function(req,res)
	{

		listtaikhoan.getTKbyLTK(req.query['ltk'],function(err,ListTaiKhoan)
		{

			

			if(ListTaiKhoan.length==0)
			{
				res.end(JSON.stringify(null));
			}
			else{
					
			
				
				res.end(JSON.stringify(ListTaiKhoan));
			}
		});
	},
	
	update:function(req,res)
	{
		//truyền tham số tương ứng với sp tới client
		
		var id=req.params.id;
		

		var CurrentTaiKhoan;
		listtaikhoan.getoneTKbyMTK(id,function(err,taikhoan)
		{
			
			
		
				res.render('taikhoan/update',{
				title:"Cập nhật thông tin tài khoản khách hàng",
				CurrentTaiKhoan:taikhoan.recordset[0],
				SelectedValue:
				{
					message: taikhoan.recordset[0].LoaiTaiKhoan
				
					
				}			

			});

		});


		
	},
	updatesubmit:function(req,res)
	{
		
			var id=req.body.mataikhoan;

				var CategoryGet;
				
				if(req.body.Category=="khtt")
				{
					CategoryGet='Khách Hàng Thân Thiết';
				}
				else if(req.body.Category=="vip")
				{
					CategoryGet='VIP';
				}
				else if(req.body.Category=="tv")
				{
					CategoryGet='Thành Viên';
				}
				

				listtaikhoan.updateTK({
					mataikhoan:req.body.mataikhoan,
					loaitaikhoan:CategoryGet,
					diemtichluy:parseInt(req.body.diemtichluy),
					sotien:parseInt(req.body.sotien),
					matkhau:req.body.mk

				},function(err,taikhoan)
				{	
					if(err)
					{
				
						res.status(404).send("Cập nhật thất bại. Vui lòng thử lại. Lỗi: ");
					}
					else
					{
						
						res.render('taikhoan/updateSuccess',{
							title:"Cập nhật thành công",
							messageDetail:"Đã cập nhật thông tin tài khoản thành công",
						});
					}
				});			

		
	}
};

module.exports=listtaikhoanGetAll;

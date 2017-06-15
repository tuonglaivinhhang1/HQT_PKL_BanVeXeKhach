
var phancong=require('../models/phancongphutrachxe');


var phancongAll={
	index:function(req,res)
	{
		phancong.getAll(function(err,ListPhanCong)
		{

			for(var i=0;i<ListPhanCong.recordset.length;i++)
			{
				ListPhanCong.recordset[i].NgayBatDau=((ListPhanCong.recordset[i].NgayBatDau).toString()).substring(0,15);
				ListPhanCong.recordset[i].NgayKetThuc=((ListPhanCong.recordset[i].NgayKetThuc).toString()).substring(0,15);
				
			}
			phancong.getAllTaiXe(function(err,ListTaiXe) 
			{
				phancong.getAllXe(function(err,ListXe) 
				{
					res.render('phancongphutrachxe/index',{
					title:"Danh sách phân công",
					ListPhanCong:ListPhanCong.recordset,
					ListTaiXe:ListTaiXe.recordset,

					ListXe:ListXe.recordset,

				});
					

				});
				
			});
			
		});

		
	},
	phancong:function(req,res)
	{
		phancong.addphancong({
			mataixe:req.body.mataixe,
			maxe:req.body.maxe,
			ngaybatdau:req.body.ngaybatdau,
			ngayketthuc:req.body.ngayketthuc

		},function(err,result)
		{
			if(err || result.output.error!=null)
			{
					res.send({
						error:"Lỗi không thể phân công. Xin điền đúng dữ liệu.",

					});
			}
			else
			{
				res.send({
					message:"Phân công hoàn thành. Vui lòng xem bảng phân công.",
				});
			}

				
			
		});
			
		
	},
};

module.exports=phancongAll;


var listuser=require("../models/nhanvien");


var dashboardController={
	index:function(req,res)
	{
		listuser.getAll(function(err,ListNhanVien)
		{
			var Taixe=0,NVQuanly=0,NVDatve=0,NVThanhtoan=0;
			
			for(var i=0;i<ListNhanVien.recordset.length;i++)
			{
				

				if(ListNhanVien.recordset[i].LoaiNhanVien=="LNV001")
				{
					Taixe++;
				}
				else if(ListNhanVien.recordset[i].LoaiNhanVien=="LNV002")
				{
					NVQuanly++;
				}
				else if(ListNhanVien.recordset[i].LoaiNhanVien=="LNV003")
				{
					NVDatve++;

				}
				else if(ListNhanVien.recordset[i].LoaiNhanVien=="LNV004") {
					NVThanhtoan++;
				}
			}

			
			
			res.render('Dashboard/index',{
				title:"Welcome to Admin page",
				
				Taixe:Taixe,
				NVQuanly:NVQuanly,
				NVDatve:NVDatve,
				NVThanhtoan:NVThanhtoan,
				user:req.user,


			});
		});
	}
};

module.exports=dashboardController;


function checkEmptyForm(vitrighe)
{
	if(vitrighe==null||vitrighe.length==0)
	{
		return true;//empty
	}
	else{
		return false;
	}


}


var fs = require('fs');

var listghe=require('../models/ghe');
var listxe=require('../models/xe');


var listgheAll={
	index:function(req,res)
	{
		listghe.getAll(function(err,ListGhe)
		{


			res.render('ghe/index',{
				title:"Danh sách ghế",
				ListGhe:ListGhe.recordset,

			});
		});
	},	
		
	add:function(req,res)
	{
		listxe.getAll(function(err,ListMaXe)
		{
			res.render('ghe/add',{
			title:"Thêm Ghế",
			ListMaXe:ListMaXe.recordset,


			});
		});

		
	},
	addsubmit:function(req,res)
	{

		if(checkEmptyForm(req.body.vitri))
			{
					res.send({
						error:"Phải điền đầy đủ các thông tin bắt buộc"
					});

			

			}
		else
		{
				
				listghe.addGhe({
						maxe:req.body.maxe,
						
						vitri:req.body.vitri,
						
						
				},function(err,result)
				{
					

					if(err || result.output.error!=null)
					{
						

						
							res.send({
							error:"Thêm thất bại. Vui lòng thử lại."
						
					});
				}
				else
				{
					res.send({
						success:"Thêm Thành Công"});
				}
			});
		}
	}
	
};

module.exports=listgheAll;

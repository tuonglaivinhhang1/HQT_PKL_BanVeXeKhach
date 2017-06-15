function checkEmptyForm(loaixe,slg,bsx)
{
	if(loaixe==null||loaixe.length==0||bsx.length==0||bsx==null||slg==null||slg.length==0)
	{
		return true;//empty
	}
	else{
		return false;
	}


}


var fs = require('fs');

var listxe=require('../models/xe');


var listxeAll={
	index:function(req,res)
	{
		listxe.getAll(function(err,ListXe)
		{


			res.render('xe/index',{
				title:"Danh sách xe",
				ListXe:ListXe.recordset,

			});
		});
	},	
		
	add:function(req,res)
	{

		res.render('xe/add',{
			title:"Thêm xe"

		});
	},
	addsubmit:function(req,res)
	{
				

		if(checkEmptyForm(req.body.loaixe,req.body.slg,req.body.bsx))
			{
					res.send({
						error:"Phải điền đầy đủ các thông tin bắt buộc"
					});

			

			}
		else
		{
				console.log(req.body);	
				listxe.addXe({
						loaixe:req.body.loaixe,
						
						bsx:req.body.bsx,
						slg: parseInt(req.body.slg)
						
				},function(err,result)
				{
					

					if(err || result.output.error!=null)
					{
						console.log(err);

						console.log(result);


						
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
	},
	
	update:function(req,res)
	{
		//truyền tham số tương ứng với sp tới client
		
		var id=req.params.id;
		

		var CurrentXe;
		listxe.getoneID(id,function(err,Xe)
		{
			
			
				res.render('xe/update',{
				title:"Cập nhật thông tin xe",
				CurrentXe:Xe.recordset[0],
						

			});

		});


		
	},
	updatesubmit:function(req,res)
	{
		
			var id=req.body.maxe;

		
				listxe.update({
					maxe:req.body.maxe,
					loaixe:req.body.loaixe,
					bsx:req.body.bsx,
					slg:parseInt(req.body.slg)
				},function(err,xe)
				{	
					if(err)
					{
				
						res.status(404).send("Cập nhật thất bại. Vui lòng thử lại. Lỗi: "+err);
					}
					else
					{
						
						res.render('xe/updatecommit',{
							title:"Cập nhật thành công",
							messageDetail:"Đã cập nhật thông tin xe thành công",
						});
					}
				});			

		
	},
	
};

module.exports=listxeAll;

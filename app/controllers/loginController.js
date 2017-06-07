
var loginController={
	index:function(req,res)
	{
	
		if(!req.user)//nếu không có user nao
		{
			res.render('Login/index',{
			title:"Trang Đăng Nhập",
			message:"Vui lòng đăng nhập",
			layout:false,
			logginerr:req.flash('logginerr'),
			
			
		});
		}
		else{
			var user=req.user[0];
			res.render('Login/index',{
			title:"Trang Đăng Nhập",
			message:"Vui lòng đăng nhập",
			layout:false,
			user:user,
			
			
		});
		}
		
	}
	
};
module.exports=loginController;

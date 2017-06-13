

var profileController={
	index:function(req,res)
	{
		res.render('Profile/index',{
			title:"Thông tin cá nhân"
		});
	}
};	

module.exports=profileController;
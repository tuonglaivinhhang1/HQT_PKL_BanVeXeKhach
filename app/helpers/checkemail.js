
var User=require('../models/nhanvien');


function Checkemail(email,callback)
{
	
	var k= User.getUserByEmail(email,function(err,user)
	{
		
		if(user[0])
		{
			
			return callback(0);
		}
		else{

			return callback(1);
		}

	});

}

module.exports={Checkemail};
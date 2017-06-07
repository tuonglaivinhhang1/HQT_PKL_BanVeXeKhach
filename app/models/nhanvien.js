

var sql = require('mssql')
 
var config=require('../../config/database');




var GetNhanVien={
	getAll:function(callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
				    .query("select * from NhanVien", function(err,recordset) {


				      callback(err,recordset);

			        
		   			 })
    		}
		    
 
	});
	

	
	
	},
	getoneNV:function(username,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			.input('username', sql.VarChar(50),username)
				    .query("select * from NhanVien where TenDangNhapNV=@username", function(err,result) {

				     
				      callback(err,result);

			        
		   			 })
    		}
		    
 
	});
	
	}
};

module.exports=GetNhanVien;

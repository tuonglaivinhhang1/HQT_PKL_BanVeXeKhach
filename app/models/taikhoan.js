

var sql = require('mssql')
 
var config=require('../../config/database');



var GetTaiKhoan={
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
	    			
				    .query("select * from TaiKhoan", function(err,recordset) {


				      callback(err,recordset);

			        
		   			 });
    		}
		    
 
		});
	},
	getoneTKbyMTK:function(mtk,callback) 
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			.input('mtk',sql.VarChar(10),mtk)
				    .query("select * from TaiKhoan where MaTaiKhoan=@mtk", function(err,result) {


				      callback(err,result);

			        
		   			 });
    		}
		    
 
		});
	},
	
	getTKbyLTK:function(ltk,callback)
	{

		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 

	    			.input('loaitk', sql.NVarChar(50),ltk)

	    			.output('error', sql.NVarChar(500))
				    .execute('ThongKeTheoLTK',
					 function(err,recordset) {						       
    					
				      callback(err,recordset);

			        
		   			 })
    		}
		});
	},
	updateTK:function(taikhoan,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			.input('matk', sql.VarChar(10),taikhoan.mataikhoan)
	    			.input('diemtichluy', sql.Int,taikhoan.diemtichluy)
	    			.input('sotien', sql.Int,taikhoan.sotien)
	    			.input('loaitaikhoan', sql.NVarChar(50),taikhoan.loaitaikhoan)
	    			.input('matkhau', sql.VarChar(100),taikhoan.mk)
	    			  			
	    			.output('error', sql.NVarChar(500))
				    .execute('SuaTaiKhoan',
					 function(err,result) {						     

					 	// console.log(result);

				      callback(err,result);

			        
		   			 })
    		}
		});
	}
};

module.exports=GetTaiKhoan;

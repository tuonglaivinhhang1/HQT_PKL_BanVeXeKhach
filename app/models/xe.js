

var sql = require('mssql')
 
var config=require('../../config/database');


var GetListXe={
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
	    			
				    .query("select * from XE", function(err,recordset) {


				      callback(err,recordset);

			        
		   			 });
    		}
		    
 
		});
	},
	
	getoneID:function(id,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
    				.input('maxe',sql.VarChar(10),id)
	    			
				    .query("select * from XE where MaXe=@maxe", function(err,result) {


				      callback(err,result);

			        
		   			 })
    		}
		    
 
		});
	},
	getXEbyLX:function(lx,callback)
	{

		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 

	    			.input('loaixe', sql.NVarChar(50),lx)

	    			.output('error', sql.NVarChar(500))
				    .execute('ThongKeTheoLoaiXe',
					 function(err,recordset) {						       
    					
				      callback(err,recordset);

			        
		   			 })
    		}
		});
	},
	update:function(xe,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			.input('maxe', sql.VarChar(10),xe.maxe)
	    			.input('loaixe', sql.NVarChar(50),xe.loaixe)
	    			.input('biensoxe', sql.NVarChar(50),xe.bsx)
	    			.input('slghe', sql.Int,xe.slg)
	    					
	    			.output('error', sql.NVarChar(500))
				    .execute('CapNhatXe',
					 function(err,result) {						     

					

				      callback(err,result);

			        
		   			 })
    		}
		});

	},
	addXe:function(xe,callback) 
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
	    			.input('loaixe', sql.NVarChar(50),xe.loaixe)
	    			.input('biensoxe', sql.NVarChar(50),xe.bsx)
	    			.input('slghe', sql.Int,xe.slg)
	    					
	    			.output('error', sql.NVarChar(500))
				    .execute('ThemXe',
					 function(err,result) {						     

					

				      callback(err,result);

			        
		   			 })
    		}
		});
	}

};

module.exports=GetListXe;



var sql = require('mssql')
 
var config=require('../../config/database');


var GetListGhe={
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
	    			
				    .query("select * from GHE", function(err,recordset) {


				      callback(err,recordset);

			        
		   			 });
    		}
		    
 
		});
	},
	
	addGhe:function(ghe,callback) 
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			.input('vitrighe', sql.VarChar(10),ghe.vitri)
	    			.input('maxe', sql.VarChar(10),ghe.maxe)
	    			
	    			.output('error', sql.NVarChar(500))
				    .execute('ThemGhe',
					 function(err,result) {						     

					

				      callback(err,result);

			        
		   			 })
    		}
		});
	}

};

module.exports=GetListGhe;

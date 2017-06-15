

var sql = require('mssql')
 
var config=require('../../config/database');




var GetPhanCong={
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
	    			
				    .query("select xe.MaXe,xe.LoaiXe,pc.TaiXe,nv.TenNhanVien,pc.NgayBatDau,pc.NgayKetThuc from phancongtaixephutrachxe pc,nhanvien nv,XE xe where pc.TaiXe=nv.MaNhanVien\
				    	and pc.MaXe=xe.MaXe", function(err,recordset) {


				      callback(err,recordset);

			        
		   			 });
    		}
		    
 
		});
	},
	getAllTaiXe:function(callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
				    .query("select * from nhanvien nv where nv.LoaiNhanVien='LNV001'", 
				    	function(err,recordset) {


				      callback(err,recordset);

			        
		   			 });
    		}
		    
 
		});

	},
	getAllXe:function(callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
				    .query("select * from XE", 
				    	function(err,recordset) {


				      callback(err,recordset);

			        
		   			 });
    		}
		    
 
		});

	},
	addphancong:function(phancong,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
				   .input('mataixe', sql.VarChar(10),phancong.mataixe)
				   .input('maxe', sql.VarChar(10),phancong.maxe)
				   .input('ngaybatdau', sql.Date,phancong.ngaybatdau)
				   .input('ngayketthuc', sql.Date,phancong.ngayketthuc)

	    			.output('error', sql.NVarChar(500))
				    .execute('PhanCongPhuTrachXe',
					 function(err,result) {						     
 				
				      callback(err,result);

			        
		   			 });
    		}
		    
 
		});
	}
	
};

module.exports=GetPhanCong;

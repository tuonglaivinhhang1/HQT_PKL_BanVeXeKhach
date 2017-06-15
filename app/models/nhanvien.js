

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

			        
		   			 });
    		}
		    
 
		});
	},
	
	getoneNVID:function(id,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
    				.input('manv',sql.VarChar(10),id)
	    			
				    .query("select * from NhanVien where MaNhanVien=@manv", function(err,result) {


				      callback(err,result);

			        
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
	
	},
	getoneCMND:function(cmnd,callback)
	{

		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 

	    			.input('soCMND', sql.VarChar(10),cmnd)

	    			.output('error', sql.NVarChar(500))
				    .execute('XemNhanVienv2_DemoUnrepeatableRead',
					 function(err,result) {						     

					
   
    
    				
				      callback(err,result.recordsets[1]);

			        
		   			 })
    		}
		});
	},
	updateNV:function(nhanvien,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			.input('manhanvien', sql.VarChar(10),nhanvien.manhanvien)
	    			.input('tenNhanVien', sql.NVarChar(50),nhanvien.name)
	    			.input('gioitinh', sql.NVarChar(50),nhanvien.gioitinh)
	    			.input('diachi', sql.NVarChar(50),nhanvien.diachi)
	    			.input('soCMND', sql.VarChar(9),nhanvien.cmnd)
	    			.input('ngaysinh', sql.Date,nhanvien.ngaysinh)
	    			.input('dienthoai', sql.VarChar(20),nhanvien.dienthoai)
	    			.input('matkhau', sql.VarChar(100),nhanvien.matkhau)
	    			.input('loainhanvien', sql.VarChar(10),nhanvien.loainhanvien)
	    			.input('luong', sql.Int,nhanvien.luong)
	    			.input('banglai', sql.NVarChar(50),nhanvien.banglai)
	    			.input('khaNangLaiDuongDai', sql.Int,nhanvien.khanang)    			
	    			.output('error', sql.NVarChar(500))
				    .execute('CapNhatNhanVienV2_DemoUnrepeatableRead',
					 function(err,result) {						     

					 	// console.log(result);

				      callback(err,result);

			        
		   			 })
    		}
		});
	},
	addNhanVien:function(nhanvien,callback) 
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
	    			.input('tenNhanVien', sql.NVarChar(50),nhanvien.name)
	    			.input('gioitinh', sql.NVarChar(50),nhanvien.gioitinh)
	    			.input('diachi', sql.NVarChar(50),nhanvien.diachi)
	    			.input('soCMND', sql.VarChar(9),nhanvien.cmnd)
	    			.input('ngaysinh', sql.Date,nhanvien.ngaysinh)
	    			.input('dienthoai', sql.VarChar(20),nhanvien.dienthoai)
	    			.input('tendangnhap', sql.VarChar(50),nhanvien.tendangnhap)
	    			.input('matkhau', sql.VarChar(100),nhanvien.matkhau)
	    			.input('loainhanvien', sql.VarChar(10),nhanvien.loainhanvien)
	    			.input('luong', sql.Int,nhanvien.luong)
	    			.input('banglai', sql.NVarChar(50),nhanvien.banglai)
	    			.input('khaNangLaiDuongDai', sql.Int,nhanvien.khanang)    			
	    			.output('error', sql.NVarChar(500))
				    .execute('ThemNhanVien',
					 function(err,result) {						     

					

				      callback(err,result);

			        
		   			 })
    		}
		});
	},
	tangluong:function(nhanvien,callback)
	{
		const pool = new sql.ConnectionPool(config, err => {
    		if(err)
    		{
    			console.log(err);
    			
    		}
    		else
    		{
    			pool.request() 
	    			
	    			.input('manhanvien', sql.VarChar(10),nhanvien.manhanvien)
	    			.input('luongtangthem', sql.Int,nhanvien.luongtangthem)
	    			 			
	    			.output('error', sql.NVarChar(500))
				    .execute('TangLuong1',
					 function(err,result) {						     

		
				      callback(err,result);

			        
		   			 })
    		}
		});
	}
};

module.exports=GetNhanVien;

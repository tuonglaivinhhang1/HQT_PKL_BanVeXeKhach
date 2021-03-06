--=============================BẢNG NHÂN VIÊN=========================================
create procedure TaoMaNhanVienMoi
@maNV varchar(10) out
as
begin

	declare @lastMaNV varchar(10)
	set @lastMaNV=(select TOP 1 MaNhanVien from NHANVIEN order by MaNhanVien desc)
	

	declare @lastIndex int
	set @lastIndex=cast (SUBSTRING(@lastMaNV,3,(select LEN(@lastMaNV))-1) as int)

	if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=1)
		begin
			set @maNV='NV'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=2)
		begin
			set @maNV='NV'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=3)
		begin 
			set @maNV='NV'+cast((@lastIndex+1) as nvarchar(10))
		end
	
	

end
go

create procedure KiemTraCMND
@cmnd varchar(9)
as
begin
	if exists(select SoCMNDNV from NHANVIEN where SoCMNDNV=@cmnd)
	begin
		--CMND đã tồn tại
		return 1
	end
	else
	begin
		--CMND chưa tồn tại
		return 0
	end
	

end
go

create procedure KiemTraNgaySinh
@ngaysinh date
as
begin
	if(@ngaysinh>=GETDATE())
		begin
			return 1--sai
		end
	else
		begin
			return 0
		end
end
go

create procedure KiemTraSoDT--numberic only will check on interface (control textbox)
@soDT varchar(20)
as
begin
	if((select LEN(@soDT))=10 or (select LEN(@soDT))=11)
		begin
			return 1--đúng

		end
	else
		begin
			return 0

		end
	
end
go

create procedure KiemTraTenDangNhap
@tenDN varchar(50)
as
begin
	if((select LEN(@tenDN))<5)
		begin
			return 0--sai

		end
	else
		begin
			return 1

		end
	
end 
go

create procedure KiemTraLoaiNhanVien
@loaiNV varchar(10)
as
begin
	
	if exists(select LoaiNhanVien from NHANVIEN where LoaiNhanVien=@loaiNV)
	begin
		--đúng
		return 1
	end
	else
	begin
		
		return 0
	end
	

end
go
--=========================THÊM NHÂN VIÊN=======================================
create procedure ThemNhanVien
	@tenNhanVien nvarchar(50),
	@gioiTinh nvarchar(50),
	@diaChi nvarchar(50),
	@soCMND varchar(9),
	@ngaySinh date,
	@dienThoai varchar(20),
	@tenDangNhap varchar(50),
	@matKhau varchar(100),
	@loaiNhanVien varchar(10),
	@luong int,
	@bangLai nvarchar(50),
	@khaNangLaiDuongDai int,
	@error nvarchar(500) out
as
begin tran
	--tạo mã nhân viên mới
	declare @maNV varchar(10)
	exec TaoMaNhanVienMoi @maNV out


	--kiểm tra so CMND có trùng không
	declare @kiemtracmnd int;
	exec @kiemtracmnd=KiemTraCMND @soCMND
	if(@kiemtracmnd=1)
		begin
			set @error=N'Số CMND đã tồn tại'
			raiserror('Số CMND đã tồn tại.', 0, 0)
			rollback tran
			return
		end
	 


	--kiểm tra ngày sinh phải lớn hơn ngày hiện tại
	declare @kiemtrangaysinh int;
	exec @kiemtrangaysinh=KiemTraNgaySinh @ngaySinh
	if(@kiemtrangaysinh=1)
		begin
			set @error=N'Ngày sinh phải nhỏ hơn ngày hiện tại'
			raiserror('Ngày sinh phải nhỏ hơn ngày hiện tại.', 0, 0)
			rollback tran
			return
		end


	--kiểm tra số điện thoại 10 hoặc 11 số
	declare @kiemtraSDT int;
	exec @kiemtraSDT=KiemTraSoDT @dienThoai
	if(@kiemtraSDT=0)
		begin
			set @error=N'Số điện thoại phải là 10 hoặc 11 số'
			raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
			rollback tran
			return
		end
		

	--kiểm tra tên đăng nhập phải lớn hơn 5 ký tự
	declare @kiemtraTDN int;
	exec @kiemtraTDN=KiemTraTenDangNhap @tenDangNhap
	if(@kiemtraTDN=0)
		begin
			set @error=N'Tên đăng nhập phải lớn hơn 5 ký tự'
			raiserror('Tên đăng nhập phải lớn hơn 5 ký tự', 0, 0)
			rollback tran
			return
		end


	--password tự hash

	--kiểm tra loại nhân viên có tồn tại không?

	
	declare @kiemtraLNV int;
	exec @kiemtraLNV=KiemTraLoaiNhanVien @loaiNhanVien
	if(@kiemtraLNV=0)
		begin
			set @error=N'Loại Nhân Viên không tồn tại'
			raiserror('Loại Nhân Viên không tồn tại', 0, 0)
			rollback tran
			return
		end
	--nếu loại nhân viên không phải là tài xế thì sẽ không có bằng lái và khả năng chạy đường dài

	if(@loaiNhanVien!='LNV001' and @bangLai!=NULL)
		begin
			set @error=N'Không phải tài xế thì không có bằng lái'
			raiserror('Không phải tài xế thì không có bằng lái', 0, 0)
			rollback tran
			return
		end

	if(@loaiNhanVien!='LNV001' and @khaNangLaiDuongDai!=0)
		begin
			set @error=N'Không phải tài xế thì không có thuộc tính khả năng lái đường dài'
			raiserror('Không phải tài xế thì không có thuộc tính khả năng lái đường dài', 0, 0)
			rollback tran
			return
		end
	--bắt đầu insert

	

	insert into NHANVIEN(MaNhanVien, TenNhanVien, GioiTinhNV, DiaChiNV, SoCMNDNV, NgaySinhNV,
	DienthoaiNV,TenDangNhapNV,MatKhauNV,LoaiNhanVien,Luong,BangLai,KhaNangLaiDuongDai)
	values (@maNV,@tenNhanVien,@gioiTinh,@diaChi,@soCMND,@ngaySinh,@dienThoai,@tenDangNhap,@matKhau,
	@loaiNhanVien,@luong,@bangLai,@khaNangLaiDuongDai)

	if (@@ERROR <> 0)
	begin
		set @error=N'Không thể thêm. Vui lòng thử lại'
		raiserror('Không thể thêm. Vui lòng thử lại', 0, 0)
		
		rollback tran
		return
	end
	
commit tran

GO

--=========================CẬp NHật NHÂN VIÊN=======================================
create procedure KiemTraTaiXeCoDuocPhanCongChua
@maTaiXe varchar(10)
as
begin
	if (exists(select TaiXe from PHANCONGTAIXELAICHUYENDI where TaiXe=@maTaiXe) or exists(select TaiXe from PHANCONGTAIXEPHUTRACHXE where TaiXe=@maTaiXe))
		begin
			return 1--đã tồn tại

		end
	else
		begin
			return 0

		end
end

GO
create procedure KiemTraNhanVienThanhToan
@maNV varchar(10)
as
begin
	if (exists(select NhanVienThanhToan from VE where NhanVienThanhToan=@maNV) or exists(select NhanVienThanhToan from VE where  NhanVienThanhToan=@maNV))
		begin
			return 1--đã tồn tại

		end
	else
		begin
			return 0

		end
end

GO
create procedure KiemTraNhanVienDatVe
@maNV varchar(10)
as
begin
	if (exists(select NhanVienDatVe from VE where NhanVienDatVe=@maNV) or exists(select NhanVienDatVe from VE where  NhanVienDatVe=@maNV))
		begin
			return 1--đã tồn tại

		end
	else
		begin
			return 0

		end
end

GO
create procedure CapNhatNhanVien
	@maNhanVien varchar(10),
	@tenNhanVien nvarchar(50)=NULL,
	@gioiTinh nvarchar(50)=NULL,
	@diaChi nvarchar(50)=NULL,
	@soCMND varchar(9)=NULL,
	@ngaySinh date=NULL,
	@dienThoai varchar(20)=NULL,
	@matKhau varchar(100)=NULL,
	@loaiNhanVien varchar(10)=NULL,
	@luong int=NULL,
	@bangLai nvarchar(50)=NULL,
	@khaNangLaiDuongDai int=NULL,
	@error nvarchar(500) out
as
begin
begin transaction
	
	--kiểm tra Ngaysinh
	
	
	IF( LEN(ISNULL(@ngaySinh, '')) <> 0)
		begin
		
			declare @kiemtrangaysinh int;
			exec @kiemtrangaysinh=PHUONGTRANG.dbo.KiemTraNgaySinh @ngaySinh
			
			if(@kiemtrangaysinh=1)
				begin
					set @error=N'Ngày sinh phải nhỏ hơn ngày hiện tại'
					raiserror('Ngày sinh phải nhỏ hơn ngày hiện tại.', 0, 0)
					rollback
				
				end
		end
	--kiểm tra dien thoai
	if(LEN(ISNULL(@dienThoai, '')) <> 0)
		begin
			declare @kiemtraSDT int;
			exec @kiemtraSDT=KiemTraSoDT @dienThoai
			if(@kiemtraSDT=0)
				begin
					set @error=N'Số điện thoại phải là 10 hoặc 11 số'
					raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
					rollback
				end
		end

	--kiểm tra loai nhan vien
	--nếu tài xế đang phân công, hoặc nhân viên thanh toán, hoặc nhân viên quản lý, hoặc nhân viên đặt vé
	--đang có mặt tại các table khác thì không cho phép cập nhật. muốn cập nhật phải xóa dữ liệu liên quan
	--đến nhân viên đó
	--lấy loại nhân viên hiện tại
	declare @currentLNV varchar(10)
	set @currentLNV = (select LoaiNhanVien from NHANVIEN where MaNhanVien=@maNhanVien)

	if(LEN(ISNULL(@loaiNhanVien, '')) <> 0)
		begin
		
			if(@currentLNV='LNV001' and @loaiNhanVien!='LNV001')  
				begin
					declare @kiemtratx int;
					exec @kiemtratx=KiemTraTaiXeCoDuocPhanCongChua @maNhanVien
					if(@kiemtratx=1)
						begin
							set @error=N'Tài xế đang được phân công. '
							raiserror('Tài xế đang được phân công', 0, 0)
							rollback
							
						end
					

				end
			else if(@currentLNV='LNV004' and @loaiNhanVien!='LNV004')  
				begin
					declare @kiemtranvtt int;
					exec @kiemtranvtt=KiemTraNhanVienThanhToan @maNhanVien
					if(@kiemtranvtt=1)
						begin
							set @error=N'Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
			else if(@currentLNV='LNV003' and @loaiNhanVien!='LNV003')  
				begin
					declare @kiemtranvdv int;
					exec @kiemtranvdv=KiemTraNhanVienDatVe @maNhanVien
					if(@kiemtranvdv=1)
						begin
							set @error=N'Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
		end


		--update
		if(LEN(ISNULL(@tenNhanVien, '')) = 0)
			begin
			
				set @tenNhanVien=(select TenNhanVien from NHANVIEN where MaNhanVien=@maNhanVien)
				
			end
		
		if(LEN(ISNULL(@gioiTinh, '')) = 0)
			begin
				set @gioiTinh=(select GioiTinhNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@diaChi, '')) = 0)
			begin
				set @diaChi=(select DiaChiNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@soCMND, '')) = 0)
			begin
				set @soCMND=(select SoCMNDNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@dienThoai, '')) = 0)
			begin
				set @dienThoai=(select DienthoaiNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(@ngaySinh is NULL)
			begin
				select  @ngaySinh=NgaySinhNV from NHANVIEN where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@matKhau, '')) = 0)
			begin
				set @matKhau=(select MatKhauNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@loaiNhanVien, '')) = 0)
			begin
				set @loaiNhanVien=(select LOAINHANVIEN from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(@luong is NULL)
			begin
				select  @luong=Luong from NHANVIEN where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@bangLai, '')) = 0)
			begin
				set @bangLai=(select BangLai from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(@khaNangLaiDuongDai is NULL)
			begin
				select @khaNangLaiDuongDai=KhaNangLaiDuongDai from NHANVIEN where MaNhanVien=@maNhanVien
			end
		
		update NHANVIEN
		set TenNhanVien=@tenNhanVien,GioiTinhNV=@gioiTinh,DiaChiNV=@diaChi,SoCMNDNV=@soCMND,
		NgaySinhNV=@ngaySinh,DienthoaiNV=@dienThoai,MatKhauNV=@matKhau,
		LoaiNhanVien=@loaiNhanVien,Luong=@luong,BangLai=@bangLai,KhaNangLaiDuongDai=@khaNangLaiDuongDai
		where MaNhanVien=@maNhanVien

	

		if (@@ERROR <> 0)
			begin
				set @error=N'Không thể cập nhật. Vui lòng thử lại'
				raiserror('Không thể cập nhật. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

		
		
				
commit tran
end

GO
create procedure CapNhatNhanViendDEADLOCKDML
	@maNhanVien varchar(10),
	@tenNhanVien nvarchar(50)=NULL,
	@gioiTinh nvarchar(50)=NULL,
	@diaChi nvarchar(50)=NULL,
	@soCMND varchar(9)=NULL,
	@ngaySinh date=NULL,
	@dienThoai varchar(20)=NULL,
	@matKhau varchar(100)=NULL,
	@loaiNhanVien varchar(10)=NULL,
	@luong int=NULL,
	@bangLai nvarchar(50)=NULL,
	@khaNangLaiDuongDai int=NULL,
	@error nvarchar(500) out
as
begin
begin transaction
	
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	--kiểm tra Ngaysinh
	
	
	IF( LEN(ISNULL(@ngaySinh, '')) <> 0)
		begin
		
			declare @kiemtrangaysinh int;
			exec @kiemtrangaysinh=PHUONGTRANG.dbo.KiemTraNgaySinh @ngaySinh
			
			if(@kiemtrangaysinh=1)
				begin
					set @error=N'Ngày sinh phải nhỏ hơn ngày hiện tại'
					raiserror('Ngày sinh phải nhỏ hơn ngày hiện tại.', 0, 0)
					rollback
				
				end
		end
	--kiểm tra dien thoai
	if(LEN(ISNULL(@dienThoai, '')) <> 0)
		begin
			declare @kiemtraSDT int;
			exec @kiemtraSDT=KiemTraSoDT @dienThoai
			if(@kiemtraSDT=0)
				begin
					set @error=N'Số điện thoại phải là 10 hoặc 11 số'
					raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
					rollback
				end
		end

	--kiểm tra loai nhan vien
	--nếu tài xế đang phân công, hoặc nhân viên thanh toán, hoặc nhân viên quản lý, hoặc nhân viên đặt vé
	--đang có mặt tại các table khác thì không cho phép cập nhật. muốn cập nhật phải xóa dữ liệu liên quan
	--đến nhân viên đó
	--lấy loại nhân viên hiện tại
	WAITFOR DELAY '00:00:10' --wait for 10 seconds


	declare @currentLNV varchar(10)
	set @currentLNV = (select LoaiNhanVien from NHANVIEN  where MaNhanVien=@maNhanVien)

	if(LEN(ISNULL(@loaiNhanVien, '')) <> 0)
		begin
		
			if(@currentLNV='LNV001' and @loaiNhanVien!='LNV001')  
				begin
					declare @kiemtratx int;
					exec @kiemtratx=KiemTraTaiXeCoDuocPhanCongChua @maNhanVien
					if(@kiemtratx=1)
						begin
							set @error=N'Tài xế đang được phân công. '
							raiserror('Tài xế đang được phân công', 0, 0)
							rollback
							
						end
					

				end
			else if(@currentLNV='LNV004' and @loaiNhanVien!='LNV004')  
				begin
					declare @kiemtranvtt int;
					exec @kiemtranvtt=KiemTraNhanVienThanhToan @maNhanVien
					if(@kiemtranvtt=1)
						begin
							set @error=N'Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
			else if(@currentLNV='LNV003' and @loaiNhanVien!='LNV003')  
				begin
					declare @kiemtranvdv int;
					exec @kiemtranvdv=KiemTraNhanVienDatVe @maNhanVien
					if(@kiemtranvdv=1)
						begin
							set @error=N'Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
		end

		
		--update
		if(LEN(ISNULL(@tenNhanVien, '')) = 0)
			begin
			
				set @tenNhanVien=(select TenNhanVien from NHANVIEN  where MaNhanVien=@maNhanVien)
				
			end

		
		
		if(LEN(ISNULL(@gioiTinh, '')) = 0)
			begin
				set @gioiTinh=(select GioiTinhNV from NHANVIEN  where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@diaChi, '')) = 0)
			begin
				set @diaChi=(select DiaChiNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@soCMND, '')) = 0)
			begin
				set @soCMND=(select SoCMNDNV from NHANVIEN  where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@dienThoai, '')) = 0)
			begin
				set @dienThoai=(select DienthoaiNV from NHANVIEN  where MaNhanVien=@maNhanVien)
			end
		if(@ngaySinh is NULL)
			begin
				select  @ngaySinh=NgaySinhNV from  NHANVIEN  where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@matKhau, '')) = 0)
			begin
				set @matKhau=(select MatKhauNV from NHANVIEN  where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@loaiNhanVien, '')) = 0)
			begin
				set @loaiNhanVien=(select LOAINHANVIEN from NHANVIEN  where MaNhanVien=@maNhanVien)
			end
		if(@luong is NULL)
			begin
				select  @luong=Luong from NHANVIEN  where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@bangLai, '')) = 0)
			begin
				set @bangLai=(select BangLai from NHANVIEN   where MaNhanVien=@maNhanVien)
			end
		if(@khaNangLaiDuongDai is NULL)
			begin
				select @khaNangLaiDuongDai=KhaNangLaiDuongDai from NHANVIEN  where MaNhanVien=@maNhanVien
			end
		
		update NHANVIEN
		set TenNhanVien=@tenNhanVien,GioiTinhNV=@gioiTinh,DiaChiNV=@diaChi,SoCMNDNV=@soCMND,
		NgaySinhNV=@ngaySinh,DienthoaiNV=@dienThoai,MatKhauNV=@matKhau,
		LoaiNhanVien=@loaiNhanVien,Luong=@luong,BangLai=@bangLai,KhaNangLaiDuongDai=@khaNangLaiDuongDai
		where MaNhanVien=@maNhanVien

	

		if (@@ERROR <> 0)
			begin
				set @error=N'Không thể cập nhật. Vui lòng thử lại'
				raiserror('Không thể cập nhật. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

		
		
				
commit tran
end

go
create procedure CapNhatNhanViendDEADLOCKSL
	@maNhanVien varchar(10),
	@tenNhanVien nvarchar(50)=NULL,
	@gioiTinh nvarchar(50)=NULL,
	@diaChi nvarchar(50)=NULL,
	@soCMND varchar(9)=NULL,
	@ngaySinh date=NULL,
	@dienThoai varchar(20)=NULL,
	@matKhau varchar(100)=NULL,
	@loaiNhanVien varchar(10)=NULL,
	@luong int=NULL,
	@bangLai nvarchar(50)=NULL,
	@khaNangLaiDuongDai int=NULL,
	@error nvarchar(500) out
as
begin
begin transaction
	
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	--kiểm tra Ngaysinh
	
	
	IF( LEN(ISNULL(@ngaySinh, '')) <> 0)
		begin
		
			declare @kiemtrangaysinh int;
			exec @kiemtrangaysinh=PHUONGTRANG.dbo.KiemTraNgaySinh @ngaySinh
			
			if(@kiemtrangaysinh=1)
				begin
					set @error=N'Ngày sinh phải nhỏ hơn ngày hiện tại'
					raiserror('Ngày sinh phải nhỏ hơn ngày hiện tại.', 0, 0)
					rollback
				
				end
		end
	--kiểm tra dien thoai
	if(LEN(ISNULL(@dienThoai, '')) <> 0)
		begin
			declare @kiemtraSDT int;
			exec @kiemtraSDT=KiemTraSoDT @dienThoai
			if(@kiemtraSDT=0)
				begin
					set @error=N'Số điện thoại phải là 10 hoặc 11 số'
					raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
					rollback
				end
		end

	--kiểm tra loai nhan vien
	--nếu tài xế đang phân công, hoặc nhân viên thanh toán, hoặc nhân viên quản lý, hoặc nhân viên đặt vé
	--đang có mặt tại các table khác thì không cho phép cập nhật. muốn cập nhật phải xóa dữ liệu liên quan
	--đến nhân viên đó
	--lấy loại nhân viên hiện tại
	WAITFOR DELAY '00:00:10' --wait for 10 seconds


	declare @currentLNV varchar(10)
	set @currentLNV = (select LoaiNhanVien from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)

	if(LEN(ISNULL(@loaiNhanVien, '')) <> 0)
		begin
		
			if(@currentLNV='LNV001' and @loaiNhanVien!='LNV001')  
				begin
					declare @kiemtratx int;
					exec @kiemtratx=KiemTraTaiXeCoDuocPhanCongChua @maNhanVien
					if(@kiemtratx=1)
						begin
							set @error=N'Tài xế đang được phân công. '
							raiserror('Tài xế đang được phân công', 0, 0)
							rollback
							
						end
					

				end
			else if(@currentLNV='LNV004' and @loaiNhanVien!='LNV004')  
				begin
					declare @kiemtranvtt int;
					exec @kiemtranvtt=KiemTraNhanVienThanhToan @maNhanVien
					if(@kiemtranvtt=1)
						begin
							set @error=N'Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
			else if(@currentLNV='LNV003' and @loaiNhanVien!='LNV003')  
				begin
					declare @kiemtranvdv int;
					exec @kiemtranvdv=KiemTraNhanVienDatVe @maNhanVien
					if(@kiemtranvdv=1)
						begin
							set @error=N'Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
		end

		
		--update
		if(LEN(ISNULL(@tenNhanVien, '')) = 0)
			begin
			
				set @tenNhanVien=(select TenNhanVien from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
				
			end

		
		
		if(LEN(ISNULL(@gioiTinh, '')) = 0)
			begin
				set @gioiTinh=(select GioiTinhNV from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@diaChi, '')) = 0)
			begin
				set @diaChi=(select DiaChiNV from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@soCMND, '')) = 0)
			begin
				set @soCMND=(select SoCMNDNV from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@dienThoai, '')) = 0)
			begin
				set @dienThoai=(select DienthoaiNV from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(@ngaySinh is NULL)
			begin
				select  @ngaySinh=NgaySinhNV from  NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@matKhau, '')) = 0)
			begin
				set @matKhau=(select MatKhauNV from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@loaiNhanVien, '')) = 0)
			begin
				set @loaiNhanVien=(select LOAINHANVIEN from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(@luong is NULL)
			begin
				select  @luong=Luong from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@bangLai, '')) = 0)
			begin
				set @bangLai=(select BangLai from NHANVIEN  WITH (XLOCK) where MaNhanVien=@maNhanVien)
			end
		if(@khaNangLaiDuongDai is NULL)
			begin
				select @khaNangLaiDuongDai=KhaNangLaiDuongDai from NHANVIEN WITH (XLOCK) where MaNhanVien=@maNhanVien
			end
		
		update NHANVIEN
		set TenNhanVien=@tenNhanVien,GioiTinhNV=@gioiTinh,DiaChiNV=@diaChi,SoCMNDNV=@soCMND,
		NgaySinhNV=@ngaySinh,DienthoaiNV=@dienThoai,MatKhauNV=@matKhau,
		LoaiNhanVien=@loaiNhanVien,Luong=@luong,BangLai=@bangLai,KhaNangLaiDuongDai=@khaNangLaiDuongDai
		where MaNhanVien=@maNhanVien

	

		if (@@ERROR <> 0)
			begin
				set @error=N'Không thể cập nhật. Vui lòng thử lại'
				raiserror('Không thể cập nhật. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

		
		
				
commit tran
end

GO
create procedure CapNhatNhanVienV2_DemoUnrepeatableRead
	@maNhanVien varchar(10),
	@tenNhanVien nvarchar(50)=NULL,
	@gioiTinh nvarchar(50)=NULL,
	@diaChi nvarchar(50)=NULL,
	@soCMND varchar(9)=NULL,
	@ngaySinh date=NULL,
	@dienThoai varchar(20)=NULL,
	@matKhau varchar(100)=NULL,
	@loaiNhanVien varchar(10)=NULL,
	@luong int=NULL,
	@bangLai nvarchar(50)=NULL,
	@khaNangLaiDuongDai int=NULL,
	@error nvarchar(500) out
as
begin transaction
	
	--kiểm tra Ngaysinh
	
	
	IF( LEN(ISNULL(@ngaySinh, '')) <> 0)
		begin
		
			declare @kiemtrangaysinh int;
			exec @kiemtrangaysinh=PHUONGTRANG.dbo.KiemTraNgaySinh @ngaySinh
			
			if(@kiemtrangaysinh=1)
				begin
					set @error=N'Ngày sinh phải nhỏ hơn ngày hiện tại'
					raiserror('Ngày sinh phải nhỏ hơn ngày hiện tại.', 0, 0)
					rollback
				
				end
		end
	--kiểm tra dien thoai
	if(LEN(ISNULL(@dienThoai, '')) <> 0)
		begin
			declare @kiemtraSDT int;
			exec @kiemtraSDT=KiemTraSoDT @dienThoai
			if(@kiemtraSDT=0)
				begin
					set @error=N'Số điện thoại phải là 10 hoặc 11 số'
					raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
					rollback
				end
		end

	--kiểm tra loai nhan vien
	--nếu tài xế đang phân công, hoặc nhân viên thanh toán, hoặc nhân viên quản lý, hoặc nhân viên đặt vé
	--đang có mặt tại các table khác thì không cho phép cập nhật. muốn cập nhật phải xóa dữ liệu liên quan
	--đến nhân viên đó
	--lấy loại nhân viên hiện tại
	declare @currentLNV varchar(10)
	set @currentLNV = (select LoaiNhanVien from NHANVIEN where MaNhanVien=@maNhanVien)

	if(LEN(ISNULL(@loaiNhanVien, '')) <> 0)
		begin
		
			if(@currentLNV='LNV001' and @loaiNhanVien!='LNV001')  
				begin
					declare @kiemtratx int;
					exec @kiemtratx=KiemTraTaiXeCoDuocPhanCongChua @maNhanVien
					if(@kiemtratx=1)
						begin
							set @error=N'Tài xế đang được phân công. '
							raiserror('Tài xế đang được phân công', 0, 0)
							rollback
							
						end
					

				end
			else if(@currentLNV='LNV004' and @loaiNhanVien!='LNV004')  
				begin
					declare @kiemtranvtt int;
					exec @kiemtranvtt=KiemTraNhanVienThanhToan @maNhanVien
					if(@kiemtranvtt=1)
						begin
							set @error='Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên thanh toán này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
			else if(@currentLNV='LNV003' and @loaiNhanVien!='LNV003')  
				begin
					declare @kiemtranvdv int;
					exec @kiemtranvdv=KiemTraNhanVienDatVe @maNhanVien
					if(@kiemtranvdv=1)
						begin
							set @error=N'Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác '
							raiserror('Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác', 0, 0)
							rollback
							
						end
				end
		end


		--update
		if(LEN(ISNULL(@tenNhanVien, '')) = 0)
			begin
			
				set @tenNhanVien=(select TenNhanVien from NHANVIEN where MaNhanVien=@maNhanVien)
				
			end
		
		if(LEN(ISNULL(@gioiTinh, '')) = 0)
			begin
				set @gioiTinh=(select GioiTinhNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@diaChi, '')) = 0)
			begin
				set @diaChi=(select DiaChiNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@soCMND, '')) = 0)
			begin
				set @soCMND=(select SoCMNDNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@dienThoai, '')) = 0)
			begin
				set @dienThoai=(select DienthoaiNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(@ngaySinh is NULL)
			begin
				select  @ngaySinh=NgaySinhNV from NHANVIEN where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@matKhau, '')) = 0)
			begin
				set @matKhau=(select MatKhauNV from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(LEN(ISNULL(@loaiNhanVien, '')) = 0)
			begin
				set @loaiNhanVien=(select LOAINHANVIEN from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(@luong is NULL)
			begin
				select  @luong=Luong from NHANVIEN where MaNhanVien=@maNhanVien
			end
		if(LEN(ISNULL(@bangLai, '')) = 0)
			begin
				set @bangLai=(select BangLai from NHANVIEN where MaNhanVien=@maNhanVien)
			end
		if(@khaNangLaiDuongDai is NULL)
			begin
				select @khaNangLaiDuongDai=KhaNangLaiDuongDai from NHANVIEN where MaNhanVien=@maNhanVien
			end
		
		update NHANVIEN
		set TenNhanVien=@tenNhanVien,GioiTinhNV=@gioiTinh,DiaChiNV=@diaChi,SoCMNDNV=@soCMND,
		NgaySinhNV=@ngaySinh,DienthoaiNV=@dienThoai,MatKhauNV=@matKhau,
		LoaiNhanVien=@loaiNhanVien,Luong=@luong,BangLai=@bangLai,KhaNangLaiDuongDai=@khaNangLaiDuongDai
		where MaNhanVien=@maNhanVien

	

		if (@@ERROR <> 0)
			begin
				set @error=N'Không thể cập nhật. Vui lòng thử lại'
				raiserror('Không thể cập nhật. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

				
commit tran

GO

--================XÓA NHÂN VIÊN=================================

create procedure KiemTraNhanVienTonTai
@maNV varchar(10)
as
begin
	if(exists(select * from NHANVIEN where MaNhanVien=@maNV))
		begin
			return 1
			
		end
	else
		return 0

end
go
create procedure NhanVienBangKhac
@maNV varchar(10)
as
begin
	if(exists(select * from PHANCONGTAIXELAICHUYENDI where TaiXe=@maNV) or 
	exists(select * from PHANCONGTAIXEPHUTRACHXE where TaiXe=@maNV) or
	exists(select * from VE where NhanVienDatVe=@maNV) or
	exists(select * from VE where NhanVienThanhToan=@maNV) )
		begin
			return 1
			
		end
	else
		return 0

end

go
go
create procedure XoaNhanVien
@maNV varchar(10),
@error nvarchar(500) out
as
begin tran
	--tìm thử nhân viên có tồn tại không

	declare @checkNV int
	exec @checkNV=KiemTraNhanVienTonTai @maNV

	if(@checkNV=0)
		begin
			set @error=N'Nhân viên không tồn tại'
			raiserror('Nhân viên không tồn tại', 0, 0)
			rollback tran
			return
		end

	--nhân viên có đang bị phân công không làm gì không (xuất hiện trong table khác)

	declare @checkNV2 int
	exec @checkNV2=NhanVienBangKhac @maNV

	if(@checkNV2=1)
		begin
			set @error=N'Nhân viên đang được phân công. Không thể xóa'
			raiserror('Nhân viên đang được phân công. Không thể xóa', 0, 0)
			rollback tran
			return
		end

	--thực hiện xóa nếu thỏa hết
	delete NHANVIEN where MaNhanVien=@maNV

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi khi xóa. Vui lòng thử lại'
			raiserror('Có lỗi khi xóa. Vui lòng thử lại', 0, 0)
			rollback tran
			return

		end


commit tran

go
--=================XEM NHÂN VIÊN============================
create procedure KiemTraNhanVienTonTaiTheoCMND
@soCMND varchar(10)
as
begin
	if(exists(select * from NHANVIEN where SoCMNDNV=@soCMND))
		begin
			return 1
			
		end
	else
		return 0

end
go
--demo dirty read và khắc phục (kết hợp với update nhân viên)
create procedure XemNhanVien --select thông tin nhân viên theo cmnd (duy nhất)
@soCMND varchar(10),
@error nvarchar(500) out
as
begin transaction
		--demo dirty read
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED

		--tìm thử nhân viên có tồn tại không

		declare @checkNV int
		exec @checkNV=KiemTraNhanVienTonTaiTheoCMND @soCMND

		if(@checkNV=0)
			begin
				set @error=N'Nhân viên không tồn tại'
				raiserror('Nhân viên không tồn tại', 0, 0)
				rollback
				
			end

		

		--select nhan vien

		select * from NHANVIEN where SoCMNDNV=@soCMND

		
		if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại'
				raiserror('Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

commit transaction

go
create procedure XemNhanVienv2_DemoUnrepeatableRead --select thông tin nhân viên theo cmnd (duy nhất)
@soCMND varchar(10),
@error nvarchar(500) out
as
begin transaction
	
		--tìm thử nhân viên có tồn tại không

		SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- demo loi
		--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- khắc phục
		
		declare @checkNV int
		exec @checkNV=KiemTraNhanVienTonTaiTheoCMND @soCMND

		if(@checkNV=0)
			begin
				set @error=N'Nhân viên không tồn tại'
				raiserror('Nhân viên không tồn tại', 0, 0)
				rollback
				
			end

		select * from NHANVIEN where SoCMNDNV=@soCMND
		WAITFOR DELAY '00:00:10' --wait for 10 seconds
		select * from NHANVIEN where SoCMNDNV=@soCMND
		
		if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại'
				raiserror('Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end
		

commit transaction

go

--====================THỐNG KÊ LƯƠNG NHÂN VIÊN, TỔNG LƯƠNG==========
--demo phantom, kết hợp với transaction them nhan viên
create procedure ThongKeLuong_TinhTong
@TongLuong int out,
@error nvarchar(500) out
as
begin tran
	--demo phantom (kết hợp với thêm nhân viên)
	--set mức cô lập SERIALIZABLE
	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	select MaNhanVien,TenNhanVien,Luong,L.TenLoaiNV from NHANVIEN T,LOAINHANVIEN L where T.LoaiNhanVien=L.MaLoaiNV


	select @TongLuong=SUM(Luong) from NHANVIEN

	WAITFOR DELAY '00:00:10' --wait for 10 seconds, only for demo
	

	
	if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra. Không thể thống kê'
				raiserror('Có lỗi xảy ra. Không thể thống kê', 0, 0)		
				rollback tran
				return
			end

commit tran
go

--======================BẢNG TÀI KHOẢN KHÁCH HÀNG================

--==================THÊM TÀI KHOẢN===========================
create procedure TaoMaTaiKhoanMoi
@maTK varchar(10) out
as
begin
	
	
	declare @lastMaTK varchar(10)
	set @lastMaTK=(select TOP 1 MaTaiKhoan from TAIKHOAN order by MaTaiKhoan desc)
	

	declare @lastIndex int
	set @lastIndex=cast (SUBSTRING(@lastMaTK,3,(select LEN(@lastMaTK))-1) as int)
	

	if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=1)
		begin
			set @maTK='TK'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=2)
		begin
			set @maTK='TK'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=3)
		begin 
			set @maTK='TK'+cast((@lastIndex+1) as nvarchar(10))
		end

		
	
end
go


create procedure ThemTaiKhoan
@diemtichluy int=0,
@loaiTK nvarchar(50),
@soTien int=0,
@tenDangNhap varchar(50),
@matKhau varchar(100),
@maKH varchar(10),
@error nvarchar(500) out
as
begin tran
	--kiểm tra tên đăng nhập
	declare @ktTDN int
	exec @ktTDN=KiemTraTenDangNhap @tenDangNhap
	if(@ktTDN=0)
		begin
			set @error=N'Tên đăng nhập phải lớn hơn 5 ký tự'
			raiserror('Tên đăng nhập phải lớn hơn 5 ký tự', 0, 0)		
		end
	--get ma tai khoan mới
	declare @maTK varchar(10)
	exec TaoMaTaiKhoanMoi @maTK out

	insert into TAIKHOAN
	values(@maTK,@diemtichluy,@loaiTK,@soTien,@tenDangNhap,@matKhau,@maKH)

	if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra. Không thể thêm tài khoản'
				raiserror('Có lỗi xảy ra. Không thể thêm tài khoản', 0, 0)		
				rollback tran
				return
			end

commit tran
go
--==================SỬA TÀI KHOẢN===========================
create procedure KiemTraMaKHCoTonTai
@maKH varchar(10)
as
begin
	if(exists(select * from KHACHHANG where MaKhachHang=@maKH))
		begin
			return 1--có tồn tại
		end 
	else
		begin
			return 0
		end
end
go

create procedure SuaTaiKhoan
@maTK varchar(10),
@diemTichLuy int =NULL,
@loaiTaiKhoan nvarchar(50) =NULL,
@soTien int=NULL,
@matKhau varchar(100)=NULL,
@error nvarchar(500) out
as
begin tran
	
	--lấy giá trị cũ
	
	if(@diemTichLuy is null)
		begin
			select @diemTichLuy=DiemTichLuy from TAIKHOAN where MaTaiKhoan=@maTK
			
		end
	if(@loaiTaiKhoan is null)
		begin
			set @loaiTaiKhoan=(select LoaiTaiKhoan from TAIKHOAN where MaTaiKhoan=@maTK)
			
		end
	
	if(@soTien is null)
		begin
			select @soTien=SoTien from TAIKHOAN where MaTaiKhoan=@maTK
			
		end

	if(@matKhau is null)
		begin
			set @matKhau=(select MatKhau from TAIKHOAN where MaTaiKhoan=@maTK)
			
		end




	update TAIKHOAN
	set DiemTichLuy=@diemTichLuy,LoaiTaiKhoan=@loaiTaiKhoan,SoTien=@soTien,MatKhau=@matKhau
	where MaTaiKhoan=@maTK


	if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra. Không thể sửa tài khoản'
				raiserror('Có lỗi xảy ra. Không thể sửa tài khoản', 0, 0)		
				rollback tran
				return
			end

	--Khối lệnh demo lỗi
		WAITFOR DELAY '00:00:15'
		rollback
	
commit tran

go

--================XÓA TÀI KHOẢN=====================

create procedure KiemTraTaiKhoanCoTonTai
@maTK varchar(10)
as
begin
	if(exists(select * from TAIKHOAN where MaTaiKhoan=@maTK))
		begin
			return 1

		end
	else
		begin
			return 0

		end
end
go

create procedure XoaTaiKhoan
@maTK varchar(10),
@error nvarchar(500) out
as
begin tran
	--tìm thử tài khoản có tồn tại không

	declare @checkTK int
	exec @checkTK=KiemTraTaiKhoanCoTonTai @maTK

	if(@maTK=0)
		begin
			set @error=N'Tài khoản không tồn tại'
			raiserror('Tài khoản không tồn tại', 0, 0)
			rollback tran
			return
		end

	--xóa
	delete TAIKHOAN where MaTaiKhoan=@maTK
	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi khi xóa. Vui lòng thử lại'
			raiserror('Có lỗi khi xóa. Vui lòng thử lại', 0, 0)
			rollback tran
			return

		end
commit tran
GO

--======================Thống kế tài khoản theo loại tk================

create procedure ThongKeTheoLTK
@loaiTK nvarchar(50),
@error nvarchar(500) out
as
begin tran

		--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --lỗi dirty read
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED --khắc phục dirty read
	if((@loaiTK <>N'VIP') and (@loaiTK <>N'Khách hàng thân thiết') and (@loaiTK <> N'Thành viên') and (@loaiTK is null))
		begin
			
			set @error=N'Loại tài khoản không đúng'
			raiserror('Loại tài khoản không đúng',0,0)
			rollback tran
			return
		end

	select MaTaiKhoan,DiemTichLuy,LoaiTaiKhoan,SoTien,TenDangNhap,MaKhachHang
	from TAIKHOAN
	where LoaiTaiKhoan=@loaiTK

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi xảy ra. Không thống kê được. Xin thử lại'
			raiserror('Có lỗi xảy ra. Không thống kê được. Xin thử lại', 0, 0)
			rollback tran
			return
		end

commit tran
go
--=========================BẢNG XE==============================
--=============Thêm xe================
create procedure TaoMaXeMoi
@maXe varchar(10) out
as
begin

	declare @lastXe varchar(10)
	set @lastXe=(select TOP 1 MaXe from XE order by MaXe desc)
	

	declare @lastIndex int
	set @lastIndex=cast (SUBSTRING(@lastXe,3,(select LEN(@lastXe))-1) as int)

	if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=1)
		begin
			set @maXe='XE'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=2)
		begin
			set @maXe='XE'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex+1 as nvarchar(50))))=3)
		begin 
			set @maXe='XE'+cast((@lastIndex+1) as nvarchar(10))
		end
	
end
go

create procedure ThemXe
@loaiXe nvarchar(50),
@biensoXe nvarchar(50),
@slGhe int,
@error nvarchar(500) out
as
begin tran
	
	--get ma xe mới
	declare @maXe varchar(10)
	exec TaoMaXeMoi @maXe out

	insert into XE
	values(@maXe,@loaiXe,@biensoXe,@slGhe)

	if (@@ERROR <> 0)
			begin
				set @error=N'Không thể thêm xe'
				raiserror('Không thể thêm xe', 0, 0)		
				rollback tran
				return
			end
commit tran
go
--===================cập nhật xe==================
create procedure CapNhatXe
@maXe varchar(10),
@loaiXe nvarchar(50)=null,
@biensoXe nvarchar(50)=null,
@slGhe int =null,
@error nvarchar(500) out
as
begin tran
	
	if(@loaiXe is null)
		begin
			set @loaiXe=(select MaXe from XE where MaXe=@maXe)
		end
	if(@biensoXe is null)
		begin
			set @biensoXe=(select BienSoXe from XE where MaXe=@maXe)
		end
	if(@slGhe is null)
		begin
			select @slGhe=SoLuongGhe from XE where MaXe=@maXe
		end

	update Xe
	set LoaiXe=@loaiXe,BienSoXe=@biensoXe,SoLuongGhe=@slGhe
	where MaXe=@maXe

	--readcommited : lock Xe 


	if (@@ERROR <> 0)
			begin
				set @error=N'Không thể cập nhật xe'
				raiserror('Không thể cập nhật xe', 0, 0)		
				rollback tran
				return
			end
			

	--Khối lệnh demo lỗi dirty read
		WAITFOR DELAY '00:00:15'
		rollback
	
	
commit tran
go

--==================XÓA XE=====================

create procedure XoaXe
@maXe varchar(10),
@error nvarchar(500) out
as
begin tran
	
	
	delete Xe
	where MaXe=@maXe

	if (@@ERROR <> 0)
			begin
				set @error=N'Xe đang được phân công. Không thể xóa'
				raiserror('Xe đang được phân công. Không thể xóa', 0, 0)		
				rollback tran
				return
			end
	
commit tran
go

--==================PHÂN CÔNG PHỤ TRÁCH XE================

create procedure KiemTraTaiXe
@maTX varchar(10) 
as
begin
	if(exists(select * from NHANVIEN where MaNhanVien=@maTX and LoaiNhanVien='LNV001'))--phải là tài xế
		begin
			return 1
		end
	else
		begin
			return 0
		end
end
go

create procedure KiemTraXe
@maXe varchar(10) 
as
begin
	if(exists(select * from XE where MaXe=@maXe))
		begin
			return 1
		end
	else
		begin
			return 0
		end
end
go

create procedure PhanCongPhuTrachXe
@maTaiXe varchar(10),
@maXe varchar(10),
@ngayBatDau date,
@ngayKetThuc date,
@error nvarchar(500) out
as
begin tran
	--kiểm tra tài xế có tồn tại khong
	declare @ktTX int
	exec @ktTX=KiemTraTaiXe @maTaiXe
	if(@ktTX=0)	
		begin
			set @error=N'Tài xế không tồn tại'
			raiserror('Tài xế không tồn tại',0,0)
			rollback tran
			return
		end



	--kiem tra Xe có tồn tại không

	declare @ktXe int
	exec @ktXe=KiemTraXe @maXe
	if(@ktXe=0)	
		begin
			set @error=N'Xe không tồn tại'
			raiserror('Xe không tồn tại',0,0)
			rollback tran
			return
		end



	--kiểm tra ngay bat dau<ngay ket thuc

	if(@ngayBatDau>@ngayKetThuc)
		begin
			
			set @error=N'Ngày bắt đầu phải nhỏ hơn ngày kết thúc'
			raiserror('Ngày bắt đầu phải nhỏ hơn ngày kết thúc',0,0)
			rollback tran
			return
		end
	
	--ngày null
	if(@ngayBatDau is null or @ngayKetThuc is null)
		begin
			
			set @error=N'Ngày không được NULL'
			raiserror('Ngày không được NULL',0,0)
			rollback tran
			return
		end
	


	--tài xế phụ trách nhiều xe trong cùng một khoảng thời gian là chuyện bình thường

	insert into PHANCONGTAIXEPHUTRACHXE
	values(@maTaiXe,@maXe,@ngayBatDau,@ngayKetThuc)

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. không thể thực hiện phân công'
			raiserror('Có lỗi phát sinh. không thể thực hiện phân công',0,0)
			rollback tran
			return

		end

commit tran

go

--====================BẢNG GHẾ=====================

create procedure ThemGhe
@vitrighe varchar(10),
@maxe varchar(10),
@error nvarchar(500) out
as
begin tran

	--kiem tra Xe có tồn tại không

	declare @ktXe int
	exec @ktXe=KiemTraXe @maXe
	if(@ktXe=0)	
		begin
			set @error=N'Xe không tồn tại'
			raiserror('Xe không tồn tại',0,0)
			rollback tran
			return
		end

	if(@vitrighe is null or @maxe is null)
		begin
			
			set @error=N'Không thể đặt giá trị null'
			raiserror('Không thể đặt giá trị null',0,0)
			rollback tran
			return
		end


	insert into GHE
	values(@vitrighe,@maxe)

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. Không thể thêm ghế'
			raiserror('Có lỗi phát sinh. Không thể thêm ghế',0,0)
			rollback tran
			return

		end

commit tran

go
create procedure XoaGhe
@vitrighe varchar(10),
@maxe varchar(10),
@error nvarchar(500) out
as
begin tran
	--kiem tra Xe có tồn tại không

	declare @ktXe int
	exec @ktXe=KiemTraXe @maXe
	if(@ktXe=0)	
		begin
			set @error=N'Xe không tồn tại'
			raiserror('Xe không tồn tại',0,0)
			rollback tran
			return
		end

	if(@vitrighe is null or @maxe is null)
		begin
			
			set @error=N'Phải bắt buộc có vị trí ghế và mã xe cụ thể'
			raiserror('Phải bắt buộc có vị trí ghế và mã xe cụ thể',0,0)
			rollback tran
			return
		end

	delete GHE where ViTriGhe=@vitrighe and MaXe=@maxe
	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. Không thể xóa ghế'
			raiserror('Có lỗi phát sinh. Không thể xóa ghế',0,0)
			rollback tran
			return

		end
	
commit tran
go
create procedure XemTinhTrangGhe --xem ghế đó là trống hay đã đặt
@maxe varchar(10),
@maghe varchar(10),
@machuyendi varchar(10),
@error nvarchar(500) out,
@output nvarchar(50) out
as
begin tran
	
	if(exists(select * from VE where MaChuyenDi=@machuyendi and MaGhe=@maghe and MaXe=@maxe))
		begin
			set @output='Đã đặt'		
		end
	else
		begin
			set @output='Trống'	
		end

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. Không thể xem tình trạng ghế'
			raiserror('Có lỗi phát sinh. Không thể xem tình trạng ghế',0,0)
			rollback tran
			return

		end

commit tran
go

--=========================TĂNG LƯƠNG TÀI XẾ================
--DEMO LOST UPDATE
--tăng lương theo QĐ1, do nhân viên 1 quy định
create procedure TangLuong1
@manhanvien varchar(10),
@luongtangthem int,
@error nvarchar(500) out
as
begin tran

	
	--kiểm tra tài xế có tồn tại khong
	declare @ktTX int
	exec @ktTX=KiemTraTaiXe @manhanvien
	if(@ktTX=0)	
		begin
			set @error=N'Tài xế không tồn tại'
			raiserror('Tài xế không tồn tại',0,0)
			rollback tran
			return
		end
	if(@luongtangthem<0)
		begin
			set @error=N'Lương không được <0'
			raiserror('Lương không được <0',0,0)
			rollback tran
			return
		end

	declare @luonghientai int
	select @luonghientai=(select Luong  from NHANVIEN where MaNhanVien=@manhanvien)	
	set @luonghientai=@luonghientai+@luongtangthem

	WAITFOR DELAY '00:00:15.000';
	--khắc phục lỗi
	--set Luong=Luong+@luongtangthem
	
	update NHANVIEN
	--set Luong=Luong+@luongtangthem
	set Luong=@luonghientai
	where MaNhanVien=@manhanvien

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. Không thể tăng lương'
			raiserror('Có lỗi phát sinh. Không thể tăng lương',0,0)
			rollback tran
			return

		end

commit tran

go
--tăng lương theo QĐ2, do nhân viên 2 thực hiện
create procedure TangLuong2
@manhanvien varchar(10),
@luongtangthem int,
@error nvarchar(500) out
as
begin tran

	
	--kiểm tra tài xế có tồn tại khong
	declare @ktTX int
	exec @ktTX=KiemTraTaiXe @manhanvien
	if(@ktTX=0)	
		begin
			set @error=N'Tài xế không tồn tại'
			raiserror('Tài xế không tồn tại',0,0)
			rollback tran
			return
		end
	if(@luongtangthem<0)
		begin
			set @error=N'Lương không được <0'
			raiserror('Lương không được <0',0,0)
			rollback tran
			return
		end

	declare @luonghientai int
	select @luonghientai=(select Luong  from NHANVIEN where MaNhanVien=@manhanvien)	
	set @luonghientai=@luonghientai+@luongtangthem

	
	update NHANVIEN
	set Luong=@luonghientai
	where MaNhanVien=@manhanvien

	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. Không thể tăng lương'
			raiserror('Có lỗi phát sinh. Không thể tăng lương',0,0)
			rollback tran
			return

		end

commit tran

go
create procedure ThongKeTheoLoaiXe
@loaixe nvarchar(50),
@error nvarchar(500) out
as
begin tran

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --lỗi dirty read
		--SET TRANSACTION ISOLATION LEVEL READ COMMITTED --khắc phục dirty read



	select * from XE where LoaiXe=@loaixe --lock


	



	if(@@ERROR<>0)
		begin
			set @error=N'Có lỗi phát sinh. Không thể thống kê'
			raiserror('Có lỗi phát sinh. Không thể thống kê',0,0)
			rollback tran
			return

		end

commit tran


go




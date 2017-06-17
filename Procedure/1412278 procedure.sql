use PHUONGTRANG
--Demo lỗi
--=============================================Them Khach Hang=================================
-- Tao mã khách hàng
-----drop proc generateMaKH
create procedure generateMaKH 
@makh varchar(10) out
as
begin

	declare @lastMakh varchar(10)
	set @lastMakh=(select TOP 1 MaKhachHang from KHACHHANG order by MaKhachHang desc)
	

	declare @lastIndex int
	set @lastIndex=cast (SUBSTRING(@lastMakh,3,(select LEN(@lastMakh))-1) as int)

	if((select LEN(cast(@lastIndex + 1 as nvarchar(50))))=1)
		begin
			set @makh='KH'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex + 1 as nvarchar(50))))=2)
		begin
			set @makh='KH'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex + 1 as nvarchar(50))))=3)
		begin 
			set @makh='KH'+cast((@lastIndex+1) as nvarchar(10))
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

create procedure KiemTraCMNDKH
@cmnd varchar(9)
as
begin
	if exists(select SoCMNDKH from KHACHHANG where SoCMNDKH=@cmnd)
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

---- them moi khach hang
create proc themKhachHang 
	@ten nvarchar(50),
	@gioitinh nvarchar(50),
	@DiaChi nvarchar(50),
	@CMNDKH varchar(9),
	@Dienthoai varchar(20),
	@error varchar(50)out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
	--declare
	declare @MaMoi nvarchar(10)
	-- tao ma khach hang
	exec generateMaKH @MaMoi out
	--Không coÌn maÞ mõìi ðêÒ taòo
	if (@MaMoi = 'error')
		begin
			Set @error = 'khong co ma de tao'
			raiserror('khong co ma de tao', 0, 0)
			rollback tran
			return
		end
			
			-- kiem tra hop le CMND
			
	declare @kiemtracmnd int;
	exec @kiemtracmnd=KiemTraCMNDKH @CMNDKH
	if(@kiemtracmnd=1)
		begin
			set @error='Số CMND đã tồn tại'
			raiserror('Số CMND đã tồn tại.', 0, 0)
			rollback tran
			return
		end
		-- kiem tra so dien thoai
	declare @kiemtraSDT int;
	exec @kiemtraSDT=KiemTraSoDT @Dienthoai
	if(@kiemtraSDT=0)
		begin
			set @error='Số điện thoại phải là 10 hoặc 11 số'
			raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
			rollback tran
			return
		end
	-- Thêm khách hàng mới
	
		insert into KHACHHANG(MaKhachHang,TenKhachHang,GioiTinhKH,DiaChiKH,SoCMNDKH,DienthoaiKH)
		values
		(@MaMoi,@ten,@gioitinh,@DiaChi,@CMNDKH,@Dienthoai)	
		if (@@ERROR <> 0)
		begin
			raiserror('Loi them khach hang vui long thu lai ', 0, 0)
			Set @error = 'Loi them khach hang vui long thu lai '
			rollback tran
			return
		end
			
commit tran

go
--=====================================================Xoa khach hang=========================================
----- Kiem tra xem khach hang con ve hay khong , con tai khoan nao tham chieu den no hay khong , kiem tra khach hang con ton tai hay khong
--- kiem tra khach hang ton tai
create procedure kiemtrakhtontai @makh varchar(10)
as
begin
	if exists(select MaKhachHang from KHACHHANG where MaKhachHang = @makh)
	begin
		
		return 1
	end
	else
	begin
		
		return 0
	end
end
-- ham kiem tra ve
create proc kiemtraVe 
	@makh varchar(10),
	@kqua int out
as
begin
	if exists(select MaKhachHang from VE where MaKhachHang = @makh)
	begin
		return 1
	end

	else
	begin 
		return 0
	end
end
	-- ham kiem tra tai khoan
create proc kiemtraTK
	@makh	varchar(10),
	@kqua	int out
as
begin
	if exists(select MaKhachHang from TAIKHOAN where MaKhachHang = @makh)
	begin
		return 1
	end
	else
	begin
		return 0
	end
end

create proc xoaKhachHang 
	@makh varchar(10),
	@error varchar(50)
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
	-- kiem tra ton tai khach hang
	declare @ktratontai int
	exec @ktratontai = kiemtrakhtontai @makh
	if(@ktratontai = 0)
	begin
		set @error = 'Khong co khach hang trong he thong'
		raiserror('Khong co khach hang trong he thong',0,0)
		rollback tran
		return
	end 
	--kiem tra xem con ve nao tham chieu khach hang hay khong
	declare @kiemtrave int 
	exec @kiemtrave = kiemtraVe @makh
	if(@kiemtrave = 1)
	begin
		set @error = 'Con ve tham chieu den khach hang nay'
		raiserror('Con ve tham chieu den khach hang nay',0,0)
		rollback tran
		return
	end
	
	delete KHACHHANG where MaKhachHang = @makh
	if (@@ERROR <> 0)
		begin
			raiserror('Loi xoa khach hang vui long thu lai ', 0, 0)
			Set @error = 'Loi xoa khach hang vui long thu lai '
			rollback tran
			return
		end
commit tran
go
---============================================== Cap nhat thong tin khach hang ============================================
-- Kiem tra khach hang co ton tai hay khong , cac du lieu dau vao co thoa hay khong
--ham kiem tra tai khoan co ton tai hay khong 
create proc kiemtratontaiTK 
	@matk varchar(10),
	@kqua int
as
begin
	if exists(Select MaTaiKhoan from TAIKHOAN where MaTaiKhoan = @matk)
	begin
		return 1
	end
	else
	begin
		return 0
	end
end
go
----drop proc capnhatKH
create proc capnhatKH 
	 @makh varchar(10),
	 @ten nvarchar(50)=null ,
	 @gioitinh nvarchar(50) = null,
	 @DiaChi nvarchar(50) = null,
	 @CMNDKH varchar(9) = null,
	 @Dienthoai varchar(20) = null, 
	 @error varchar(50) out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
	-- Kiem tra ton tai 
	declare @khtt int
	exec @khtt = kiemtrakhtontai @makh
	if (@khtt = 0)
	begin
		Set @error = 'Khach hang khong ton tai'
		raiserror('Khach hang khong ton tai',0,0)
		rollback tran
		return 
	end
	--Kiem tra CMND nhap hop le hay khong
	if(LEN(ISNULL(@CMNDKH,'')) <> 0 )
	begin
		declare @ktCMND int
		exec @ktCMND = KiemTraCMNDKH @CMNDKH
			if(@ktCMND = 1) 
			begin
				Set @error = 'CMND bi trung vui long nhap lai'
				raiserror('CMND bi trung vui long nhap lai',0,0) 
				rollback tran
				return
			end
		end

	---kiem tra so dien thoai co hop le hay khong
	if(LEN(ISNULL(@Dienthoai,'')) <> 0 )
	begin
		declare @ktdt int
		exec @ktdt  = KiemTraSoDT @Dienthoai
		if(@ktdt = 0)
		begin
			Set @error = 'Chieu dai so dien thoai khong dung'
			raiserror ('Chieu dai so dien thoai khong dung',0,0)
			rollback tran
			return
		end
	end

	
	-- kiem tra du lieu nhap vao co null hay khong
	if(LEN(ISNULL(@ten,'')) = 0 )
	begin
		set @ten = (Select TenKhachHang from KHACHHANG where MaKhachHang = @makh  )
	end
	if(LEN(ISNULL(@gioitinh,'')) = 0 )
	begin
		set @gioitinh = (Select GioiTinhKH from KHACHHANG where MaKhachHang = @makh)
	end
	if(LEN(ISNULL(@DiaChi,'')) = 0 )
	begin
		set @DiaChi = (Select DiaChiKH from KHACHHANG where MaKhachHang = @makh)
	end
	if(LEN(ISNULL(@CMNDKH,'')) = 0 )
	begin
		set @CMNDKH = (Select SoCMNDKH from KHACHHANG where MaKhachHang = @makh)
	end
	if(LEN(ISNULL(@Dienthoai,'')) = 0 )
	begin
		set @Dienthoai = (Select DienthoaiKH from KHACHHANG where MaKhachHang = @makh)
	end
	-- Set gia tri moi vao khach hang
	Update KHACHHANG 
	set TenKhachHang = @ten,
	GioiTinhKH = @gioitinh,
	DiaChiKH = @DiaChi,
	SoCMNDKH = @CMNDKH,
	DienthoaiKH = @Dienthoai
	where MaKhachHang = @makh	
	if (@@ERROR <> 0)
			begin
				set @error='khong the cap nhat thong tin KH'
				raiserror('khong the cap nhat thong tin KH', 0, 0)
				rollback tran
				return
			end
commit tran

go

--=================Xem thong tin khach hang================
create proc xemthongtinKH @makh varchar(10), @error varchar(50) out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
	declare @khtt int
	declare @sql varchar(200)
	exec @khtt = kiemtrakhtontai @makh
	if (@khtt = 0)
	begin
		Set @error = 'Khach hang khong ton tai'
		raiserror('Khach hang khong ton tai',0,0)
		rollback tran
		return 
	end
	
	 Select * from KHACHHANG where MaKhachHang = @makh
	
	if (@@ERROR <> 0)
			begin
				set @error='Lay thong tin khach hang bi loi '
				raiserror('Lay thong tin khach hang bi loi ', 0, 0)
				rollback tran
				return
			end

commit tran
go
--==============Xem Ve =========================

create procedure veCoTonTai @MaVe varchar(10)
as
begin
	if exists(select MaVe from VE where MaVe = @MaVe)
	begin
		
		return 1
	end
	else
	begin
		
		return 0
	end
end

-- Xem tung ve rieng le
Create proc xemve @MaVe varchar(10), @error varchar(50)
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
	declare @kiemtrave int
	exec  @kiemtrave =  veCoTonTai @MaVe
	if(@kiemtrave =1 )
		begin
		 select * from  VE where MaVe = @MaVe
		end
	  if (@@ERROR <> 0)
		begin
			set @error = 'Phat sinh loi trong luc doc ve'
			raiserror('Phat sinh loi trong luc doc ve', 0, 0)
			rollback tran
			return
		end
   else
	   begin
		 raiserror('khong co ve ',0,0)
		 rollback tran
		 return 
	   end
commit tran
go
-- Xem ve theo khach hang
create proc xemveKH @makh varchar(10),@error varchar(50)
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
	---SET TRANSACTION ISOLATION LEVEL SERIAlIZABLE
	declare @ktratontai int
	exec @ktratontai = kiemtrakhtontai @makh
	if(@ktratontai = 0)
	begin
		set @error = 'Khong co khach hang trong he thong'
		raiserror('Khong co khach hang trong he thong',0,0)
		rollback tran
		return
	end 

	select * from VE where MaKhachHang = @makh
	  if (@@ERROR <> 0)
		begin
			set @error = 'Phat sinh loi trong luc doc ve theo khach hang'
			raiserror('Phat sinh loi trong luc doc ve theo khach hang', 0, 0)
			rollback tran
			return
		end

commit tran
go

--======================Thong ke loai tai khoan==========

----drop proc thongketaikhoantheodiem

 create proc thongketaikhoantheodiem @diem int, @error varchar(50) out
  as
  begin tran
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
  		select *
		from TAIKHOAN
		where DiemTichLuy >= @diem
		WAITFOR DELAY '00:00:15'
		---------thong ke lai --------------

		if (@@ERROR <> 0)
		begin
			set @error = 'Co loi trong luc thong ke so tai khoan theo diem tich luy'
			raiserror('Co loi trong luc thong ke so tai khoan theo diem tich luy', 0, 0)
			rollback tran
			return
		end

  commit tran
  --Thong ke theo loai khach hang
  ---drop proc thongketaikhoantheoloai
   create proc thongketaikhoantheoloai @loai nvarchar(50), @error varchar(50) out, @tongcong int out
  as
  begin tran
		SET TRANSACTION ISOLATION LEVEL READ COMMITtED
		
		begin
		select * 
		from TAIKHOAN
		where LoaiTaiKhoan like @loai 

  		select @tongcong = count(LoaiTaiKhoan) 
		from TAIKHOAN
		where LoaiTaiKhoan like @loai 
		
		end
		
		if (@@ERROR <> 0)
		begin
			set @error = 'Co loi trong luc thong ke so tai khoan theo loai'
			raiserror('Co loi trong luc thong ke so tai khoan theo loai', 0, 0)
			rollback tran
			return
		end

  commit tran
  go
  --==================THÊM TÀI KHOẢN===========================
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

----drop proc TaoMaTaiKhoanMoi
create procedure TaoMaTaiKhoanMoi
@maTK varchar(10) out
as
begin

	declare @lastMaTK varchar(10)
	set @lastMaTK=(select TOP 1 MaTaiKhoan from TAIKHOAN order by MaTaiKhoan desc)
	

	declare @lastIndex int
	set @lastIndex=cast (SUBSTRING(@lastMaTK,3,(select LEN(@lastMaTK))-1) as int)

	if((select LEN(cast(@lastIndex + 1 as nvarchar(50))))=1)
		begin
			set @maTK='TK'+'00'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex + 1 as nvarchar(50))))=2)
		begin
			set @maTK='TK'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex + 1 as nvarchar(50))))=3)
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
@maKH varchar(10)=NULL,
@diemTichLuy int =NULL,
@loaiTaiKhoan nvarchar(50) =NULL,
@soTien int=NULL,
@matKhau varchar(100)=NULL,
@error nvarchar(500) out
as
begin tran
	
	--kiểm tra mã khách hàng
	if(@maKH is not NULL)
		begin
			declare @ktKH int
			exec @ktKH=KiemTraMaKHCoTonTai @maKH
			if(@ktKH=0)
				begin
					set @error=N'Khách Hàng không tồn tại'
					raiserror('Khách Hàng không tồn tại', 0, 0)		
					rollback tran
					return
				end
		end
	
	--lấy giá trị cũ
	if(@maKH is null)
		begin
			set @maKH=(select MaKhachHang from TAIKHOAN where MaTaiKhoan=@maTK)
			
		end
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
	set DiemTichLuy=@diemTichLuy,LoaiTaiKhoan=@loaiTaiKhoan,SoTien=@soTien,MatKhau=@matKhau,MaKhachHang=@maKH
	where MaTaiKhoan=@maTK


	if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra. Không thể sửa tài khoản'
				raiserror('Có lỗi xảy ra. Không thể sửa tài khoản', 0, 0)		
				rollback tran
				return
			end
	
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
	--tìm thử nhân viên có tồn tại không

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

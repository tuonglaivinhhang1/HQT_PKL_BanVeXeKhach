---=====================================Sua Loi PhanTom=============================================
  -------------------------------Sua loi thiet lap muc co lap trong proc thongketheodiem thanh serializable
  ------- Sau khi thong ke xong thi moi duoc them tai khoan moi vao.
  ----proc sau khi sua loi
  ---------drop proc thongketaikhoantheodiem_fix_PT
  create proc thongketaikhoantheodiem_fix_PT @diem int, @error varchar(50) out
  as
  begin tran
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  		select *
		from TAIKHOAN
		where DiemTichLuy >= @diem
		WAITFOR DELAY '00:00:15'

		select *
		from TAIKHOAN
		where DiemTichLuy >= @diem

		Select Count(DiemTichLuy)
		from TAIKHOAN
		where DiemTichLuy >= @diem
		if (@@ERROR <> 0)
		begin
			set @error = 'Co loi trong luc thong ke so tai khoan theo diem tich luy'
			raiserror('Co loi trong luc thong ke so tai khoan theo diem tich luy', 0, 0)
			rollback tran
			return
		end

  commit tran
  --------------- chay lai demo--------------------
  declare @errorphantom varchar(50)
  exec thongketaikhoantheodiem_fix_PT 1000 , @errorphantom out

  ------mo them 1 trans để chạy lệnh dưới.
  declare @errordemo varchar(50)
  exec ThemTaiKhoan 2400, N'Thành Viên',100,'lamphan_88','conbuombuom','KH001',@errordemo out

  select * from TAIKHOAN
  
----=======================================================Sua loi Lost Update==============================================================
---- drop proc CapNhatDiemTL_FIX_LU
create proc CapNhatDiemTL_FIX_LU
	 @matk varchar(10), 
	 @diem int,
	 @error varchar(50) out,
	 @diemkq int out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	if(exists(Select * from TAIKHOAN where MaTaiKhoan = @matk))
		begin
				select @diemkq= DiemTichLuy  from TAIKHOAN  WITH(XLOCK) where MaTaiKhoan = @matk
				set @diemkq = @diemkq + @diem
				if (@diemkq < 0 )
				set @diemkq = 0
				waitfor delay '00:00:10'
				Update TAIKHOAN 
				set DiemTichLuy = @diemkq
				where MaTaiKhoan = @matk
	
		end
	else
		begin
			set @error = 'Khong co tai khoan nay'
			raiserror('khong co tai khoan nay',0,0)
			rollback tran 
			return
		end
commit tran
----------chay demo 2 trans ---------------------------------------------------
----Update set DIem tich luy trong TK003 = 0
UPDATE TAIKHOAN SET DIEMTICHLUY = 0 where MaTaiKhoan = 'TK003'
select * from TAIKHOAN
--- trans 1
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_FIX_LU 'TK003',100,@error,@kq
--- trans 2
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_FIX_LU 'TK003',100,@error,@kq


--=============================================================== Sua DeadLock ====================================================================
---- drop proc CapNhatDiemTL_FIX_DL
create proc CapNhatDiemTL_FIX_DL
	 @matk varchar(10), 
	 @diem int,
	 @error varchar(50) out,
	 @diemkq int out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ  
	if(exists(Select * from TAIKHOAN where MaTaiKhoan = @matk))
		begin
				select @diemkq= DiemTichLuy  from TAIKHOAN  WITH(XLOCK) where MaTaiKhoan = @matk
				set @diemkq = @diemkq + @diem
				if (@diemkq < 0 )
				set @diemkq = 0
				waitfor delay '00:00:10'
				Update TAIKHOAN 
				set DiemTichLuy = @diemkq
				where MaTaiKhoan = @matk
	
		end
	else
		begin
			set @error = 'Khong co tai khoan nay'
			raiserror('khong co tai khoan nay',0,0)
			rollback tran 
			return
		end
commit tran
---- Update set Diem Tich Luy trong TK 003 = 0
Update TaiKhoan set DiemTichLuy = 0 where MaTaiKhoan = 'TK003'
--- trans 1
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_FIX_DL 'TK003',100,@error,@kq
--- trans 2
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_FIX_DL 'TK003',100,@error,@kq

select * from TAIKHOAN



----==================================================Sua loi Dirty Read==========================================================
--------------set mức cô lập thành Read committed--------------------
---- chinh sua lai proc sua tai khoan 
----drop proc SuaTaiKhoan_fix_DR
create procedure SuaTaiKhoan_fix_DR
@maTK varchar(10),
@maKH varchar(10)=NULL,
@diemTichLuy int =NULL,
@loaiTaiKhoan nvarchar(50) =NULL,
@soTien int=NULL,
@matKhau varchar(100)=NULL,
@error nvarchar(500) out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
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

		waitfor delay '00:00:15'
		rollback tran
		return

	if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra. Không thể sửa tài khoản'
				raiserror('Có lỗi xảy ra. Không thể sửa tài khoản', 0, 0)		
				rollback tran
				return
			end
	
commit tran
------------------Demo sau khi fix loi Dirty-Read--------------
-------trans 1 chay lenh sau-----------------------------
declare @error varchar(500) 
exec SuaTaiKhoan_fix_DR @maTK ='TK006',@loaiTaiKhoan = 'VIP',@error = @error out
----------------trans 2 chay lenh sau------------------

select * from TAIKHOAN
declare @error varchar(50)
declare @tongcong int
exec thongketaikhoantheoloai N'VIP', @error out,@tongcong out



-----------------------------------------Sua loi Unrepeatable Read------------------------------
------- sua lai proc xem thong tin khach hang, chinh sua muc co lap lai thanh Repeatable Read-----
---drop proc xemthongtinKH_fix_UR
create proc xemthongtinKH_fix_UR @makh varchar(10), @error varchar(50) out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
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
	else
		begin
		Select * from KHACHHANG where MaKhachHang = @makh
		waitfor delay '00:00:15'
		Select * from KHACHHANG as a,TAIKHOAN as b where a.MaKhachHang = @makh and a.MaKhachHang = b.MaKhachHang
		end
	if (@@ERROR <> 0)
			begin
				set @error='Lay thong tin khach hang bi loi '
				raiserror('Lay thong tin khach hang bi loi ', 0, 0)
				rollback tran
				return
			end

commit tran

-------------proc demo unrepeattable read-----------
-----drop proc capnhatKH_UR_FIX
create proc capnhatKH_UR_FIX
	 @makh varchar(10),
	 @ten nvarchar(50)=null ,
	 @gioitinh nvarchar(50) = null,
	 @DiaChi nvarchar(50) = null,
	 @CMNDKH varchar(9) = null,
	 @Dienthoai varchar(20) = null, 
	 @error varchar(50) out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ COMMITtED
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
		exec @ktCMND = kiemtrakhtontai @CMNDKH
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


---------------------------------------Demo sua lai loi Unrepeatable READ ----------------------------------------------------
----------------- proc cap nhat khach hang se phai doi lenh xem thong tin xong thi moi duoc cap nhat---------
-----Tinh huong, sau khi proc Xemkhachhang chay xong thi lenh update moi duoc thuc hien, do do thong tin khong bi thay doi sau 15s delay
---update KHACHHANG set TenKhachHang = N'Nguyễn Hoàng Kim' where MaKhachHang = 'KH002'
------Lenh xem toan bo khach hang
select * from KHACHHANG
--- cau lenh trong trans 1
declare @error varchar(50)
exec xemthongtinKH_fix_UR 'KH002', @error out

----- câu lệnh trong trans 2
declare @error2 varchar(50)
exec capnhatKH @makh = 'KH002',@ten = N'Gia  Ngọc',@error = @error2 out

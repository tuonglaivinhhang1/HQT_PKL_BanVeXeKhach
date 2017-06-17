----------=================================DEMO CAC LOI======================================================================-----------------------------------------------------------------------------------------------------
  ----====================================Demo Phantom============================================== 
  --- tinh huong : khi dang thong ke thi them tai khoan moi vao thanh cong => thong ke so lieu khong dung
 create proc thongketaikhoantheodiem @diem int, @error varchar(50) out
  as
  begin tran
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
  		select *
		from TAIKHOAN
		where DiemTichLuy >= @diem

		select Count(DiemTichLuy)
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
  ---- trans 1
  -- Thong ke so tai khoan có điểm trên 700, sau đó delay 15s,  thêm 1 tài khoản vào ( có điểm tích lũy là > 700)
  declare @errorphantom varchar(50)
  exec thongketaikhoantheodiem 700 , @errorphantom out

  ----trans 2
  declare @errordemo varchar(50)
  exec ThemTaiKhoan 2000, N'Thành Viên',100,'lamphan_01','hqt2014-PKL@*','KH001',@errordemo out

  select * from TAIKHOAN
  --=====================================================Demo Lost Update========================================================
---- tình huống : cập nhật số điểm khách hàng , mỗi lần 100 điểm, trans 1 với trans 2 cùng chạy, kq bị cộng trùng.
---proc demo 
--drop proc CapNhatDiemTL_LU
create proc CapNhatDiemTL_LU
	 @matk varchar(10), 
	 @diem int,
	 @error varchar(50) out,
	 @diemkq int out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	if(exists(Select * from TAIKHOAN where MaTaiKhoan = @matk))
		begin
				select @diemkq= DiemTichLuy  from TAIKHOAN  where MaTaiKhoan = @matk
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


select * from TAIKHOAN
-------update set diem tich luy TK002  =0
Update TaiKhoan set DiemTichLuy = 0 where MaTaiKhoan = 'TK002'
--- trans 1
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_LU 'TK002',100,@error,@kq
--- trans 2
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_LU 'TK002',100,@error,@kq
--==============================================================Demo Deadlock==============================================================
-- Tinh huong  : cho 2 proc cung truy cap vao bang Tai Khoan va cap nhat DiemTichLuy => bi deadlock, sql server se tu dong kill trans chay sau 

---drop proc CapNhatDiemTL_DL
create proc CapNhatDiemTL_DL
	 @matk varchar(10), 
	 @diem int,
	 @error varchar(50) out,
	 @diemkq int out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ  
	if(exists(Select * from TAIKHOAN where MaTaiKhoan = @matk))
		begin
				select @diemkq= DiemTichLuy  from TAIKHOAN where MaTaiKhoan = @matk
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
-----Update set Diem Tich Luy trong TK 003 = 0
UPDATE TAIKHOAN SET DIEMTICHLUY = 0 where MaTaiKhoan = 'TK003'
select * from TAIKHOAN
--- trans 1
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_DL 'TK003',100,@error,@kq
--- trans 2
declare @error varchar(50)
declare @kq int

exec CapNhatDiemTL_DL 'TK003',100,@error,@kq

--================================================================Demo Dirty Read================================================================================================
---- Tình huống cập nhật thông tin tài khoản , sau đó delay 15s, sau đó gặp trục trặc nên bị rollback trước khi commit tran, song song đó có máy khác đang truy cập thống kê tài khoản => bị đọc dự liệu sai.
--- proc demo tình huống
---proc thong ke tai khoan theo loai
drop proc thongketaikhoantheoloai
create proc thongketaikhoantheoloai @loai nvarchar(50), @error varchar(50) out, @tongcong int out
  as
  begin tran
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
		
		begin
		select * 
		from TAIKHOAN
		where LoaiTaiKhoan like @loai 

  		select count(LoaiTaiKhoan) 
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
---drop proc SuaTaiKhoan_DR
create procedure SuaTaiKhoan_DR
	@maTK varchar(10),
	@maKH varchar(10)=NULL,
	@diemTichLuy int =NULL,
	@loaiTaiKhoan nvarchar(50) =NULL,
	@soTien int=NULL,
	@matKhau varchar(100)=NULL,
	@error nvarchar(500) out
as
begin tran
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITtED
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
	Rollback tran
	return
	
	if (@@ERROR <> 0)
			begin
				set @error=N'Có lỗi xảy ra. Không thể sửa tài khoản'
				raiserror('Có lỗi xảy ra. Không thể sửa tài khoản', 0, 0)		
				rollback tran
				return
			end
	
commit tran

---- trans1
declare @error varchar(500) 
exec SuaTaiKhoan_DR @maTK ='TK006',@loaiTaiKhoan = 'VIP',@error = @error out

select * from TAIKHOAN
---trans 2 (ở đây mặc định đang có 3 tk VIP , nhg khi thống kê lại ra 4 )
declare @tongcong int
declare @error varchar(50)
exec thongketaikhoantheoloai N'VIP', @error out, @tongcong out
---=================================================DEMO UNREPEATABLE READ======================================================s=========

---Tình huống đọc khách hàng bất kì, sau đó đặt wait for delay, chạy 1 trans khác gọi  proc update thông tin khách hàng đó. O day ban dau la KH002 co ten la Nguyen Hoang Kim, sau khi cap nhat la co ten Nguyen Nhu Ngoc=> thong tin ten bi thay doi sau 15s
---proc demo tình huống
---drop proc xemthongtinKH_UR
create proc xemthongtinKH_UR @makh varchar(10), @error varchar(50) out
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
--------------------------------------------chay 2 proc doc và cập nhật khách hàng--------------------------------------------------
---- cau lenh trong tran 1
select * from KHACHHANG
declare @error varchar(50)
exec xemthongtinKH_UR 'KH002', @error out

----- câu lệnh trong trans 2
declare @error2 varchar(50)
exec capnhatKH @makh = 'KH002',@ten = N'Nguyễn Như Ngọc',@error = @error2 out
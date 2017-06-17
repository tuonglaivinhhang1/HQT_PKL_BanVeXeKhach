----===VIET ANH===---
use PHUONGTRANG 
go
--Duyet ve--
Create proc SP_DuyetVe @trangthai int, @phuongthucthanhtoan varchar(10),@nhanviendatve varchar(10), @mave varchar(10)
As
Begin tran
	Begin
		Update PHUONGTRANG.DBO.VE Set TrangThaiVe =@trangthai, PhuongThucThanhToan= @phuongthucthanhtoan, NhanVienDatVe = @nhanviendatve, NgayThanhToan= GETDATE()  where MaVe =@mave
 
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình duyệt', 0, 0)
			rollback
		End
	End
Commit tran
 
 go
--CRUD Phuong thuc thanh toan--
 --
 
--- tạo mã phương thức thanh toán --
create proc generatemaPTTT @mapttt varchar(10) out
as
begin
	declare @Max int
	
	select @Max = convert(int,substring(max(PHUONGTHUCTHANHTOAN.MaPhuongThucThanhToan ), 3, 48)) from PHUONGTRANG.DBO.PHUONGTHUCTHANHTOAN
	
	set @Max = @Max + 1
 
	if (@Max is null)
	begin
		set @mapttt = 'PTTT00000000'
		return
	end
	
	if (@Max < 10)
	begin
		set @mapttt = 'PTTT0000000' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 100)
	begin
		set @mapttt = 'PTTT000000' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 1000)
	begin
		set @mapttt = 'PTTT00000' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 10000)
	begin
		set @mapttt = 'PTTT0000' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 100000)
	begin
		set @mapttt = 'PTTT000' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 1000000)
	begin
		set @mapttt = 'PTTT00' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 10000000)
	begin
		set @mapttt = 'PTTT0' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 100000000)
	begin
		set @mapttt = 'PTTT' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max >= 100000000)
	begin
		set @mapttt = 'error'
		return
	end
end
go
--Them phuong thuc tt --
create proc SP_ThemPhuongThucThanhToan @tenphuongthuc nvarchar(50)
as
begin tran
	begin
		Declare  @maphuongthuc varchar(10)
		exec generatemaPTTT @maphuongthuc out 
		
		if (@maphuongthuc = 'error')
			begin
				raiserror('Hết mã để tạo', 0, 0)
				rollback
			end
			
		insert into PHUONGTRANG.DBO.PHUONGTHUCTHANHTOAN values(@maphuongthuc,@tenphuongthuc)
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình thêm phương thức thanh toan', 0, 0)
			rollback
		End
	end
commit tran
 go
--SP Xoa phuong thuc thanh toan--
create proc SP_XoaPhuongThucThanhToan @maphuongthuc varchar(10) 
as
begin tran
	begin
		If NOT EXISTs (select * from  PHUONGTRANG.DBO.PHUONGTHUCTHANHTOAN where  MaPhuongThucThanhToan = @maphuongthuc)
		Begin 
			raiserror('không tồn tại phương thức thanh toán', 0, 0)
			rollback tran
		End
		
		delete  from  PHUONGTRANG.DBO.PHUONGTHUCTHANHTOAN where  MaPhuongThucThanhToan = @maphuongthuc
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình xóa phương thức thanh toan', 0, 0)
			rollback tran
		End
	end
commit tran
 go
--SP cap nhat phuong thuc thanh toan
create proc SP_CapNhatPhuongThucThanhToan @maphuongthuc varchar(10), @tenphuongthuc nvarchar(50)
as
begin tran
	begin
		update PHUONGTRANG.DBO.PHUONGTHUCTHANHTOAN set TenPhuongThucThanhToan = @tenphuongthuc where MaPhuongThucThanhToan= @maphuongthuc
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình cập nhật phương thức thanh toán', 0, 0)
			rollback tran
		End
	end
commit tran
 
 go
--- CRUD Khuyen mai---
--- tạo mã KM --
drop  proc generatemaKM
create proc generatemaKM @makm varchar(10) out
as
begin
	declare @Max int
	
	select @Max = convert(int,substring(max(KHUYENMAI.MaKhuyenMai ), 4, 48)) from PHUONGTRANG.DBO.KHUYENMAI

	set @Max = @Max + 1
 
	if (@Max is null)
	begin
		set @makm = 'MKM0000000'
		return
	end
	
	if (@Max < 10)
	begin
		set @makm = 'MKM000000' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 100)
	begin
		set @makm = 'MKM00000' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 1000)
	begin
		set @makm = 'MMKM00000' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 10000)
	begin
		set @makm = 'MKM000' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 100000)
	begin
		set @makm = 'MKM00' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 1000000)
	begin
		set @makm = 'MKM' + convert(varchar(10), @Max)
		return
	end
 
	if (@Max < 10000000)
	begin
		set @makm = 'error'
		return
	end
end
go
-- them ma KM --
--- kiem tra ngay bat dau km

create procedure KiemTraNgayBatDauKM
@ngaybatdaukm date
as
begin
	if(@ngaybatdaukm>=GETDATE())
		begin
			return 1--sai
		end
	else
		begin
			return 0
		end
end
go
-- them khuyen mai --

create proc SP_ThemKM  @tenkm nvarchar(50), @ngaybatdau datetime, @ngayketthuc datetime ,@hinhthuckm nvarchar(50), @tilegiamgia int
as
begin tran
	begin
		Declare  @makm varchar(10)
		exec generatemaKM  @makm out 
		
		if (@makm = 'error')
			begin
				raiserror('Hết mã để tạo', 0, 0)
				rollback
			end
		If @ngaybatdau > @ngayketthuc
		begin
				raiserror('Ngày bắt đầu lớn hơn ngày kết thúc', 0, 0)
				rollback
		end
		
		If  @tilegiamgia >50
		begin
				raiserror('Ti lệ giảm giá hơn 50%', 0, 0)
				rollback
		end
		 
		
		If  @hinhthuckm != N'Giảm giá'or @hinhthuckm != N'Tặng quà'
		begin
				raiserror('Sai định dạng', 0, 0)
				rollback
		end
		
		insert into PHUONGTRANG.DBO.KHUYENMAI values(@makm,@tenkm, @ngaybatdau, @ngayketthuc, @hinhthuckm,  @tilegiamgia)
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình thêm KM', 0, 0)
			rollback
		End
	end
commit tran
 
 go
 --SP Xoa khuyen mai--
 
create proc SP_XoaKM @makm varchar(10) 
as
begin tran
	begin
		If NOT EXISTs (select * from  PHUONGTRANG.DBO.KHUYENMAI where  MaKhuyenMai = @makm)
		Begin 
			raiserror('không tồn tại khuyến mãi', 0, 0)
			rollback tran
		End
		
		delete  from  PHUONGTRANG.DBO.KHUYENMAI where  MaKhuyenMai = @makm
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình xóa khuyến mãi', 0, 0)
			rollback tran
		End
	end
commit tran
go
--SP cap nhat khuyen mai--

create proc SP_CapNhatKhuyenMai @makhuyenai varchar(10),@tenkhuyenmai nvarchar(50),@ngaybatdau datetime,@ngayketthuc datetime,@hinhthuckhuyenmai nvarchar(50),@tilegiamgia int  
as
begin tran
	begin
		If @ngaybatdau > @ngayketthuc
		begin
				raiserror('NgaY BAT DAU LON HON NGAY KET THUC', 0, 0)
				rollback
		end
		
		If  @tilegiamgia >50
		begin
				raiserror('Tỉ lệ giảm giá hơn 50%', 0, 0)
				rollback
		end
		 
		
		If  @hinhthuckhuyenmai != N'Giảm giá' or @hinhthuckhuyenmai != N'Tặng quà'
		begin
				raiserror('Sai định dạng', 0, 0)
				rollback
		end
		
		update PHUONGTRANG.DBO.KHUYENMAI set  TenKhuyenMai= @tenkhuyenmai, NgayBatDau =@ngaybatdau, NgayKetThuc =@ngayketthuc, HinhThucKhuyenMai =@hinhthuckhuyenmai where MaKhuyenMai =  @makhuyenai
		If (@@ERROR <> 0)
		Begin
			raiserror('Có lỗi trong quá trình cập nhật khuyến mãi', 0, 0)
			rollback tran
		End
	end
commit tran
go
 -- thong ke so ghe ngoi con trong --

create function ThongKeGheNgoiConTrong(@maxe varchar(10) = NULL)
returns int
as
begin
	declare @soluongghedat int
	declare @soluongghe int
	select @soluongghe = SoLuongGhe from PHUONGTRANG.dbo.XE where MaXe = @maxe
	select @soluongghedat= COUNT(*) from PHUONGTRANG.dbo.VE where MaXe = @maxe
	
	return @soluongghe - @soluongghedat
end;


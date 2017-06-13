--Tạo DATABASE
create database PHUONGTRANG
GO
use PHUONGTRANG

--Tạo bảng KHUYENMAI
create table KHUYENMAI
(
	MaKhuyenMai varchar(10) primary key,
	TenKhuyenMai nvarchar(50),
	NgayBatDau datetime,
	NgayKetThuc datetime,
	HinhThucKhuyenMai nvarchar(50) check(HinhThucKhuyenMai in (N'Giảm giá', N'Tặng quà')),
	TyLeGiamGia int check(TyLeGiamGia <= 50)
)

--Tạo bảng PHUONGTHUCTHANHTOAN
create table PHUONGTHUCTHANHTOAN
(
	MaPhuongThucThanhToan varchar(10) primary key,
	TenPhuongThucThanhToan nvarchar(50)
)
--Tạo bảng KHACHHANG
create table KHACHHANG
(
	MaKhachHang varchar(10) primary key,
	TenKhachHang nvarchar(50),
	GioiTinhKH nvarchar(50) check(GioiTinhKH in (N'Nam', N'Nữ')),
	DiaChiKH nvarchar(50),
	SoCMNDKH varchar(9) unique check(Len(SoCMNDKH) = 9 and ISNUMERIC(SoCMNDKH) = 1),
	DienthoaiKH varchar(20) check(Len(DienThoaiKH) <= 12 and Len(DienThoaiKH) >= 10)
	
)

--Tạo bảng TAIKHOAN
create table TAIKHOAN
(
	MaTaiKhoan varchar(10) primary key,
	DiemTichLuy int check(DiemTichLuy >= 0),
	LoaiTaiKhoan nvarchar(50) check(LoaiTaiKhoan in (N'Khách hàng thân thiết', N'Thành viên', N'VIP')),
	SoTien int check(SoTien >= 0),
	TenDangNhap varchar(50) check(len(TenDangNhap) >= 10) unique not null,
	MatKhau varchar(100) check(len(MatKhau) >= 10)  not null,
	MaKhachHang varchar(10) foreign key references KHACHHANG(MaKhachHang)
)


--Tạo bảng LOAINHANVIEN
create table LOAINHANVIEN
(
	MaLoaiNV varchar(10) primary key,
	TenLoaiNV nvarchar(50),
)

--Tạo bảng NHANVIEN
create table NHANVIEN
(
	MaNhanVien varchar(10) primary key,
	TenNhanVien nvarchar(50),
	GioiTinhNV nvarchar(50) check(GioiTinhNV in (N'Nam', N'Nữ')),
	DiaChiNV nvarchar(50),
	SoCMNDNV varchar(9) unique check(Len(SoCMNDNV) = 9 and ISNUMERIC(SoCMNDNV) = 1),
	NgaySinhNV date,
	DienthoaiNV varchar(20) check(Len(DienThoaiNV) <= 12 and Len(DienThoaiNV) >= 10),
	TenDangNhapNV varchar(50) check(len(TenDangNhapNV) >= 10) unique not null,
	MatKhauNV varchar(100) check(len(MatKhauNV) >= 10)  not null,
	LoaiNhanVien varchar(10) foreign key references LOAINHANVIEN(MaLoaiNV),
	Luong int check(Luong >= 0), 
	BangLai nvarchar(50),
	KhaNangLaiDuongDai int check(KhaNangLaiDuongDai >= 0)
)

--Tạo bảng XE
create table XE
(
	MaXe varchar(10) primary key,
	LoaiXe nvarchar(50),
	BienSoXe nvarchar(50) unique,
	SoLuongGhe int check (SoLuongGhe >= 0),
)

--Tạo bảng GHE
create table GHE
(
	ViTriGhe varchar(10) not null,
	MaXe varchar(10) foreign key references XE(MaXe),
	primary key (ViTriGhe, MaXe)
)

--Tạo bảng TUYENDUONG
create table TUYENDUONG
(
	MaTuyenDuong varchar(10) primary key,
	NoiXuatPhat nvarchar(50),
	NoiDen nvarchar(50),
	BenDi nvarchar(50),
	BenDen nvarchar(50)
)

--Tạo bảng CHUYENDI
create table CHUYENDI
(
	MaChuyenDi varchar(10) primary key,
	TuyenDuong varchar(10) foreign key references TUYENDUONG(MaTuyenDuong),
	NgayGioXuatPhat datetime,
	NgayGioDen datetime,
	QuangDuong int check(QuangDuong >= 0),
	GiaDuKien int check(GiaDuKien >= 0),
	Xe varchar(10) foreign key references XE(MaXe)
)

--Tạo bảng VE

create table VE
(
	MaVe varchar(10) primary key,
	GiaVeThuc int check(GiaVeThuc >= 0),
	TrangThaiVe int check(TrangThaiVe in (1, 0)),--1 là đã duyệt, 0 là chưa duyệt
	TrangThaiThanhToan int check(TrangThaiThanhToan in (1, 0)),--1 là đã thanh toán, 0 là chưa thanh toán
	MaKhachHang varchar(10) foreign key references KHACHHANG(MaKhachHang),
	PhuongThucThanhToan varchar(10) foreign key references PHUONGTHUCTHANHTOAN(MaPhuongThucThanhToan),
	NgayThanhToan datetime,
	NgayDatVe datetime,
	NhanVienDatVe varchar(10) foreign key references NHANVIEN(MaNhanVien),
	MaGhe varchar(10) not null,
	MaXe varchar(10) not null,
	MaChuyenDi varchar(10) foreign key references CHUYENDI(MaChuyenDi),
	NhanVienThanhToan varchar(10) foreign key references NHANVIEN(MaNhanVien)
)
alter table VE
add constraint FK1
foreign key( MaGhe,MaXe) references GHE(ViTriGhe,MaXe)

--Tạo bảng KHUYENMAI_VE
create table KHUYENMAI_VE
(
	MaKhuyenMai varchar(10) foreign key references KHUYENMAI(MaKhuyenMai),
	MaVe varchar(10) foreign key references VE(MaVe)
)

--Tạo bảng PHANCONGTAIXELAICHUYENDI
create table PHANCONGTAIXELAICHUYENDI
(
	MaChuyenDi varchar(10) foreign key references CHUYENDI(MaChuyenDi),
	TaiXe varchar(10) foreign key references NHANVIEN(MaNhanVien),
	LoaiTaiXe nvarchar(50),
	primary key (MaChuyenDi, TaiXe)
)

--Tạo bảng PHANCONGTAIXELAIXE
create table PHANCONGTAIXEPHUTRACHXE
(
	TaiXe varchar(10) foreign key references NHANVIEN(MaNhanVien),
	MaXe varchar(10) foreign key references XE(MaXe),
	NgayBatDau date,
	NgayKetThuc date,
	primary key (MaXe, TaiXe,NgayBatDau,NgayKetThuc)
)

--================================================================================
insert into XE
values('XE001',N'Giường Nằm','59B-72622',40)

insert into XE
values('XE002',N'Giường Nằm','59B-09332',40)
--================================================================================

insert into TUYENDUONG
values('TD001',N'TP Hồ Chí Minh',N'Phú Yên',N'Bến Xe Miền Đông',N'Bến Xe Phú Lâm')

insert into TUYENDUONG
values('TD002',N'TP Hồ Chí Minh',N'Phú Yên',N'Cầu Vượt Sóng Thần',N'Tạp Hóa Lệ Quang-Hòa Phong')
--================================================================================

insert into LoaiNhanVien
values('LNV001',N'Tài Xế')
insert into LoaiNhanVien
values('LNV002',N'Nhân Viên Quản Lý')
insert into LoaiNhanVien
values('LNV003',N'Nhân Viên Đặt Vé')
insert into LoaiNhanVien
values('LNV004',N'Nhân Viên Thanh Toán')

--================================================================================
insert into NhanVien
values('NV001',N'Nguyễn Thanh Phi',N'Nam',N'Tây Hòa-Phú Yên','221425270','1996-01-04','01265190526','thanhphi1996','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','LNV002',10000000,NULL,0)

--mật khẩu hash hqt2014-PKL@*
insert into NhanVien
values('NV002',N'Nguyễn Hoàng Kim',N'Nam',N'TP Hồ Chí Minh','226166441','1996-10-01','01227374411','nguyenhoangkim1996','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','LNV001',20000000,'B2',500)

insert into NhanVien
values('NV003',N'Phan Khánh Lâm',N'Nam',N'TP Hồ Chí Minh','224515576','1996-10-02','01234451122','khanhlam1996','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','LNV001',18000000,'B2',400)

insert into NhanVien
values('NV004',N'Vương Thiên Phú',N'Nam',N'TP Hồ Chí Minh','226514411','1996-10-03','0987661444','thienphu1996','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','LNV003',10000000,NULL,0)

insert into NhanVien
values('NV005',N'Ngô Việt Anh',N'Nam',N'TP Hồ Chí Minh','226515614','1996-10-04','0987665222','vietanh1996','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','LNV001',20000000,NULL,200)

insert into NhanVien
values('NV006',N'Lương Công Vĩ',N'Nam',N'Phú Yên','221441155','1991-10-04','0988776111','congvi1996','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','LNV004',10000000,NULL,0)


--================================================================================

insert into ChuyenDi
values('CD001','TD001','2017-06-06 17:00','2017-06-07 05:00',530,220000,'XE001')
insert into ChuyenDi
values('CD002','TD002','2017-06-06 17:00','2017-06-07 05:00',550,220000,'XE002')
insert into ChuyenDi
values('CD003','TD001','2017-06-07 17:00','2017-06-08 05:00',530,220000,'XE001')

--================================================================================
insert into PHANCONGTAIXEPHUTRACHXE
values('NV002','XE001','2017-06-06','2017-07-06')

insert into PHANCONGTAIXEPHUTRACHXE
values('NV003','XE002','2017-06-06','2017-07-06')

--================================================================================
insert into GHE
values('A1','XE001')
insert into GHE
values('A10','XE001')
insert into GHE
values('B1','XE001')
insert into GHE
values('B10','XE001')

insert into GHE
values('A1','XE002')
insert into GHE
values('A10','XE002')
insert into GHE
values('B1','XE002')
insert into GHE
values('B10','XE002')
--================================================================================

insert into PHANCONGTAIXELAICHUYENDI
values('CD001','NV002',N'Tài xế bình thường')

insert into PHANCONGTAIXELAICHUYENDI
values('CD001','NV003',N'Tài xế bình thường')

insert into PHANCONGTAIXELAICHUYENDI
values('CD003','NV003',N'Tài xế bình thường')

--================================================================================
insert into PHUONGTHUCTHANHTOAN
values('PTTT001',N'Internet Banking')

insert into PHUONGTHUCTHANHTOAN
values('PTTT002',N'Tiền Mặt')

insert into PHUONGTHUCTHANHTOAN
values('PTTT003',N'Thẻ Tín Dụng')

insert into PHUONGTHUCTHANHTOAN
values('PTTT004',N'Chuyển Khoản Ngân Hàng Trực Tiếp')

--================================================================================

insert into KHACHHANG
values('KH001',N'Nguyễn Thanh Phi',N'Nam',N'Phú Yên','221425270','01265190526')

insert into KHACHHANG
values('KH002',N'Nguyễn Hoàng Kim',N'Nam',N'TP Hồ Chí Minh','226517711','0987111333')

insert into KHACHHANG
values('KH003',N'Phan Khánh Lâm',N'Nam',N'TP Hồ Chí Minh','117721134','01267114411')

insert into KHACHHANG
values('KH004',N'Vương Thiên Phú',N'Nam',N'TP Hồ Chí Minh','227614411','0988772134')

insert into KHACHHANG
values('KH005',N'Ngô Việt Anh',N'Nam',N'TP Hồ Chí Minh','988222455','0908333113')


--mật khẩu hash hqt2014-PKL@*
--================================================================================
insert into TAIKHOAN
values('TK001',0,N'Thành viên',0,'thanhphi_hqtpkl','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','KH001')
insert into TAIKHOAN
values('TK002',600,N'VIP',10000000,'hoangkim_hqtpkl','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','KH002')

insert into TAIKHOAN
values('TK003',700,N'VIP',10000000,'khanhlam_hqtpkl','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','KH003')

insert into TAIKHOAN
values('TK004',900,N'Khách hàng thân thiết',20000000,'thienphu_hqtpkl','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','KH004')

insert into TAIKHOAN
values('TK005',800,N'Khách hàng thân thiết',5000000,'vietanh_hqtpkl','$2a$10$SOcu7UmX5ZbJDBVPd02QPOrZ2LS9GOGzKkxPF5SHeb/25PGMtxOva','KH005')

--================================================================================
insert into VE
values('VE001',200000,1,1,'KH001','PTTT001','2017-06-06','2017-06-06','NV004','A1','XE001','CD001','NV006')

insert into VE
values('VE002',200000,1,0,'KH002',NULL,NULL,'2017-06-06','NV004','A10','XE001','CD001',NULL)

insert into VE
values('VE003',200000,1,1,'KH003','PTTT002','2017-06-06','2017-06-06','NV004','B1','XE002','CD001','NV006')

insert into VE
values('VE004',200000,0,0,'KH004',NULL,NULL,'2017-06-07',NULL,'A1','XE002','CD002',NULL)

--================================================================================
insert into KHUYENMAI
values('MKM001',N'Khuyến Mãi Sinh Nhật Phương Trang','2017-06-01','2017-06-20',N'Giảm giá',10)


--================================================================================
insert into KHUYENMAI_VE
values('MKM001','VE004')


insert into KHUYENMAI_VE
values('MKM001','VE001')






go
--=============================BẢNG NHÂN VIÊN=========================================
create procedure TaoMaNhanVienMoi
@maNV varchar(10) out
as
begin

	declare @lastMaNV varchar(10)
	set @lastMaNV=(select TOP 1 MaNhanVien from NHANVIEN order by MaNhanVien desc)
	

	declare @lastIndex int
	set @lastIndex=cast (SUBSTRING(@lastMaNV,3,(select LEN(@lastMaNV))-1) as int)

	if((select LEN(cast(@lastIndex as nvarchar(50))))=1)
		begin
			set @maNV='NV'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex as nvarchar(50))))=2)
		begin
			set @maNV='NV'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex as nvarchar(50))))=3)
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
			set @error='Số CMND đã tồn tại'
			raiserror('Số CMND đã tồn tại.', 0, 0)
			rollback tran
			return
		end
	 


	--kiểm tra ngày sinh phải lớn hơn ngày hiện tại
	declare @kiemtrangaysinh int;
	exec @kiemtrangaysinh=KiemTraNgaySinh @ngaySinh
	if(@kiemtrangaysinh=1)
		begin
			set @error='Ngày sinh phải nhỏ hơn ngày hiện tại'
			raiserror('Ngày sinh phải nhỏ hơn ngày hiện tại.', 0, 0)
			rollback tran
			return
		end


	--kiểm tra số điện thoại 10 hoặc 11 số
	declare @kiemtraSDT int;
	exec @kiemtraSDT=KiemTraSoDT @dienThoai
	if(@kiemtraSDT=0)
		begin
			set @error='Số điện thoại phải là 10 hoặc 11 số'
			raiserror('Số điện thoại phải là 10 hoặc 11 số', 0, 0)
			rollback tran
			return
		end
		

	--kiểm tra tên đăng nhập phải lớn hơn 5 ký tự
	declare @kiemtraTDN int;
	exec @kiemtraTDN=KiemTraTenDangNhap @tenDangNhap
	if(@kiemtraTDN=0)
		begin
			set @error='Tên đăng nhập phải lớn hơn 5 ký tự'
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
			set @error='Loại Nhân Viên không tồn tại'
			raiserror('Loại Nhân Viên không tồn tại', 0, 0)
			rollback tran
			return
		end
	--nếu loại nhân viên không phải là tài xế thì sẽ không có bằng lái và khả năng chạy đường dài

	if(@loaiNhanVien!='LNV001' and @bangLai!=NULL)
		begin
			set @error='Không phải tài xế thì không có bằng lái'
			raiserror('Không phải tài xế thì không có bằng lái', 0, 0)
			rollback tran
			return
		end

	if(@loaiNhanVien!='LNV001' and @khaNangLaiDuongDai!=0)
		begin
			set @error='Không phải tài xế thì không có thuộc tính khả năng lái đường dài'
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
		set @error='Không thể thêm. Vui lòng thử lại'
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
	--kiểm tra số CMND
	
	if(LEN(ISNULL(@soCMND, '')) <> 0)
		begin
			declare @kiemtracmnd int;
			exec @kiemtracmnd=KiemTraCMND @soCMND
			if(@kiemtracmnd=1)
				begin
					set @error='Số CMND đã tồn tại'
					raiserror('Số CMND đã tồn tại.', 0, 0)
					rollback
					
				end
		end

	--kiểm tra Ngaysinh
	
	
	IF( LEN(ISNULL(@ngaySinh, '')) <> 0)
		begin
		
			declare @kiemtrangaysinh int;
			exec @kiemtrangaysinh=PHUONGTRANG.dbo.KiemTraNgaySinh @ngaySinh
			
			if(@kiemtrangaysinh=1)
				begin
					set @error='Ngày sinh phải nhỏ hơn ngày hiện tại'
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
					set @error='Số điện thoại phải là 10 hoặc 11 số'
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
							set @error='Tài xế đang được phân công. '
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
							set @error='Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác '
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
				set @error='Không thể cập nhật. Vui lòng thử lại'
				raiserror('Không thể cập nhật. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

		
		--Khối lệnh demo lỗi
		WAITFOR DELAY '00:00:15'
		rollback
				
commit tran
end

GO
alter procedure CapNhatNhanVienV2_DemoUnrepeatableRead
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
	--kiểm tra số CMND
	
	if(LEN(ISNULL(@soCMND, '')) <> 0)
		begin
			declare @kiemtracmnd int;
			exec @kiemtracmnd=KiemTraCMND @soCMND
			if(@kiemtracmnd=1)
				begin
					set @error='Số CMND đã tồn tại'
					raiserror('Số CMND đã tồn tại.', 0, 0)
					rollback
					
				end
		end

	--kiểm tra Ngaysinh
	
	
	IF( LEN(ISNULL(@ngaySinh, '')) <> 0)
		begin
		
			declare @kiemtrangaysinh int;
			exec @kiemtrangaysinh=PHUONGTRANG.dbo.KiemTraNgaySinh @ngaySinh
			
			if(@kiemtrangaysinh=1)
				begin
					set @error='Ngày sinh phải nhỏ hơn ngày hiện tại'
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
					set @error='Số điện thoại phải là 10 hoặc 11 số'
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
							set @error='Tài xế đang được phân công. '
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
							set @error='Không thể cập nhật nhân viên đặt vé này sang loại nhân viên khác '
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
				set @error='Không thể cập nhật. Vui lòng thử lại'
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
			set @error='Nhân viên không tồn tại'
			raiserror('Nhân viên không tồn tại', 0, 0)
			rollback tran
			return
		end

	--nhân viên có đang bị phân công không làm gì không (xuất hiện trong table khác)

	declare @checkNV2 int
	exec @checkNV2=NhanVienBangKhac @maNV

	if(@checkNV2=1)
		begin
			set @error='Nhân viên đang được phân công. Không thể xóa'
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
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		--tìm thử nhân viên có tồn tại không

		declare @checkNV int
		exec @checkNV=KiemTraNhanVienTonTaiTheoCMND @soCMND

		if(@checkNV=0)
			begin
				set @error='Nhân viên không tồn tại'
				raiserror('Nhân viên không tồn tại', 0, 0)
				rollback
				
			end

		

		--select nhan vien

		select * from NHANVIEN where SoCMNDNV=@soCMND

		
		if (@@ERROR <> 0)
			begin
				set @error='Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại'
				raiserror('Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại', 0, 0)
				
				rollback
				
			end

commit transaction

go
alter procedure XemNhanVienv2_DemoUnrepeatableRead --select thông tin nhân viên theo cmnd (duy nhất)
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
				set @error='Nhân viên không tồn tại'
				raiserror('Nhân viên không tồn tại', 0, 0)
				rollback
				
			end

		select * from NHANVIEN where SoCMNDNV=@soCMND
		WAITFOR DELAY '00:00:10' --wait for 10 seconds
		select * from NHANVIEN where SoCMNDNV=@soCMND
		
		if (@@ERROR <> 0)
			begin
				set @error='Có lỗi xảy ra khi truy xuất thông tin. Vui lòng thử lại'
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
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	select MaNhanVien,TenNhanVien,Luong,L.TenLoaiNV from NHANVIEN T,LOAINHANVIEN L where T.LoaiNhanVien=L.MaLoaiNV

	select @TongLuong=SUM(Luong) from NHANVIEN
	WAITFOR DELAY '00:00:10' --wait for 10 seconds, only for demo
	

	
	if (@@ERROR <> 0)
			begin
				set @error='Có lỗi xảy ra. Không thể thống kê'
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

	if((select LEN(cast(@lastIndex as nvarchar(50))))=1)
		begin
			set @maTK='TK'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex as nvarchar(50))))=2)
		begin
			set @maTK='TK'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex as nvarchar(50))))=3)
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

--======================Thống kế tài khoản theo loại tk================
create procedure ThongKeTheoLTK
@loaiTK nvarchar(50),
@error nvarchar(500) out
as
begin tran
	if(@loaiTK !=N'VIP' or @loaiTK !=N'Khách hàng thân thiết' or @loaiTK !=N'Thành viên' or @loaiTK is null)
		begin
			
			set @error=N'Loại tài khoản không đúng'
			raiserror('Loại tài khoản không đúng',0,0)
			rollback tran
			return
		end

	select MaTaiKhoan,TenDangNhap,LoaiTaiKhoan,DiemTichLuy
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

	if((select LEN(cast(@lastIndex as nvarchar(50))))=1)
		begin
			set @maXe='XE'+'00'+cast((@lastIndex+1) as nvarchar(10))


		end
	else if((select LEN(cast(@lastIndex as nvarchar(50))))=2)
		begin
			set @maXe='XE'+'0'+cast((@lastIndex+1) as nvarchar(10))
		end
	else if((select LEN(cast(@lastIndex as nvarchar(50))))=3)
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
	exec TaomTaoMaXeMoi @maXe out

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

	if (@@ERROR <> 0)
			begin
				set @error=N'Không thể cập nhật xe'
				raiserror('Không thể cập nhật xe', 0, 0)		
				rollback tran
				return
			end
	
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


--==========================TEST=====================================
select * from NHANVIEN
select * from VE
declare @error2 nvarchar(500)
exec CapNhatNhanVien @maNhanVien='NV002',@soCMND='776218844',@ngaySinh='2017-01-29',@matKhau='ffs65tryretert4534534t4t4aa',@loaiNhanVien='LNV002',@error=@error2 OUT
print(@error2)

declare @error3 nvarchar(500)
exec XoaNhanVien @maNV='NV002',@error=@error3 out
print(@error3)



--=============================DEMO LỖI DIRTY READ -CÁCH KHẮC PHỤC====================
--(KẾT HỢP 2 PROC: CAPNHATNHANVIEN VA LỆNH XEMNHANVIEN THEO CMND)
--1. chạy procedure update nhân viên 

declare @errorCNNV nvarchar(500)
exec CapNhatNhanVien @maNhanVien='NV001',@soCMND='221425370',@error=@errorCNNV out
print(@errorCNNV)

select * from NHANVIEN
--2. mở cửa sổ khác,Chạy lệnh sau đây 

declare @errorTestDirty nvarchar(500)
exec XemNhanVien '221425370',@error=@errorTestDirty out
print(@errorTestDirty)

--=============================DEMO LỖI PHANTOM -CÁCH KHẮC PHỤC====================
--(KẾT HỢP 2 PROC: THONGKELUONG VA THEMNHANVIEN)

--lệnh insert hoặc delete sẽ chờ cho lệnh tính tổng này chạy xong rồi mới insert/delete vào database
--(tức là nó ngăn chặn lệnh insert/delete cho đến khi lệnh thống kê này chạy xong)
--=====================CÁCH DEMO===============
--1. chạy lênh thống kê

declare @errorTKL nvarchar(500)
declare @sumLuong int
exec ThongKeLuong_TinhTong @sumLuong out,@errorTKL out

print(@sumLuong)

--2. mở của sổ khác và chạy đồng thời lệnh insert sau đây
declare @error nvarchar(500)
exec ThemNhanVien N'Ngô Hồng Anh',N'Nam',N'Hồ Chí Minh','220913300','04-01-1990','01231141144','honganh_yeudau',
'ro3242i3rhoierfhjwekfnrw4ro3wriejfksfnieojofwef33','LNV002',2000000,NULL,0,@error out
print(@error)

delete from NHANVIEN where MaNhanVien='NV007' --(for test when insert)

--==========DEMO LỖI UNREPEATABLE READ- cách khắc phục==========================

--lúc đầu là 221425270, cđang đọc thì chạy cập nhật thành 221425370 và select bị lỗi
--khắc phục: SET TRANSACTION ISOLATION LEVEL REPEATABLE READ trong hàm xemnhanvien
--1. Chạy lệnh xem nhân viên theo cmnd

declare @errorUnrepeatableRead nvarchar(500)
exec XemNhanVienv2_DemoUnrepeatableRead '221425270',@error=@errorUnrepeatableRead out
print(@errorUnrepeatableRead)

--2. cửa sổ 2 chạy lệnh update nhân viên 
declare @errorCNNVUnrepeatableRead nvarchar(500)
exec CapNhatNhanVienV2_DemoUnrepeatableRead @maNhanVien='NV001',@soCMND='221425370',@error=@errorCNNVUnrepeatableRead out
print(@errorCNNVUnrepeatableRead)

--==============DEMO LOST UPDATE=====================
select * from NHANVIEN






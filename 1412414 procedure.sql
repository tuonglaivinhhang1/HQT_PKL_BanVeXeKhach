USE PHUONGTRANG

--*********************************************************************************************************************--
--****************************************** BẢNG TUYENDUONG **********************************************************--
--*********************************************************************************************************************--

------------------------THÊM TUYẾN ĐƯỜNG------------------------------
----------------------------------------------------------------------

--Kiểm tra nơi xuất phát và nơi đến có trùng hay không
------------------------------------------------------
create procedure noiXuatPhatNoiDenKhacNhau @NoiXuatPhat nvarchar(50), @NoiDen nvarchar(50)
as
begin
	if (@NoiXuatPhat = @NoiDen)
	begin
		--false	
		return 0; 	
	end

	--true
	return 1;
end

--Tạo mã mới cho tuyến đường
----------------------------
create procedure taoMaTuyenDuong @MaMoi varchar(10) out
as
begin
	declare @Max int
	
	select @Max = convert(int,substring(max(MaTuyenDuong), 3, 48)) from PHUONGTRANG.DBO.TUYENDUONG

	set @Max = @Max + 1

	if (@Max is null)
	begin
		set @MaMoi = 'TD000'
		return
	end
	
	if (@Max < 10)
	begin
		set @MaMoi = 'TD00' + convert(varchar(10), @Max)
		return
	end

	if (@Max < 100)
	begin
		set @MaMoi = 'TD0' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 1000)
	begin
		set @MaMoi = 'TD' + convert(varchar(10), @Max)
		return
	end

	if (@Max >= 1000)
	begin
		set @MaMoi = 'error'
		return
	end
end

--Thêm tuyến đường
------------------
create procedure themTuyenDuong @NoiXuatPhat nvarchar(50), @NoiDen nvarchar(50), @BenDi nvarchar(50), @BenDen nvarchar(50), @QuangDuong int, @error nvarchar(100) out
as
begin tran
	--declare
	declare @noiXuatPhatNoiDenKhacNhau int
	declare @MaMoi nvarchar(10)

	--Kiểm tra nơi xuất phát và nơi đến có khác nhau không
	exec @noiXuatPhatNoiDenKhacNhau = noiXuatPhatNoiDenKhacNhau @NoiXuatPhat, @NoiDen

	--Nếu khác nhau thì bằng 1
	if (@noiXuatPhatNoiDenKhacNhau = 1)
	begin
		--Kiểm tra quảng đường
		if (@QuangDuong >= 0)
		begin
			--Tạo một mã mới cho tuyến đường
			exec taoMaTuyenDuong @MaMoi out

			--Không còn mã mới để tạo
			if (@MaMoi = 'error')
			begin
				set @error = 'Hết mã để tạo'
			end
			else
			begin
				--Thêm vào bảng tuyến đường
				insert into PHUONGTRANG.DBO.TUYENDUONG(MaTuyenDuong , NoiXuatPhat, NoiDen, BenDi, BenDen, QuangDuong) values (@MaMoi, @NoiXuatPhat, @NoiDen, @BenDi, @BenDen, @QuangDuong)

				set @error = ''

				if (@@ERROR <> 0)
				begin
					raiserror('Có lỗi trong lúc thêm dữ liệu', 0, 0)
					rollback
				end
			end
		end
		else
		begin
			set @error = 'Quảng đường phải lớn hơn hoặc bằng 0'
		end
	end
	else
	begin
		set @error = 'Nơi đến và nơi xuất phát phải khác nhau'
	end
commit tran

------------------------XÓA TUYẾN ĐƯỜNG-------------------------------
----------------------------------------------------------------------

--Procedure kiểm tra xem còn chuyến đi nào tham chiếu đến tuyến đường không
create procedure khongConChuyenDiThamChieuDenTuyenDuong @MaTuyenDuong varchar(10)
as
begin
	if exists(select MaChuyenDi from PHUONGTRANG.DBO.CHUYENDI where TuyenDuong = @MaTuyenDuong)
	begin
		--Có tồn tại thì trả về false
		return 0;
	end
	else
	begin
		--Trả về true
		return 1;
	end
end

--Kiểm tra tồn tại của tuyến đường
----------------------------------
create procedure tuyenDuongCoTonTai @MaTuyenDuong varchar(10)
as
begin
	if exists(select MaTuyenDuong from PHUONGTRANG.DBO.TUYENDUONG where MaTuyenDuong = @MaTuyenDuong)
	begin
		--Có tồn tại tuyến đường trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Procedure xóa tuyến đường
---------------------------
create procedure xoaTuyenDuong @MaTuyenDuong varchar(10),@error nvarchar(100) out
as
begin tran
	--declare
	declare @khongConChuyenDiThamChieuDenTuyenDuong int
	declare @tuyenDuongCoTonTai int

	exec @tuyenDuongCoTonTai = tuyenDuongCoTonTai @MaTuyenDuong

	if (@tuyenDuongCoTonTai = 1)
	begin
		--Kiểm tra xem còn chuyến đi nào tham chiếu đến tuyến đường hay không
		exec @khongConChuyenDiThamChieuDenTuyenDuong = khongConChuyenDiThamChieuDenTuyenDuong @MaTuyenDuong

		if (@khongConChuyenDiThamChieuDenTuyenDuong = 1)
		begin
			delete from PHUONGTRANG.DBO.TUYENDUONG where MaTuyenDuong = @MaTuyenDuong

			if (@@ERROR <> 0)
			begin
				raiserror('Có lỗi trong lúc xóa dữ liệu', 0, 0)
				rollback
			end
			else
			begin
				set @error = ''
			end
		end
		else
		begin
			set @error = 'Vẫn còn chuyến đi tham chiếu đến tuyến đường'
		end
	end
	else
	begin
		set @error = 'Tuyến đường không tồn tại'
	end
commit tran

------------------------CẬP NHẬT TUYẾN ĐƯỜNG--------------------------
----------------------------------------------------------------------

--Procedure cập nhật tuyến đường
--------------------------------
create procedure capNhatTuyenDuong @MaTuyenDuong varchar(10), @NoiXuatPhat nvarchar(50), @NoiDen nvarchar(50), @BenDi nvarchar(50), @BenDen nvarchar(50), @QuangDuong int, @error nvarchar(100) out
as
begin tran
	--declare
	declare @tuyenDuongCoTonTai int
	declare @noiXuatPhatNoiDenKhacNhau int

	--Kiểm tra mã tuyến đường này có tồn tại hay không
	exec @tuyenDuongCoTonTai = tuyenDuongCoTonTai @MaTuyenDuong

	if (@tuyenDuongCoTonTai = 1)
	begin
		--Kiểm tra nơi đến và nơi xuất phát có khác nhau không
		exec @noiXuatPhatNoiDenKhacNhau = noiXuatPhatNoiDenKhacNhau @NoiXuatPhat, @NoiDen

		if (@noiXuatPhatNoiDenKhacNhau = 1)
		begin
			if (@QuangDuong >= 0)
			begin
				--Cập nhật tuyến đường
				update PHUONGTRANG.DBO.TUYENDUONG
				set NoiXuatPhat = @NoiXuatPhat, NoiDen = @NoiDen, QuangDuong = @QuangDuong, BenDi = @BenDi, BenDen = @BenDen
				where MaTuyenDuong = @MaTuyenDuong

				set @error = ''

				if (@@ERROR <> 0)
				begin
					raiserror('Có lỗi trong lúc cập nhật dữ liệu', 0, 0)
					rollback
				end
			end
			else
			begin
				set @error = 'Quảng đường phải lớn hơn hoặc bằng 0'
			end
		end
		else
		begin
			set @error = 'Nơi xuất phát và nơi đến giống nhau'
		end
	end
	else
	begin
		set @error = 'Tuyến đường không tồn tại'
	end
commit tran

------------------------XEM TUYẾN ĐƯỜNG-------------------------------
----------------------------------------------------------------------
create procedure xemTuyenDuong
as
begin tran
	select * from PHUONGTRANG.DBO.TUYENDUONG

	if (@@ERROR <> 0)
	begin
		raiserror('Có lỗi trong lúc tìm kiếm dữ liệu', 0, 0)
		rollback
	end
commit tran

--*********************************************************************************************************************--
--****************************************** BẢNG CHUYENDI ************************************************************--
--*********************************************************************************************************************--

------------------------THÊM CHUYẾN ĐI---------------------------------
-----------------------------------------------------------------------

--Kiểm tra sự tồn tại của xe
----------------------------
create procedure xeCoTonTai @MaXe varchar(10)
as
begin
	if exists(select MaXe from PHUONGTRANG.DBO.XE where MaXe = @MaXe)
	begin
		--Có tồn tại xe trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Kiểm tra ngày giờ xuất phát và ngày giờ đến
---------------------------------------------
create procedure ngayGioXuatPhatNhoHonNgayGioDen @NgayGioXuatPhat datetime, @NgayGioDen datetime
as
begin
	if (@NgayGioXuatPhat > @NgayGioDen)
	begin
		--Ngày giờ xuất phát lớn hơn hoặc bằng ngày giờ đến
		--false
		return 0
	end
	else
	begin
		--true
		return 1
	end
end

--Kiểm tra xe đã được sử dụng trong khoảng thời gian đó hay chưa
----------------------------------------------------------------
create procedure xeChuaDuocSuDung @NgayGioXuatPhat datetime, @NgayGioDen datetime, @MaXe varchar(10), @MaChuyenDi varchar(10)
as
begin
	if (@MaChuyenDi is null)
	begin
		--Nếu xe đã được phân công vào một chuyến đi khác có thời gian chay trùng với thời gian chạy của chuyến đi ta sắp thêm
		if exists(select MaChuyenDi 
					from PHUONGTRANG.DBO.CHUYENDI 
					where Xe = @MaXe 
						and ((NgayGioXuatPhat <= @NgayGioDen and NgayGioXuatPhat >= @NgayGioXuatPhat) 
						or (NgayGioDen <= @NgayGioDen and NgayGioDen >= @NgayGioXuatPhat))) 
		begin
			--false (xe đã được sử dụng)
			return 0;
		end
		else
		begin
			--true (xe chưa được sử dụng)
			return 1;
		end
	end
	else
	begin
		--Nếu xe đã được phân công vào một chuyến đi khác có thời gian chay trùng với thời gian chạy của chuyến đi ta sắp thêm
		if exists(select MaChuyenDi 
					from PHUONGTRANG.DBO.CHUYENDI 
					where Xe = @MaXe 
						and ((NgayGioXuatPhat <= @NgayGioDen and NgayGioXuatPhat >= @NgayGioXuatPhat) 
						or (NgayGioDen <= @NgayGioDen and NgayGioDen >= @NgayGioXuatPhat)) and MaChuyenDi != @MaChuyenDi) 
		begin
			--false (xe đã được sử dụng)
			return 0;
		end
		else
		begin
			--true (xe chưa được sử dụng)
			return 1;
		end
	end
end

--Tính giá dự kiến cho chuyến đi
--------------------------------
create procedure tinhGiaDuKien @MaTuyenDuong varchar(10), @MaXe varchar(10), @GiaMoiQuangDuong int
as
begin
	--declare
	declare @QuangDuong int
	declare @LoaiXe nvarchar(50)
	declare @GiaDuKien int

	--Lấy quảng đường của chuyến đi
	select @QuangDuong = QuangDuong from PHUONGTRANG.DBO.TUYENDUONG where MaTuyenDuong = @MaTuyenDuong

	--Lấy loại xe
	select @LoaiXe = LoaiXe from PHUONGTRANG.DBO.XE where MaXe = @MaXe

	--Tính giá dự kiến, lấy quảng đường nhân giá mỗi quảng đường
	set @GiaDuKien = @QuangDuong * @GiaMoiQuangDuong

	--Nếu là xe giường nằm
	if (@LoaiXe = 'Giường Nằm')
	begin
		--Cộng thêm 50%
		return @GiaDuKien + @GiaDuKien * 50 / 100
	end
	else
	begin
		return @GiaDuKien
	end
end

--Tạo mã mới cho chuyến đi
----------------------------
create procedure taoMaChuyenDi @MaMoi varchar(10) out
as
begin
	declare @Max int
	
	select @Max = convert(int,substring(max(MaChuyenDi), 3, 48)) from PHUONGTRANG.DBO.CHUYENDI

	set @Max = @Max + 1

	if (@Max is null)
	begin
		set @MaMoi = 'CD000'
		return
	end
	
	if (@Max < 10)
	begin
		set @MaMoi = 'CD00' + convert(varchar(10), @Max)
		return
	end

	if (@Max < 100)
	begin
		set @MaMoi = 'CD0' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 1000)
	begin
		set @MaMoi = 'CD' + convert(varchar(10), @Max)
		return
	end

	if (@Max >= 1000)
	begin
		set @MaMoi = 'error'
		return
	end
end

--Thêm chuyến đi
----------------
create procedure themChuyenDi @MaTuyenDuong varchar(10), @NgayGioXuatPhat datetime, @NgayGioDen datetime, @MaXe varchar(10), @GiaMoiQuangDuong int, @error nvarchar(100) out
as
begin tran
	--declare
	declare @ngayGioXuatPhatNhoHonNgayGioDen int
	declare @xeChuaDuocSuDung int
	declare @GiaDuKien int
	declare @xeCoTonTai int
	declare @tuyenDuongCoTonTai int
	declare @MaChuyenDiMoi varchar(10)
	
	--Kiểm tra mã xe này có tồn tại hay không
	exec @xeCoTonTai = xeCoTonTai @MaXe

	if (@xeCoTonTai = 1)
	begin
		exec @tuyenDuongCoTonTai = tuyenDuongCoTonTai @MaTuyenDuong

		if (@tuyenDuongCoTonTai = 1)
		begin
			--Kiêm tra ngày giờ xuất phát có nhỏ hơn ngày giờ đến
			exec @ngayGioXuatPhatNhoHonNgayGioDen = ngayGioXuatPhatNhoHonNgayGioDen @NgayGioXuatPhat, @NgayGioDen

			--Nếu ngày giờ xuất phát nhỏ hơn ngày giờ đến
			if (@ngayGioXuatPhatNhoHonNgayGioDen = 1)
			begin
				--Kiểm tra xe đã được sử dụng trong khoảng thời gian đó hay chưa
				exec @xeChuaDuocSuDung = xeChuaDuocSuDung @NgayGioXuatPhat, @NgayGioDen, @MaXe, null

				--Nếu xe chưa được sử dụng
				if (@xeChuaDuocSuDung = 1)
				begin
					if (@GiaMoiQuangDuong >= 0)
					begin
						--Tính giá dự kiến cho chuyến đi
						exec @GiaDuKien = tinhGiaDuKien @MaTuyenDuong, @MaXe, @GiaMoiQuangDuong

						--Tạo mã chuyến đi mới
						exec taoMaChuyenDi @MaChuyenDiMoi out

						--Kiểm tra xem còn mã mới không
						if (@MaChuyenDiMoi = 'error')
						begin
							set @error = 'Hết mã chuyến đi để tạo'
						end
						else
						begin
							--Thêm vào bảng chuyến đi
							insert into PHUONGTRANG.DBO.CHUYENDI(MaChuyenDi, TuyenDuong, NgayGioXuatPhat, NgayGioDen, GiaDuKien, Xe)
							values (@MaChuyenDiMoi, @MaTuyenDuong, @NgayGioXuatPhat, @NgayGioDen, @GiaDuKien, @MaXe)

							set @error = ''

							if (@@ERROR <> 0)
							begin
								raiserror('Có lỗi trong lúc thêm dữ liệu', 0, 0)
								rollback
							end
						end
					end
					else
					begin
						set @error = 'Giá mỗi quảng đường phải lớn hơn hoặc bằng 0'
					end
				end
				else
				begin
					set @error = 'Xe đã được sử dụng'
				end
			end
			else
			begin
				set @error = 'Ngày giờ xuất phát lớn hơn hoặc bằng ngày giờ đến'
			end
		end
		else
		begin
			set @error = 'Không tồn tại tuyến đường này'
		end
	end
	else
	begin
		set @error = 'Không tồn tại xe này'
	end
commit tran

------------------------XÓA CHUYẾN ĐI---------------------------------
----------------------------------------------------------------------

--Kiểm tra chuyến đi có tồn tại hay không
-----------------------------------------
create procedure chuyenDiCoTonTai @MaChuyenDi varchar(10)
as
begin
	if exists(select MaChuyenDi from PHUONGTRANG.DBO.CHUYENDI where MaChuyenDi = @MaChuyenDi)
	begin
		--Có tồn tại chuyến đi trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Procedure kiểm tra xem có vé nào tham chiếu đến chuyến đi hay không
---------------------------------------------------------------------
create procedure khongConVeThamChieuDenChuyenDi @MaChuyenDi varchar(10)
as
begin
	if exists(select MaVe from PHUONGTRANG.DBO.VE where MaChuyenDi = @MaChuyenDi)
	begin
		--Tồn tại vé tham chiếu đến chuyến đi
		return 0;
	end
	else
	begin
		--Trả về true
		return 1;
	end
end

--Procedure xóa chuyến đi
-------------------------
create procedure xoaChuyenDi @MaChuyenDi varchar(10), @error nvarchar(100) out
as
begin tran
	--declare
	declare @khongConVeThamChieuDenChuyenDi int
	declare @chuyenDiCoTonTai int

	--Kiểm tra xem chuyến đi có tồn tại không
	exec @chuyenDiCoTonTai = chuyenDiCoTonTai @MaChuyenDi

	if (@chuyenDiCoTonTai = 1)
	begin
		--Kiểm tra xem còn vé nào tham chiếu đến chuyến đi hay không
		exec @khongConVeThamChieuDenChuyenDi = khongConVeThamChieuDenChuyenDi @MaChuyenDi

		if (@khongConVeThamChieuDenChuyenDi = 1)
		begin
			delete from PHUONGTRANG.DBO.CHUYENDI where MaChuyenDi = @MaChuyenDi

			set @error = ''

			if (@@ERROR <> 0)
			begin
				raiserror('Có lỗi trong lúc xóa dữ liệu', 0, 0)
				rollback
			end
		end
		else
		begin
			set @error = 'Tồn tại vé tham chiếu đến chuyến đi'
		end 
	end
	else
	begin
		set @error = 'Chuyến đi này không tồn tại'
	end
commit tran

------------------------CẬP NHẬT CHUYẾN ĐI----------------------------
----------------------------------------------------------------------

--Procedure cập nhật chuyến đi
------------------------------
create procedure capNhatChuyenDi @MaChuyenDi varchar(10), @MaTuyenDuong varchar(10), @NgayGioXuatPhat datetime, @NgayGioDen datetime, @MaXe varchar(10), @GiaMoiQuangDuong int, @error nvarchar(100) out
as
begin tran
	--declare
	declare @chuyenDiCoTonTai int
	declare @ngayGioXuatPhatNhoHonNgayGioDen int
	declare @xeChuaDuocSuDung int
	declare @GiaDuKien int
	declare @xeCoTonTai int
	declare @tuyenDuongCoTonTai int

	--Kiểm tra chuyến đi có tồn tại
	exec @chuyenDiCoTonTai = chuyenDiCoTonTai @MaChuyenDi

	if (@chuyenDiCoTonTai = 1)
	begin
		--Kiểm tra mã xe này có tồn tại hay không
		exec @xeCoTonTai = xeCoTonTai @MaXe

		if (@xeCoTonTai = 1)
		begin
			exec @tuyenDuongCoTonTai = tuyenDuongCoTonTai @MaTuyenDuong

			if (@tuyenDuongCoTonTai = 1)
			begin
				--Kiêm tra ngày giờ xuất phát có nhỏ hơn ngày giờ đến
				exec @ngayGioXuatPhatNhoHonNgayGioDen = ngayGioXuatPhatNhoHonNgayGioDen @NgayGioXuatPhat, @NgayGioDen

				--Nếu ngày giờ xuất phát nhỏ hơn ngày giờ đến
				if (@ngayGioXuatPhatNhoHonNgayGioDen = 1)
				begin
					--Kiểm tra xe đã được sử dụng trong khoảng thời gian đó hay chưa
					exec @xeChuaDuocSuDung = xeChuaDuocSuDung @NgayGioXuatPhat, @NgayGioDen, @MaXe, @MaChuyenDi

					--Nếu xe chưa được sử dụng
					if (@xeChuaDuocSuDung = 1)
					begin
						if (@GiaMoiQuangDuong >= 0)
						begin
							--Tính giá dự kiến cho chuyến đi
							exec @GiaDuKien = tinhGiaDuKien @MaTuyenDuong, @MaXe, @GiaMoiQuangDuong
											
							--Cập nhật bảng chuyến đi
							update PHUONGTRANG.DBO.CHUYENDI
							set TuyenDuong = @MaTuyenDuong, NgayGioXuatPhat = @NgayGioXuatPhat, NgayGioDen = @NgayGioDen, GiaDuKien = @GiaDuKien, Xe = @MaXe
							where MaChuyenDi = @MaChuyenDi

							set @error = ''

							if (@@ERROR <> 0)
							begin
								raiserror('Có lỗi trong lúc thêm dữ liệu', 0, 0)
								rollback
							end
						end
						else
						begin
							set @error = 'Giá mỗi quảng đường phải lớn hơn hoặc bằng 0'
						end
					end
					else
					begin
						set @error = 'Xe đã được sử dụng'
					end
				end
				else
				begin
					set @error = 'Ngày giờ xuất phát lớn hơn hoặc bằng ngày giờ đến'
				end
			end
			else
			begin
				set @error = 'Không tồn tại tuyến đường này'
			end
		end
		else
		begin
			set @error = 'Không tồn tại xe này'
		end
	end
	else
	begin
		set @error = 'Không tồn tại chuyến đi này'
	end
commit tran

------------------------XEM CHUYẾN ĐI---------------------------------
----------------------------------------------------------------------

--Procedure xem tất cả chuyến đi
--------------------------------
create procedure xemTatCaChuyenDi
as
begin tran
	select * from PHUONGTRANG.DBO.CHUYENDI

	if (@@ERROR <> 0)
	begin
		raiserror('Có lỗi trong lúc xem dữ liệu', 0, 0)
		rollback
	end
commit tran

--Procedure xem chuyến đi chưa xuất phát
-------------------------
create procedure xemChuyenDiChuaXuatPhat
as
begin tran
	select * from PHUONGTRANG.DBO.CHUYENDI where NgayGioXuatPhat > getdate()

	if (@@ERROR <> 0)
	begin
		raiserror('Có lỗi trong lúc xem dữ liệu', 0, 0)
		rollback
	end
commit tran

--Procedure xem chuyến đi đã xuất phát
-------------------------
create procedure xemChuyenDiDaXuatPhat
as
begin tran
	select * from PHUONGTRANG.DBO.CHUYENDI where NgayGioXuatPhat <= getdate()

	if (@@ERROR <> 0)
	begin
		raiserror('Có lỗi trong lúc xem dữ liệu', 0, 0)
		rollback
	end
commit tran

--*********************************************************************************************************************--
--****************************************** BẢNG LOAI NHANVIEN ************************************************************--
--*********************************************************************************************************************--

------------------------THÊM LOẠI NHÂN VIÊN---------------------------
----------------------------------------------------------------------

--Tạo mã mới cho loại nhân viên
----------------------------
create procedure taoMaLoaiNV @MaMoi varchar(10) out
as
begin
	declare @Max int	
	
	select @Max = convert(int,substring(max(MaLoaiNV), 4, 47)) from PHUONGTRANG.DBO.LOAINHANVIEN

	set @Max = @Max + 1

	if (@Max is null)
	begin
		set @MaMoi = 'LNV000'
		return
	end
	
	if (@Max < 10)
	begin
		set @MaMoi = 'LNV00' + convert(varchar(10), @Max)
		return
	end

	if (@Max < 100)
	begin
		set @MaMoi = 'LNV0' + convert(varchar(10), @Max)
		return
	end
	
	if (@Max < 1000)
	begin
		set @MaMoi = 'LNV' + convert(varchar(10), @Max)
		return
	end

	if (@Max >= 1000)
	begin
		set @MaMoi = 'error'
		return
	end
end

--Procedure thêm loại nhân viên
create procedure themLoaiNhanVien @TenLoaiNV nvarchar(50), @error nvarchar(100) out
as
begin tran
	--declare
	declare @MaLoaiNVMoi varchar(10)

	--Tạo mã mới cho loại nhân viên
	exec taoMaLoaiNV @MaLoaiNVMoi out

	if (@MaLoaiNVMoi = 'error')
	begin
		set @error = 'Không còn mã loại nv để tạo'
	end
	else
	begin
		insert into PHUONGTRANG.DBO.LOAINHANVIEN(MaLoaiNV, TenLoaiNV) values (@MaLoaiNVMoi, @TenLoaiNV)

		set @error = ''

		if (@@ERROR <> 0)
		begin
			raiserror('Có lỗi trong lúc thêm loại nhân viên', 0, 0)
			rollback
		end
	end
commit tran

------------------------CẬP NHẬT LOẠI NHÂN VIÊN-----------------------
----------------------------------------------------------------------

--Procedure kiểm tra loại nhân viên có tồn tại hay không
--------------------------------------------------------
create procedure loaiNhanVienCoTonTai @MaLoaiNV varchar(10)
as
begin
	if exists(select MaLoaiNV from PHUONGTRANG.DBO.LOAINHANVIEN where MaLoaiNV = @MaLoaiNV)
	begin
		--Có tồn tại loại nhân viên trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Procedure cập nhật loại nhân viên
-----------------------------------
create procedure capNhatLoaiNhanVien @MaLoaiNV varchar(10), @TenLoaiNV nvarchar(50), @error nvarchar(100) out
as
begin tran
	--declare
	declare @loaiNhanVienCoTonTai int

	--Kiểm tra loại nhân viên có tồn tại
	exec @loaiNhanVienCoTonTai = loaiNhanVienCoTonTai @MaLoaiNV

	if (@loaiNhanVienCoTonTai = 1)
	begin
		update PHUONGTRANG.DBO.LOAINHANVIEN
		set TenLoaiNV = @TenLoaiNV
		where MaLoaiNV = @MaLoaiNV

		set @error = ''

		if (@@ERROR <> 0)
		begin
			raiserror('Có lỗi trong lúc cập nhật loại nhân viên', 0, 0)
			rollback
		end
	end
	else
	begin
		set @error = 'Mã loại nhân viên không tồn tại'
	end
commit tran

------------------------XÓA LOẠI NHÂN VIÊN----------------------------
----------------------------------------------------------------------

--Procedure kiểm tra xem có nhân viên nào tham chiếu đến loại nhân viên hay không
---------------------------------------------------------------------
create procedure khongConNhanVienThamChieuDenLoaiNV @MaLoaiNV varchar(10)
as
begin
	if exists(select MaNhanVien from PHUONGTRANG.DBO.NHANVIEN where LoaiNhanVien = @MaLoaiNV)
	begin
		--Tồn tại nhân viên tham chiếu đến chuyến đi
		return 0;
	end
	else
	begin
		--Trả về true
		return 1;
	end
end

--Procedure xóa loại nhân viên
------------------------------
create procedure xoaLoaiNhanVien @MaLoaiNV varchar(10), @error nvarchar(100) out
as
begin tran
	--declare
	declare @khongConNhanVienThamChieuDenLoaiNV int
	declare @loaiNhanVienCoTonTai int

	--Kiểm tra loại nhân viên có tồn tại
	exec @loaiNhanVienCoTonTai = loaiNhanVienCoTonTai @MaLoaiNV

	if (@loaiNhanVienCoTonTai = 1)
	begin
		--Kiểm tra xem còn nhân viên nào tham chiếu đến loại nhân viên hay không
		exec @khongConNhanVienThamChieuDenLoaiNV = khongConNhanVienThamChieuDenLoaiNV @MaLoaiNV

		if (@khongConNhanVienThamChieuDenLoaiNV = 1)
		begin
			delete from PHUONGTRANG.DBO.LOAINHANVIEN
			where MaLoaiNV = @MaLoaiNV

			set @error = ''

			if (@@ERROR <> 0)
			begin
				raiserror('Có lỗi trong lúc xóa loại nhân viên', 0, 0)
				rollback
			end
		end
		else
		begin
			set @error = 'Còn nhân viên tham chiếu đến mã loại nhân viên'
		end
	end
	else
	begin
		set @error = 'Mã loại nhân viên không tồn tại'
	end
commit tran

------------------------XEM LOẠI NHÂN VIÊN----------------------------
----------------------------------------------------------------------

--Procedure xem loại nhân viên
-------------------------
create procedure xemLoaiNhanVien
as
begin tran
	select * from PHUONGTRANG.DBO.LOAINHANVIEN

	if (@@ERROR <> 0)
	begin
		raiserror('Có lỗi trong lúc xem loại nhân viên', 0, 0)
		rollback
	end
commit tran

--*********************************************************************************************************************--
--****************************************** BẢNG VE ******************************************************************--
--*********************************************************************************************************************--

------------------------THANH TOÁN VÉ CỦA KHÁCH HÀNG------------------
----------------------------------------------------------------------

--Kiểm tra phương thức thanh toán có tồn tại
--------------------------------------------
create procedure phuongThucThanhToanCoTonTai @PhuongThucThanhToan varchar(10)
as
begin
	if exists(select MaPhuongThucThanhToan from PHUONGTRANG.DBO.PHUONGTHUCTHANHTOAN where MaPhuongThucThanhToan = @PhuongThucThanhToan)
	begin
		--Có tồn tại phương thức thanh toán trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Kiểm tra vé có tồn tại
------------------------
create procedure veCoTonTai @MaVe varchar(10)
as
begin
	if exists(select MaVe from PHUONGTRANG.DBO.VE where MaVe = @MaVe)
	begin
		--Có tồn tại vé trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Kiểm tra tên đăng nhập có tồn tại
create procedure tenDangNhapCoTonTai @TenDangNhap varchar(50)
as
begin
	if exists(select TenDangNhap from PHUONGTRANG.DBO.TAIKHOAN where TenDangNhap = @TenDangNhap)
	begin
		--Tên đăng nhập có tồn tại
		return 1
	end
	else
	begin
		--Tên đăng nhập không tồn tại
		return 0
	end
end

--Kiểm tra giá vé thực và số tiền có giống nhau
create procedure giaVeThucVaSoTienGiongNhau @MaVe varchar(10), @SoTien int
as
begin
	declare @GiaVeThuc int

	select @GiaVeThuc = GiaVeThuc from PHUONGTRANG.DBO.VE where MaVe = @MaVe

	if (@GiaVeThuc = @SoTien)
	begin
		--Giống nhau
		return 1;
	end
	else
	begin
		--Không giống nhau
		return 0;
	end
end

--Thanh toán vé của khách hàng
------------------------------
create procedure thanhToanVeKhachHang @MaVe varchar(10), @PhuongThucThanhToan varchar(10), @TenDangNhap varchar(50), @SoTien int, @error nvarchar(100) out
as
begin tran
	--declare
	declare @veCoTonTai int
	declare @phuongThucThanhToanCoTonTai int
	declare @tenDangNhapCoTonTai int
	declare @giaVeThucVaSoTienGiongNhau int

	if (@TenDangNhap is null)
	begin
		--Kiểm tra vé có tồn tại hay không
		exec @veCoTonTai = veCoTonTai @MaVe

		if (@veCoTonTai = 1)
		begin
			--Kiểm tra phương thức thanh toán có tồn tại hay không
			exec @phuongThucThanhToanCoTonTai = phuongThucThanhToanCoTonTai @PhuongThucThanhToan

			if (@phuongThucThanhToanCoTonTai = 1)
			begin
				--Kiểm tra giá vé thực và số tiền có giống nhau
				exec @giaVeThucVaSoTienGiongNhau = giaVeThucVaSoTienGiongNhau @MaVe, @SoTien

				if (@giaVeThucVaSoTienGiongNhau = 1)
				begin
					update PHUONGTRANG.DBO.VE
					set PhuongThucThanhToan = @PhuongThucThanhToan, NgayThanhToan = getdate(), TrangThaiThanhToan = N'Đã thanh toán'
					where MaVe = @MaVe

					set @error = ''

					if (@@ERROR <> 0)
					begin
						raiserror('Có lỗi trong lúc thanh toán vé', 0, 0)
						rollback
					end
				end
				else
				begin
					set @error = 'Bạn đóng không đủ tiền'
				end
			end
			else
			begin
				set @error = 'phương thức thanh toán không tồn tại'
			end
		end
		else
		begin
			set @error = 'Vé này không tồn tại'
		end
	end
	else
	begin
		--Kiểm tra vé có tồn tại hay không
		exec @veCoTonTai = veCoTonTai @MaVe

		if (@veCoTonTai = 1)
		begin
			--Kiểm tra phương thức thanh toán có tồn tại hay không
			exec @phuongThucThanhToanCoTonTai = phuongThucThanhToanCoTonTai @PhuongThucThanhToan

			if (@phuongThucThanhToanCoTonTai = 1)
			begin
				--Kiểm tra tên đăng nhập có tồn tại
				exec @tenDangNhapCoTonTai = tenDangNhapCoTonTai @TenDangNhap

				if (@tenDangNhapCoTonTai = 1)
				begin
					--Kiểm tra giá vé thực và số tiền có giống nhau
					exec @giaVeThucVaSoTienGiongNhau = giaVeThucVaSoTienGiongNhau @MaVe, @SoTien

					if (@giaVeThucVaSoTienGiongNhau = 1)
					begin
						--Cập nhật số tiền trong tài khoản
						update PHUONGTRANG.DBO.TAIKHOAN
						set SoTien = SoTien - @SoTien
						where TenDangNhap = @TenDangNhap

						set @error = ''

						if (@@ERROR <> 0)
						begin
							raiserror('Có lỗi trong lúc thanh toán vé', 0, 0)
							rollback
						end

						--Cập nhật vé đã thanh toán
						update PHUONGTRANG.DBO.VE
						set PhuongThucThanhToan = @PhuongThucThanhToan, NgayThanhToan = getdate(), TrangThaiThanhToan = N'Đã thanh toán'
						where MaVe = @MaVe

						set @error = ''

						if (@@ERROR <> 0)
						begin
							raiserror('Có lỗi trong lúc thanh toán vé', 0, 0)
							rollback
						end
					end
					else
					begin
						set @error = 'Bạn đóng không đủ tiền'
					end
				end
				else
				begin
					set @error = 'Tên đăng nhập không tồn tại'
				end
			end
			else
			begin
				set @error = 'phương thức thanh toán không tồn tại'
			end
		end
		else
		begin
			set @error = 'Vé này không tồn tại'
		end
	end
commit

------------------------THANH TOÁN VÉ CỦA NHÂN VIÊN-------------------
----------------------------------------------------------------------

--Kiểm tra nhân viên thanh toán có tồn tại
------------------------------------------
create procedure nhanVienThanhToanCoTonTai @MaNV varchar(10)
as
begin
	if exists(select MaNhanVien from PHUONGTRANG.DBO.NHANVIEN where MaNhanVien = @MaNV and LoaiNhanVien in (select MaLoaiNV from PHUONGTRANG.DBO.LOAINHANVIEN where TenLoaiNV = N'Nhân viên thanh toán'))
	begin
		--Có tồn tại nhân viên thanh toán trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Thanh toán vé của nhân viên
------------------------------
create procedure thanhToanVeNhanVien @MaVe varchar(10), @PhuongThucThanhToan varchar(10), @MaNV varchar(10), @SoTien int, @error nvarchar(100) out
as
begin tran
	--declare
	declare @veCoTonTai int
	declare @nhanVienThanhToanCoTonTai int
	declare @phuongThucThanhToanCoTonTai int
	declare @giaVeThucVaSoTienGiongNhau int

	--Kiểm tra vé có tồn tại hay không
	exec @veCoTonTai = veCoTonTai @MaVe

	if (@veCoTonTai = 1)
	begin
		exec @nhanVienThanhToanCoTonTai = nhanVienThanhToanCoTonTai @MaNV

		if (@nhanVienThanhToanCoTonTai = 1)
		begin
			--Kiểm tra phương thức thanh toán có tồn tại hay không
			exec @phuongThucThanhToanCoTonTai = phuongThucThanhToanCoTonTai @PhuongThucThanhToan

			if (@phuongThucThanhToanCoTonTai = 1)
			begin
				--Kiểm tra giá vé thực và số tiền có giống nhau
				exec @giaVeThucVaSoTienGiongNhau = giaVeThucVaSoTienGiongNhau @MaVe, @SoTien

				if (@giaVeThucVaSoTienGiongNhau = 1)
				begin
					update PHUONGTRANG.DBO.VE
					set PhuongThucThanhToan = @PhuongThucThanhToan, NgayThanhToan = getdate(), NhanVienThanhToan = @MaNV, TrangThaiThanhToan = N'Đã thanh toán'
					where MaVe = @MaVe

					set @error = ''

					if (@@ERROR <> 0)
					begin
						raiserror('Có lỗi trong lúc thanh toán vé', 0, 0)
						rollback
					end
				end
				else
				begin
					set @error = 'Bạn đóng không đủ tiền'
				end
			end
			else
			begin
				set @error = 'phương thức thanh toán không tồn tại'
			end
		end
		else
		begin
			set @error = 'nhân viên thanh toán không tồn tại'
		end
	end
	else
	begin
		set @error = 'Vé này không tồn tại'
	end
commit

------------------------THỐNG KÊ DOANH THU----------------------------
----------------------------------------------------------------------

--Procedure thống kê doanh thu bán vé trong một khoảng thời gian nào đó
-----------------------------------------------------------------------
create procedure thongKeDoanhThuTheoThoiGian @NgayBatDau datetime, @NgayKetThuc datetime, @error nvarchar(100) out, @TongDoanhThu int out
as
begin tran
	--declare
	declare @NgayHomNay datetime
	
	if (@NgayBatDau is not null and @NgayKetThuc is not null)
	begin
		set @TongDoanhThu = 0
		--Tính tổng doanh thu
		select @TongDoanhThu = sum(GiaVeThuc)
		from PHUONGTRANG.DBO.VE
		where TrangThaiThanhToan = 1 and NgayThanhToan >= @NgayBatDau and NgayThanhToan <= @NgayKetThuc

		if (@@ERROR <> 0)
		begin
			raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
			rollback
		end
	end
	else
	begin
		if (@NgayBatDau is null and @NgayKetThuc is not null)
		begin
			set @TongDoanhThu = 0
			--Tính tổng doanh thu
			select @TongDoanhThu = sum(GiaVeThuc)
			from PHUONGTRANG.DBO.VE
			where TrangThaiThanhToan = 1 and NgayThanhToan <= @NgayKetThuc

			if (@@ERROR <> 0)
			begin
				raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
				rollback
			end
		end
		else
		begin
			if (@NgayBatDau is not null and @NgayKetThuc is null)
			begin
				--Lấy ngày hôm nay
				set @NgayHomNay = getdate()

				set @TongDoanhThu = 0
				--Tính tổng doanh thu
				select @TongDoanhThu = sum(GiaVeThuc)
				from PHUONGTRANG.DBO.VE
				where TrangThaiThanhToan = 1 and NgayThanhToan >= @NgayBatDau and NgayThanhToan <= @NgayHomNay

				if (@@ERROR <> 0)
				begin
					raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
					rollback
				end
			end
			else
			begin
				set @TongDoanhThu = 0
				--Tính tổng doanh thu
				select @TongDoanhThu = sum(GiaVeThuc)
				from PHUONGTRANG.DBO.VE
				where TrangThaiThanhToan = 1

				if (@@ERROR <> 0)
				begin
					raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
					rollback
				end
			end
		end
	end
commit tran

--Procedure thống kê doanh thu bán vé theo chuyến đi
----------------------------------------------------
create procedure thongKeDoanhThuTheoChuyenDi @MaChuyenDi varchar(10), @error nvarchar(100) out, @TongDoanhThu int out
as
begin tran
	--declare
	declare @chuyenDiCoTonTai int

	--Kiểm tra chuyến đi có tồn tại không
	exec @chuyenDiCoTonTai = chuyenDiCoTonTai @MaChuyenDi

	if (@chuyenDiCoTonTai = 1)
	begin
		set @TongDoanhThu = 0

		--Tính tổng doanh thu
		select @TongDoanhThu = sum(GiaVeThuc)
		from PHUONGTRANG.DBO.VE
		where TrangThaiThanhToan = 1 and MaChuyenDi = @MaChuyenDi

		set @error = ''

		if (@@ERROR <> 0)
		begin
			raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
			rollback
		end
	end
	else
	begin
		set @error = 'Chuyến đi không tồn tại'
	end
commit tran

--Procedure thống kê doanh thu bán vé theo tuyến đường trong một khoảng thời gian nào đó
----------------------------------------------------------------------------------------
create procedure thongKeDoanhThuTheoThoiGianTuyenDuong @NgayBatDau datetime, @NgayKetThuc datetime, @MaTuyenDuong varchar(10), @error nvarchar(100) out, @TongDoanhThu int out
as
begin tran
	--declare
	declare @NgayHomNay datetime
	declare @tuyenDuongCoTonTai int
	
	--Kiểm tra xem mã tuyến đường có tồn tại
	exec @tuyenDuongCoTonTai = tuyenDuongCoTonTai @MaTuyenDuong

	if (@tuyenDuongCoTonTai = 1)
	begin
		if (@NgayBatDau is not null and @NgayKetThuc is not null)
		begin
			set @TongDoanhThu = 0
			--Tính tổng doanh thu
			select @TongDoanhThu = sum(GiaVeThuc)
			from PHUONGTRANG.DBO.VE
			where TrangThaiThanhToan = 1 and NgayThanhToan >= @NgayBatDau and NgayThanhToan <= @NgayKetThuc
					and MaChuyenDi in (select MaChuyenDi from PHUONGTRANG.DBO.CHUYENDI where TuyenDuong = @MaTuyenDuong)

			if (@@ERROR <> 0)
			begin
				raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
				rollback
			end
		end
		else
		begin
			if (@NgayBatDau is null and @NgayKetThuc is not null)
			begin
				set @TongDoanhThu = 0
				--Tính tổng doanh thu
				select @TongDoanhThu = sum(GiaVeThuc)
				from PHUONGTRANG.DBO.VE
				where TrangThaiThanhToan = 1 and NgayThanhToan <= @NgayKetThuc
					and MaChuyenDi in (select MaChuyenDi from PHUONGTRANG.DBO.CHUYENDI where TuyenDuong = @MaTuyenDuong)

				if (@@ERROR <> 0)
				begin
					raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
					rollback
				end
			end
			else
			begin
				if (@NgayBatDau is not null and @NgayKetThuc is null)
				begin
					--Lấy ngày hôm nay
					set @NgayHomNay = getdate()

					set @TongDoanhThu = 0
					--Tính tổng doanh thu
					select @TongDoanhThu = sum(GiaVeThuc)
					from PHUONGTRANG.DBO.VE
					where TrangThaiThanhToan = 1 and NgayThanhToan >= @NgayBatDau and NgayThanhToan <= @NgayHomNay
					and MaChuyenDi in (select MaChuyenDi from PHUONGTRANG.DBO.CHUYENDI where TuyenDuong = @MaTuyenDuong)

					if (@@ERROR <> 0)
					begin
						raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
						rollback
					end
				end
				else
				begin
					set @TongDoanhThu = 0
					--Tính tổng doanh thu
					select @TongDoanhThu = sum(GiaVeThuc)
					from PHUONGTRANG.DBO.VE
					where TrangThaiThanhToan = 1 and MaChuyenDi in (select MaChuyenDi from PHUONGTRANG.DBO.CHUYENDI where TuyenDuong = @MaTuyenDuong)

					if (@@ERROR <> 0)
					begin
						raiserror('Có lỗi trong lúc thống kê doanh thu', 0, 0)
						rollback
					end
				end
			end
		end
	end
	else
	begin
		set @error = 'Tuyến đường không tồn tại'
	end
commit tran

--*********************************************************************************************************************--
--****************************************** BẢNG PHANCONGTAIXELAICHUYENDI ********************************************--
--*********************************************************************************************************************--

------------------------PHÂN CÔNG TÀI XẾ LÁI CHUYẾN ĐI----------------
----------------------------------------------------------------------

--Xem tài xế
create procedure xemTaiXe
as
begin tran
	select * from PHUONGTRANG.DBO.NHANVIEN where LoaiNhanVien in (select MaLoaiNV from PHUONGTRANG.DBO.LOAINHANVIEN where TenLoaiNV = N'Tài Xế')
	
	 if (@@ERROR <> 0)
	begin
		raiserror('Có lỗi trong lúc xem tài xế', 0, 0)
		rollback
	end
commit tran

--Kiểm tra tài xế có tồn tại
------------------------------------------
create procedure taiXeCoTonTai @MaNV varchar(10)
as
begin
	if exists(select MaNhanVien from PHUONGTRANG.DBO.NHANVIEN where MaNhanVien = @MaNV and LoaiNhanVien in (select MaLoaiNV from LOAINHANVIEN where TenLoaiNV = N'Tài xế'))
	begin
		--Có tồn tại tài xế trả về true
		return 1
	end
	else
	begin
		--Không tồn tại trả về false
		return 0
	end
end

--Kiểm tra tài xế đã lái chuyến đi nào khác trong khoảng thời gian đó hay chưa
----------------------------------------------------------------
create procedure taiXeChuaLaiChuyenKhac @MaChuyenDi varchar(10), @TaiXe varchar(10)
as
begin
	--declare
	declare @NgayGioXuatPhat datetime
	declare @NgayGioDen datetime

	--Lấy ngày giờ xuất phát và ngày giờ đến của chuyến đi
	select @NgayGioXuatPhat = NgayGioXuatPhat, @NgayGioDen = NgayGioDen
	from PHUONGTRANG.DBO.CHUYENDI
	where MaChuyenDi = @MaChuyenDi

	--Nếu tài xế đã được phân công vào một chuyến đi khác có thời gian chay trùng với thời gian chạy của chuyến đi ta sắp thêm
	if exists(select TaiXe
				from PHUONGTRANG.DBO.PHANCONGTAIXELAICHUYENDI pc, (select MaChuyenDi 
																	from PHUONGTRANG.DBO.CHUYENDI
																	where  (NgayGioXuatPhat <= @NgayGioDen and NgayGioXuatPhat >= @NgayGioXuatPhat) 
																			or (NgayGioDen <= @NgayGioDen and NgayGioDen >= @NgayGioXuatPhat)) cd 
				where TaiXe = @TaiXe and pc.MaChuyenDi = cd. MaChuyenDi and cd.MaChuyenDi != @MaChuyenDi)
	begin
		--false (tài xế đã lái chuyến khác)
		return 0;
	end
	else
	begin
		--true (tài xế chưa lái chuyến khác)
		return 1;
	end
end

--Procedure kiểm tra tài xế có được phân công lái xe đó hay không
-----------------------------------------------------------------
create procedure taiXeCoTheLaiXe @MaChuyenDi varchar(10), @TaiXe varchar(10)
as
begin
	--declare
	declare @Xe varchar(10)
	declare @NgayGioXuatphat datetime

	--Lấy xe của chuyến đi
	select @Xe = Xe, @NgayGioXuatphat = NgayGioXuatPhat
	from PHUONGTRANG.DBO.CHUYENDI
	where MaChuyenDi = @MaChuyenDi

	if exists(select TaiXe from PHUONGTRANG.DBO.PHANCONGTAIXEPHUTRACHXE where TaiXe = @TaiXe and MaXe = @Xe and NgayKetThuc >= @NgayGioXuatphat)
	begin
		--Tài xế có thể lái xe
		return 1
	end
	else
	begin
		return 0
	end
end

--Procedure kiểm tra khả năng lái quảng đường của tài xế
--------------------------------------------------------
create procedure taiXeCoTheLaiQuangDuong @TaiXe varchar(10), @MaChuyenDi varchar(10)
as
begin
	--declare
	declare @QuangDuong int
	declare @KhaNangLaiDuongDai int

	--Lấy ra quảng đường của chuyến đi
	select @QuangDuong = QuangDuong 
	from PHUONGTRANG.DBO.TUYENDUONG td, (select TuyenDuong 
										from PHUONGTRANG.DBO.CHUYENDI
										where MaChuyenDi = @MaChuyenDi) cd
	where cd.TuyenDuong = td.MaTuyenDuong

	--Lấy khả năng lái đường dài của tài xế
	select @KhaNangLaiDuongDai = KhaNangLaiDuongDai
	from PHUONGTRANG.DBO.NHANVIEN
	where MaNhanVien = @TaiXe

	--Kiểm tra tài xế có đủ khả năng lái quảng đường hay không
	if (@KhaNangLaiDuongDai >= @QuangDuong)
	begin
		--Có thể lái
		return 1
	end
	else
	begin
		--không thể lái
		return 0
	end
end

--Procedure phân công tài xế lái chuyến đi
------------------------------------------
create procedure phanCongTaiXeLaiCD @MaChuyenDi varchar(10), @TaiXe varchar(10), @LoaiTaiXe nvarchar(50), @error nvarchar(100) out
as
begin tran
	--declare
	declare @taiXeCoTonTai int
	declare @chuyenDiCoTonTai int
	declare @taiXeChuaLaiChuyenKhac int
	declare @taiXeCoTheLaiXe int
	declare @taiXeCoTheLaiQuangDuong int

	--Kiểm tra chuyến đi có tồn tại hay không
	exec @chuyenDiCoTonTai = chuyenDiCoTonTai @MaChuyenDi

	if (@chuyenDiCoTonTai = 1)
	begin
		--Kiểm tra tài xế có tồn tại
		exec @taiXeCoTonTai = taiXeCoTonTai @TaiXe

		if (@taiXeCoTonTai = 1)
		begin
			--Kiểm tra xem tài xế có đang lái chuyến khác trong cùng thời điểm hay không
			exec @taiXeChuaLaiChuyenKhac = taiXeChuaLaiChuyenKhac @MaChuyenDi, @TaiXe

			if (@taiXeChuaLaiChuyenKhac = 1)
			begin
				--Kiểm tra tài xê có thể lái xe này hay không
				exec @taiXeCoTheLaiXe = taiXeCoTheLaiXe @MaChuyenDi, @TaiXe

				if (@taiXeCoTheLaiXe = 1)
				begin
					--Kiểm tra xem tài xế có thể lái chuyến đi với quảng đường như vậy không
					exec @taiXeCoTheLaiQuangDuong = taiXeCoTheLaiQuangDuong @TaiXe, @MaChuyenDi

					if (@taiXeCoTheLaiQuangDuong = 1)
					begin
						--Thêm phân công
						insert into PHUONGTRANG.DBO.PHANCONGTAIXELAICHUYENDI(MaChuyenDi, TaiXe, LoaiTaiXe) 
						values (@MaChuyenDi, @TaiXe, @LoaiTaiXe)

						set @error = ''

						if (@@ERROR <> 0)
						begin
							raiserror('Có lỗi trong lúc phân công tài xế lái chuyến đi', 0, 0)
							rollback
						end
					end
					else
					begin
						set @error = 'Tài xế không đủ khả năng để lái quảng đường như vậy'
					end
				end
				else
				begin
					set @error = 'Tài xế không thể lái xe của chuyến này'
				end
			end
			else
			begin
				set @error = 'Tài xế đang lái chuyến khác tại cùng thời điểm'
			end
		end
		else
		begin
			set @error = 'Tài xế này không tồn tại'
		end
	end
	else
	begin
		set @error = 'Chuyến đi này không tồn tại'
	end
commit tran

use PHUONGTRANG2
go

--Store procedure kiểm tra xe có thuộc chuyến đi
CREATE PROCEDURE XeThuocChuyenDi @maxe VARCHAR(10), @machuyendi VARCHAR(10), @ketqua INT OUT
AS
BEGIN
	DECLARE @maxetemp VARCHAR(10)
	SET @maxetemp = (SELECT Xe FROM CHUYENDI WHERE MaChuyenDi = @machuyendi)
	IF (@maxe = @maxetemp)
		SET @ketqua = 1
	ELSE
		SET @ketqua = 0
END
GO

--Store procedure kiểm tra ghế có thuộc chuyến xe
CREATE PROCEDURE GheThuocxe @maxe VARCHAR(10), @maghe VARCHAR(10), @ketqua INT OUT
AS
BEGIN
	IF (@maghe in (select g.ViTriGhe from VE v, GHE g where g.MaXe = @maxe))
		SET @ketqua = 1
	ELSE
		SET @ketqua = 0
END
GO

--Store procedure kiểm tra vé có tồn tại
CREATE PROCEDURE KiemTraVeTonTai @mave VARCHAR(10), @ketqua INT OUT
AS
BEGIN	
	IF EXISTS (SELECT MaVe FROM VE WHERE MaVe = @mave)
		SET @ketqua = 1
	ELSE
		SET @ketqua = 0
END
GO

--Store procedure kiểm tra phương thức thanh toán có tồn tại
CREATE PROCEDURE KiemTraPTTT @maphuongthuctt VARCHAR(10), @ketqua INT OUT
AS
BEGIN	
	IF EXISTS (SELECT MaPhuongThucThanhToan FROM PHUONGTHUCTHANHTOAN WHERE MaPhuongThucThanhToan = @maphuongthuctt)
		SET @ketqua = 1
	ELSE
		SET @ketqua = 0
END
GO

CREATE PROCEDURE KiemTraKHTonTai @makh VARCHAR(10), @ketqua INT OUT
AS
BEGIN	
	IF EXISTS (SELECT MaKhachHang FROM KHACHHANG WHERE MaKhachHang = @makh)
		SET @ketqua = 1
	ELSE
		SET @ketqua = 0
END
GO

CREATE PROCEDURE KiemTraGheTrong @machuyendi VARCHAR(10), @maghe VARCHAR(10), @maxe VARCHAR(10), @ketqua INT OUT
AS
BEGIN				 
	IF EXISTS (SELECT * 
				FROM VE 
				WHERE MaGhe = @maghe 
				AND MaChuyenDi = @machuyendi
				AND MaXe = @maxe)
		SET @ketqua = 0
	ELSE
		SET @ketqua = 1
END
GO


--------------------------------------------------Lỗi Phantom--------------------------------------------------
--Transaction 1: để waitfor delay, ko đặt rollback
--Giao tác 1 để cái level serializable, wait for delay

DROP PROCEDURE ThongKeVe_ChuyenDi_PT_FIX
GO

CREATE PROCEDURE ThongKeVe_ChuyenDi_PT_FIX
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	IF NOT EXISTS (SELECT * FROM VE)
	BEGIN
		RAISERROR ('Không tồn tại vé nào trong csdl', 16, 1)
		ROLLBACK TRAN
		RETURN
	END	
	ELSE
	BEGIN
		SELECT v.MaChuyenDi, COUNT(v.MaVe) AS SoLuongVe, sum(v.GiaVeThuc) AS TongDoanhThu
		FROM VE v, CHUYENDI cd
		WHERE v.MaChuyenDi = cd.MaChuyenDi AND v.TrangThaiVe = 1 AND v.TrangThaiThanhToan = 1
		GROUP BY v.MaChuyenDi
	END
	WAITFOR DELAY '00:00:15' 
COMMIT TRAN
GO

EXEC ThongKeVe_ChuyenDi_PT_FIX
GO

--Transaction 2: Để bỉnh thường, ko rollback hay wait for delay, phải đợi 1 chạy xong thì 2 mới xong  
DROP PROCEDURE DatVeNV_PT_FIX
GO

CREATE PROCEDURE DatVeNV_PT_FIX @makh VARCHAR(10), @vitrighe VARCHAR(10), @maxe VARCHAR(10), @maphuongthuctt VARCHAR(10), @machuyendi VARCHAR(10), @manhanvienthanhtoan VARCHAR(10),  @manvdatve VARCHAR(10), @error NVARCHAR(100) OUT
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	--Các biến kiểm tra
	DECLARE @ktmakh INT, @ktmaptttt INT, @ghethuocxe INT, @xethuocchuyendi INT, @ghettrong INT
	--Các biến của vé 
	DECLARE @trangthaive INT, @thoigiandat DATETIME
	DECLARE @giave INT, @giavethuc INT, @makm VARCHAR(10), @hinhthuckm NVARCHAR(50), @tylegiamgia INT, @tyle FLOAT
	DECLARE @mave VARCHAR(10), @maxmave VARCHAR(10), @substr VARCHAR(10), @tempstr VARCHAR(10), @tempnum INT
	DECLARE @trangthaitt INT
	DECLARE @ngaythanhtoan datetime

	--Set thời gian đặt vé
	SET @thoigiandat = GETDATE()

	--Chạy các kiểm tra
	IF (@maphuongthuctt IS NOT NULL)
	BEGIN
		EXEC KiemTraPTTT @maphuongthuctt, @ktmaptttt OUT
		IF (@ktmaptttt = 1)
		BEGIN
			--Set trạng thái thanh toán. Đã thanh toán là 1, chưa thanh toán là 0
			SET @trangthaitt = 1
			SET @ngaythanhtoan = @thoigiandat	
		END			
		ELSE
		BEGIN
			SET @error = N'Lỗi phương thức thanh toán không tồn tại'
			RAISERROR (N'Lỗi phương thức thanh toán không tồn tại', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
	END
	ELSE
	BEGIN
		SET @trangthaitt = 0
		SET @ngaythanhtoan = NULL
	END
		
	EXEC KiemTraKHTonTai @makh, @ktmakh OUT
	EXEC XeThuocChuyenDi @maxe, @machuyendi, @xethuocchuyendi OUT
	EXEC GheThuocxe @maxe ,@vitrighe, @ghethuocxe OUT
	EXEC KiemTraGheTrong @machuyendi, @vitrighe, @maxe, @ghettrong OUT

	IF (@ktmakh = 1)
	BEGIN
		IF (@xethuocchuyendi = 1)
		BEGIN
			IF (@ghethuocxe = 1)
			BEGIN
				IF (@ghettrong = 1)
				BEGIN

					--Set trạng thái vé. Ban đầu sẽ có giá trị mặc định là 0 (Chưa duyệt)
					SET @trangthaive = 1

					--Tinh toán giá chuyến đi từ mã chuyến đi nhập từ input
					IF EXISTS (SELECT MaKhuyenMai FROM KHUYENMAI WHERE NgayBatDau <= @thoigiandat and NgayKetThuc >= @thoigiandat)
					BEGIN
						SET @makm = (SELECT MaKhuyenMai 
										FROM KHUYENMAI 
										WHERE NgayBatDau <= @thoigiandat and NgayKetThuc >= @thoigiandat)

						SET @hinhthuckm =  (SELECT HinhThucKhuyenMai
											FROM KHUYENMAI 
											WHERE MaKhuyenMai = @makm)

						SET @tylegiamgia = (SELECT TyLeGiamGia
											FROM KHUYENMAI 
											WHERE MaKhuyenMai = @makm)

						--Kiểm tra loại hình thứckhuyến mãi để tính giá chuyến đi
						IF (@hinhthuckm like N'%Tặng quà%')
						BEGIN
							SET @giavethuc = (SELECT GiaDuKien
												FROM CHUYENDI
												WHERE MaChuyenDi = @machuyendi)
						END
						ELSE
						BEGIN
							SET @giave = (SELECT GiaDuKien
											FROM CHUYENDI
											WHERE MaChuyenDi = @machuyendi)
							SET @tyle = convert(float, @tylegiamgia) / convert(float, 100)
							--Trừ cho phần giảm của khuyến mãi
							SET @giavethuc = @giave * (1 - @tyle)
						END
					END
					ELSE
					BEGIN
						SET @giavethuc = (SELECT GiaDuKien
											FROM CHUYENDI
											WHERE MaChuyenDi = @machuyendi)
					END
		
					--Tao ma ve va them vao csdl cua ve
					SELECT @maxmave = MAX(MaVe)
					FROM VE

					--Lay phan so cua ma ve lon nhat
					SET @substr = SUBSTRING(@maxmave, 3, 3)
					set @tempnum = CONVERT(INT, @substr)

					--Tang so cua ma ve, chuyen thanh dang chuoi
					SET @tempnum = @tempnum + 1
					SET @tempstr = CONVERT(VARCHAR(10), @tempnum)
	
					IF (@tempnum < 10)
					BEGIN
						SET @mave = CONCAT('VE00', @tempstr)
						INSERT INTO VE
						VALUES (@mave, @giavethuc, @trangthaive, @trangthaitt, @makh, @maphuongthuctt, @ngaythanhtoan, @thoigiandat, @manvdatve, @vitrighe, @maxe, @machuyendi, @manhanvienthanhtoan)
					END

					IF (@tempnum < 100 AND @tempnum >= 10)
					BEGIN
						SET @mave = CONCAT('VE0', @tempstr)
						INSERT INTO VE
						VALUES (@mave, @giavethuc, @trangthaive, @trangthaitt, @makh, @maphuongthuctt, @ngaythanhtoan, @thoigiandat, @manvdatve, @vitrighe, @maxe, @machuyendi, @manhanvienthanhtoan)
					END

					IF (@tempnum < 1000 AND @tempnum >= 100)
					BEGIN
						SET @mave = CONCAT('VE', @tempstr)
						INSERT INTO VE
						VALUES (@mave, @giavethuc, @trangthaive, @trangthaitt, @makh, @maphuongthuctt, @ngaythanhtoan, @thoigiandat, @manvdatve, @vitrighe, @maxe, @machuyendi, @manhanvienthanhtoan)
					END

					IF (@tempnum >= 1000)
					BEGIN
						SET @error = N'Lỗi không tạo được mã vé'
						RAISERROR ('Lỗi không tạo được mã vé', 16, 1)
						ROLLBACK TRAN
						RETURN
					END
				END
				ELSE
				BEGIN
					SET @error = N'Lỗi ghế không phải ghế trống'
					RAISERROR ('Lỗi ghế không phải ghế trống', 16, 1)
					ROLLBACK TRAN
					RETURN
				END
			END
			ELSE
			BEGIN
				SET @error = N'Lỗi ghế không thuộc xe'
				RAISERROR ('Lỗi ghế không thuộc xe', 16, 1)
				ROLLBACK TRAN
				RETURN
			END
		END
		ELSE
		BEGIN
			SET @error = N'Lỗi xe không thuộc huyến đi'
			RAISERROR ('Lỗi xe không thuộc huyến đi', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
	END
	ELSE
	BEGIN
		SET @error = N'Lỗi mã khách hàng không tồn tại'
		RAISERROR ('Lỗi mã khách hàng không tồn tại', 16, 1)
		ROLLBACK TRAN
		RETURN
	END

	--Them vào csdl cua KHUYENMAI_VE
	IF (@makm IS NOT NULL)
	BEGIN
		INSERT INTO KHUYENMAI_VE
		VALUES (@makm, @mave)
	END

COMMIT TRAN
GO

DECLARE @error NVARCHAR(100)
EXEC DatVeNV_PT_FIX 'KH005', 'B10', 'XE002', 'PTTT003', 'CD002', 'NV006', 'NV004', @error OUT
PRINT @error
GO
---------------------------------------------------------------------------------------------------------------

--------------------------------------------------Lỗi Dirty Read-------------------------------------------------- 
--Transaction 1: Giao tác 1 để level read committed, để waitfor delay, đặt rollback
DROP PROCEDURE DoiVe_DT_FIX
GO

CREATE PROCEDURE DoiVe_DT_FIX @mave VARCHAR(10), @ghemoi VARCHAR(10), @xemoi VARCHAR(10), @chuyendimoi VARCHAR(10)
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL READ COMMITtED
	--Không tồn tại mã vé hợp lệ
	IF NOT EXISTS(SELECT *
				  FROM VE
				  WHERE MaVe = @mave)
	BEGIN
		RAISERROR (N'Không tồn tại vé có mã nhập vào', 16, 1)
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		--Các biến kiểm tra 
		DECLARE @ghethuocxe INT, @xethuocchuyendi INT, @ghettrong INT
		EXEC XeThuocChuyenDi @xemoi, @chuyendimoi, @xethuocchuyendi OUT
		EXEC GheThuocxe @xemoi ,@ghemoi, @ghethuocxe OUT
		EXEC KiemTraGheTrong @chuyendimoi, @ghemoi, @xemoi, @ghettrong OUT

		--Cập nhật lại ngày đặt cho vé
		DECLARE @thoigiandoi DATETIME
		SET @thoigiandoi = GETDATE()

		--Cập nhật lại vé
		IF (@chuyendimoi IS NOT NULL)
		BEGIN
			IF (@xemoi IS NOT NULL)
			BEGIN
				IF (@ghemoi IS NOT NULL)
				BEGIN
					DECLARE @giave INT, @giavethuc INT, @makm VARCHAR(10), @hinhthuckm NVARCHAR(50), @tylegiamgia INT, @tyle FLOAT
		
					IF EXISTS (SELECT MaKhuyenMai FROM KHUYENMAI WHERE NgayBatDau <= @thoigiandoi and NgayKetThuc >= @thoigiandoi)
					BEGIN
						SET @makm = (SELECT MaKhuyenMai 
										FROM KHUYENMAI 
										WHERE NgayBatDau <= @thoigiandoi and NgayKetThuc >= @thoigiandoi)

						SET @hinhthuckm =  (SELECT HinhThucKhuyenMai
											FROM KHUYENMAI 
											WHERE MaKhuyenMai = @makm)

						SET @tylegiamgia = (SELECT TyLeGiamGia
											FROM KHUYENMAI 
											WHERE MaKhuyenMai = @makm)

						--Kiểm tra loại hình thứckhuyến mãi để tính giá chuyến đi
						IF (@hinhthuckm like N'%Tặng quà%')
						BEGIN
							SET @giavethuc = (SELECT GiaDuKien
												FROM CHUYENDI
												WHERE MaChuyenDi = @chuyendimoi)
						END
						ELSE
						BEGIN
							SET @giave = (SELECT GiaDuKien
										  FROM CHUYENDI
										  WHERE MaChuyenDi = @chuyendimoi)
							SET @tyle = convert(float, @tylegiamgia) / convert(float, 100)
							--Trừ cho phần giảm của khuyến mãi
							SET @giavethuc = @giave * (1 - @tyle)
						END
					END
					ELSE
					BEGIN
						SET @giavethuc = (SELECT GiaDuKien
											FROM CHUYENDI
											WHERE MaChuyenDi = @chuyendimoi)
					END
					
					IF (@xethuocchuyendi = 1)
					BEGIN
						IF (@ghethuocxe = 1)
						BEGIN
							IF (@ghettrong = 1)
							BEGIN
								--Cập nhật lại chuyến đi 
								UPDATE VE SET MaChuyenDi = @chuyendimoi, GiaVeThuc = @giavethuc, MaGhe = @ghemoi, MaXe = @xemoi
								WHERE MaVe = @mave
							END
							ELSE
							BEGIN
								RAISERROR (N'Ghế không phải ghế trống', 16, 1)
								ROLLBACK TRAN
								RETURN
							END
						END
						ELSE
						BEGIN
							RAISERROR (N'Ghế không thuộc xe', 16, 1)
							ROLLBACK TRAN
							RETURN
						END
					END
					ELSE
					BEGIN
						RAISERROR (N'Xe không thuộc chuyến đi', 16, 1)
						ROLLBACK TRAN
						RETURN
					END
				END
				ELSE
				BEGIN
					RAISERROR (N'Phát sinh lỗi trong việc đổi vé', 16, 1)
					ROLLBACK TRAN
					RETURN
				END
			END
			ELSE
			BEGIN
				RAISERROR (N'Phát sinh lỗi trong việc đổi vé', 16, 1)
				ROLLBACK TRAN
				RETURN
			END
		END
		ELSE
		BEGIN
			RAISERROR (N'Phát sinh lỗi trong việc đổi vé', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
		--Cập nhật lại tham chiếu khuyến mãi vé 
		IF (@makm IS NOT NULL)
		BEGIN
			IF EXISTS (SELECT MaKhuyenMai, MaVe FROM KHUYENMAI_VE WHERE MaVe = @mave)
			BEGIN
				UPDATE KHUYENMAI_VE SET MaKhuyenMai = @makm
				WHERE MaVe = @mave
			END
			ELSE
			BEGIn
				INSERT INTO KHUYENMAI_VE
				VALUES (@makm, @mave)
			END 
		END
	END
	--Khối lệnh demo lỗi 
	WAITFOR DELAY '00:00:15'
	ROLLBACK
COMMIT TRAN
GO

EXEC DoiVe_DT_FIX 'VE004', 'B1', 'XE003', 'CD004'
GO

--Transaction 2: Giao tac 2 set level read committed, ko rollback hay wait for delay
CREATE PROCEDURE ThongKeVe_ChuyenDi_DT_FIX
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	IF NOT EXISTS (SELECT * FROM VE)
	BEGIN
		RAISERROR (N'Không tồn tại vé nào trong csdl', 16, 1)
		ROLLBACK TRAN
		RETURN
	END	
	ELSE
	BEGIN
		SELECT v.MaChuyenDi, COUNT(v.MaVe) AS SoLuongVe, sum(v.GiaVeThuc) AS TongDoanhThu
		FROM VE v, CHUYENDI cd
		WHERE v.MaChuyenDi = cd.MaChuyenDi AND v.TrangThaiVe = 1 AND v.TrangThaiThanhToan = 1
		GROUP BY v.MaChuyenDi
	END
COMMIT TRAN
GO

EXEC ThongKeVe_ChuyenDi_DT_FIX
GO

------------------------------------------------------------------------------------------------------------------


--------------------------------------------------Lỗi Unrepeatable Read--------------------------------------------------- 
--Transaction 1: giao tác 1 set level là repeatable read, wait for delay, ko có rollback
DROP PROCEDURE XemVe_UR_FIX
GO

CREATE PROCEDURE XemVe_UR_FIX @mave VARCHAR(10)
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	--Khong tồn tại vé hợp lệ
	IF NOT EXISTS(SELECT *
				  FROM VE
				  WHERE MaVe = @mave)
	BEGIN
		RAISERROR (N'Không tồn tại vé nhập vào', 16, 1)
		ROLLBACK TRAN
		RETURN
	END
	ELSE
	BEGIn
		SELECT * 
		FROM VE
		WHERE MaVe = @mave
	END
	WAITFOR DELAY '00:00:15'

	SELECT * 
	FROM KHACHHANG
	WHERE MaKhachHang IN (SELECT MaKhachHang
							FROM VE
							WHERE MaVe = @mave)

COMMIT TRAN
GO

EXEC XemVe_UR_FIX 'VE005'
GO

--Transaction 2: giao tác 2 set level read committed, ko có rollback và wait for delay 
DROP PROCEDURE HuyVe_UR_FIX
GO

CREATE PROCEDURE HuyVe_UR_FIX @mave VARCHAR(10)
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL READ COMMITtED
	--Khong tồn tại vé hợp lệ
	IF NOT EXISTS(SELECT *
					FROM VE
					WHERE MaVe = @mave)
	BEGIN
		RAISERROR (N'Không tồn tại vé nhập vào', 16, 1)
		ROLLBACK TRAN
		RETURN
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * 
					FROM KHUYENMAI_VE 
					WHERE MaVe = @mave)
		BEGIN
			--Xóa tham chiếu của khuyến mãi cho vé
			DELETE FROM KHUYENMAI_VE 
			WHERE MaVe = @mave

		END
		--Xóa vé ra khỏi csdl	
		DELETE FROM VE
		WHERE MaVe = @mave
	END
COMMIT TRAN
GO

EXEC HuyVe_UR_FIX 'VE005'
GO
--------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------Lỗi Deadlock--------------------------------------------------- 
--Transaction 1: để waitfor delay sau câu lệnh select kiểm tra tồn tại, ko đặt rollback
EXEC DoiVe_DL_FIX 'VE004', 'A2', 'XE003', 'CD004'
GO

--Transaction 2: 
EXEC DoiVe_DL_FIX 'VE004', 'A1', 'XE003', 'CD004'
GO
--select * from VE where MaVe = 'VE004'
--------------------------------------------------------------------------------------------------------------------------


DROP PROCEDURE DoiVe_DL_FIX
GO

CREATE PROCEDURE DoiVe_DL_FIX @mave VARCHAR(10), @ghemoi VARCHAR(10), @xemoi VARCHAR(10), @chuyendimoi VARCHAR(10)
AS
BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	--Không tồn tại mã vé hợp lệ
	IF NOT EXISTS(SELECT *
				  FROM VE 
				  WHERE MaVe = @mave)
	BEGIN
		RAISERROR (N'Không tồn tại vé có mã nhập vào', 16, 1)
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		SELECT *
		FROM VE WITH (XLOCK) 
		WHERE MaVe = @mave

		WAITFOR DELAY '00:00:15'
		--Các biến kiểm tra 
		DECLARE @ghethuocxe INT, @xethuocchuyendi INT, @ghettrong INT
		EXEC XeThuocChuyenDi @xemoi, @chuyendimoi, @xethuocchuyendi OUT
		EXEC GheThuocxe @xemoi ,@ghemoi, @ghethuocxe OUT
		EXEC KiemTraGheTrong @chuyendimoi, @ghemoi, @xemoi, @ghettrong OUT

		--Cập nhật lại ngày đặt cho vé
		DECLARE @thoigiandoi DATETIME
		SET @thoigiandoi = GETDATE()

		--Cập nhật lại vé
		IF (@chuyendimoi IS NOT NULL)
		BEGIN
			IF (@xemoi IS NOT NULL)
			BEGIN
				IF (@ghemoi IS NOT NULL)
				BEGIN
					DECLARE @giave INT, @giavethuc INT, @makm VARCHAR(10), @hinhthuckm NVARCHAR(50), @tylegiamgia INT, @tyle FLOAT
		
					IF EXISTS (SELECT MaKhuyenMai FROM KHUYENMAI WHERE NgayBatDau <= @thoigiandoi and NgayKetThuc >= @thoigiandoi)
					BEGIN
						SET @makm = (SELECT MaKhuyenMai 
										FROM KHUYENMAI 
										WHERE NgayBatDau <= @thoigiandoi and NgayKetThuc >= @thoigiandoi)

						SET @hinhthuckm =  (SELECT HinhThucKhuyenMai
											FROM KHUYENMAI 
											WHERE MaKhuyenMai = @makm)

						SET @tylegiamgia = (SELECT TyLeGiamGia
											FROM KHUYENMAI 
											WHERE MaKhuyenMai = @makm)

						--Kiểm tra loại hình thứckhuyến mãi để tính giá chuyến đi
						IF (@hinhthuckm like N'%Tặng quà%')
						BEGIN
							SET @giavethuc = (SELECT GiaDuKien
												FROM CHUYENDI
												WHERE MaChuyenDi = @chuyendimoi)
						END
						ELSE
						BEGIN
							SET @giave = (SELECT GiaDuKien
										  FROM CHUYENDI
										  WHERE MaChuyenDi = @chuyendimoi)
							SET @tyle = convert(float, @tylegiamgia) / convert(float, 100)
							--Trừ cho phần giảm của khuyến mãi
							SET @giavethuc = @giave * (1 - @tyle)
						END
					END
					ELSE
					BEGIN
						SET @giavethuc = (SELECT GiaDuKien
											FROM CHUYENDI
											WHERE MaChuyenDi = @chuyendimoi)
					END
					
					IF (@xethuocchuyendi = 1)
					BEGIN
						IF (@ghethuocxe = 1)
						BEGIN
							IF (@ghettrong = 1)
							BEGIN
								--Cập nhật lại chuyến đi 
								UPDATE VE SET MaChuyenDi = @chuyendimoi, GiaVeThuc = @giavethuc, MaGhe = @ghemoi, MaXe = @xemoi
								WHERE MaVe = @mave
							END
							ELSE
							BEGIN
								RAISERROR (N'Ghế không phải ghế trống', 16, 1)
								ROLLBACK TRAN
								RETURN
							END
						END
						ELSE
						BEGIN
							RAISERROR (N'Ghế không thuộc xe', 16, 1)
							ROLLBACK TRAN
							RETURN
						END
					END
					ELSE
					BEGIN
						RAISERROR (N'Xe không thuộc chuyến đi', 16, 1)
						ROLLBACK TRAN
						RETURN
					END
				END
				ELSE
				BEGIN
					RAISERROR (N'Phát sinh lỗi trong việc đổi vé', 16, 1)
					ROLLBACK TRAN
					RETURN
				END
			END
			ELSE
			BEGIN
				RAISERROR (N'Phát sinh lỗi trong việc đổi vé', 16, 1)
				ROLLBACK TRAN
				RETURN
			END
		END
		ELSE
		BEGIN
			RAISERROR (N'Phát sinh lỗi trong việc đổi vé', 16, 1)
			ROLLBACK TRAN
			RETURN
		END

		--Cập nhật lại tham chiếu khuyến mãi vé 
		IF (@makm IS NOT NULL)
		BEGIN
			IF EXISTS (SELECT MaKhuyenMai, MaVe FROM KHUYENMAI_VE WHERE MaVe = @mave)
			BEGIN
				UPDATE KHUYENMAI_VE SET MaKhuyenMai = @makm
				WHERE MaVe = @mave
			END
			ELSE
			BEGIn
				INSERT INTO KHUYENMAI_VE
				VALUES (@makm, @mave)
			END 
		END
	END
COMMIT TRAN
GO

SELECT * FROM VE
SELECT * FROM GHE 
SELECT * FROM CHUYENDI
SELECT * FROM KHACHHANG
SELECT * FROM KHUYENMAI_VE 

UPDATE VE SET TrangThaiThanhToan = 1, PhuongThucThanhToan = 'PTTT003', NgayThanhToan = GETDATE(), NhanVienThanhToan = 'NV006'
WHERE MaVe = 'VE002'
GO

UPDATE VE SET TrangThaiThanhToan = 1, TrangThaiVe = 1, PhuongThucThanhToan = 'PTTT003', NgayThanhToan = GETDATE(), NhanVienDatVe = 'NV004', NhanVienThanhToan = 'NV006'
WHERE MaVe = 'VE004'
GO
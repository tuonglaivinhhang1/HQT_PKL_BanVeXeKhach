--Lỗi và cách demo, khắc phục


--=============================DEMO LỖI DIRTY READ -CÁCH KHẮC PHỤC====================
--(KẾT HỢP 2 PROC:THỐNG KÊ LOẠI XE VÀ CẬP NHẬT XE)
--1. chạy procedure update Xe
--có lệnh wait for delay ở CapNhatXe

declare @errorLX nvarchar(500)
exec  CapNhatXe @maxe='XE006',@loaixe=N'Giường Nằm',@error=@errorLX out
print(@errorLX)

select * from XE
--2. mở cửa sổ khác,Chạy lệnh sau đây 
--lỗi: read uncommitted
--khắc phục: read committed

declare @errorLX2 nvarchar(500)
exec  ThongKeTheoLoaiXe @loaixe=N'Giường Nằm',@error=@errorLX2 out
print(@errorLX2)


--=============================DEMO LỖI PHANTOM -CÁCH KHẮC PHỤC====================
--(KẾT HỢP 2 PROC: THONGKELUONG VA THEMNHANVIEN)

--lệnh insert hoặc delete sẽ chờ cho lệnh tính tổng này chạy xong rồi mới insert/delete vào database
--(tức là nó ngăn chặn lệnh insert/delete cho đến khi lệnh thống kê này chạy xong)
--=====================CÁCH DEMO===============
--1. chạy lênh thống kê
--có wait for delay
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED --có lỗi (đang thống kê, cho lệnh insert luôn)
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE --khắc phục lỗi (thống kê xong mới cho lệnh insert chạy)


declare @errorTKL nvarchar(500)
declare @sumLuong int
exec ThongKeLuong_TinhTong @sumLuong out,@errorTKL out

print(@sumLuong)

--2. mở của sổ khác và chạy đồng thời lệnh insert sau đây

declare @error nvarchar(500)
exec ThemNhanVien N'Nguyễn Việt Hùng',N'Nam',N'Hồ Chí Minh','221425091','04-01-1990','0987199100','viethung1990',
'ro3242i3rhoierfhjwekfnrw4ro3wriejfksfnieojofwef33','LNV002',2000000,NULL,0,@error out
print(@error)

--khắc phục lỗi chạy dòng này
--declare @error nvarchar(500)
--exec ThemNhanVien N'Nguyễn Việt Thanh',N'Nam',N'Hồ Chí Minh','221425099','04-01-1990','0903926551','vietthanh1990',
--'ro3242i3rhoierfhjwekfnrw4ro3wriejfksfnieojofwef33','LNV002',2000000,NULL,0,@error out
--print(@error)

--delete from NHANVIEN where MaNhanVien='NV007' --(for test when insert)

--==========DEMO LỖI UNREPEATABLE READ- cách khắc phục==========================

--lúc đầu là 221425270, cđang đọc thì chạy cập nhật thành 221425370 và select bị lỗi
--khắc phục: SET TRANSACTION ISOLATION LEVEL REPEATABLE READ trong hàm XemNhanVienv2_DemoUnrepeatableRead
--1. Chạy lệnh xem nhân viên theo cmnd
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- demo loi
--có wait for delay
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- khắc phục lỗi
		

declare @errorUnrepeatableRead nvarchar(500)
exec XemNhanVienv2_DemoUnrepeatableRead '221425270',@error=@errorUnrepeatableRead out
print(@errorUnrepeatableRead)

select * from NHANVIEN
--2. cửa sổ 2 chạy lệnh update nhân viên 
declare @errorCNNVUnrepeatableRead nvarchar(500)
exec CapNhatNhanVienV2_DemoUnrepeatableRead @maNhanVien='NV001',@soCMND='221425370',@error=@errorCNNVUnrepeatableRead out
print(@errorCNNVUnrepeatableRead)

----khôi phục lại 221425270 để chạy lần 2
--declare @errorCNNVUnrepeatableReadkp nvarchar(500)
--exec CapNhatNhanVienV2_DemoUnrepeatableRead @maNhanVien='NV001',@soCMND='221425270',@error=@errorCNNVUnrepeatableReadkp out



--==============DEMO LOST UPDATE=====================
--tình huống tăng lương nhân viên:
--quy định tăng lương tài xế: 
--1. QĐ1: Không gay tai nan nao trong 3 thang: tang 1 trieu
--2. QĐ2: Khong nghỉ ngày nào : tăng 500k 
--Tăng lương do bộ phận quản lý tăng. (2 nhân viên quản lý)

--1. nhân viên 1 chạy tăng lương theo QĐ1
--WAITFOR DELAY '00:00:15.000';
--khắc phục lỗi
--set Luong=Luong+@luongtangthem

declare @errorlostupdate nvarchar(500)
exec TangLuong1 @manhanvien='NV002',@luongtangthem=1000000,@error=@errorlostupdate out
print(@errorlostupdate)


--2. nhân viên 2 chạy tăng lương theo QĐ2

declare @errorlostupdate2 nvarchar(500)
exec TangLuong1 @manhanvien='NV002',@luongtangthem=500000,@error=@errorlostupdate2 out
print(@errorlostupdate2)

select * from NHANVIEN

--======================DEMO DEALOCK lỗi========================
--1 cửa sổ 1
declare @errorDL nvarchar(500)
exec CapNhatNhanViendDEADLOCKDML @maNhanVien='NV006',@soCMND='221441156',@error=@errorDL out
print(@errorDL)


--2 cửa sổ 2
declare @errorDL2 nvarchar(500)
exec CapNhatNhanViendDEADLOCKDML @maNhanVien='NV006',@soCMND='221441157',@error=@errorDL2 out
print(@errorDL2)


----RETURN GIÁ TRỊ SAU B1
declare @errorDL2 nvarchar(500)
exec CapNhatNhanVien @maNhanVien='NV006',@soCMND='221441155',@error=@errorDL2 out
print(@errorDL2)

--======================DEMO DEALOCK sửa lỗi========================
--1 cửa sổ 1
declare @errorDL nvarchar(500)
exec CapNhatNhanViendDEADLOCKSL @maNhanVien='NV006',@soCMND='221441156',@error=@errorDL out
print(@errorDL)


--2 cửa sổ 2
declare @errorDL2 nvarchar(500)
exec CapNhatNhanViendDEADLOCKSL @maNhanVien='NV006',@soCMND='221441157',@error=@errorDL2 out
print(@errorDL2)



SELECT * FROM NHANVIEN
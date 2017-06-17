use PHUONGTRANG

----------------------------------------------------------------------------------------------------
-------------------------------------------DIRTY READ-----------------------------------------------
----------------------------------------------------------------------------------------------------
--Cập nhật chuyến đi trở lại trạng thái ban đầu
declare @error nvarchar(100)
exec capNhatChuyenDi 'CD001', 'TD001', '2017-06-06', '2017-06-07', 'XE001', 500, @error 
print @error

--Cập nhật chuyến đi
declare @error nvarchar(100)
exec capNhatChuyenDiRollback 'CD001', 'TD001', '2017-06-17', '2017-06-18', 'XE001', 500, @error 
print @error

----------------------------------------------------------------------------------------------------
-------------------------------------------UNREPEATABLE READ----------------------------------------
----------------------------------------------------------------------------------------------------
--cập nhật lại
declare @error nvarchar(100)
exec capNhatTuyenDuong 'TD001', N'TP Hồ Chí Minh', N'Phú Yên', N'Bến Xe Miền Đông', N'Bến Xe Phú Lâm', 500, @error out
print @error

--cập nhật tuyến đường
declare @error nvarchar(100)
exec capNhatTuyenDuong 'TD001', N'Đã bị thay đổi', N'Phú Yên', N'Bến Xe Miền Đông', N'Bến Xe Phú Lâm', 500, @error out
print @error

--thêm tuyến đường
declare @error nvarchar(100)
exec themTuyenDuong N'TP Hồ Chí Minh', N'Phú Yên', N'Bến Xe Miền Đông', N'Bến Xe Phú Lâm', 500, @error out
print @error

--xóa tuyến đường
declare @error nvarchar(100)
exec xoaTuyenDuong 'TD006', @error out
print @error

----------------------------------------------------------------------------------------------------
-------------------------------------------PHANTOM--------------------------------------------------
----------------------------------------------------------------------------------------------------

--cập nhật lại trạng thái vé
update VE
set TrangThaiThanhToan = 0
where MaVe = 'VE002'

--thanh toán vé của nhân viên
declare @error nvarchar(100)
exec thanhToanVeNhanVien 'VE002', 'PTTT002', 'NV006', 200000, @error out
print @error

--Xóa vé đã thanh toán
delete from PHUONGTRANG.dbo.VE where MaVe = 'VE003'

--Thêm vé lại
insert into VE (MaVe, GiaVeThuc, TrangThaiVe, TrangThaiThanhToan, MaKhachHang, PhuongThucThanhToan, NgayThanhToan, NgayDatVe, NhanVienDatVe, MaGhe, MaXe, MaChuyenDi, NhanVienThanhToan)
values ('VE003', 200000, 1, 1, 'KH003', 'PTTT002', '2017-06-10 00:00:00.000', '2017-06-06 00:00:00.000', 'NV004', 'B1', 'XE002', 'CD001', 'NV006')

select * from VE

----------------------------------------------------------------------------------------------------
--------------------------------------LOST UPDATE - DEADLOCK----------------------------------------
----------------------------------------------------------------------------------------------------
select * from VE where MaVe = 'VE002'
--cập nhật lại trạng thái vé
update VE
set TrangThaiThanhToan = 0
where MaVe = 'VE002'

--thanh toán vé của nhân viên
declare @error nvarchar(100)
exec thanhToanVeNhanVienWaitforDelay 'VE002', 'PTTT002', 'NV006', 200000, @error out
print @error

--thanh toán vé của nhân viên -- gây ra lỗi deadlock
declare @error nvarchar(100)
exec thanhToanVeNhanVienWaitforDelayRepeatableRead 'VE002', 'PTTT002', 'NV006', 200000, @error out
print @error

--thanh toán vé của nhân viên
declare @error nvarchar(100)
exec thanhToanVeNhanVienWaitforDelayXLock 'VE002', 'PTTT002', 'NV006', 200000, @error out
print @error
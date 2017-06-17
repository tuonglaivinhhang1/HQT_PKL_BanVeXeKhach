use PHUONGTRANG


----------------------------------------------------------------------------------------------------
-------------------------------------------DIRTY READ-----------------------------------------------
----------------------------------------------------------------------------------------------------

--Xem chuyến đi chưa xuất
exec xemChuyenDiChuaXuatPhatReadUncommitted

--Xem chuyến đi chưa xuất phát
exec xemChuyenDiChuaXuatPhatReadCommitted

----------------------------------------------------------------------------------------------------
-------------------------------------------UNREPEATABLE READ----------------------------------------
----------------------------------------------------------------------------------------------------

--Xem tuyến đường
exec xemTuyenDuong

--Xem tuyến đường isolation
exec xemTuyenDuongRepeatableRead

----------------------------------------------------------------------------------------------------
-------------------------------------------PHANTOM--------------------------------------------------
----------------------------------------------------------------------------------------------------

--Thống kê doanh thu
declare @error nvarchar(100)
declare @TongDoanhThu int
exec thongKeDoanhThuTheoThoiGian '2000-01-01', null, @error out, @TongDoanhThu out
print @TongDoanhThu

--Thống kê doanh thu có isolation
declare @error nvarchar(100)
declare @TongDoanhThu int
exec thongKeDoanhThuTheoThoiGianSerializable null, null, @error out, @TongDoanhThu out
print @TongDoanhThu

----------------------------------------------------------------------------------------------------
--------------------------------------LOST UPDATE - DEADLOCK----------------------------------------
----------------------------------------------------------------------------------------------------
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
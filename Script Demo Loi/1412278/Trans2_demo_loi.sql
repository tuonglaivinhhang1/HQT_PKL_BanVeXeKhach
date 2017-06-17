
-----------------------------------DeadLock-------------------------------------------
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_DL 'TK003',100,@error,@kq



--------------------------------------PhanTom-------------------------------------------
Delete TAIKHOAN where MaTaiKhoan = 'TK009'

declare @errordemo varchar(50)
exec ThemTaiKhoan 2000, N'Thành Viên',100,'lamphan_01','conbuombuom','KH001',@errordemo out

--------------------------------------LOST UPDATE----------------------------------------
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_LU 'TK002',100,@error,@kq
-----------------------------------------Dirty READ---------------------------------------
declare @tongcong int
declare @error varchar(50)
exec thongketaikhoantheoloai N'VIP', @error out, @tongcong out
---------------------------------------Unrepeatable READ------------------------------------
declare @error2 varchar(50)
exec capnhatKH @makh = 'KH002',@ten = N'Lai Như Ngọc',@error = @error2 out

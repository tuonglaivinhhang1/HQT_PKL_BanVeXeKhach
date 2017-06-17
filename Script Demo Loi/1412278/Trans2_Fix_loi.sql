
--------------------------------demo PhanTom---------------------------------- 
Delete TAIKHOAN where MaTaiKhoan = 'TK009'

declare @errordemo varchar(50)
 exec ThemTaiKhoan 2400, N'Thành Viên',100,'lamphan_88','conbuombuom','KH001',@errordemo out
 -------------------------------Lost UpDate-----------------------------------
 declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_FIX_LU 'TK003',100,@error,@kq
--------------------------------DeadLock---------------------------------------
declare @error varchar(50)
declare @kq int
exec CapNhatDiemTL_FIX_DL 'TK003',100,@error,@kq
---------------------------------Dirty Read--------------------------------------
declare @error varchar(50)
declare @tongcong int
exec thongketaikhoantheoloai N'VIP', @error out,@tongcong out
-----[SoTien]----------------------------Unrepeatable READ-------------------------------
declare @error2 varchar(50)
exec capnhatKH @makh = 'KH002',@ten = N'Gia  Ngọc',@error = @error2 out
select * from KHACHHANG
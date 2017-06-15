
module.exports={
	
	setSelectedcategory:function(valueSelected)
	{
				if(valueSelected==undefined)
				{
					return "";
				}
				if(valueSelected.message.toLowerCase()=="tài xế")
				{
					return '<option value="tx" selected>Tài Xế</option> <option value="dv">Nhân Viên Đặt Vé</option> <option value="ql" >Nhân Viên Quản Lý</option> <option value="tt" >Nhân Viên Thanh Toán</option>';
				}
				if(valueSelected.message.toLowerCase()=="nhân viên quản lý")
				{
					return '<option value="tx" >Tài Xế</option> <option value="dv">Nhân Viên Đặt Vé</option> <option value="ql" selected>Nhân Viên Quản Lý</option> <option value="tt" >Nhân Viên Thanh Toán</option>';
				}
				if(valueSelected.message.toLowerCase()=="nhân viên đặt vé")
				{
					return '<option value="tx" >Tài Xế</option> <option value="dv" selected>Nhân Viên Đặt Vé</option> <option value="ql" >Nhân Viên Quản Lý</option> <option value="tt" >Nhân Viên Thanh Toán</option>';
				}
				if(valueSelected.message.toLowerCase()=="nhân viên thanh toán")
				{
					return '<option value="tx" >Tài Xế</option> <option value="dv">Nhân Viên Đặt Vé</option> <option value="ql" >Nhân Viên Quản Lý</option> <option value="tt" selected >Nhân Viên Thanh Toán</option>';
				}

				return "";
	},
	selectedLoaiTaiKhoan:function(valueSelected)
	{
		

				if(valueSelected==undefined)
				{
					return "";
				}
				if(valueSelected.message.toLowerCase()=="vip")
				{
					return '<option value="vip" selected>VIP</option> <option value="khtt">Khách Hàng Thân Thiết</option> <option value="tv" >Thành Viên</option>';
				}
				if(valueSelected.message.toLowerCase()=="khách hàng thân thiết")
				{
					return '<option value="vip" >VIP</option> <option value="khtt" selected>Khách Hàng Thân Thiết</option> <option value="tv" >Thành Viên</option>';
				}
				if(valueSelected.message.toLowerCase()=="thành viên")
				{

					return '<option value="vip" >VIP</option> <option value="khtt">Khách Hàng Thân Thiết</option> <option value="tv" selected >Thành Viên</option>';
				}
				

				return "";
	},
};

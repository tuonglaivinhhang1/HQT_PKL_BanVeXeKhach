
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
	}
};

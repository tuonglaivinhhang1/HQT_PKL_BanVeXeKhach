
module.exports={
	setSelected:function(valueSelected)//message là tham số helpers gọi, ở đây là detailMessage
			{
				

				if(valueSelected==undefined)
				{
					return "";
				}
				if(valueSelected.message2.toLowerCase()=="còn hàng")
				{
					return '<option value="CH" selected>Còn Hàng</option> <option value="SCH">Sắp Có Hàng</option> <option value="NKD">Ngừng Kinh Doanh</option>';
				}
				if(valueSelected.message2.toLowerCase()=="sắp có hàng")
				{
					return '<option value="CH">Còn Hàng</option> <option value="SCH" selected>Sắp Có Hàng</option> <option value="NKD">Ngừng Kinh Doanh</option>';
				}
				if(valueSelected.message2.toLowerCase()=="ngừng kinh doanh")
				{
					return '<option value="CH">Còn Hàng</option> <option value="SCH" >Sắp Có Hàng</option> <option  value="NKD" selected>Ngừng Kinh Doanh</option>';
				}

				return "";
			},

	setSelectedcategory:function(valueSelected)
	{
				if(valueSelected==undefined)
				{
					return "";
				}
				if(valueSelected.message.toLowerCase()=="laptop")
				{
					return '<option value="Mo">Mobile</option> <option value="Ka">Karaoke</option> <option value="La" selected>Laptop</option>';
				}
				if(valueSelected.message.toLowerCase()=="mobile")
				{
					return '<option value="Mo" selected>Mobile</option> <option value="Ka">Karaoke</option> <option value="La" >Laptop</option>';
				}
				if(valueSelected.message.toLowerCase()=="karaoke")
				{
					return '<option value="Mo" >Mobile</option> <option value="Ka" selected>Karaoke</option> <option value="La" >Laptop</option>';
				}

				return "";
	}
};

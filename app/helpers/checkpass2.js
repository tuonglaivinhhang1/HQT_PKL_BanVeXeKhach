


function checkpass(pass)
{
	var strongRegex = new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,})");
	if(!strongRegex.test(pass))
	{
		return false;
	}
	else{
		return true;
	}
	
}
module.exports={checkpass};
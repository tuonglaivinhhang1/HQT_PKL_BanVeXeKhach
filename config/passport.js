var passport=require('passport');
var LocalStrategy = require('passport-local').Strategy;

var User=require('../app/models/nhanvien');

var authHelpers = require('../app/helpers/checkpass');
var checkEmail= require('../app/helpers/checkemail');
var checkpassreg= require('../app/helpers/checkpass2');
var bcrypt = require('bcryptjs');






passport.serializeUser(function(user, done) {
	//hàm được gọi khi đã xác thực thành công và lưu user vào session 
	
    done(null, user.recordset[0].TenDangNhapNV);
  });

passport.deserializeUser(function(username, done) {
   //lấy dữ liệu user từ db và đưa vào session
   User.getoneNV(username,function(err,user)
   {
   		
   		if(err)
   		{
   			done(err,null);
   		}

   		else{
   			done(null,user.recordset[0]);
   		}
   		

   });
});

// //kịch bản signup

// passport.use('local.signup',new LocalStrategy({
// 	usernameField:'username',
// 	passwordField:'password',
// 	passReqToCallback: true,
	
   
// }, function(req,username, password, done) {

//   	var result_checkemail;

// 	checkEmail.Checkemail(req.body.email,function(getResult)
// 	{
// 		result_checkemail=getResult;
// 	});
//   // check to see if the username exists
//   User.getUser(username,function(err,user)
//   {
//     if(err)
//     {
    	
//       return done(err);
//     }
//     if(user[0])//đã có thằng user với username này (username đã đc đăng ký)
//   	{
  		
// 		req.flash('singuperr1','Username đã tồn tại. Vui lòng chọn username khác!');
	      
// 	     return done(null,false);      
	  
//   	}
//   	else if(result_checkemail==0)// email đã tồn tại
//   	{
  		
//   		req.flash('singuperr2','Email đã tồn tại');
	   
// 	     return done(null,false);    
//   	}
//   else if(!checkpassreg.checkpass(req.body.password))
//   	{
  	
//   		req.flash('singuperr3','Password phải lớn hơn 8 ký tự và phải bao gồm: chữ hoa, chữ thường, số, ký tự đặc biệt');
	   
// 	     return done(null,false);    
//   	}

//     else
//     {
      
//       	var salt = bcrypt.genSaltSync();
// 	 	var hash = bcrypt.hashSync(req.body.password, salt);

//        	var Newuser=[
//        		{firstname:req.body.firstname,
// 			lastname:req.body.lastname,
// 			email:req.body.email,
// 			username:req.body.username,
// 			password:hash}
//        	];  	

//       	User.insert(Newuser,function(err){

//       		if(err)
//       		{
//       			return done(err);

//       		}
//       		else{

//       			return done(null,Newuser);
//       		}
      		
//       	});
//     }
   
//   });

// }));


//kịch bản login

passport.use('local.login',new LocalStrategy({
	usernameField:'username',
	passwordField:'password',
	passReqToCallback: true,
	
}, function(req,username, password, done) {//tự động lấy req.body.password và req.body.username

  User.getoneNV(username,function(err,user)//get user với username đó
  {
  	
    if(err)
    {
      return done(err);
    }
    if(!user.recordset[0])//không có thằng user với username này (username không tồn tại)
  	{
      

    //console.log(JSON.stringify(user));

  		// console.log('Username hoặc mật khẩu không chính xác. Vui lòng thử lại!');

	    req.flash('logginerr','Username hoặc mật khẩu không chính xác. Vui lòng thử lại!');
	   
	     return done(null,false);      
	  
  	}

    else
    {
     
    // // console.log(user);
    //  console.log(password);
    //  console.log(user.recordset[0].MatKhauNV);
        if (!authHelpers.comparePass(password, user.recordset[0].MatKhauNV))//1 cái nhập vào ,1 cai trong db
        {
        req.flash('logginerr','Username hoặc mật khẩu không chính xác. Vui lòng thử lại!');
          return done(null, false);
        } 
        else
        {

          return done(null, user);
        }

    }
   
  });

}));





module.exports = passport;
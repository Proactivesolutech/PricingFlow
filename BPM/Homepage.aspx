<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Homepage.aspx.cs" Inherits="SHFL.BPM.Homepage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
        <script src="../COMMON/js/jquery.min.js"></script>
        <script src="../COMMON/js/Scrn/CommonFns.js"></script>


</head>
    <style>
body {font-family: Arial, Helvetica, sans-serif;}
form {border: 3px solid #f1f1f1;}

input[type=text], input[type=password] {
  width: 100%;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  box-sizing: border-box;
}

button {
  background-color: #04AA6D;
  color: white;
  padding: 14px 20px;
  margin: 8px 0;
  border: none;
  cursor: pointer;
  width: 100%;
}

button:hover {
  opacity: 0.8;
}

.cancelbtn {
  width: auto;
  padding: 10px 18px;
  background-color: #f44336;
}

.imgcontainer {
  text-align: center;
  margin: 24px 0 12px 0;
}

img.avatar {
  width: 40%;
  border-radius: 50%;
}

.container {
  padding: 16px;
}

span.psw {
  float: right;
  padding-top: 16px;
}

/* Change styles for span and cancel button on extra small screens */
@media screen and (max-width: 300px) {
  span.psw {
     display: block;
     float: none;
  }
  .cancelbtn {
     width: 100%;
  }
}
</style>
<body>


<%--<form  method="post" style="width:320px;margin-left:36%;margin-top:11%">--%>


  <div class="container" style="width:320px;margin-left:36%;margin-top:11%;border:1px solid">
                <h2 style="text-align:center">Login</h2>

    <label for="uname"><b>Username</b></label>
    <input type="text" placeholder="Enter Username" name="uname" id="username"  required />

    <label for="psw"><b>Password</b></label>
    <input type="password" placeholder="Enter Password" name="psw" id="password" required />
        
    <button type="submit" id="submit">Login</button>
      </div>
   
<%--</form>--%>
<%-- <div id="Homepage" style="height: 101%; width: 98%; position: absolute; top: -1%; padding-left: 2%;" class='bg-overlay'>
        <div>
            <div class="login-block">
                <h1>Login</h1>
                <!--<div class="imgSize"><img style="width: 111px; margin-top: -11px;" src="images/user.png" /></div>-->
                <div class="circle-mask" style="">
                    <canvas id="canvas" class="circle" width="96" height="96"></canvas>
                </div>
                <input type="text" data-tabname="TABLE-1" data-colname="USERNAME" data-validate="true" value="" placeholder="Username" id="username" />
                <input type="password" data-tabname="TABLE-1" data-colname="PASSWORD" data-validate="true" value="" placeholder="Password" id="password" />
                <button type="button" id="submit">Submit</button>
                 <input type="hidden"id="Hdn_UsrId" />
            </div>
        </div>
        <!-- <div style="color: navy;margin-left: 45%;margin-top: 2%;">
            <span title="New User"  style="cursor:pointer;" onclick="NewUser();"><strong>New User ?</strong></span>
        </div>-->
        <div style="margin-top: 105px; margin-left: 13px; display: none; color: floralwhite;">
            <!--<p>ProActive Solutech India (P) Ltd</p>
            <p style="font-size: 11px;">www.proactivesolutech.com</p>-->
        </div>
         <!-- Error Popup Div Starts-->
    <div class="error-div" style="display:none;">
        <div class="error-content">
            <i id="AlertIcon"></i>
            <p id="error_msg"></p>
            <input type="button" id="btn_Ok" value="OK"/>
            <input type="button" id="btn_Cancel" value="CANCEL"/>
        </div>
    </div>
    <!-- Error Popup Div Ends-->
    </div>--%>
    <script>
        debugger
        $('#submit').click(function () {
            debugger
            if ($('#username').val() == 'sa' && $('#password').val() == '123') {
                sessionStorage.user = $('#username').val() ;
                parent.location.href = "home.html"

            }
            else {
                alert("Invalid User")
                window.location = "Homepage.aspx"
                return
            }

        });
    </script>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomePage.aspx.cs" Inherits="SHFL.HomePage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>

    <div id="Homepage" style="height: 101%; width: 98%; position: absolute; top: -1%; padding-left: 2%;" class='bg-overlay'>
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
    </div>
    <script>
        debugger
        $('#submit').click(function () {
            if ($('#username').val() == 'sa' && $('#password').val() == '123') {
                window.location = "Home.html"

            }
             
            }
    </script>
</body>
    
</html>

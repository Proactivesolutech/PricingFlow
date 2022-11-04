var DeDupeXml = [{}];



$(document).ready(function () {
    DeDupeXml = [{}];
    DeDupeXml[0].LeadPk = GlobalXml[0].FwdDataPk;
    DeDupeXml[0].GeoFk = GlobalXml[0].BrnchFk;
    DeDupeXml[0].UsrPk = GlobalXml[0].UsrPk;
    DeDupeXml[0].UsrDispNm = GlobalXml[0].UsrNm;    
    DeDupeXml[0].PrdCd = GlobalXml[0].PrdCd;
    DeDupeXml[0].AgtFk = GlobalXml[0].AgtFk;
    DeDupeXml[0].AppNo = GlobalXml[0].AppNo;
    fnDedupe();     
});
function fnDedupe() {
    var objProcData = { ProcedureName: "PrcShflCusDedupe", Type: "SP", Parameters: ["SELECT_LEAD_DATA", JSON.stringify(DeDupeXml)] }
    fnCallLOSWebService("LoadDetails", objProcData, fnDedupeResult, "MULTI", "");
}
function fnDedupeResult(ServDesc, Obj, Param1, Param2) {

    if (!Obj.status) {
        fnShflAlert("error", Obj.error);
        return;
    }
    if (ServDesc == "LoadDetails") {

        var data = JSON.parse(Obj.result_1);
        var RuleData = JSON.parse(Obj.result_2);
        var cusStg = '';
        console.log(RuleData);
        $(".content-div.dedupe-div div.box-div.match-div").remove();
        $(".content-div.dedupe-div div.box-div").remove();

        if (data != null) {
            window.dedupeData = [];
            for (var i = 0; i < data.length; i++) {
                dedupeData[i] = { pk: data[i].qdeFk, data: "" };
                var Found = $(RuleData).filter(function () {
                    return this.QdeFk == data[i].qdeFk;
                });
                cusStg = data[i].cusfk > 0 ? "Customer Assigned" : "Create Customer";
                console.log(Found);
                var htmlApp = $('<div CusPk ="' + data[i].cusfk + '" pk="' + data[i].qdeFk + '"class="box-div verification-list1 dedupe-score">' +
                                    '<ul class="form-controls div-left">' +
                                    '<li class="read-only width-19">' +
                                    '<p>' + data[i].Leadid + '</p>' +

                                      '<p>' + data[i].qdeactornm + '</p>' +
                                   '</li>' +
                                    '<li class="read-only width-19">' +
                                     '<label>First Name</label>' +
                                     '<p name="applNm">' + data[i].qdeFstNm + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Middle Name</label>' +
                                     '<p>' + data[i].qdeMidNm + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Last Name</label>' +
                                     '<p>' + data[i].qdeLstNm + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>DOB</label>' +
                                     '<p>' + data[i].qdeDob + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Gender</label>' +
                                     '<p>' + data[i].qdeGender + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Mobile</label>' +
                                     '<p>' + data[i].qdemob + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>FatherName</label>' +
                                     '<p>' + data[i].FatherName + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>PINCODE</label>' +
                                     '<p>' + data[i].qdePin + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>PAN</label>' +
                                     '<p>' + data[i].qdepan + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Driving License</label>' +
                                     '<p>' + data[i].qdedrvlic + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Voter ID</label>' +
                                     '<p>' + data[i].qdeVotId + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Aadhar</label>' +
                                     '<p>' + data[i].qdeAdhar + '</p>' +
                                   '</li>' +
         
                     '</ul>' +
                     ' <div class="div-right">' +
                     '<div class="dedupe-box match_found status">' +
                     '<p>Match</p>' +
                     '<p class="bg bg1"><i class="icon-positive status"></i></>' +
                     '<p>Found(' + Found.length + ')</p>' +
                     '</div>' +
                     '<div class="dedupe-box create-div" onclick="fncreateCustomer(this);">' +
                     '<div class="status">' +
                     '<p class="bg bg6" val="">' + cusStg + '</p>' +
                     '</div>' +
                     '</div>' +
                     /*'<div class="dedupe-box wild">' +
                     '<div class="status">' +
                     '<p class="bg bg6">Wild Search</p>' +
                     '</div>' +
                     '</div>' +*/
                     '</div>' +
             '<div class="clear"></div>' +
          '</div>'
        );

                $(".content-div.dedupe-div").append(htmlApp);
                if (Found.length == 0) {
                    $(".box-div.verification-list1.dedupe-score.dedupe-score[pk='" + data[i].qdeFk + "']").find(".dedupe-box.match_found.status p.bg").attr("class", "bg bg2");
                    $(".box-div.verification-list1.dedupe-score.dedupe-score[pk='" + data[i].qdeFk + "']").find(".dedupe-box.match_found.status i").attr("class", "icon-negative");
                }

            }

        }
        var RuleData = JSON.parse(Obj.result_2);
        $(".box-div.verification-list1.dedupe-score div.dedupe-box.match_found").click(function (e) {
            window.QdePk = $(this).closest(".dedupe-score").attr("pk");

            var dedupeDataObj = $(dedupeData).filter(function () {
                return this.pk == QdePk;
            });
            var index = 0;
            if (dedupeDataObj && dedupeDataObj.length > 0) {
                index = dedupeData.indexOf(dedupeDataObj[0]);
            }
            if (dedupeData[index].data == "") {
                //var dedupeObj = json_dedupeMatch;
                var Obj = [];
                $(RuleData).each(function () {
                    if (this.QdeFk == QdePk)
                        Obj.push(this);
                });
                var objProcData = { ProcedureName: "PrcShflCusDedupe", Type: "SP", Parameters: ["INSERT_MATCH", "", "", "", "", JSON.stringify(Obj)] };
                fnCallLOSWebService("MATCH", objProcData, fnDedupeResult, "MULTI", "");
            }
            else {
                var disp = $(".dedupe-score-content.dedupe-score-content1").css("display") || "";
                disp = disp.toLowerCase();
                $(".dedupe-score-content.dedupe-score-content1").remove();

                $(".box-div.verification-list1.dedupe-score[pk='" + QdePk + "']").after(dedupeDataObj[0].data);
                var disp1 = $(".dedupe-score-content.dedupe-score-content1").css("display") || "";
                if (disp.indexOf("block") >= 0 && disp1.indexOf("block") >= 0) {
                    $(".dedupe-score-content.dedupe-score-content1").hide();
                }
                else {
                    $(".dedupe-score-content.dedupe-score-content1").show();
                }
            }
        });

    }
    if (ServDesc == "MATCH") {
        debugger;
        var Matdata = JSON.parse(Obj.result);
        var value = $(".box-div.match-div").attr("pk");
        var togglediv = '';
        $(".dedupe-score-content.dedupe-score-content1").remove();
        var maindiv = $('  <div class="dedupe-score-content dedupe-score-content1">' +
                            '</div>');
        var Operator = ''
        if (Matdata != null) {
            for (var i = 0; i < Matdata.length; i++) {
                Operator = Matdata[i].Operator == "LIKE" ? "Ambiguous Match" : "Exact Match";
                togglediv = $('<div  cusfk="' + Matdata[i].CusFk + '" class="match-div-content">' +
                                 '<div class="box-div">' +
                                 '<h2>RULE : ' + Matdata[i].RuleName +'<span class="bg bg1">' + Operator + '</span>'+ '</h2>' +                                  
                                 '<ul class="form-controls div-left">' +
                                   '<li class="category-icons width-9">' +
                                     '<label><i class="icon-home-loan"></i></label>' +
                                     '<p>Home Loan</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>First Name</label>' +
                                     '<p key = "fstNm">' + Matdata[i].FirstName + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Middle Name</label>' +
                                     '<p key = "midNm">' + Matdata[i].MiddleName + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Last Name</label>' +
                                     '<p key = "lstNm">' + Matdata[i].LastName + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>DOB</label>' +
                                     '<p key = "dob">' + Matdata[i].DOB + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Gender</label>' +
                                     '<p key = "gender">' + Matdata[i].Gender + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Mobile</label>' +
                                     '<p key = "mobno">' + Matdata[i].MobileNo + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>FatherName</label>' +
                                     '<p key = "FfstNm">' + Matdata[i].FatherName + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>PINCODE</label>' +
                                     '<p key = "FmdNm">' + Matdata[i].Pincode + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>PAN</label>' +
                                     '<p key = "FlstNm">' + Matdata[i].PAN + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Driving License</label>' +
                                     '<p key = "drvlic">' + Matdata[i].DrvLic + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Voter ID</label>' +
                                     '<p key = "votid">' + Matdata[i].VoterId + '</p>' +
                                   '</li>' +
                                   '<li class="read-only width-19">' +
                                     '<label>Aadhar</label>' +
                                     '<p key = "aadharno">' + Matdata[i].AadharNo + '</p>' +
                                   '</li>' +
                                 '</ul>' +
                                 '<div class="div-right">' +
                                   /*'<div class="dedupe-box">' +
                                     '<p>&nbsp</p>' +
                                   '<div class="status">' +
                                       '<p class="bg bg2">780</p>' +
                                     '</div>' +
                                     '<p>Score</p>' +
                                   '</div>' +*/
                                   '<div class="dedupe-box">' +
                                     '<div class="status">' +
                                       '<p class="bg bg6" onclick = "fnchooseCustomer(this);">Choose</p>' +
                                     '</div>' +
                                   '</div>' +
                                 '</div>' +
                                 '<div class="clear"></div>' +
                               '</div>');

                $(maindiv).append(togglediv);


            }
            $(".box-div.verification-list1.dedupe-score[pk=" + QdePk + "]").after(maindiv);
            var dedupeDataObj = $(dedupeData).filter(function () {
                return this.pk == QdePk;
            });
            if (dedupeDataObj && dedupeDataObj.length > 0) {
                var index = dedupeData.indexOf(dedupeDataObj[0]);
                dedupeData[index].data = maindiv;
            }

            $(".dedupe-score-content.dedupe-score-content1").show();
        }
    }
    if (ServDesc == "CusCreate") {
        debugger;    
        fnDedupe();
        console.log("created");
    }

    if (ServDesc == 'updatefk') {

        fnDedupe();
    }
}
    function fncreateCustomer(elem) {
        debugger;
    var pk = $(elem).closest(".dedupe-score").attr("pk");
    var cuspk = $(elem).closest(".dedupe-score").attr("cuspk");
    if (cuspk > 0) {
        return false;
        alert("customer already created");       
    }
    else if (cuspk == "null" || cuspk == "undefined" || cuspk == 0)
    {
        var ClassNm = $(".box-div.verification-list1.dedupe-score.dedupe-score[pk='" + pk + "']").find(".dedupe-box.match_found i").attr("class");
        var objProcData = { ProcedureName: "PrcShflCusDedupe", Type: "SP", Parameters: ["CREATE_CUSDATA", JSON.stringify(DeDupeXml), "", "", "", "", pk, ""] }
        fnCallLOSWebService("CusCreate", objProcData, fnDedupeResult, "MULTI", "");
    }
   
}
         

function fnchooseCustomer(elem)
{
    debugger;
    //window.maindiv = $(elem).parent("div .box-div.verification-list1.dedupe-score").attr("CusPk");
    window. whichDiv = $(elem).closest("div.dedupe-score-content").prev("div.box-div.verification-list1.dedupe-score")
    cusFk = $(whichDiv).attr("CusPk")
    window.matfk = $(elem).closest(".match-div-content").attr("cusfk");
    var errmsg = "";
    $(".box-div.verification-list1.dedupe-score").each(function () {
        debugger;       
        if ($(this).attr("cuspk") == matfk && $(this).attr("cuspk") != "null")
        {          
            errmsg = "Customer Already Choosed. Choose Different Customer";            
        }
    });    
    if (errmsg!=""){
        fnShflAlert("error", errmsg);
        return;
    }

    else{
    if (cusFk == matfk) {
        alert("Same Customer already choosed")
    }
    else if(cusFk == "null")
    {
        fnUpdateCusFk();        
    }

    else if(cusFk != matfk || cusFk != "null")
    {
        var confirmSts = confirm("Customer Already Exist Do You Want To Proceed??");
        if (confirmSts == true) {
            fnUpdateCusFk();
        }           

    }  
 }


}
function fnCallScrnFn(FinalConfirm) {
    
    IsFinalConfirm = FinalConfirm;
    fndedupeconfirm();
  
}
function fndedupeconfirm()
{
    
    var errorMsg = ''
  
    $(".content-div.dedupe-div").find(".box-div.verification-list1.dedupe-score").each(function () {
        var applNm = $(this).find("[name='applNm']");
        var applName = $(applNm).text();
        if ($(this).attr("CusPk") == "null") {
            errorMsg += "Either Create or Choose Customer for " + applName + " <br/> ";
        }
        else {
            errorMsg += "";
        }
    
    });
    if (errorMsg != "")
    { fnShflAlert("error", errorMsg); }
    else {

        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
        }
    }
}    
function fnUpdateCusFk()
{
    debugger;
    window.QdePk = $(whichDiv).attr("pk");
    var objProcData = { ProcedureName: "PrcShflCusDedupe", Type: "SP", Parameters: ["UPDATE_CUSFK", JSON.stringify(DeDupeXml), "", "", "", "", QdePk, matfk] };
    fnCallLOSWebService("updatefk", objProcData, fnDedupeResult, "MULTI", "");
}

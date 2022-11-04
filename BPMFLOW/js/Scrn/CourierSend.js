var chckpni;
var Agttyp;
var SancGlobal = [{}];
var sanc_frm = "";
var PropDvCnt = 0;
$(document).ready(function () {
    console.log("accept");
    SancGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    //SancGlobal[0].LeadPk = GlobalXml[0].FwdDataPk; //For Common SP
    SancGlobal[0].LeadId = GlobalXml[0].LeadID;
    SancGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    SancGlobal[0].BranchNm = GlobalXml[0].Branch;
    SancGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    SancGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    SancGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    SancGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    SancGlobal[0].AppNo = GlobalXml[0].AppNo;
    SancGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    SancGlobal[0].SancPk = GlobalXml[0].DpdFk;
    SancGlobal[0].PrdGrpFk = GlobalXml[0].PrdGrpFk;
    SancGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    SancGlobal[0].GrpCd = GlobalXml[0].GrpCd;
    sanc_frm = GlobalXml[0].Sanc_Frm;
    selectfocus();
    fnGetPrd();
    fnloadleaddtls();
    var param = JSON.stringify(GlobalBrnch);
    $(".Seller_help").attr("Extraparam", param);

});
function fnGetPrd() {
    
    var PrcObj = { ProcedureName: "PrcShflDates", Type: "SP", Parameters: ["SELECT_LEAD",JSON.stringify(SancGlobal)] };
    fnCallLOSWebService("SELECT_LEAD", PrcObj, fnResult, "MULTI");
}
function fnloadleaddtls() {
    
    var PrcObj = { ProcedureName: "PrcShflDates", Type: "SP", Parameters: ["LOAD", JSON.stringify(SancGlobal)] };
    fnCallLOSWebService("LOAD", PrcObj, fnResult, "MULTI");
}


function fnResult(ServDesc, Obj, param1, param2) {
    
    if (ServDesc == "SELECT_LEAD") {

       
        var GRPdtls = JSON.parse(Obj.result);

        if (GRPdtls.length > 0) {

            $("#prddiv i").attr("pk", GRPdtls[0].productpk);
            $("#LeadGrdPk").val(GRPdtls[0].productpk);
            $("#LeadGrdPk").attr("pcd", GRPdtls[0].ProductCode);
            $("#prddiv i").attr("class", GRPdtls[0].ClasNm);
            $("#prddiv p").text(GRPdtls[0].productnm);
            $("#Scan_LeadId").text(GRPdtls[0].ledid);
            $("#Scan_LeadNm").text(GRPdtls[0].Name);
            $("#Scan_Branch").text(GRPdtls[0].branch);
            if (GlobalXml[0].PrdCd == "HLTopup") {
                $("#prddiv i").attr("class", "icon-hl-topup");
                $("#prddiv p").text("Topup");
            } else if (GlobalXml[0].PrdCd == "HLBT") {
                $("#prddiv i").attr("class", "icon-hl-bt");
                $("#prddiv p").text("Balance Transfer");
            }
            else if (GlobalXml[0].PrdCd == "LAPTopup") {
                $("#prddiv i").attr("class", "icon-lap-topup");
                $("#prddiv p").text("Topup");
            } else if (GlobalXml[0].PrdCd == "LAPBT") {
                $("#prddiv i").attr("class", "icon-lap-bt");
                $("#prddiv p").text("Balance Transfer");
            } 
            chckpni = GRPdtls[0].PNICASE;
            Agttyp = GRPdtls[0].TYP;
            
            if (chckpni == "Y" && Agttyp == "N") {
                if (!window.BO)
                    window.BO = 1;
                $("#div_append").append("<div id='Loadhtml'></div>");
                $("#Loadhtml").load('AgentPNI.html', function () {
                    $("#agt_title").hide();
                    $("#main_agtLeadDiv").hide();
                    $("#PostSancProperty_bo").hide();
                });
            }
            //else
            //{
            //    $("#PostSancProperty_bo").show();
            //}

        }
    }
    if (ServDesc == "LOAD") {
        
        var dates = JSON.parse(Obj.result_1);
        var Prpdata = JSON.parse(Obj.result_2);
        var Prddata = JSON.parse(Obj.result_3);
        var SelDet = JSON.parse(Obj.result_4);

        SellerDetHide = Prddata[0].SellerDetHide;
        //SancGlobal[0].SancHdrPk = Prddata[0].SancHdrPk;
        if (SellerDetHide == "Y") {
            $('.postsanction-property-bo').attr('style', 'display:none');
        }
        else {
            $('.postsanction-property-bo').attr('style', 'display:block');
        }

        if (dates.length > 0) {
            $("#sanctionDt").val(dates[0].DATE);
            $("#CourierDt").val(dates[1].DATE);
            $("#boxdivid").attr("pk", dates[0].AdtPk)
        }
        if(Prpdata.length > 0){
            fnaddProp(Prpdata);
        }
        if (SelDet.length > 0) {
            
            fnSetSellerDetails_BO(SelDet, Prpdata);
        }
    }
    
    if (ServDesc == "SAVE") {
        
        var inspk = JSON.parse(Obj.result);
        $("#boxdivid").attr("pk", inspk[0].AdtFK)        
        if  (chckpni == "Y" && Agttyp == "N") {
            fnCallScrnFnfrmBO(IsFinalConfirm);
        }
        else if (chckpni == "N") {
        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }
        }
        else {
            if (IsFinalConfirm != "") {
                fnCallFinalConfirmation(IsFinalConfirm);
                return;
            }
        }
}
}

function fnsave() {
    
    var errmgs = fnChkMandatory("boxdivid");
    if (errmgs != "") {
        fnShflAlert("error", errmgs);
        return false;
    }
    var Courdate = $("#CourierDt").val();
    if (Courdate == "") {
        fnShflAlert("error", "Courier Sent Date Required!!");
        return;
    }
    var sandate = $("#sanctionDt").val();
    if (sandate == "") {
        fnShflAlert("error", "Sanction Signed Date Required!!");
        return;
    }
    var sandt = $("#sanctionDt").val();
    var coudt = $("#CourierDt").val();

    var date = sandt.substring(0, 2);
    var month = sandt.substring(3, 5);
    var year = sandt.substring(6, 10);
    var Sanctiondate = new Date(year, month - 1, date);
    
    var date2 = coudt.substring(0, 2);
    var month2 = coudt.substring(3, 5);
    var year2 = coudt.substring(6, 10);
    var Courierdate = new Date(year2, month2 - 1, date2);
    var currentDate1 = new Date();
    if (Sanctiondate > currentDate1) {
        fnShflAlert("error", "Sanction Date Should not be greater than Current Date!!");
        return false;
    }
    if (Courierdate > currentDate1) {
        fnShflAlert("error", "Courier Sent Date Should not be greater than Current Date!!");
        return false;
    }
    if (Courierdate > Sanctiondate) {
        fnShflAlert("error", "Courier Sent Date Should not be greater than Sanction Signed Date!!");
        return;
    }
    else {
        if (IsFinalConfirm == "true") {
            $("#psq_hdn_confirm_bo").val(1);
        }
    }
    
    var SancDivJson = [];
    /* For Seller/Builder */
    if (SellerDetHide == "N") {
        GlobalXml[0].TgtPageID = gAutoDec["FIS"];
        $("#sanction_div [key='psq_hdn_new']").val(1);
    }
    else {
        GlobalXml[0].TgtPageID = gAutoDec["PS"];
        $("#sanction_div [key='psq_hdn_new']").val(0);
    }
        if (Agttyp != "N" && SellerDetHide == "N") {                            
            /*validation for seller*/
            
                var PropDivCnt = Number($("#PostSancProperty_bo").find("li.propDiv.active").attr("licount"));
                var cur_div_active = Number($("#psq_prop_div_bo_" + PropDivCnt).find("#PostSancSeller_bo li.common.active").attr("value"));
                var cur_sel_Typ = $("#psq_prop_div_bo_" + PropDivCnt + " #psq_seller_div_bo_" + PropDivCnt + "_" + cur_div_active);
                if (cur_sel_Typ == "-1") {
                    fnShflAlert("error", "Type of Seller Required !!");
                    return;
                }
                Cur_Sel_show_error = fnchkselMandatory(PropDivCnt, cur_div_active);
                
                 if (Cur_Sel_show_error != "") {
                    fnShflAlert("error", Cur_Sel_show_error);
                    return;
                }
                 SellerErr = fnsellerChkMandatory();
                 if (SellerErr != "") {
                     fnShflAlert("error", SellerErr);
                     return;
                 }
                mainErr = fnCheckseller("psq_prop_div_bo");
                if (mainErr != "") {
                    fnShflAlert("error", mainErr);
                    return;
                }
 
                SancDivJson = fnGetFormValsJson_IdVal("sanction_div");
          }
            
    var valPk = $("#boxdivid").attr("pk");
    var sellerDet = fngetsellerdet("psq_prop_div_bo");       
    var DetJsondata = [{ "Code": "S", "Date": sandt }, { "Code": "C", "Date": coudt }];
    var PrcObj = { ProcedureName: "PrcShflDates", Type: "SP", Parameters: ['INSERT', JSON.stringify(SancGlobal), JSON.stringify(DetJsondata), JSON.stringify(SancDivJson), JSON.stringify(sellerDet)] };
    fnCallLOSWebService("SAVE", PrcObj, fnResult, "MULTI");

}

function fnCallScrnFn(FinalConfirm) {
    IsFinalConfirm = FinalConfirm;
    fnsave();
}

function fnaddProp(Prpdata)
{
    
    var val = "psq_prop_div_bo_0";
    PropDvCnt = Prpdata.length;
    for(var i = 0; i < Prpdata.length; i++)
    {
        var property = [];
        divId = "psq_prop_div_" + i;
        var k = 0;
        property.push(Prpdata[i]);
        if (i > 0) {
            $("#psq_ul_prop_tabs_bo").append
           (
               "<li class='tab_" + i + " propDiv' licount='" + i + "' onclick=fnshowprop_bo(this);><span> Property" + (i + 1) + "</span></li>"
           );

            $("#PostSancProperty_bo").append('<div style="display:none;" id="psq_prop_div_bo_' + i + '" class="tab' + i + '-content div_content property" val="' + i + '" propfk = "' + Prpdata[i].sanc_prppk + '" contentchanged="true"></div>');
            var content = $("#psq_prop_div_bo_0").html();
            $("#psq_prop_div_bo_" + i).html(content);

            fnInitiateSelect("psq_prop_div_bo_" + i);
            val = "psq_prop_div_bo_" + i;
            fnClearForm("psq_prop_div_bo_" + i);
        }
        else {
            $("#psq_prop_div_bo_0").attr("propfk", Prpdata[0].sanc_prppk);

        }
        if (SancGlobal[0].GrpCd.toUpperCase() == "PL") {

            $("#psq_prop_div_bo_" + i).find("#psq_seller_div_bo_" + i + "_0").find("[key='psq_SellerType']").find("option").each(function () {
                if ($(this).val() == "B") { $(this).remove(); }
            });
        }
        $("#psq_prop_div_bo_" + i).find(".seller_div").attr("id", "psq_seller_div_bo_" + i + "_0");
        $("#psq_prop_div_bo_" + i).find("#psq_seller_div_bo_" + i + "_0").attr("propfk", Prpdata[i].sanc_prppk);
        $("#psq_prop_div_bo_" + i).find(".seller_div").attr("class", "tab0-content div_content seller_div psq_seller_div_bo_" + i + "_0");
        $("#psq_prop_div_bo_" + i).find("#psq_seller_div_bo_" + i + "_0").find("[key='psq_SellerType']").attr("onchange", 'fnSellerTypChange(this,"psq_seller_div_bo_' + i + "_" + 0 + '")')

        fnSetValues("psq_prop_div_bo_" + i, property);
        fnInitiateSelect("psq_seller_div_bo_" + i + '_' + '0');

    }

}
function fnSetSellerDetails_BO(SelDet, propdet) {
    
    var divId = '';
    var sellerId = '';
    var ptBuiler = "";
    ptBuiler = SancGlobal[0].GrpCd.toUpperCase() == "PL" ? "" : '<option value="B">Builder</option>';
    if (SelDet.length > 0 && propdet.length > 0) {
        for (var i = 0; i < propdet.length; i++) {
            divId = "psq_prop_div_bo_" + i;
            var k = 0;

            for (var j = 0; j < SelDet.length; j++) {
                var sellerDet = [];
                sellerId = "psq_seller_div_bo_" + i + '_' + k;
                if (propdet[i].sanc_prppk == SelDet[j].PropFk) {
                    sellerDet.push(SelDet[j]);
                    if (k > 0) {
                        var mainHtml = $("#psq_seller_div_bo_0_0").html();
                        var sellerLi = '<li value = ' + k + ' class="tab_' + k + ' common" onclick="fnshowseller(this);">Seller' + (k + 1) + '<i onclick="fnsellerliClose(this,event)" class="li-close icon-close"></i></li>'
                        var sellerDiv = '<div id="psq_seller_div_bo_' + i + '_' + k + '" val="' + k + '" propfk="' + SelDet[j].PropFk + '" sellerpk="' + SelDet[j].psq_hdn_Sellerpk + '" class="tab' + k + '-content div_content seller_div psq_seller_div_bo_' + i + '_' + k + '" contentchanged="true"style="display:none;">' + mainHtml + '</div>'
                        var sellerSelect = '<label>Type of Seller</label>' +
                                            '<select name="select2" key="psq_SellerType" class="select mandatory" onchange=\'fnSellerTypChange(this,"psq_seller_div_bo_' + i + '_' + k + '");\'>' +
                                                        '<option value="-1">Select</option>' +
                                                       '<option value="S">Seller</option>' +
                                                       //'<option value="B">Builder</option>'+
                                                       ptBuiler 
                                                    '</select>'
                        $("#" + divId).find("#psq_ul_seller_tabs_bo li.add").before(sellerLi);
                        $("#" + divId).find("#PostSancSeller_bo").append(sellerDiv);
                        $("#" + divId).find("#" + sellerId).find("li.seller").empty();
                        $("#" + divId).find("#" + sellerId).find("li.seller").append(sellerSelect);
                                           

                    }
                    else {
                        $("#" + divId).find("#" + sellerId).attr("sellerpk", SelDet[j].psq_hdn_Sellerpk);
                        $("#" + divId).find("#" + sellerId).attr("propfk", SelDet[j].PropFk);
                    }
                    //fnInitiateSelect("psq_seller_div_bo_" + i + '_' + k);
            
                   // $("#" + divId).find("#" + sellerId).find("li.seller").find("[key = 'psq_SellerType']").val("-1").trigger("change.select2");
                    //$("#" + divId).find("#" + sellerId).find("li.seller").find("[key = 'psq_SellerType']").val("-1");
                    $("#" + divId).find("#psq_ul_seller_tabs_bo").find("li.tab_" + k).addClass("active");
                    $("#" + divId).find("#psq_ul_seller_tabs_bo").find("li.tab_" + k).siblings("li").removeClass("active");
                    $("#" + divId).find("#" + sellerId).show();
                    $("#" + divId).find("#" + sellerId).siblings("div.div_content").css("display", "none");
                    $("#" + divId).find("#" + sellerId).find('#sanc_buildercin').hide();
                    $("#" + divId).find("#" + sellerId).find('#sanc_UlSellerAddr').hide();
                    $("#" + divId).find("#" + sellerId).find('#sanc_SelAGent').hide();
                    $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
                    fnClearForm_psq(divId, sellerId, "sanc_UlSellerAddr");
                    $("#" + divId).find("#" + sellerId).find(".buildermas").hide();
                    if (SelDet[j].psq_SellerType == "-1") {
                        $("#" + divId).find("#" + sellerId).find('#sanc_buildercin').hide();
                        $("#" + divId).find("#" + sellerId).find('#sanc_UlSellerAddr').hide();
                        $("#" + divId).find("#" + sellerId).find('#sanc_chkagent').hide();
                        //$("#" + divId).find("#" + sellerId).find('#psq_SelAGent').hide();
                        //$("#" + divId).find("#" + sellerId).find('#checkAgt').hide();
                        fnClearForm_psq(divId, sellerId, "sanc_checkAgt");
                        $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
                        fnClearForm_psq(divId, sellerId, " .UlSellerAddr");
                        $("#" + divId).find("#" + sellerId).find(".buildermas").hide();


                    }
                    else if (SelDet[j].psq_SellerType == "S") {
                        $("#" + divId).find("#" + sellerId).find(".buildermas").empty();
                        $("#" + divId).find("#" + sellerId).find(".buildermas").show();
                        //$("#" + divId).find("#" + sellerId).find('#sanc_chkagent').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_checkAgt').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_SelAGent').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_buildercin').hide();
                        $("#" + divId).find("#" + sellerId).find('#sanc_UlSellerAddr').show();
                        $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');

                        fnClearForm_psq(divId, sellerId, "checkAgt");
                        // $("#" + divId).find("#" + sellerId).find('#checkAgt').show();
                        $("#" + divId).find("#" + sellerId).find(".buildermas input").attr("type", "text");
                        var html = $('<label>Seller Name</label><input type="text" class = "mandatory"name="text" key="psq_SellerName">');
                        $("#" + divId).find("#" + sellerId).find(".buildermas").append(html);

                    }
                    else {
                        $("#" + divId).find("#" + sellerId).find(".buildermas").empty();
                        $("#" + divId).find("#" + sellerId).find(".buildermas").show();
                        //$("#" + divId).find("#" + sellerId).find('#sanc_chkagent').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_checkAgt').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_SelAGent').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_buildercin').show();
                        $("#" + divId).find("#" + sellerId).find('#sanc_UlSellerAddr').hide();
                        fnClearForm_psq(divId, sellerId, "sanc_UlSellerAddr");
                        fnClearForm_psq(divId, sellerId, "sanc_checkAgt");
                        // $("#" + divId).find("#" + sellerId).find('#checkAgt').show();
                        var html = $('<label>Builder Name</label><comp-help id="comp-help" class="mandatory"txtcol="BuilderName" valcol="GPk" onrowclick="builderclick" prcname="PrcShflBuilderhelp" width="100%"></comp-help>' +
                                    '<input type="hidden" class="mandatory" valtext="" name="text" key="psq_SellerName">' + '<input type="hidden"  valtext="" name="text" key="psq_BuilderPk">');
                        $("#" + divId).find("#" + sellerId).find(".buildermas").append(html);

                    }



                    //InfavourlistBind(divId, sellerId);
                    fnSetValues(divId + " #psq_seller_div_bo_" + i + '_' + k, sellerDet);
                    if (SelDet[j].psq_check_agt == "0") {
                        $("#" + divId).find("#" + sellerId).find('#sanc_SelAGent').show();
                    }
                    else if (SelDet[j].psq_check_agt == "1") {
                        $("#" + divId).find("#" + sellerId).find('#sanc_SelAGent').hide();
                    }

                    if (SelDet[j].psq_SellerType == "S") {
                        var valtxt = $("#" + divId).find("#" + sellerId).find("input[key=psq_SellerPin]").val();
                        $("#" + divId).find("#" + sellerId).find("input[key=psq_SellerPin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas").find("input[key='psq_SellerName']").val(SelDet[j].psq_SellerName);
                    } else {
                        $("#" + divId).find("#" + sellerId).find("li.buildermas comp-help").find("input[name='helptext']").val(SelDet[j].psq_SellerName);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas input[key='psq_SellerName']").attr("valtext", SelDet[j].psq_SellerName);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas input[key='psq_SellerName']").attr("value", SelDet[j].psq_SellerName);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas input[key='psq_BuilderPk']").attr("value", SelDet[j].psq_BuilderPk);

                    }
                    $("#" + divId).find("#" + sellerId).find("li.sanc-SelAGent").find("input[key='psq_agnttype']").attr("valtext", SelDet[j].AgtName);
                    $("#" + divId).find("#" + sellerId).find("li.sanc-SelAGent").find("input[key='psq_agnttype']").attr("value", SelDet[j].psq_agnttype);
                    $("#" + divId).find("#" + sellerId).find("li.sanc-SelAGent comp-help").find("input[name='helptext']").val(SelDet[j].AgtName);
       
                    k++;
                }
            }
            //~ISSUE
            //$("#psq_prop_div_" + i).find("#PostSancSeller li").eq(0).click();
        }
        //fnInitiateSelect("postsanction-seller", 1);
    }
}

function fnshowprop_bo(elem) {
           
    var PropDivCnt = Number($("#PostSancProperty_bo").find("li.propDiv.active").attr("licount"));
    var cur_div_active = Number($("#psq_prop_div_bo_" + PropDivCnt).find("#PostSancSeller_bo li.common.active").attr("value"));
    var cur_sel_Typ = $("#psq_prop_div_bo_" + PropDivCnt + " #psq_seller_div_bo_" + PropDivCnt + "_" + cur_div_active).find("[key = 'psq_SellerType']").val();    
    if (cur_sel_Typ == "-1") {
        fnShflAlert("error", "Type of Seller Required !!");
        return;
    }
    Cur_Sel_show_error = fnchkselMandatory(PropDivCnt, cur_div_active);
    if (Cur_Sel_show_error != "") {
        fnShflAlert("error", Cur_Sel_show_error);
        return;
    }
    var value = $(elem).attr("licount");
    var cur_div = $("#PostSancProperty_bo").find("#psq_prop_div_bo_" + value);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div").css("display", "none")
    $(".tab_" + value).addClass("active");
    $(".tab_" + value).siblings("li").removeClass("active");
    $(cur_div).find("#psq_seller_div_bo_" + value + "_0").css("display", "block");
    $(cur_div).find("#psq_seller_div_bo_" + value + "_0").siblings("div.div_content").css("display", "none");
    $(cur_div).find("#psq_ul_seller_tabs_bo").find("li.tab_0").addClass("active");
    $(cur_div).find("#psq_ul_seller_tabs_bo").find("li.tab_0").siblings("li").removeClass("active");
}

function fnSellerTypChange(obj, formId) {
    

    var divId = '';
    var PropDivCnt = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    var sellerDiv = $($(obj).closest(".postsanction-seller").find(".seller_div")[0]);

    divId = "psq_prop_div_bo_" + PropDivCnt;
    //var SelTyp = $("#" + divId + " #psq_seller_div_" + PropDivCnt + "_0").find("[key='psq_SellerType']").val();
    var SelTyp = $(sellerDiv).find("[key='psq_SellerType']").val();
    if (formId != "psq_seller_div_bo_" + PropDivCnt + "_0") {
        if (SelTyp != $(obj).val()) {
            $("#" + divId).find("#" + formId).find('#sanc_buildercin').hide();
            $("#" + divId).find("#" + formId).find('#sanc_UlSellerAddr').hide();
            $("#" + divId).find("#" + formId).find('#sanc_SelAGent').hide();
            $("#" + divId).find("#" + formId).find('#sanc_checkAgt').hide();            
            $("#" + divId).find("#" + formId).find("input[key='psq_CIN']").val(' ');
            fnClearForm_psq(divId, formId, "sanc_UlSellerAddr");
            fnClearForm_psq(divId, formId, "sanc_checkAgt");
            $("#" + divId).find("#" + formId).find(".buildermas").hide();
            $("#" + divId).find("#" + formId).find("[key='psq_SellerType']").val("-1");
            fnShflAlert("error", "Choose Same Seller Type!!");
            return false;
        }
    }
    if ($(obj).val() == "-1") {
        $("#" + divId).find("#" + formId).find('#sanc_buildercin').hide();
        $("#" + divId).find("#" + formId).find('#sanc_UlSellerAddr').hide();
        $("#" + divId).find("#" + formId).find('#sanc_SelAGent').hide();
        $("#" + divId).find("#" + formId).find('#sanc_checkAgt').hide();        
        $("#" + divId).find("#" + formId).find("input[key='psq_CIN']").val(' ');
        fnClearForm_psq(divId, formId, "sanc_UlSellerAddr");
        fnClearForm_psq(divId, formId, "sanc_checkAgt");
        $("#" + divId).find("#" + formId).find(".buildermas").hide();
    }
    else if ($(obj).val() == "S") {
        $("#" + divId).find("#" + formId).find(".buildermas").empty();
        $("#" + divId).find("#" + formId).find(".buildermas").show();
        $("#" + divId).find("#" + formId).find('#sanc_SelAGent').hide();
        $("#" + divId).find("#" + formId).find('#sanc_buildercin').hide();
        $("#" + divId).find("#" + formId).find('#sanc_UlSellerAddr').show();
        $("#" + divId).find("#" + formId).find('#sanc_checkAgt').show();
        $("#" + divId).find("#" + formId).find("input[key='psq_CIN']").val(' ');        
        fnClearForm_psq(divId, formId, "sanc_checkAgt");
        $("#" + divId).find("#" + formId).find(".buildermas input").attr("type", "text");
        var html = $('<label>Seller Name</label><input type="text" class="mandatory"name="text" key="psq_SellerName">');
        $("#" + divId).find("#" + formId).find(".buildermas").append(html);
    }
    else {
        $("#" + divId).find("#" + formId).find(".buildermas").empty();
        $("#" + divId).find("#" + formId).find(".buildermas").show();
        $("#" + divId).find("#" + formId).find('#sanc_SelAGent').hide();
        $("#" + divId).find("#" + formId).find('#sanc_buildercin').show();
        $("#" + divId).find("#" + formId).find('#sanc_UlSellerAddr').hide();
        $("#" + divId).find("#" + formId).find('#sanc_checkAgt').show();
        fnClearForm_psq(divId, formId, "sanc_UlSellerAddr");
        fnClearForm_psq(divId, formId, "sanc_checkAgt");
        var html = $('<label>Builder Name</label><comp-help id="comp-help" class="mandatory"txtcol="BuilderName" valcol="GPk" onrowclick="builderclick" prcname="PrcShflBuilderhelp" width="100%"></comp-help>' + '<input type="hidden"  valtext="" name="text" key="psq_SellerName">' + '<input type="hidden"  valtext="" name="text" key="psq_BuilderPk">');
        $("#" + divId).find("#" + formId).find(".buildermas").append(html);
    }    

}

function fnClearForm_psq(divId, sellerId, FormID, IsClass) {

    var AppendOperator = "#";
    if (IsClass == 1) { AppendOperator = "." }

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='text']").each(function () {
        $(this).val("");
    });

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='select']").each(function () {
        var Option = $(this).siblings("ul").children("li").eq(0).val();

        if (isNaN(Option))
            $(this).attr("selval", "");
        else
            $(this).attr("selval", "-1");

        $(this).val("");
    });

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='select2']").each(function () {
        $(this).val("");
    });

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='checkbox']").each(function () {
        $(this).prop("checked", false);
    });

    //$(AppendOperator + FormID + " .datepicker").val(GlobalXml[0].GlobalDt);
}


function fnAddSeller(elem) {

    var divId = '';
    var sellerId = '';
    var option = '';
    var ErrMsg = '';
    var SelTyp = ''
    var ptBuiler = '';
    var PropDivCnt = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    divId = "psq_prop_div_bo_" + PropDivCnt;
    var PropFk = $('#' + divId).attr("propfk");
    var selvalCnt = Number($("#sanction_div").find("#" + divId).find("#psq_ul_seller_tabs_bo li.common").last().attr("value"));
    var SellerCount = selvalCnt + 1;
    sellerId = "psq_seller_div_bo_" + PropDivCnt + "_" + SellerCount;
    //validation for seller 
    var cur_sel_Typ = $("#" + divId + " #psq_seller_div_bo_" + PropDivCnt + "_" + selvalCnt).find("[key = 'psq_SellerType']").val();
    if (cur_sel_Typ == "-1") {
        fnShflAlert("error", "Type of Seller Required !!");
        return;
    }
    Cur_Sel_error = fnchkselMandatory(PropDivCnt, selvalCnt);
    if (Cur_Sel_error != "") {
        fnShflAlert("error", Cur_Sel_error);
        return;
    }

    ptBuiler = SancGlobal[0].GrpCd.toUpperCase() == "PL" ? "" : '<option value="B">Builder</option>';

    var mainHtml = $("#psq_seller_div_bo_0_0").html();
    var sellerLi = '<li value = ' + SellerCount + ' class="tab_' + SellerCount + ' common" onclick="fnshowseller(this);">Seller' + (SellerCount + 1) + '<i onclick="fnsellerliClose(this,event)" class="li-close icon-close"></i></li>'
    var sellerDiv = '<div id="psq_seller_div_bo_' + PropDivCnt + "_" + SellerCount + '" val="' + SellerCount + '" propfk="' + PropFk + '" sellerpk="0" class="tab' + SellerCount + '-content div_content seller_div psq_seller_div_bo_' + PropDivCnt + "_" + SellerCount + '" contentchanged="true"style="display:none;">' + mainHtml + '</div>'
    var sellerSelect = '<label>Type of Seller</label>' +
                        '<select name="select2" key="psq_SellerType" class="select mandatory" onchange=\'fnSellerTypChange(this,"psq_seller_div_bo_' + PropDivCnt + "_" + SellerCount + '");\'>' +
                                    '<option value="-1">Select</option>' +
                                    '<option value="S">Seller</option>' +
                                    ptBuiler 
    '</select>'

    $(elem).closest("li").before(sellerLi);
    $("#" + divId).find("#PostSancSeller_bo").append(sellerDiv);
    $("#" + divId).find("#" + sellerId).attr("sellerpk", "0");
    $("#" + divId).find("#" + sellerId).find("li.seller").empty();
    $("#" + divId).find("#" + sellerId).find("li.seller").append(sellerSelect);


    fnInitiateSelect("PostSancSeller_bo");
    $("#" + divId).find("#" + sellerId).find("[key='psq_agnttype']").prop("disabled", true);
    $("#" + divId).find("#psq_ul_seller_tabs_bo").find("li.tab_" + SellerCount).addClass("active");
    $("#" + divId).find("#psq_ul_seller_tabs_bo").find("li.tab_" + SellerCount).siblings("li").removeClass("active");
    $("#" + divId).find("#" + sellerId).show();
    $("#" + divId).find("#" + sellerId).siblings("div.div_content").css("display", "none");
    $("#" + divId).find("#" + sellerId).find('#sanc_buildercin').hide();
    $("#" + divId).find("#" + sellerId).find('#sanc_UlSellerAddr').hide();
    $("#" + divId).find("#" + sellerId).find('#sanc_SelAGent').hide();
    $("#" + divId).find("#" + sellerId).find('#sanc_checkAgt').hide();
    $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
    fnClearForm_psq(divId, sellerId, "sanc_UlSellerAddr");
    $("#" + divId).find("#" + sellerId).find(".buildermas").hide();
    $("#" + divId).find("#" + sellerId).find("input[key='psq_agnttype']").attr("valtext", "");
    $("#" + divId).find("#" + sellerId).find("input[key='psq_agnttype']").attr("value", "");
    $("#" + divId).find("#" + sellerId).find("input[key='psq_agnttype']").attr("valcol", "");
}

function fnshowseller(elem) {

    var ErrMsg = '';
    var value = $(elem).attr("value");
    var PropDivCnt = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    var cur_div_active = Number($("#psq_prop_div_bo_" + PropDivCnt).find("#PostSancSeller_bo li.common.active").attr("value"));
    var cur_sel_Typ = $("#psq_prop_div_bo_" + PropDivCnt + " #psq_seller_div_bo_" + PropDivCnt + "_" + cur_div_active).find("[key = 'psq_SellerType']").val();
    if (cur_sel_Typ == "-1") {
        fnShflAlert("error", "Type of Seller Required !!");
        return;
    }
    Cur_Sel_show_error = fnchkselMandatory(PropDivCnt, cur_div_active);
    if (Cur_Sel_show_error != "") {
        fnShflAlert("error", Cur_Sel_show_error);
        return;
    }
    var cur_div = $("#psq_prop_div_bo_" + PropDivCnt).find("#psq_seller_div_bo_" + PropDivCnt + '_' + value);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div.div_content").css("display", "none")
    $("#psq_prop_div_bo_" + PropDivCnt).find("#psq_ul_seller_tabs_bo").find("li.tab_" + value).addClass("active");
    $("#psq_prop_div_bo_" + PropDivCnt).find("#psq_ul_seller_tabs_bo").find("li.tab_" + value).siblings("li").removeClass("active");
}

function fngetsellerdet(FormID, IsClass) {

    var KeyVal = [];
    var KeyJsonTxt = "";
    var IsKeyExists = 0;
    var KeyValObj = {};
    var lpcnt = 0;
    while (lpcnt < PropDvCnt) {
        KeyJsonTxt = "";
        IsKeyExists = 0;
        KeyValObj = {};
        var AppendOperator = "#";
        if (IsClass == 1) { AppendOperator = "." }

        $(AppendOperator + FormID + "_" + lpcnt).find(".seller_div").each(function () {
            KeyJsonTxt = "";
            IsKeyExists = 0;
            KeyValObj = {};
            $(this).find("[name='text']").each(function () {
                if (!($(this).is("[key]"))) { return; }
                if ($(this).hasClass("currency")) {
                    $(this).val(FormatCleanComma($(this).val().trim()));
                }
                var AssignValue = $(this).val().trim();
                if (AssignValue == "") { if ($(this).is("[value]")) AssignValue = $(this).attr("value"); }
                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                KeyValObj[keyTxt] = AssignValue;
                KeyJsonTxt += keyTxt + ",";
            });

            $(this).find("[name='select2']").each(function () {
                if (!($(this).is("[key]"))) { return; }
                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                var keyVal = $(this).val();
                KeyValObj[keyTxt] = keyVal;
                KeyJsonTxt += keyTxt + ",";
            });
            $(this).find(" [name='checkbox']").each(function () {
                if (!($(this).is("[key]"))) { return; }

                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                var keyVal = ($(this).is(":checked")) ? "Y" : "N";
                KeyValObj[keyTxt] = keyVal;
                KeyJsonTxt += keyTxt + ",";
            });


            if (IsKeyExists == 1)
                //KeyValObj["PropFk"] = $(AppendOperator + FormID + "_" + lpcnt).attr("propfk");
                KeyValObj["PropFk"] = $(this).attr("propfk");
            KeyValObj["psq_hdn_Sellerpk"] = $(this).attr("sellerpk");
            KeyVal.push(KeyValObj);
        });
        lpcnt += 1;
    }
    return KeyVal;
}

function fncheckAgt(elem) {

    var chkCnt = 0;
    var ErrMsg = '';
    var propDiv = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    $("#psq_prop_div_bo_" + propDiv).find(".seller_div").each(function () {
        var chk = $(this).find("[key='psq_check_agt']");
        if ($(chk).prop('checked')) { chkCnt++; }
    });

    if (chkCnt > 1) {
        $(elem).prop("checked", false);
        fnShflAlert("error", "Select One seller for one Property");
        return false;
        //$(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").prop("disabled", true);
    }
    $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li.sanc-SelAGent").find("input[key='psq_agnttype']").attr("valtext", "");
    $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li.sanc-SelAGent").find("input[key='psq_agnttype']").attr("value", "");
    $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li.sanc-SelAGent").find("input[key='psq_agnttype']").attr("valcol", "");
    $(elem).parent().closest('li').siblings().find("input[name='helptext']").val("");
    if ($(elem).parent().closest('li').find("[name='checkbox']").prop('checked')) {

        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").val("");
        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li").show();
    }
    else {
        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").val("");
        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li").hide();
    }

}

function Pinclick(rowjson, elem) {
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}

function builderclick(rowjson) {

    var propDiv = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    var activeDiv = $("#psq_prop_div_bo_" + propDiv).find("#psq_ul_seller_tabs_bo li.common.active").attr("value");
    var cur_div = $("#psq_prop_div_bo_" + propDiv).find("#psq_seller_div_bo_" + propDiv + '_' + activeDiv);
    $(cur_div).find("li.buildermas input[name='helptext']").val(rowjson.BuilderName);
    $(cur_div).find("li.buildermas input[key='psq_SellerName']").attr("valtext", rowjson.BuilderName);
    $(cur_div).find("li.buildermas input[key='psq_SellerName']").attr("value", rowjson.BuilderName);
    $(cur_div).find("li.buildermas input[key='psq_BuilderPk']").attr("value", rowjson.GPk);
    $(cur_div).find("ul").attr("contentchanged", "true");
}

function agtclick(rowjson) {
    
    var propDiv = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    var activeDiv = $("#psq_prop_div_bo_" + propDiv).find("#psq_ul_seller_tabs_bo li.common.active").attr("value");
    var cur_div = $("#psq_prop_div_bo_" + propDiv).find("#psq_seller_div_bo_" + propDiv + '_' + activeDiv);
    $(cur_div).find("li.sanc-SelAGent input[name='helptext']").val(rowjson.AgentName);
    $(cur_div).find("li.sanc-SelAGent input[key='psq_agnttype']").attr("valtext", rowjson.AgentName);
    $(cur_div).find("li.sanc-SelAGent input[key='psq_agnttype']").attr("value", rowjson.Agtpk);
    $(cur_div).find("li.sanc-SelAGent input[key='psq_agnttype']").attr("valcol", rowjson.Agtpk);
    $(cur_div).find("ul").attr("contentchanged", "true");
}


function fnchkselMandatory(propval, cur_typ) {
    
    var MandatoryMsg = "";
    var AppendOperator = "";

    $("#psq_prop_div_bo_" + propval + " #psq_seller_div_bo_" + propval + "_" + cur_typ + " [contentchanged='true'] .mandatory").each(function () {
        var lbl_sibling; var label = "";
        if ($(this).is(":visible") && $(this).attr("name") == "text" && (($(this).val() == "") || ($(this).val() == "0"))) {
            lbl_sibling = $(this).siblings("label");
            label = $(lbl_sibling).text();
            if (label == "") { label = $(this).attr("placeholder"); }

            if (label != "" && label != undefined)
                MandatoryMsg += label + " Required!! <br/>";
        }
        if ($(this).is(":visible") && $(this).attr("name") == "select" && ($(this).attr("selval") == "-1") || ($(this).attr("selval") == "")) {
            lbl_sibling = $(this).closest(".select-focus");
            lbl_sibling = lbl_sibling.siblings("label");
            label = $(lbl_sibling).text();

            if (label != "" && label != undefined)
                MandatoryMsg += label + " Required!! <br/>";
        }
        if ($(this).is(":visible") && $(this).attr("name") == "select2" && ($(this).val() == "" || $(this).val() == "-1")) {
            lbl_sibling = $(this);
            lbl_sibling = lbl_sibling.siblings("label");
            label = $(lbl_sibling).text();

            if (label != "" && label != undefined)
                MandatoryMsg += label + " Required!! <br/>";
        }
        if ($(this).is(":visible") && $(this).attr("id") == "comp-help" && $(this).find("input[name = 'helptext']").val() == "") {
            lbl_sibling = $(this);
            lbl_sibling = lbl_sibling.siblings("label");
            label = $(lbl_sibling).text();

            if (label != "" && label != undefined)
                MandatoryMsg += label + " Required!! <br/>";
        }
    });
    if (MandatoryMsg != "") {
        MandatoryMsg = "<br/><b>Seller" + (cur_typ + 1) + "</b><br/>" + MandatoryMsg + "<br/>";
    }    
    return MandatoryMsg;

}
function fnsellerliClose(elem, e) {

    e.stopPropagation();
    var PropDivCnt = $("#PostSancProperty_bo").find("li.propDiv.active").attr("licount");
    var divno = $(elem).closest("li").attr("value");
    var PrvDiv = Number($(elem).closest("li").attr("value")) - 1;
    var sellerPk = Number($("#psq_prop_div_bo_" + PropDivCnt).find("#psq_seller_div_bo_" + PropDivCnt + '_' + divno).attr("sellerpk"));


    if (sellerPk == 0 || sellerPk == "0") {
        $("#psq_prop_div_bo_" + PropDivCnt).find("#psq_seller_div_bo_" + PropDivCnt + '_' + divno).remove();
        $(elem).closest("li").remove();
        $("#psq_prop_div_bo_" + PropDivCnt).find("#psq_seller_div_bo_" + PropDivCnt + '_' + PrvDiv).show();
    }
    else {
        var confirmSts = confirm("Do you wish to Delete??");
        if (confirmSts == true) {
            $("#psq_prop_div_bo_" + PropDivCnt).find("#psq_seller_div_bo_" + PropDivCnt + '_' + divno).remove();
            $(elem).closest("li").remove();       
            var PrcObj = { ProcedureName: "PrcShflDates", Type: "SP", Parameters: ['Delete_Seller', JSON.stringify(SancGlobal), "", "", "", sellerPk] };
            fnCallLOSWebService("Delete_Seller", PrcObj, fnResult, "MULTI");
        }

    }
}
function fnsellerChkMandatory(FormID) {
    
    var MandatoryMsg = "";
    var FinalErrMsg = '';
    var Mainid = '';
    var ErrMsg = ''

    for (var i = 0; i < PropDvCnt; i++) {

        ErrMsg = '';
        selvalCnt = Number($("#sanction_div").find("#psq_prop_div_bo_" + i).find("#psq_ul_seller_tabs_bo li.common").last().attr("value"));
        for (var j = 0; j <= selvalCnt; j++) {
            MandatoryMsg = "";
            Mainid = "#psq_prop_div_bo_" + i + " #psq_seller_div_bo_" + i + "_" + j;                                     
           
                $(Mainid).find("[name=select2]").each(function () {                
                        if ($(this).attr("name") == "select2" && ($(this).val() == "" || $(this).val() == "-1") && $(this).attr("key") == 'psq_SellerType') {
                            lbl_sibling = $(this);
                            lbl_sibling = lbl_sibling.siblings("label");
                            label = $(lbl_sibling).text();
                            if (label != "" && label != undefined)
                                MandatoryMsg += label + " Required!! <br/>";
                        }
                });

                if (MandatoryMsg != "") {
                    ErrMsg += "<b>Seller" + (j + 1) + "</b><br/>" + MandatoryMsg ;
                }
            }
                     
        if (ErrMsg != "") {
            FinalErrMsg = FinalErrMsg == "" ? "<b>Property" + (i + 1) + "</b><br/>" + ErrMsg  : FinalErrMsg + "<br/><b>Property" + (i + 1) + "</b><br/>" + ErrMsg ;
        }
    }
    return FinalErrMsg;
}
function fnCheckseller(FormID) {
    var IsKeyExists = 0;
    var lpcnt = 0;
    var chkCount = '';
    var ErrMsg = '';
    while (lpcnt < PropDvCnt) {
        IsKeyExists = 0;
        chkCount = '';
        var AppendOperator = "#";
        $(AppendOperator + FormID + "_" + lpcnt).find(".seller_div").each(function () {
            var elem = this;
            $(elem).find("[key='psq_SellerType']").each(function () {
                var keyVal = $(this).val();
                $(elem).find("[name='checkbox']").each(function () {
                    var keyVal = ($(this).is(":checked")) ? 0 : 1;
                    if (keyVal == 0) { chkCount = 'Y' }
                });
            });

        });
        if (chkCount != 'Y') {
            ErrMsg = ErrMsg == "" ? "<br/><b>Property" + (lpcnt + 1) + "</b><br/>Trigger Atleast One Agent !!" : ErrMsg + "<br/><b>Property" + (lpcnt + 1) + "</b><br/>Trigger Atleast One Agent !!";
        }
        lpcnt += 1;
    }

    return ErrMsg;
}

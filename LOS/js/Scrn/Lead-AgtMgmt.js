    var LedAgtGlobal = [{}];
    $(document).ready(function () {
        console.log("agt");
        LedAgtGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
        LedAgtGlobal[0].LeadId = GlobalXml[0].LeadID;
        LedAgtGlobal[0].AppNo = GlobalXml[0].AppNo;
        LedAgtGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
        LedAgtGlobal[0].BranchNm = GlobalXml[0].Branch;   
        LedAgtGlobal[0].AgtFk = GlobalXml[0].AgtFk;
        LedAgtGlobal[0].AgtNm = GlobalXml[0].AgtNm;
        LedAgtGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
        LedAgtGlobal[0].PrdFk = GlobalXml[0].PrdFk;
        LedAgtGlobal[0].PrdNm = GlobalXml[0].PrdNm;
        LedAgtGlobal[0].PrdCd = GlobalXml[0].PrdCd;
        fnSelAgtLead();
    });

    function fnSelAgtLead()
    {    
        var PrcObj = { ProcedureName: "PrcShflLedAgtMgt", Type: "SP", Parameters: ["S", JSON.stringify(LedAgtGlobal)] };
        fnCallLOSWebService("SEL-LEAD", PrcObj, fnAgentFinResult, "MULTI");
    }


    function fnAgtBindEvts() {
        fnDrawDatePicker();

        $(".mainul .datepicker").each(function () {
            fnRestrictDate($(this));
        });

        $(".mainul [key]").each(function () {
            if ($(this).closest(".agt_user_content").attr("changeevt") == "0") {

                $(this).closest(".agt_user_content").attr("changeevt", "1");
                $(this).addClass("mandatory");

                $(document).on("change", ".mainul [key]", function () {
                    $(this).closest(".agt_user_content").attr("contentchanged", "true");
                });
            }
        });
    }

    function fnSaveChangedData(elem) {
        debugger;
        var HdrJson = {};
        HdrJson = fnGetFormValsJson_IdVal("mainlegaldiv");
        console.log(HdrJson);
        var LavPk = $(cont).attr("lavPk");
        var Sertype = $(cont).parent().siblings("li[lavpk='" + LavPk + "']").attr("Sertype");
        var LajPk = $(cont).parent().siblings("li[lavpk='" + LavPk + "']").attr("LajFk");
        var AgtPk = $(cont).parent().siblings("li[lavpk='" + LavPk + "']").attr("AgtFk");
        jsonarr["LavPk"] = LavPk;
        jsonarr["ServiceType"] = Sertype;
        jsonarr["LajFk"] = LajPk;
        jsonarr["AgtFk"] = AgtPk;
        //jsonarr["LpvPk"] = LpvPk;
        JsonObj.push(jsonarr);
        console.log(JsonObj);
    
        var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: ["Save", JSON.stringify(LedAgtGlobal), JSON.stringify(HdrJson), JSON.stringify(JsonObj)] };
        fnCallLOSWebService("Save_Agt_data", PrcObj, fnAgentFinResult, "MULTI", elem);

    }
    function fnGetDetaildata(elem) {
        debugger;
        var JsonObj = [];
        var jsonarr = {};
        var lavpk = $(elem).closest("li").attr("LavPk");
        var Sertype = $(elem).closest("li").attr("Sertype");
        var LajPk = $(elem).closest("li").attr("LajFk");
        var AgtPk = $(elem).closest("li").attr("AgtFk");              
        jsonarr["LavPk"] = lavpk;
        jsonarr["ServiceType"] = Sertype;
        jsonarr["LajFk"] = LajPk;
        jsonarr["AgtFk"] = AgtPk;
        //jsonarr["LpvPk"] = LpvPk;
        JsonObj.push(jsonarr);    
        $(".agent-content-drilldown").remove();

        var PrcObj = { ProcedureName: "PrcShflLedAgtMgt", Type: "SP", Parameters: ["SelDetails", JSON.stringify(LedAgtGlobal), JSON.stringify(JsonObj)] };
        fnCallLOSWebService("SelDetails", PrcObj, fnAgentFinResult, "MULTI", lavpk);
    }
    function fnReprtSts(elem)
    {     
        var cls = $(elem).attr("class");
        if (cls == "icon-positive") {
            var contentdiv = $(".agent-content-drilldown").find("div.fidt2");
            var lihtml = $(contentdiv).find("ul.fom-controls li.div-right.status");
            $(lihtml).find("p.bg.bg1 i").attr("class", "icon-negative");
            $(lihtml).find("input[key=agt_rptstatus]").val(0);               
        }
        else if (cls == "icon-negative") {
            var contentdiv = $(".agent-content-drilldown").find("div.fidt2");
            var lihtml = $(contentdiv).find("ul.fom-controls li.div-right.status");
            $(lihtml).find("p.bg.bg1 i").attr("class", "icon-positive");
            $(lihtml).find("input[key=agt_rptstatus]").val(1);
        }
    }

function fnAgentFinResult(ServiceFor, Obj, Param1, Param2) {

    if (ServiceFor == "Save_Agt_data") {
        $("#ul_list_agt").find("div[contentchanged='true']").each(function () { $(this).attr("contentchanged", "false"); })
        fnGetDetaildata(Param2);
    }

    if (ServiceFor == "SEL-LEAD") {
        var leadData = JSON.parse(Obj.result_1);
        var AgentData = JSON.parse(Obj.result_2);

        if (leadData[0] && leadData[0] != null) {
            $("#PrdName").attr("ProductFk", leadData[0].ProductFk);
            $("#PrdName").text(leadData[0].ProductName);
            $("#LeadId").text(leadData[0].LeadId);
            $("#Appno").text(leadData[0].ApplicationNo);
            $("#BranchNm").attr("BranchFk", leadData[0].BranchFk);
            $("#BranchNm").text(leadData[0].BranchNm);
            $("#AgentName").attr("AgentFk", leadData[0].AgtFk);
            $("#AgentName").text(leadData[0].AgentName);
        }
        for (var i = 0; i < AgentData.length; i++) {
            var clsNm = ""; var UlData;
            var SerType = parseInt(AgentData[i].ServiceType);

            if (SerType == 2) {
                clsNm = "doc-pop"
            }
            else if (SerType == 4) {
                clsNm = "legal-popup";
            }
            else if (SerType == 5) {
                clsNm = "technical-popup";
            }
            else {
                clsNm = "doc-pop";
            }

            if (SerType < 4) {
                var ActorName = AgentData[i].ActorType == 0 ? "Applicant" : "CoApplicant";
                UlData = $(
                    '<li LajFk = "' + AgentData[i].LajPk + '" LavPk = "' + AgentData[i].Pk + '" Sertype = "' + AgentData[i].ServiceType + '"AgtFk = "' + AgentData[i].AgtPk + '"class="' + clsNm + '">' +
                    '<div class="div-left">' +
                      '<div> <i class="icon-agents"></i>' +
                        '<p>' + AgentData[i].AgentJob + '</p>' +
                      '</div>' +
                      '<div>' +
                        '<h2>' + AgentData[i].AgentName + '</h2>' +
                        '<span>' + AgentData[i].LeadId + '</span>' +
                        '<p><span>' + AgentData[i].AppName + '</span> <span>' + ActorName + '</span> <span class="div-right">Allocated on : 08 Jun 2016</span></p>' +
                      '</div>' +
                    '</div>' +
                    '<div class="div-right align-center status">' +
                      '<div class="bg bg2" onclick = "fnSaveChangedData(this);"><i class="icon-pending"></i></div>' +
                      '<p>Overdue 2 days</p>' +
                    '</div>' +
                    '<div class="clear"></div>' +
                  '</li>');
                $(".tab2-content.agent-cnt").find("ul.mainul").append(UlData);
            }
            else {
                UlData = $(
                    '<li LajFk = "' + AgentData[i].LajPk + '"Sertype = "' + AgentData[i].ServiceType + '" AgtFk = "' + AgentData[i].AgtPk + '"LavPk = "' + AgentData[i].Pk + '"class="' + clsNm + '">' +
                    '<div class="div-left">' +
                      '<div> <i class="icon-agents"></i>' +
                        '<p>' + AgentData[i].AgentJob + '</p>' +
                      '</div>' +
                      '<div>' +
                        '<h2>' + AgentData[i].AgentName + '</h2>' +
                        '<span>' + AgentData[i].LeadId + '</span>' +
                        '<p><span>' + AgentData[i].AppName + '</span> <span>' + AgentData[i].QDEActorNm + '</span> <span class="div-right">Allocated on : 08 Jun 2016</span></p>' +
                      '</div>' +
                    '</div>' +
                    '<div class="div-right align-center status">' +
                      '<div class="bg bg2"  onclick = "fnSaveChangedData(this);"><i class="icon-pending"></i></div>' +
                      '<p>Overdue 2 days</p>' +
                    '</div>' +
                    '<div class="clear"></div>' +
                  '</li>');
                $(".tab2-content.agent-cnt").find("ul.mainul").append(UlData);
            }
        }

    }

    if (ServiceFor == "SelDetails") {
        var data = JSON.parse(Obj.result);
        var maindiv = $('<div class="agent-content-drilldown">' +
                        '</div>');
        var CntChangediv = $("<div lavPk='"+ Param2 +"' class='agt_user_content' changeevt='0' contentchanged='false'></div>");
        $(maindiv).append(CntChangediv);
        if (data[0] && data[0] != null) {
            var ActorType = data[0].ActorType == 0 ? "Applicant" : "CoApplicant";
            var CommonDiv = '<div class="field-content">' +
                      '<div class="div-left grid-50">' +
                        '<p>' + data[0].LeadId + '</p>' +
                        '<p>' + data[0].AppNm + '</p>' +
                        '<p> <span>' + ActorType + '</span> , <span>' + data[0].Gender + '</span></p>' +
                        '<p>' + data[0].Contact + '</p>' +
                      '</div>' +
                      '<div class="div-right grid-50">' +
                        '<ul class="">' +
                          '<li class="width-9"> <span class="bg">' + data[0].AddrType + '</span> </li>' +
                          '<li class="width-12">' +
                            '<p>' + data[0].DoorNo + ',' + data[0].Street + '</p>' +
                            '<p>' + data[0].PlotNo + ',' + data[0].Building + '</p>' +
                            '<p>' + data[0].Area + ',' + data[0].District + '</p>' +
                            '<p>' + data[0].State + ',' + data[0].Country + '</p>' +
                            '<p>' + data[0].Pincode + '</p>' +
                          '</li>' +
                        '</ul>' +
                      '</div>' +
                      '<div class="clear"></div>' +
                    '</div>'
            var datediv = '<div class="fidt2">' +
                      '<ul class="fom-controls">' +
                        '<li class="div-left width-4">' +
                          '<label>Date of Report</label>' +
                          '<input name="text" key="agt_rptdt" type="text" class="datepicker">' +
                        '</li>' +
                        '<li class="div-right status">' +
                          '<p class="bg bg1"><i class="icon-positive" onclick = "fnReprtSts(this);"></i></p>' +
                            '<input name="text" key="agt_rptstatus" type="hidden" >' +
                        '</li>' +
                      '</ul>' +
                      '<textarea name="text" key="agt_notes"></textarea>' +
                      '<ul class="div-left attachment-div">' +
                        '<li> <span><i class="icon-attach"></i> report.pdf <i class="icon-down-arrow"></i></span>' +
                          '<ul class="attach-dd" style="display:none;">' +
                            '<li>Remove</li>' +
                            '<li>Download</li>' +
                          '</ul>' +
                        '</li>' +
                      '</ul>' +
                      '<span class="div-right bg-blue"><i class="icon-attach"></i> Attach</span> </div>' +
            '<div class="clear"></div>'
                    if (data[0].ServiceType == 0 || data[0].ServiceType == 1 || data[0].ServiceType == 3) {
                        var fieldDiv = $(
                            CommonDiv +
                            datediv
                          );
                        $(CntChangediv).append(fieldDiv);
                        $(".field-pop[LavPk = " + data[0].LavPk + "]").after(maindiv);
                    }
                    if (data[0].ServiceType == 2) {
                        var fieldDiv = $(
                            CommonDiv +
                    '<div class="agent-document-list document-entry">' +
                      '<h2>Documents</h2>' +
                      '<div class="documents attach-icon doc-list-view">' +
                        '<ul>' +
                          '<li>' +
                            '<h5>' + data[0].DocCatogory + '</h5>' +
                            '<p>' + data[0].DocSubCatogory + '</p>' +
                          '</li>' +
                          '<li>' +
                            '<textarea name="text" key="agt_FdbkNotes"></textarea>' +
                          '</li>' +
                          '<li class="status">' +
                            '<p class="bg bg1"><i class="icon-positive" onclick = "fnReprtSts(this);"></i></p>' +
                          '</li>' +
                        '</ul>' +

                  '</div>' +
                  datediv
                  );
                        $(CntChangediv).append(fieldDiv);
                        $(".doc-pop[LavPk = " + data[0].LavPk + "]").after(maindiv);
                    }
                    if (data[0].ServiceType == 5) {
                        var fieldDiv = $(
                            CommonDiv +
                            '<div class="legal-content legal-agent">' +
                      '<ul class="grid-45 div-left box-div form-controls">' +
                        '<h2>Boundaries As Per Sale Deed</h2>' +
                        '<li class="width-98p">' +
                          '<label>East</label>' +
                          '<input name="text" key="agt_lftEst" type="text" >' +
                        '</li>' +
                        '<li class="width-98p">' +
                          '<label>West</label>' +
                          '<input name="text" key="agt_lftWst" type="text" >' +
                        '</li>' +
                        '<li class="width-98p">' +
                          '<label>North</label>' +
                          '<input name="text" key="agt_lftNor" type="text" >' +
                        '</li>' +
                        '<li class="width-98p">' +
                          '<label>South</label>' +
                          '<input name="text" key="agt_lftSou" type="text" >' +
                        '</li>' +
                      '</ul>' +
                      '<div class="grid-50 div-right box-div">' +
                        '<ul class="form-controls">' +
                          '<li class="width-48p">' +
                            '<label>Reference Number</label>' +
                            '<input name="text" key="agt_lftRefno" type="text" >' +
                          '</li>' +
                          '<h2>Property Valuation</h2>' +
                          '<li class="width-48p amount">' +
                            '<label>Market value</label>' +
                            '<i class="icon-indian-rupee"></i>' +
                            '<input name="text" key="agt_lftmgtval" type="text" >' +
                          '</li>' +
                          '<li class="width-48p amount">' +
                            '<label>Amenities amount </label>' +
                            '<input name="text" key="agt_amenAmt" type="text" >' +
                            '<i class="icon-indian-rupee"></i> </li>' +
                          '<li class="width-100p">' +
                            '<textarea></textarea>' +
                          '</li>' +
                          '<h2>&nbsp;</h2>' +
                          '<h2>&nbsp;</h2>' +
                        '</ul>' +
                      '</div>' +
                      '<div class="clear"></div>' +
                    '</div>' +
                            datediv
                            );
                        $(CntChangediv).append(fieldDiv);
                        $(".technical-popup[LajFk = " + data[0].LajFk + "]").after(maindiv);
                    }
                    if (data[0].ServiceType == 4) {
                        var fieldDiv = $(
                                          CommonDiv +
                                          '<div class="legal-content legal-agent">' +
                      '<ul class="grid-45 div-left box-div form-controls">' +
                        '<h2>Boundaries As Per Sale Deed</h2>' +
                        '<li class="width-98p read-only">' +
                          '<label>East</label>' +
                          '<input type="text" name = "text" key = "agt_Est" >' +
                        '</li>' +
                        '<li class="width-98p read-only">' +
                        '<label>West</label>' +
                          '<input type="text" name = "text" key = "agt_Wst " >' +
                        '</li>' +
                        '<li class="width-98p read-only">' +
                          '<label>North</label>' +
                        '<input type="text" name = "text" key = "agt_Nor" >' +
                        '</li>' +
                        '<li class="width-98p read-only">' +
                          '<label>South</label>' +
                          '<input type="text" name = "text" key = "agt_Sou">' +
                        '</li>' +
                      '</ul>' +
                      '<div class="grid-50 div-right box-div">' +
                        '<ul class="form-controls">' +
                          '<li class="width-48p">' +
                            '<label>Reference Number</label>' +
                            '<input type="text" name = "text" key = "agt_Refno">' +
                          '</li>' +
                          '<li class="width-48p">' +
                            '<label>Approval Plan Number</label>' +
                          '<input type="text" name = "text" key = "agt_AppplnNo">' +
                          '</li>' +
                          '<h2>Property Valuation</h2>' +
                          '<li class="width-48p amount">' +
                            '<label>Asset Cost</label>' +
                            '<i class="icon-indian-rupee"></i>' +
                            '<input type="text" name = "text" key = "agt_AstCost">' +
                          '</li>' +
                          '<li class="width-48p amount">' +
                            '<label>Registration Charges</label>' +
                            '<i class="icon-indian-rupee"></i>' +
                            '<input type="text" name = "text" key = "agt_Regchg">' +
                          '</li>' +
                          '<li class="width-48p amount">' +
                            '<label>Stamp Duty Charges</label>' +
                            '<i class="icon-indian-rupee"></i>' +
                            '<input type="text" name = "text" key = "agt_stmpchg" >' +
                          '</li>' +
                          '<li class="width-48p amount">' +
                            '<label>Agreement Value</label>' +
                            '<i class="icon-indian-rupee"></i>' +
                            '<input type="text" name = "text" key = "agt_agtval" >' +
                          '</li>' +
                          '<h2>&nbsp;</h2>' +
                          '<h2>&nbsp;</h2>' +
                          '<h2>&nbsp;</h2>' +
                      '  </ul>' +
                      '</div>' +
                      '<div class="clear"></div>' +
                    '</div>' +
                      datediv);
                        $(CntChangediv).append(fieldDiv);
                        $(".legal-popup[LajFk = " + data[0].LajFk + "]").after(maindiv);
                    }
        }
        fnAgtBindEvts();
    }
}


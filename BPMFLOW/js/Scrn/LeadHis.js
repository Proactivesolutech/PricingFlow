var HisGlobal = [{}];
$(document).ready(function () {
    debugger;
    fnloaddetails();
});
function fnloaddetails() {
    debugger;
    var LeadFk = gup("lead","");
    var verfk = gup("version", "");
    var objProcData = { ProcedureName: "PrcGetLeadHis", Type: "SP", Parameters: [LeadFk, verfk] };
    fnCallWebService("DOC_LIST", objProcData, fnhisResult, "MULTI");
}
function fnhisResult(secaction, Obj, param1, param2) {
    debugger;
    if (secaction == "DOC_LIST") {
        //var data1 = JSON.parse(Obj.result_1);
        //var data2 = JSON.parse(Obj.result_2);
        //var Hisdata = JSON.parse(Obj.result_3);
        //var data3 = JSON.parse(Obj.result_4);
        //var Compata = JSON.parse(Obj.result_5);
        //var data4 = JSON.parse(Obj.result_6);
        //var Pendata = JSON.parse(Obj.result_7);
        //var data5 = JSON.parse(Obj.result_8);
        var Penursrefata = JSON.parse(Obj.result_7);
        //var data6 = JSON.parse(Obj.result_10);
        var Ritscrndata = JSON.parse(Obj.result_9);
        //if (Hisdata != "") {
        //    var ul = "";
        //    for (var i = 0; i < Hisdata.length; i++) {
        //        ul = $('<ul class="form-controls">' +
        //                                '<li class="read-only">' +                                        
        //                                 '<p>' + Hisdata[i]["Screen Name"] + '</p>' +
        //                               '</li>' +
        //                               '<li class="read-only">' +                                        
        //                                 '<p>' + Hisdata[i]["Source Screen"] + '</p>' +
        //                               '</li>' +
        //                               '<li class="read-only">' +                                         
        //                                 '<p>' + Hisdata[i]["Target Screen"] + '</p>' +
        //                               '</li>' + '</ul>');
                                      
        //        $("#fulHtmlhisdivId").append(ul);
        //    }

        //}
        //if (Compata != "") {
        //    var ul = "";
        //    for (var i = 0; i < Compata.length; i++) {
        //        ul = $('<ul class="form-controls">' +
        //                                '<li class="read-only width-19">' +                                        
        //                                 '<p>' + Compata[i]["Screen Name"] + '</p>' +
        //                               '</li>' +
        //                               '<li class="read-only width-19">' +                                       
        //                                 '<p>' + Compata[i]["Source Screen"] + '</p>' +
        //                               '</li>' +
        //                               '<li class="read-only width-19">' +                                    
        //                                 '<p>' + Compata[i]["Target Screen"] + '</p>' +
        //                               '</li>' + '</ul>');

        //        $("#fulHtmlcompdivId").append(ul);
        //    }

        //}
        //if (Pendata != "") {
        //    var ul = "";
        //    for (var i = 0; i < Pendata.length; i++) {
        //        ul = $('<ul class="form-controls">' +
        //                                '<li class="read-only width-19">' +                                        
        //                                 '<p>' + Pendata[i]["Screen Name"] + '</p>' +
        //                               '</li>' +
        //                               '<li class="read-only width-19">' +                                       
        //                                 '<p>' + Pendata[i]["Source Screen"] + '</p>' +
        //                               '</li>' +
        //                               '<li class="read-only width-19">' +                                     
        //                                 '<p>' + Pendata[i]["Target Screen"] + '</p>' +
        //                               '</li>' + '</ul>');

        //        $("#fulHtmlpendivId").append(ul);
        //    }

        //}
        if (Penursrefata != "") {
            var ul = "";
            for (var i = 0; i < Penursrefata.length; i++) {
                ul = $('<ul class="form-controls">' +
                                        '<li class="read-only width-19">' +                                      
                                         '<p>' + Penursrefata[i].ScreenName + '</p>' +
                                       '</li>' +
                                       //'<li class="read-only width-19">' +                                        
                                       //  '<p>' + Penursrefata[i].SourceScreen + '</p>' +
                                       //'</li>' +
                                       //'<li class="read-only width-19">' +                                        
                                       //  '<p>' + Penursrefata[i].TargetScreen+ '</p>' +
                                       //'</li>' +
                                       '<li class="read-only width-19">' +                                        
                                         '<p>' + Penursrefata[i].UsrNm + '</p>' +
                                       '</li>'+'</ul>');

                $("#PenursrefdataId").append(ul);
            }

        }
        if (Ritscrndata != "") {
            var ul = "";
            for (var i = 0; i < Ritscrndata.length; i++) {
                ul = $('<ul class="form-controls">' +
                                        '<li class="read-only width-19">' +                                      
                                         '<p>' + Ritscrndata[i]["Screen Name"] + '</p>' +
                                       '</li>' +
                                       //'<li class="read-only width-19">' +                                      
                                       //  '<p>' + Ritscrndata[i]["Source Screen"] + '</p>' +
                                       //'</li>' +
                                       //'<li class="read-only width-19">' +                                        
                                       //  '<p>' + Ritscrndata[i]["Target Screen"] + '</p>' +
                                       //'</li>' +
                                        '<li class="read-only width-19">' +                                      
                                         '<p>' + Ritscrndata[i].UsrNm + '</p>' +
                                       '</li>' + '</ul>');

                $("#Ritscrndata").append(ul);
            }

        }

    }
}

function gup(name, url) {
    if (!url) url = location.href;
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(url);
    return results == null ? null : results[1];
}
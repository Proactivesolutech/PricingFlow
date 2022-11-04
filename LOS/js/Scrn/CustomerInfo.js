var cusGlobal = [{}];
$(document).ready(function () {
    var leadpk = localStorage.getItem("LeadPK");
    cusGlobal[0].LeadFk = leadpk;
    fnloaddetails();
});
function fnloaddetails() {
    var objProcData = { ProcedureName: "CustomerInfo", Type: "SP", Parameters: ["SELECT", JSON.stringify(cusGlobal)] }
    fnCallLOSWebService("DOC_LIST", objProcData, fnCusResult, "MULTI");
}
function fnCusResult(secaction, Obj, param1, param2) {
    debugger;
    if (secaction == "DOC_LIST") {
        var cusdata = JSON.parse(Obj.result);
        //var codata = JSON.parse(Obj.result_2);
        if (cusdata != "") {
            var ul = "";
            for (var i = 0; i < cusdata.length; i++) {
                ul = $('<div class="box-div" style="height:245px;">' + '<table>' + '<tr>' + '<td>' +
                                         '<label>' + '<h2 class="read-only width-19">' + cusdata[i].actor + '</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdeNm + '</p>' + '</td>' + '</tr>' +
                                          '<tr>' + '<td>' +
                                         '<label>' + '<h2>Father Name</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].FatherName + '</p>' + '</td>' + '</tr>' +
                                         '<tr>' + '<td>' +
                                         '<label>' + '<h2>DOB</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdeDob + '</p>' + '</td>' + '</tr>' +
                                         '<tr>' + '<td>' +
                                         '<label>' + '<h2>Gender</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdeGender + '</p>' + '</td>' + '</tr>' +
                                         '<tr>' + '<td>' +
                                         '<label>' + '<h2>Mobile No</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdemob + '</p>' + '</td>' + '</tr>' +
                                         '<tr>' + '<td>' +
                                         '<label>' + '<h2>PAN NO</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdepan + '</p>' + '</td>' + '</tr>' +
                                         '<tr>' + '<td>' +
                                         '<label>' + '<h2>Driving License</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdedrvlic + '</p>' + '</td>' + '</tr>' +
                                          '<tr>' + '<td>' +
                                         '<label>' + '<h2>Passport Number</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].passnum + '</p>' + '</td>' + '</tr>' +
                                          '<tr>' + '<td>' +
                                         '<label>' + '<h2>Voter ID</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdeVotId + '</p>' + '</td>' + '</tr>' +
                                          '<tr>' + '<td>' +
                                         '<label>' + '<h2>Aadhar No</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].qdeAdhar + '</p>' + '</td>' + '</tr>' +
                                         '<tr>' + '<td>' +
                                         '<label>' + '<h2>JOB PROFILE</h2>' + '</label>' + '</td>' +
                                         '<td>' + '<p class="read-only width-19">' + cusdata[i].emptyp + '</p>' + '</td>' + '</tr>' + '</table>' + '</div>');

                $("#fulHtmlleftdivId").append(ul);
                                       

                addul = $('<div class="box-div" style="height:245px;">' + '<table>' +
                                '<tr>' + '<td>' +
                               '<label>' + '<h2>Door No</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].door + '</p>' + '</td>' + '</tr>' +
                               '<tr>' + '<td>' +
                               '<label>' + '<h2>Building</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].building + '</p>' + '</td>' + '</tr>' +
                               '<tr>' + '<td>' +
                               '<label>' + '<h2>Plot No</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].plot + '</p>' + '</td>' + '</tr>' +
                               '<tr>' + '<td>' +
                               '<label>' + '<h2>Street Name</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].str + '</p>' + '</td>' + '</tr>' +
                               '<tr>' + '<td>' +
                               '<label>' + '<h2>LandMark</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].landmark + '</p>' + '</td>' + '</tr>' +
                               '<tr>' + '<td>' +
                               '<label>' + '<h2>Town/Village</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].city + '</p>' + '</td>' + '</tr>' +
                                '<tr>' + '<td>' +
                               '<label>' + '<h2>District</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].dist + '</p>' + '</td>' + '</tr>' +
                                '<tr>' + '<td>' +
                               '<label>' + '<h2>State</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].state + '</p>' + '</td>' + '</tr>' +
                                '<tr>' + '<td>' +
                               '<label>' + '<h2>Pin Code</h2>' + '</label>' + '</td>' +
                               '<td>' + '<p class="read-only width-19">' + cusdata[i].qdePin + '</p>' + '</td>' + '</tr>' +
                               '</table>' + '</div>');

                $("#fulHtmlrightdivId").append(addul);
                                     
            }
           
        }

    }
}

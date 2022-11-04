var obj;

var g_langlist = ["English", "हिन्दी"];

var English = '{"LgnIn" : "Login","Reg":"Register","NfySgnUp":"Haven’t signed up yet?","RegNw":" Register now","SgnUp":"Sign Up","SgnIn":"Sign in","TConds" :"By signing up, I agree with Wedplanner Terms of Service.","AldySgnUp":" Already signed up? ","LgnHr":"Login here","CrAc":"Create Account","RU":"Are You?","CplDesc":"For Brides, Grooms.<br>Manage Wedding Events.<br>Save and share wedding ideas.<br>Join wedding discussions.<br>Follow your favorite vendors and brands.","Cpl":"Couples","VendDesc":"For Wedding Professionals.<br>Create your own customized profile.<br>Connect with Wedding couples.<br>Post your packages and promotions.<br>Manage enquiries from couples.","Vndr":"Vendor","BusProf":"Business Profile","CtrlPanl":"Control Panel","TmMgmt":"Team Management","Mrgs":"Marriages","Promo":"Promotions","SgnOt":"Sign Out","AbtUs":"About Us","Amnty":"Amenities","CntDtls":"Contact Details","Glry":"Gallery","OthrServ":"Other Services","AdServ":"Add Services","BusNm":"Business Name","SelBusCatg":"Select Your Business Category","Loc":"Location","Submit":"Submit","TmMbr":"Team Member","Nm":"Name","MobNum":"Mobile Number","email":"Email Id","role":"Role","Mgs":"Marriages","WedInfo":"Wedding Information","WedImg":"Wedding Image","WedNm":"Wedding Name","WedDt":"Wedding Date","WedLoc":"Wedding Location","CelbInfo":"Celebrant Information","IBrd":"I am the Bride","IGrm":"I am the Groom","BrdNm":"Bride\'s Name","BrdMail":"Bride\'s Email","GrmNm":"Groom\'s Name","GrmMail":" Groom\'s Email","A_S_P":"Add social pages","FB":"Facebook","GP":"Google Plus","PI":"Pinterest","Twt":"Twitter","Crt":"CREATE","Evt":"Event","Itry":"Itineraries","ideas":"Ideas","Doc":"Documents","task":"Task","notes":"Notes","GstLst":"Guest List","Budget":"Budget","Sumry":"Summary","Dtls":"Details","Exps":"Expenses","Prodr":"Providers","Ctgry":"Category","ExpHd":"Expenses Head","Desc":"Description","Clsfy":"Classification","Cmtd":"Committed","Paid":"Paid","Itry2":"Itinerary","All":"All","Pndng":"Pending","ODue":"Overdue","Cmptd":"Completed","TskMgmt":"Task Management","Asgnd":"Assigned","SfyLst":"The Simplified<br>List","PrvLst":"Preview List","Impt":"Import","SmplChkLst":"Simple Starting Checklist","PckChkLst":"Pickup a Checklist","TskLst":"Task List","TskNF":"No task found","TskNm":"Task Name","DDt":"Due Date","Ownr":"Owner","MrkCmpl":"Mark Complete","Doct":"Document","DocLst":"Document List","note":"Note","WedBrd":"Wedding Ideas Board ","AddBrd":"Add New Board","Invte":"Invitees","MstrGLst":"Master Guest list","Expt":"Export","AddGst":"Add Guest","Group":"Group","emailId":"Email Id","VndrDtls":"Vendor Details ","CompNm":"Company Name","Addrs":"Address","Map":"Map","Vndrs":"Vendors","Doc2":"Docs","Nbk":"Notebook","WbstCrtn":"Website Creation","Evts":"Events","Ques":"Question","Mand":"Mandatory","SelLst":"Selection List","PbUrl":"Published Url","SgOut":"Sign Out","totbgt":"Total Budget","GoToVenPg":"GoTo Vendor Page","EvtEgtext":"i.e.Event name, etc...","CrtEvtText":"Create new event","add":"Add"}';
var Tamil = '{"LgnIn" : "உள் நுழை","Reg":"பதிவு","NfySgnUp":"க","RegNw":"இப்போது பதிவு","SgnUp":"க","SgnIn":"க","TConds" :"க","AldySgnUp":"க ","LgnHr":"க","CrAc":"க","RU":"நீங்கள்?","CplDesc":"க<br>க<br>க<br>க.<br>க","Cpl":"தம்பதி","VendDesc":"க.<br>க.<br>க.<br>க.<br>க","Vndr":"விற்பனையாளர்","BusProf":"க","CtrlPanl":"க","TmMgmt":"க","Mrgs":"க","Promo":"க","SgnOt":"க","AbtUs":"க","Amnty":"க","CntDtls":"க","Glry":"க","OthrServ":"க","AdServ":"க","BusNm":"க","SelBusCatg":"க","Loc":"க","Submit":"க","TmMbr":"க","Nm":"க","MobNum":"மொபைல் எண்","email":"க","role":"க","Mgs":"க","WedInfo":"க","WedImg":"க","WedNm":"க","WedDt":"க","WedLoc":"க","CelbInfo":"க","IBrd":"க","IGrm":"க","BrdNm":"க","BrdMail":"க","GrmNm":"க","GrmMail":"க","A_S_P":"க","FB":"க","GP":"க","PI":"க","Crt":"க","Evt":"க","Itry":"க","ideas":"க","Doc":"க","task":"க","notes":"க","GstLst":"க","Budget":"க","Sumry":"க","Dtls":"க","Exps":"க","Prodr":"க","Ctgry":"க","ExpHd":"க","Desc":"க","Clsfy":"க","Cmtd":"க","Paid":"க","Itry2":"க","All":"க","Pndng":"க","ODue":"க","Cmptd":"க","TskMgmt":"க","Asgnd":"க","SfyLst":"க<br>க","PrvLst":"க","Impt":"க","SmplChkLst":" க","PckChkLst":"க","TskLst":"க","TskNF":"க","TskNm":"க","DDt":"க","Ownr":"க","MrkCmpl":"க","Doct":"க","DocLst":"க","note":"க","WedBrd":"க","AddBrd":"க","Invte":"க","MstrGLst":"க","Expt":"க","AddGst":"க","Group":"க","emailId":"க","VndrDtls":"க","CompNm":"க","Addrs":"க","Map":"க","Vndrs":"க","Doc2":"க","Nbk":"க","WbstCrtn":"க","Evts":"நிகழ்வுகள்","Ques":"க","Mand":"க","SelLst":"க","PbUrl":"க","SgOut":"க","totbgt":"க","Twt":"க","GoToVenPg":"க","EvtEgtext":"க","CrtEvtText":"க","add":"க"}';


$(document).ready(function () {
    assignLanguage();
    SetLanguage();
});
function assignLanguage() {


  //  if (getLocalStorage("Lang") == "0") {

    obj = JSON.parse(English);

//    }
//    if (getLocalStorage("Lang") == "1") {
//        obj = JSON.parse(Hindi);
//    }
}


function SetLanguage() {
  //  alert(obj.LgnIn + '' + $('#indxLgnin').text);
  
    $('#regHdrSgnUp').html(obj.SgnUp);
    $('#btnLogin').val(obj.LgnIn);
    $('#regTConds').html(obj.TConds);
    $('#LgnNfySgnUp').html(obj.NfySgnUp);
    $('#indxLgnin').html(obj.LgnIn);
    $('#indxReg').html(obj.Reg);
    $('#LgnRegNw').html(obj.RegNw);
    $('#LgnHdrSgnIn').html(obj.SgnIn);
    $('#regAdySgnUp').html(obj.AldySgnUp);
    $('#regLgnHr').html(obj.LgnHr)
    $('#btnRegister').val(obj.CrAc);
    $('#sgnInHdrRU').html(obj.RU);
    $('#sgnCplDesc').html(obj.CplDesc);
    $('#sgnBtnCpl').html(obj.Cpl);
    $('#sgnVendDesc').html(obj.VendDesc);
    $('#sgnBtnVndr').html(obj.Vndr);
    $('#viSpnBusProf').html(obj.BusProf);
    $('#viSpnCtrlPanl').html(obj.CtrlPanl);
    $('#viSpnTmMgmt').html(obj.TmMgmt);
    $('#viSpnMrge').html(obj.Mrgs);
    $('#viSpnPromo').html(obj.Promo);
    $('#viSgnOut').html(obj.SgnOt);
    $('#vbiAbtUs').html(obj.AbtUs)
    $('#vbiAmnty').html(obj.Amnty);
    $('#vbiCntDtls').html(obj.CntDtls);
    $('#vbiBusProfHdr').html(obj.BusProf);
    $('#vbtHdrGlry').html(obj.Glry);
    $('#vabtOthServ').html(obj.OthrServ);
    $('#ven_ser_heading').html(obj.AdServ);


    $('#VAbtBusNm').html(obj.BusNm);
    $('#VAbtLblSelCat').html(obj.SelBusCatg);
    $('#VAbtLoc').html(obj.Loc);
    $('#ven_DtlsSubmit').val(obj.Submit);
    $('#SpnTmMbrHdr').html(obj.TmMbr);
    $('#hdrTmMbr').html(obj.TmMbr);
    $('#spnTmMbrNm').html(obj.Nm);
    $('#TmMemMobNum').html(obj.MobNum);
    $('#TmMbrMail').html(obj.email);
    $('#TmMbrRole').html(obj.role);
    $('#TmMbrLoc').html(obj.Loc);
    $('#spnVenHdrMg').html(obj.Mgs);
    $('#WCrHdrCelbInfo').html(obj.CelbInfo);
    $('#SpnWCrWedLoc').html(obj.WedLoc);
    $('#SpnWCrWedDt').html(obj.WedDt);
    $('#spnWCrWedNm').html(obj.WedNm);
    $('#WCrHdrWedImg').html(obj.WedImg);
    $('#SpnHdrWedInfo').html(obj.WedInfo);

    $('#lbl_ImBride').html(obj.IBrd);
    $('#lbl_ImGroom').html(obj.IGrm);
    $('#WCrBrdNm').html(obj.BrdNm);
    $('#WcrBrdMail').html(obj.BrdMail);
    $('#WCrGrmNm').html(obj.GrmNm);
    $('#WCrGrmMail').html(obj.GrmMail);

    $('#lbladd_scl').html(obj.A_S_P);
    $('#WCrSpnFb').html(obj.FB);
    $('#WCrSpnGP').html(obj.GP);
    $('#WCrSpnPin').html(obj.PI);
    $('#UsrSpnHdrEvt').html(obj.Evt);
    $('#UsrEvtSpnItry*').html(obj.Itry);

    $('#UsrEvtSpnIdea*').html(obj.ideas);
    $('#UsrEvtSpnDoc*').html(obj.Doc);
    $('#UsrEvtSpnTsk*').html(obj.task);
    $('#UsrEvtSpnNts*').html(obj.notes);

    $('#UsrEvtSpnGLst*').html(obj.GstLst);
    $('#UsrBgtSpnHdr').html(obj.Budget);
    $('#tab_1').html(obj.Sumry);
    $('#tab_2').html(obj.Dtls);
    $('#tab1_6').html(obj.Exps);
    $('#tab1_7').html(obj.Prodr);
    $('#tab1_8').html(obj.notes);

    $('#UsrBgtCtg').html(obj.Ctgry);
    $('#UsrBgtExpHd').html(obj.ExpHd);
    $('#UsrBgtSpnBgt').html(obj.Budget);

    $('#UsrBgtDesc').html(obj.Desc);
    $('#UsrBgtClsfy').html(obj.Clsfy);
    $('#UsrBgtCmtd').html(obj.Cmtd);
    $('#UsrBgtPaid').html(obj.Paid);
    $('#UsrBgtSpnBgt').html(obj.Budget);
    $('#UsrEvtItry').html(obj.Itry2);
    $('#UsrTskAll').html(obj.All);
    $('#UsrTskPndg').html(obj.Pndng);
    $('#UsrTskODue').html(obj.ODue);
    $('#UsrTskCmptd').html(obj.Cmptd);
    $('#UsrTskMgmt').html(obj.TskMgmt);
    $('#Tsk_tab_1').html(obj.Sumry);
    $('#Tsk_tab_2').html(obj.Clsfy);
    $('#Tsk_tab_3').html(obj.Asgnd);
    $('#UsrTskSfyLst').html(obj.SfyLst);
    $('#UsrTskPrvLst').html(obj.PrvLst);
    $('#UsrTskImpt').html(obj.Impt);

    $('#UsrTskSmplChkLst').html(obj.SmplChkLst);
    $('#UsrTskPckupLst').html(obj.PckChkLst);
    $('#UsrTskLst').html(obj.TskLst);
    $('#UsrTskNoTsk').html(obj.TskNF);

    $('#UsrTskLbl').html(obj.task);
    $('#UsrTskNm').html(obj.TskNm);
    $('#UsrTskDueDt').html(obj.DDt);
    $('#UsrTskClsfy').html(obj.Clsfy);
    $('#UsrTskOwnr').html(obj.Ownr);

    $('#UsrTskDesc').html(obj.Desc);
    $('#UsrTskMrkCmpl').html(obj.MrkCmpl);
    $('#UsrTskDoc').html(obj.Doc);
    $('#UsrTskDocTtl').html(obj.Doct);
    $('#UsrTskDocLst').html(obj.DocLst);

    $('#UsrTskNte').html(obj.note);
    $('#UsrHdrIdea').html(obj.ideas);
    $('#UsrIdeaWedBrd').html(obj.WedBrd);
    $('#UsrIdeaAddBrd').html(obj.AddBrd);
    $('#UsrInvteSpnHdr').html(obj.Invte);
    $('#UsrInvMstrGLst').html(obj.MstrGLst);

    $('#UsrInvSpnImpt').html(obj.Impt);
    $('#UsrInvSpnExpt').html(obj.Expt);
    $('#Inv_AddrEditTitle').html(obj.AddGst);

    $('#UsrInvGstGrp').html(obj.Group);
    $('#UsrInvGrpNm').html(obj.Nm);
    $('#UsrInvMailID').html(obj.emailId);
    $('#UsrInvMobNo').html(obj.MobNum);
    $('#UsrVenHdr').html(obj.Vndr);

    $('#UsrVendSpnDtls').html(obj.VndrDtls);
    $('#UsrVndrCompNm').html(obj.CompNm);
    $('#UsrVndrCatg').html(obj.Ctgry);
    $('#UsrVndrNm').html(obj.Nm);
    $('#UsrVndrEmail').html(obj.emailId);
    $('#UsrVndrLoc').html(obj.Loc);
    $('#UsrVndrAddrs').html(obj.Addrs);
    $('#UsrVndrClsfy').html(obj.Clsfy);

    $('#UsrVndrCmtd').html(obj.Cmtd);
    $('#UsrVndrPaid').html(obj.Paid);

    $('#UsrEvtLstMap').html(obj.Map);
    $('#UsrEvtLstInvte').html(obj.Invte);
    $('#UsrEvtLstItry').html(obj.Itry2);
    $('#UsrEvtLstVndr').html(obj.Vndrs);
    $('#UsrEvtLstDoc').html(obj.Doc2);
    $('#UsrEvtLstNbk').html(obj.Nbk);
    $('#UsrVndrMobNo').html(obj.MobNum);
    $('#UsrBdtMnu').html(obj.Budget);
    $('#UsrEvtMnu').html(obj.Evts);
    $('#UsrTskMgtMnu').html(obj.TskMgmt);
    $('#UsrIdsMnu').html(obj.ideas);
    $('#UsrIvtMnu').html(obj.Invte);
    $('#UsrVenMnu').html(obj.Vndrs);
    $('#UsrWbcrtMnu').html(obj.WbstCrtn);
    $('#spnAmtyCatg').html(obj.Ctgry);
    $('#spnAmtyQues').html(obj.Ques);
    $('#spnAmtyMand').html(obj.Mand);
    $('#AmtyCatg').html(obj.Ctgry);
    $('#spnSelLst').html(obj.SelLst);

    $('#WCrSpnPbUrl').html(obj.PbUrl);
    $('#SgnOt').html(obj.SgOut);
    $('#TotBgt').html(obj.totbgt);
    $('#Bud_Comm_Total').html(obj.Cmtd);
    $('#Bud_Head_Total').html(obj.Budget);
    $('#Bud_Paid_Total').html(obj.Paid);
    $('#Bud_Comm_Total1').html(obj.Cmtd);
    $('#indxLgnin').html(obj.LgnIn);
    $('#indxReg').html(obj.Reg);
    $('#WCrSpnWeb').html(obj.PbUrl);
    $('#WCrSpnTwt').html(obj.Twt);
    $('#go_ven_page').html(obj.GoToVenPg + "<i class='fa fa-long-arrow-left right'></i>");
    $('#CrtEvtTxt').html(obj.CrtEvtText);
    $('#EvtEgTxt').html(obj.EvtEgtext);
  //  $('#Add_Ven_Galry').html(obj.add);
}
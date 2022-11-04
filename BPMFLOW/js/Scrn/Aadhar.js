function Capture(AadharVal) {
    try {

        //var data = { "status": true, "error": "", "ResultCount": 0, "result": "{\"SynKycRes\":[{\"UidData\":{   \"uid\":\"297606527580\",   \"Code\":\"0612e23fafbf4cb3b12417f415aca640\",   \"TxnID\":\"UKC:public:20160920185129632\",   \"TimeStamp\":\"2016-09-20T18:51:31.576+05:30\"},\"Poi\":{   \"name\":\"Praveenraj\",   \"dob\":\"20-04-1994\",   \"gender\":\"M\",   \"phone\":\"NA\",   \"email\":\"NA\"},\"Poa\":{   \"co\":\"S/O Janarthanan\",   \"dist\":\"Viluppuram\",   \"house\":\"1/75\",   \"loc\":\"VANUR  TALUK\",   \"pc\":\"604102\",   \"state\":\"Tamil Nadu\",   \"vtc\":\"Siruvalur (ten)\",   \"vtcCode\":\"33070300536500\",   \"street\":\"NEDU STREET\",   \"lm\":\"M\",   \"subdist\":\"NA\",   \"po\":\"Thensiruvalur\"},\"Pht\":\"/9j/4AAQSkZJRgABAgAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCADIAKADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD0OinYoxTM7jcU0in4pMUCITSr1pWFKooEOUcU4CgCngUDExQRxT8UYoAiYVA9WXHFQsD3pgVz1pRTjQBSAKRulPAz9aawoAhIqM1Kw5qM9KAGUlONJQFzYopRRigY000jrT8UhHHSgkiahe1KwpE+tAEgzTxTR1pS6qCWYAAZJJ4oGOorC1DxfomnxuW1G2kkQ4MccgZh9QOcVyV78UIzuFvbqp5AYuSD6HGB7/55oA9HZh6j0xUbHOQCM+/415xbeN7i6Yi3CSEjO2Nwj556RsNrDGP4s9KtDxxLmRJTAki53ZBGcdsHvzxk8+voBY7GWZYld3PyjHTnqcDFPjcOgYZH1Uj+dchY+KLW7ukDyoCoAQk4DHHpzg+2T9eDXU29zFcR7o23D/dIP60AWc8Uh4FIDmg9KAI2OaYelOPJNMbPTNADe9JQaQ0AbYFLRRQMTFIRS96OxoEQt1qpd6haafAZru4jhQEDLEDP09aj1nU7fS7N57mXYozj1c4JwPfj9K8Y8SeJptXvS8mBEmREvUrnGefU47Y7fUgJXOu1v4nyRFo9JhiIzgSTgkkeoXI/X8RXF6l4u1fVY9t5fSSpziMBUX8QoAP4g1zskrkn0pnLrn+VBVkiWS5djk8/jUPng5HSomJH+IqIvuJx1pjLIuWjYMjEMDkEHGDRJfzTyB5JGZjxkmqa9yelPAyP60CLSXLr0Y5HStjTPEt/p8yvHO2O4JyCPQg8H/PSsEYI46k8Uu7a3sDQB7/4Y8Qw63ZeYCizLw6K2cf1GcdD79Ryd9m47V856Jrc+i6pHdwEZBwynoy+le56NrttrVklzbNlG4I7qe4PvSZLRqetMb71KTxTM/NmgQhpKCaDQBuUUUtBQlJ+IpTSFA42FQwPGKBHkXxC8SRXkyWtqVeKMksysDz07E/5NedyPvyxPFbniWezn1i8ewRUtTKfLC9CPUex6/jXPM2CQO9BS2HySRooUc+/pUEj/uyyn6gUFS+QetEdoW46UXsNFfO5SwP1FCqMnitAaaQMg8GmyWZVcKPrU86K5GZ2CCcVIBtjO489RUq2zDIKkMaZMhXg9RTTFykSy/gafglcg5pgiJ608YWPbk59KomxHuwa6Twn4ll0DUVdmLWkpCzJ6D+8PcfqOPTHLsOcipImyMGgLH0vDOsqDBBGOo71L71wHw/1eW50ZYJjlrZvKUk8lQAR+hx+Fd4rhkBFIloXtSd6U9KSkI3aKKKZQVQ1iZrXR725RSzw28kiqDgsVUkD8cYq/Wbr8Mtx4e1GGHPmPbSKvudp49/pQI+ebgLnCj5V4APpVMxM7gKPyq/cRncc9Ks6dalmLkcCk3ZGiV2V4NOKJmT73pVpI0QYAq1MQKqkN2rGTudMYpbE6RqfT8KcbZGHQVXG8U9WYDvUDsV57dc8cY9az5NP8yTJPy1qS7veqjlhVJktIqzwoo+XiqEkYBrQlJ5zVVxk1cWRJIoSLk02NfmH9atzR7Y94HA61WT5pAB3PStU7mDVj0DwbcCGAhT/AB4P1r06xl8yIEeleW6DCYrePA+ZuTXpmlKRbqT6UuopbGkxzTT0pe9J1OKCTfopKM0FC01uVI9RS0lAHgGvWv2TW721VNixXDqiD+Fc/KPyIp5JtbZY1UmQjOBXTeO9PRPGUbqoH2iJZZOcksMr0+ir+tZrRxxoZGAye57VM3Y2pK5zhecMWeNsewp8d5EDhlYfhVi5uQhyAQPU8D9aqy3dvKoDqre4INRa+6NG2tmaVvLazfxY+vFWhp4kTchzxmufiWPJMZOPQ1qWs00LZRuD1HrUNIpNtEsthjGR35qpPbRoOWH4mn6hqEygrwD3NYFxctK3LcdetFriuWbjyVz86/nWbLNEvIbJ9BUkdq0oyVdlprC3QYEYGPUVaSRDk2EbJcxOg4bHQ1Ts4zLcpGByzAZq5EitKrLwfatDQrH/AEmaVh91yo+taJmTR12i2+ZY0xwteh2sYSFRXKeHrQl95HFdgBgUIiW4o6H3pM+9OOQuKYelMk3s0vamZpc0yxc1geL9Zl0bQJJbdtt1MwiiJGcE8k/goOD6kVvVwHxJIE+jlxkfvsD/AL95/pSYJXZyKTXV1cma6uJrhkjCK8zl2wSTjJ5POaLpzImxCAe24ZApbYZgbHUNjP4CopUKnNZSZ1Rj2GJFpg024t7+KQX78x3LZZCMggcAlfTgVj2OmxreJLfkC2QHaFTJYc4GVHr3POB7cabqJMAmkEVvEpLkH270KRMolDy4Y5X8re0Y5ViCPwORT1nYDinSCS5baBtjHRaUxBE2gVEmaQizNvpnc85qvBHGAWk5bcAvoPc1YvFINV4JmhkzjKnqKqL0ImtSzqsENnInlXEt1C8R3eVIFw5BAzweAdpxjkZAIPIrwacn9lPNcOYZi2Y9x6jHpV6RlkizExKnqp5rPa3cmq5tLEKJDASsmGGCK0oNUOnXBURb1Yhzz1yKreUQeaJ0HmQMfQiqTJtY9n8PrE9jFNEwZHQMp9QRkVtdW+tcT4Fu2GmQwOTld/X03HFdrGctVGMtxWIzimE/Nj3p/JY+1Rk/MaBG52pRTc8UuaZYtcB8ScmfSF6Lift3/d4rvs1w/wAQYy7aewXJXzcccc7P8KT2HHc47T8m1IYc7jmnzop7U2zyFcNwc5qaXkVizqjoZkseOlRrbk845q66nPNNZgq4H4mouVYqOREMKu5z+lILeWTovJ7VJNd7dsUEIZz1LHFQw39583m27Jt/iB4pO9irpFS8tHQkOpBrKCYfBFaN7qbu5GGdjxgDJqqzNHEDMmwsMgEgmqjexnKzYBGU5U4qUNkfMOaWFg0C7hzjvUcjgUANkaorxzttx3yT/KkLbmplwd80cf8AdX+taRRjN3Z6T4STLQ46CMV3kY+UmuH8IECNBwTsAzXbg/u8VaMZbgvKk0wdOaex2xgetMY8UxG3S0lFBQVDc28N1CYbiGOWM8lJFDA/gampKAOA8QaXFYyeZBBHEhbHyKBn/OKwSRyK9J1+z+1aTcBFy4XcuBySDnA9yAR+NeaOQCazmjanK+hDMMJms2WZV6tzVy6kPk4U1hzMok+fP4CpUbmrlYle8AHyjNM+3s3ysevaohKjH5IyQO5pzSrtwY1IPqtOxLk2VJ3COSp5PXFQrOu4k9fU1JM4yRtAHoBVR3Qn0p2I5mW/OGMhqiZ91ViSOVPHpUqNuUUKIOVyROXFakGj+ZIJmlb5gPlA6fjVC0jMtyiDuea7Cxg3uigdTirINXw4n2eVURSFAwBXahu1ZOnWKQ7WwM1qrjcPamZt3HO2cCmk5cU7q2aYTgkigRuZpc0zNANBQ/NIWppNNzQBJuIIINeXeINPOmak8ariCT54SPT0/Dp9MHvXppPy1g+JrVLnSLjcOY0MinHII5pNXHF2Z5lN0qqY0Pap2fDFG6io2XuKyOkrs6Qk4T8qhkvYhgCPP4VYkjJ/GomtV20XE0Up7tXGAgH4VQOGbOOKvTwgHrVGQ44FNPsQ0NkbdQpwKYaWMhpFGepxVohm3pEHJlYdeBXZ6LDvnU44FYFpEAFVQABwAK7PRbfy4wx60xM3ogFA46CpVPPFQqacD70zMkDdT0qPPH1pd2ExTGoA3s0ZpuaM0FDs0mabupC1IY7PFZurIJdOuUYgBoXBJ7cVeLcVy3jbUTaaOEBI81sE9sDnH+fSi4jgblQx9COhqk0zRHDjj1q00gcBgevNROAyEGsrnVbqV2u1I4NU5Lli3UU6e2GTgkVQlt5ByGp2RLkyaWUY65zVJ37monEwOMioSkhPzMapRsQ5XHyTZ+Valt1IdWb1pkcIXk81LnHNO4rHeaMq3DRkkYIB5ruLZBHEAK848PXphghkOTgZP05H9DXfafqEF5ErRSq24ZAB5oM5GmDgU4HpUO7il3HNMmxMSCAKYTzTS3pTS2TQBv5oJpmaazqqlmIAAySeAKCyQmmk1i3/AIktLTcsR86XBAC/dz9fT1IzjBzXO3utTXcCPO6ESHAijk4we23jd9efwpNjSOnv9dsrBCXk3NnAVe5zjGenX8a43XL2TWdEa5kKkNO6xhBkKBuX8eQTnvWNNdSahdxQAjgkhhkDrwc9/XPTgYA5zr3ixwadFCiFIkhb5SQMfL+pyc0mx2OMsbzdEI2PI6VbL5rMv4vst/IEPyE5WpIrkletTJGsJaWLUgyKpykgHirAkB4NQyrx1qLltGYyncaj281alWoFGWq7mbQbSBTH4WpzwKjRPMmROcFgKEwaOitF8mzjXHKgA/kP/r0m+S3ZpoeCPmDLwQcYHI9NzGntgFwGJUsetNUFSvQg1RidJo/ix9oi1AFsdJQOevcD+npXSWeq2d8zLbTq7L1GCD+teZMBGWZfuk5Htxn+n+eKaJ9jDLEHnJHXNO4WPWt1ITXEab4pmtgsVyrTxEAL84Lr+Pf15/Ount9WsboJ5V1Huf7qMwDH8DzTuKxq6h4gtrIYQiVyCQAwC/n/AIVx2oa1cXsu+aVGC/MkajAB7EDPX364Paiio3LKt5JLcEOWBBB42g+4+nAH/fNVopZXjLlwVYgSMckkZwPl6HBzwR9OCaKKAZPZQN5bS/emlOcsDkAnABHpnHT39BVi9nDXMsUhxGXC4LfKFUbiPxI6+9FFAHN6tbO6nKMrx/3h3IBI/WsRHwaKKbHHcmEtKZTjGaKKzNrkEhLUirtFFFMQ1zk1b0uAy3e4HBQE8988f1oooRMjVmfcSdu0B2+X05J/rUW8sir2A7+uaKKtGTEwxbbx+eP88/54qC4icfOgJHf29/btRRQIFnLooCASbhzjLY5HJ+mPyqZWyo9BywP5ECiigZ//2Q==\"}]}" };
        //fnAdharSuccess(JSON.parse(data.result));
        //return true;

        var AadharVal = trim(AadharVal);

        if (AadharVal == "") {
            fnShflAlert("error", "Enter Aadhar No. !!");
            return false;
        }
        else if (AadharVal.length != 12) {
            fnShflAlert("error", "Enter 12 Digits Aadhar No. !!");
            return false;
        }

        var quality = 60; //(1 to 100) (recommanded minimum 55)
        var timeout = 10; // seconds (minimum=10(recommended), maximum=60, unlimited=0 )
        document.getElementById('imgFinger').src = "data:image/bmp;base64,";

        var res = CaptureFinger(quality, timeout);
        if (res.httpStaus) {
            if (res.data.ErrorCode == "0") {
                document.getElementById('imgFinger').src = "data:image/bmp;base64," + res.data.BitmapData;
                var AadharVal = trim($("#qde_txt_adhar").val());
                var BioStr = trim(res.data.IsoTemplate);
                var Fing = trim($("#txt_SelFinger").text().replace(" ","_"));

                var Obj = { AadharNum: AadharVal, OTPGenerated: "", BioString: BioStr, AuthType: "BIO", FingPrint: Fing };
                fnCallLOSWebService("AadharDetails", Obj, fnAadharResult, "AadharDetails", "");
            }
        }
        else {
            fnShflAlert("error", res.err);
        }
    }
    catch (e) {
        alert(e);
    }
    return false;
}

function OnGoOTPclick(AadharVal) {
    var AadharVal = trim(AadharVal);

    if (AadharVal == "") {
        fnShflAlert("error", "Enter Aadhar No. !!");
        return false;
    }
    else if (AadharVal.length != 12) {
        fnShflAlert("error", "Enter 12 Digits Aadhar No. !!");
        return false;
    }

    var Obj = { AadharNum: AadharVal, OTPGenerated: "", BioString: "", AuthType: "", FingPrint: "" };
    fnCallLOSWebService("GenerateOTP", Obj, fnAadharResult, "GenerateOTP", "");

    return true;
}

function OnGoclick(AadharVal, OTPVal) {

    var AadharVal = trim(AadharVal);
    var OTPVal = trim(OTPVal);

    if (OTPVal == "") {
        fnShflAlert("error", "Enter OTP No. !!");
        return false;
    }
    else if (OTPVal.length < 6) {
        fnShflAlert("error", "Enter 6 Digits OTP No. !!");
        return false;
    }

    var Obj = { AadharNum: AadharVal, OTPGenerated: OTPVal, BioString: "", AuthType: "OTP", FingPrint: "" };
    fnCallWebService("AadharDetails", Obj, fnAadharResult, "AadharDetails", "");
    return true;
}

function fnAadharResult(ServDesc, Obj, Param1, Param2) {
    if (ServDesc == "GenerateOTP") {
        fnShflAlert("error",Obj.result);
    }
    if (ServDesc == "AadharDetails") {
        if (Obj.status == false || Obj.status == "false") {
            var ResultData = JSON.parse(Obj.result);
            fnAdharSuccess(ResultData);
        }
    }
}

function trim(str) {
    return str ? str.trim() : "";
}

function fnAdharSuccess(ResultData) {
    var Datas = ResultData.SynKycRes[0];

    var BuildBoj = {}; var BuildJson = [];

    BuildBoj["qde_adhar_pic"] = Datas.Pht;
    BuildBoj["qde_txt_DisCity"] = Datas.Poa.dist;
    BuildBoj["qde_txt_DoorNo"] = Datas.Poa.house;
    BuildBoj["qde_txt_Pin"] = Datas.Poa.pc;
    BuildBoj["qde_txt_TownVil"] = Datas.Poa.po;
    BuildBoj["qde_txt_State"] = Datas.Poa.state;
    BuildBoj["qde_txt_Street"] = Datas.Poa.street;
    BuildBoj["qde_dt_dob"] = Datas.Poi.dob.replace(/-/g, "/");
    BuildBoj["qde_txt_email"] = Datas.Poi.email;
    BuildBoj["qde_txt_Gender"] = Datas.Poi.gender;
    BuildBoj["qde_txt_FirstNm"] = Datas.Poi.name;
    BuildBoj["qde_txt_mob"] = Datas.Poi.phone;

    BuildJson.push(BuildBoj);

    var displaydivval = $(Cur_Active_li).attr("val");
    var set_val_divid = $(".qde_content[val = '" + displaydivval + "']").attr("id");

    fnSetValues(set_val_divid, BuildJson[0]);
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using SynPIDLIBRARYV2;
using System.Net;
using System.Collections.Specialized;
using SHFL_RS;

namespace SHFL_RS
{
    public class Aadhar
    {
        public string error = "";
        public string Url = ConfigurationManager.AppSettings["AadharEKYC"];
        public string MAC_ID = ConfigurationManager.AppSettings["MAC_ID"];


        public string hdnotp = "";
        public string hdnaadharno = "";

        public string RemoveSpecialChars(string str)
        {

            string[] chars = new string[] { ",", ".", "/", "!", "@", "#", "$", "%", "^", "&", "*", "'", "\"", ";", "_", "(", ")", ":", "|", "[", "]" };

            for (int i = 0; i < chars.Length; i++)
            {
                if (str.Contains(chars[i]))
                {
                    str = str.Replace(chars[i], "");
                }
            }
            return str;
        }

        public bool fnGenerateOTP(AadharContract AadharCt)
        {
            bool result = false;
            string AadhaarNumber = AadharCt.AadharNum; 
            try
            {
                if (hdnaadharno == "" && error == "")
                {
                    AadhaarBuilder ObjAadhaar = new AadhaarBuilder();
                    OTPPARAMETERS ekycParams = new OTPPARAMETERS();

                    string LK = ConfigurationManager.AppSettings["LICENSEKEY"];
                    string UserName = "";
                    string DEVICEID = "User";
                    string PinCode = "600015";
                    string hostAddress = "";

                    string Meta_UDC = string.Empty;
                    UserName = RemoveSpecialChars(UserName);
                    string UDC = "API";
                    if (UserName.Length >= 12)
                    {
                        Meta_UDC = UDC + UserName.Substring(0, 12);

                    }
                    else
                    {
                        int UserMaxLength = 12;
                        int UserLength = UserMaxLength - UserName.Length;
                        string LeftPadd = "";
                        for (int i = 0; i < UserLength; i++)
                        {
                            LeftPadd += "0";
                        }
                        Meta_UDC = UDC + LeftPadd + UserName;

                    }

                    ekycParams.AADHAARID = AadhaarNumber;
                    ekycParams.SLK = LK;
                    ekycParams.MACID = MAC_ID;
                    ekycParams.DEVICEID = DEVICEID;
                    ekycParams.META_LOT = "P";
                    ekycParams.META_LOV = PinCode;
                    ekycParams.META_PIP = hostAddress;
                    ekycParams.META_UDC = Meta_UDC;
                    string responsexml = ObjAadhaar.SendOtpKUARequest(ekycParams);
                    System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                    doc.LoadXml(responsexml);
                    if (doc.InnerXml.Contains("err") == true)
                    {
                        result = false;
                        error = "Invalid Aadhar Number";
                    }
                    else
                    {
                        error = "";
                        hdnotp = "Yes";
                        result = true;
                    }
                }

            }
            catch (Exception ex)
            {
                result = false;
            }
            return result;
        }


        public string fnCheckGeneratedOTP(AadharContract AadharCt)
        {

            string backstr = "";

            string AadhaarNumber = AadharCt.AadharNum;//txtaadharno.Text;

            string otp = AadharCt.OTPGenerated;//txtotp.Text;

            try
            {
                if (hdnaadharno == "" && error == "")
                {
                    string LK = ConfigurationManager.AppSettings["LICENSEKEY"];

                    string DEVICEID = "User";
                    string PinCode = "600015";
                    string hostAddress = "http://svsglobal.com";

                    string UserName = "test";//hdnname.Value;
                    string Meta_UDC = string.Empty;
                    UserName = RemoveSpecialChars(UserName);
                    string UDC = "API";
                    if (UserName.Length >= 12)
                    {
                        Meta_UDC = UDC + UserName.Substring(0, 12);

                    }
                    else
                    {
                        int UserMaxLength = 12;
                        int UserLength = UserMaxLength - UserName.Length;
                        string LeftPadd = "";
                        for (int i = 0; i < UserLength; i++)
                        {
                            LeftPadd += "0";
                        }
                        Meta_UDC = UDC + LeftPadd + UserName;

                    }


                    AadhaarBuilder ObjAadhaar = new AadhaarBuilder();
                    EKYCPARAMETERS ekycParams = new EKYCPARAMETERS();
                    ekycParams.AADHAARID = AadhaarNumber;
                    ekycParams.SLK = LK;
                    ekycParams.MACID = MAC_ID;
                    ekycParams.DEVICEID = DEVICEID;

                    ekycParams.KYCVALUE = otp;
                    ekycParams.CONSENT = "Y";
                    ekycParams.LANG = "N";

                    ekycParams.POSH = "";
                    ekycParams.SERVICETYPE = "EKYCWITHOTP";
                    ekycParams.META_FDC = "NC";
                    ekycParams.META_IDC = "NA";
                    ekycParams.META_LOT = "P";
                    ekycParams.META_LOV = PinCode;
                    ekycParams.META_PIP = hostAddress;
                    ekycParams.META_UDC = Meta_UDC;
                    string responsexml = ObjAadhaar.SendEkycRequest(ekycParams);
                    System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                    doc.LoadXml(responsexml);


                    if (doc.InnerXml.Contains("err") == true)
                    {
                        error = "Yes";
                        error = "Please Enter Correct OTP";
                        backstr = "ERROR:" + error;
                    }
                    else
                    {
                        error = "";
                        using (var client = new WebClient())
                        {

                            var values = new NameValueCollection();
                            values["AadhaarNumber"] = AadharCt.AadharNum;
                            values["MACID"] = MAC_ID;
                            values["LCODE"] = "Yjk5ZDRiODMtNThjNS00NjZmLTgzNTEtZDlkMzc1MmRhY2I5";
                            var response = client.UploadValues(Url, values);
                            backstr = System.Text.Encoding.UTF8.GetString(response);
                        }
                        hdnaadharno = "Yes";
                        backstr = backstr.Replace("\n", "");
                    }
                }
            }
            catch (Exception ex)
            {
                backstr = "ERROR:" + ex.Message;
            }
            return backstr;
        }



        public string fnGetAadharDetails(AadharContract AadharCt)
        {
            string resultStr = "";

            string sMacAddress, MACID = "";
            // Registered macid in device management.
            string LK = ConfigurationManager.AppSettings["LICENSEKEY"];
            // Registered macid in device management.

            // DEVICEID as your wish which can be track on your side and its optional 
            string DEVICEID = "291811";//291811
            string PinCode = "600015";
            //string hostAddress = HttpContext.Current.Request.UserHostAddress;
            string hostAddress = "http://svsglobal.com";
            //you can use any of your core application credentials.
            string UserName = "test";// hdnname.Value;
            string Meta_UDC = string.Empty;
            try
            {
                UserName = RemoveSpecialChars(UserName);
                string UDC = "API";
                if (UserName.Length >= 12)
                {
                    Meta_UDC = UDC + UserName.Substring(0, 12);

                }
                else
                {
                    int UserMaxLength = 12;
                    int UserLength = UserMaxLength - UserName.Length;
                    string LeftPadd = "";
                    for (int i = 0; i < UserLength; i++)
                    {
                        LeftPadd += "0";
                    }
                    Meta_UDC = UDC + LeftPadd + UserName;

                }
                //e-KYC
                string BIO = AadharCt.BioString;
                //"Rk1SACAyMAAAAAEIAAABPAFiAMUAxQEAAAAoJ0C0ALD0ZEDNAKTtZEDfAMr1ZECkAGpzZEC7ARt1ZIB2AGZ4ZECRASL8ZIDPAEVtZEDKATNwZIBiASOrZIAiAK+WPEBzADLxZEB7ABpuXUC4AMJ0ZEC7ANx0ZEDtAMd2ZEBoAOuNZEDlAGZwZED9AQHjZEEiAJnsXUCqAD9xZEElAO3pXYEBASFjZEAqAOyeZEC8ABfxZEBAADt7V0DGALB2ZIDSAJx0ZECVAQOEZEEMALXsZECCAROYXUBEALqNZEClATCFXUEqAL1sV4BtASIZXUCeAUCTV0BmADpxZEEeATfXUEDcABZxUAAA";

                AadhaarBuilder ObjAadhaar = new AadhaarBuilder();
                EKYCPARAMETERS ekycParams = new EKYCPARAMETERS();
                ekycParams.AADHAARID = AadharCt.AadharNum;
                ekycParams.SLK = LK;
                ekycParams.MACID = MAC_ID;
                ekycParams.DEVICEID = DEVICEID;
                ekycParams.KYCVALUE = BIO;
                // please refer e-kyc document
                ekycParams.CONSENT = "Y";
                // please refer e-kyc document
                ekycParams.LANG = "N";

                // LEFT_INDEX LEFT_LITTLE  LEFT_MIDDLE LEFT_RING LEFT_THUMB RIGHT_INDEX RIGHT_LITTLE RIGHT_MIDDLE RIGHT_RING RIGHT_THUMB  
                ekycParams.POSH = AadharCt.FingPrint;
                ekycParams.SERVICETYPE = "EKYCWITHBIO";
                ekycParams.META_FDC = "NC";
                ekycParams.META_IDC = "NA";
                ekycParams.META_LOT = "P";
                ekycParams.META_LOV = PinCode;
                ekycParams.META_PIP = hostAddress;
                ekycParams.META_UDC = Meta_UDC;
                string responsexml = ObjAadhaar.SendEkycRequest(ekycParams);
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.LoadXml(responsexml);
                var XmlTags = doc.GetElementsByTagName("SynKycRes");

                if (XmlTags.Count > 0)
                {
                    if (XmlTags[0].Attributes["ret"].Value.ToString().ToLower() == "n")
                    {
                        resultStr += "ERROR:";
                        resultStr += XmlTags[0].Attributes["err"].Value.ToString() + "<br />";
                        resultStr += XmlTags[0].Attributes["ret"].Value.ToString() + "<br />";
                        resultStr += XmlTags[0].Attributes["reason"].Value.ToString();

                    }
                    else
                    {
                        string backstr = "";
                        using (var client = new WebClient())
                        {
                            var values = new NameValueCollection();
                            values["AadhaarNumber"] = AadharCt.AadharNum;// txtaadharno.Text;
                            values["MACID"] = MAC_ID;
                            values["LCODE"] = "Yjk5ZDRiODMtNThjNS00NjZmLTgzNTEtZDlkMzc1MmRhY2I5";
                            var response = client.UploadValues(Url, values);
                            backstr = System.Text.Encoding.UTF8.GetString(response);
                        }

                        hdnaadharno = "Yes";
                        backstr = backstr.Replace("\n", "");
                        resultStr = backstr;
                    }

                }
            }
            catch (Exception ex)
            {
                resultStr = "ERROR:" + ex.Message;
            }
            return resultStr;
        }
    }
}
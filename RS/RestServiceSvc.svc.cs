using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Web.Configuration;
using System.Configuration;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Data;
using System.Data.OleDb;
using System.Web.Script.Serialization;
using System.Net.Mail;
using System.Net.Mime;
using System.IO;
using System.Net.NetworkInformation;
using System.ServiceModel.Channels;
using System.Web.Services;
using System.Web;
using System.Net;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using SHFL_RS.FileManagerClasses;

namespace SHFL_RS
{    
    public class RestServiceSvc : IRestServiceSvc
    {      

        public bool IsError = false;
        public string ErrText = "";
        public static string ConnString = ConfigurationManager.ConnectionStrings["DbConnect"].ConnectionString;

        /// <summary>
        /// This Method Gets an argument of Procedure and its parameter.
        /// and executes in SqlDB. 
        /// </summary>
        /// <param name="Data"></param>
        /// <returns> Returns Json serialized string as output </returns>

        public string fnDataAccessService(DataContract Data) {
            
            string ReturnData = "";
            DataSet DS = new DataSet();
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                ResultDictionary.Add("status", true);
                ResultDictionary.Add("error", "");
                ResultDictionary.Add("ResultCount", 0);

                Serializer.MaxJsonLength = 500000000;

                string[] PrcParams = new string[Data.Parameters.Length];

                int iParam = 0;
                foreach (string param in Data.Parameters)
                {
                    PrcParams[iParam] = param;
                    iParam++;
                }

                if (Data.ProcedureName == "$Query" || Data.Type == "T")
                    DS = fnExecuteProcedure(Data.QryTxt);
                else if(Data.ConnString != "")
                    DS = fnExecuteProcedure(Data.ConnString, Data.ProcedureName, PrcParams);
                else
                    DS = fnExecuteProcedure(Data.ProcedureName, PrcParams);

                if (IsError)
                    ResultDictionary["error"] = ErrText;

                int iTableIndex = 0;

                if (DS.Tables.Count != 0)
                {
                    ResultDictionary["ResultCount"] = DS.Tables.Count;
                }
                if (DS.Tables.Count == 1)
                {
                    ResultDictionary["result"] = ConvertDataTableToJson(DS.Tables[0]);
                }
                else if (DS.Tables.Count > 1)
                {
                    foreach (DataTable dtResult in DS.Tables)
                    {
                        ResultDictionary["result_" + (iTableIndex + 1).ToString()] = ConvertDataTableToJson(dtResult);
                        ++iTableIndex;
                    }
                }
                else if (DS.Tables.Count == 0)
                {
                    ResultDictionary["result"] = null;
                }
                if (IsError)
                {
                    ResultDictionary["status"] = false;
                }
            }
            catch (Exception ex)
            {
                ResultDictionary["status"] = false;
                ResultDictionary["error"] = ex.Message;               
            }
            finally
            {
                ReturnData = Serializer.Serialize(ResultDictionary);
            }

            return ReturnData;
        }

        public string fnAadharGenerateOTP(AadharContract AadharCt)
        {
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            ResultDictionary.Add("status", true);
            ResultDictionary.Add("error", "");
            ResultDictionary.Add("ResultCount", 0);
            ResultDictionary.Add("result", "");

            Aadhar adObj = new Aadhar();
            bool result = adObj.fnGenerateOTP(AadharCt);
            if (result)
            {
                ResultDictionary["status"] = true;
                ResultDictionary["result"] = "OTP Generated and sent to Your Mobile Number.";
            }
            else
            {
                ResultDictionary["status"] = false;
                ResultDictionary["result"] = "OTP not Generated. Error Occured";
            }
            string resStr = Serializer.Serialize(ResultDictionary);
            return resStr;
        }

         public string fnGetAadharDetails(AadharContract AadharCt)
         {
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            ResultDictionary.Add("status", true);
            ResultDictionary.Add("error", "");
            ResultDictionary.Add("ResultCount", 0);
            ResultDictionary.Add("result", "");

            Aadhar adObj = new Aadhar();
            string result = "";
            if (AadharCt.AuthType == "BIO")
            {
                result = adObj.fnGetAadharDetails(AadharCt);
            }
            else if (AadharCt.AuthType == "OTP")
            {
                result = adObj.fnCheckGeneratedOTP(AadharCt);
            }

            if (result.IndexOf("ERROR:") == -1)
            {
                ResultDictionary["status"] = true;
                ResultDictionary["result"] = result;
            }
            else
            {
                ResultDictionary["status"] = false;
                ResultDictionary["result"] = result.Replace("ERROR:", "");
            }
            string resStr = Serializer.Serialize(ResultDictionary);
            return resStr;
        }
        public string fnCreateFolder(FolderContract folder)
        {
            string result = "";
            try
            {
                string pk = folder.userpk;
                string folderPath = System.Web.Hosting.HostingEnvironment.MapPath("~/") + "REPOSITORY";
                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);
                Directory.CreateDirectory(folderPath + "/" + pk);
                result = "{msg:'success'}";
            }
            catch (Exception ex)
            {
                result = "{msg:'error'}";
            }            
            return result;
        }

        public static string ConvertDataTableToJson(DataTable tbData)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = 500000000;
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
            Dictionary<string, object> row;
            foreach (DataRow dr in tbData.Rows)
            {
                row = new Dictionary<string, object>();

                foreach (DataColumn dc in tbData.Columns)
                {
                    row.Add(dc.ColumnName, dr[dc]);
                }
                rows.Add(row);
            }

            return serializer.Serialize(rows);
        }

        /// <summary>
        /// Method Executes Query.
        /// </summary>
        /// <param name="Query"> Query to be Executed</param>
        /// <returns> Dataset </returns>
        public DataSet fnExecuteProcedure(string Query)
        {
            DataSet RetData = new DataSet();
            OleDbConnection conn = new OleDbConnection(ConnString);
            try
            {                
                OleDbDataAdapter DataAdapter;
                conn.Open();
                OleDbCommand cmd = new OleDbCommand();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = Query;

                DataAdapter = new OleDbDataAdapter(cmd);
                DataAdapter.Fill(RetData);
            }
            catch (Exception Ex)
            {
                IsError = true;
                ErrText = Ex.Message;
                RetData = new DataSet();
            }
            finally {
                conn.Close();
                conn.Dispose();
                OleDbConnection.ReleaseObjectPool();
                GC.Collect();
                GC.WaitForPendingFinalizers();
                GC.Collect();                
            }
            return RetData;
        }

        /// <summary>
        /// Method Executes procedure.
        /// 2 parameters - Procedure name and its parameters
        /// </summary>
        /// <param name="ProcedureName"> Name of the Procedure</param>
        /// <param name="Parameters"> parameters of procedure </param>
        /// <returns> Dataset </returns>
        public DataSet fnExecuteProcedure(string ProcedureName, string[] Parameters)
        {
            DataSet RetData = new DataSet();
            OleDbConnection conn = new OleDbConnection(ConnString);
            try
            {
                //OleDbDataReader DataReader = new OleDbDataReader();
                OleDbDataAdapter DataAdapter;
                conn.Open();
                OleDbCommand cmd = new OleDbCommand();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 0;
                cmd.CommandText = ProcedureName;
                foreach (var paramStr in Parameters)
                {
                    if (string.IsNullOrEmpty(paramStr))
                        cmd.Parameters.Add(new OleDbParameter("param", DBNull.Value));
                    else
                        cmd.Parameters.Add(new OleDbParameter("param", paramStr));
                }
                DataAdapter = new OleDbDataAdapter(cmd);
                DataAdapter.Fill(RetData);
            }
            catch (Exception Ex)
            {
                IsError = true;
                ErrText = Ex.Message;
                RetData = new DataSet();
            }
            finally
            {
                conn.Close();
                conn.Dispose();
                OleDbConnection.ReleaseObjectPool();
                GC.Collect();
                GC.WaitForPendingFinalizers();
                GC.Collect();
            }

            return RetData;
        }

        /// <summary>
        /// Method Executes procedure.
        /// 3 parameters - ConnectionString Procedure name and its parameters
        /// </summary>
        /// <param name="ProcedureName"> Name of the Procedure</param>
        /// <param name="Parameters"> parameters of procedure </param>
        /// <returns> Dataset </returns>
        public DataSet fnExecuteProcedure(string ConnString, string ProcedureName, string[] Parameters)
        {
            DataSet RetData = new DataSet();
            OleDbConnection conn = new OleDbConnection(ConnString);
            try
            {
                //OleDbDataReader DataReader = new OleDbDataReader();
                OleDbDataAdapter DataAdapter;
                conn.Open();
                OleDbCommand cmd = new OleDbCommand();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 0;
                cmd.CommandText = ProcedureName;
                foreach (var paramStr in Parameters)
                {
                    if (string.IsNullOrEmpty(paramStr))
                        cmd.Parameters.Add(new OleDbParameter("param", DBNull.Value));
                    else
                        cmd.Parameters.Add(new OleDbParameter("param", paramStr));
                }
                DataAdapter = new OleDbDataAdapter(cmd);
                DataAdapter.Fill(RetData);
            }
            catch (Exception Ex)
            {
                IsError = true;
                ErrText = Ex.Message;
                RetData = new DataSet();
            }
            finally
            {
                conn.Close();
                conn.Dispose();
                OleDbConnection.ReleaseObjectPool();
                GC.Collect();
                GC.WaitForPendingFinalizers();
                GC.Collect();
            }

            return RetData;
        }

        [WebMethod]
        public string GetLocalIpAddress()
        {
            try
            {
                OperationContext context = OperationContext.Current;
                MessageProperties messageProperties = context.IncomingMessageProperties;
                RemoteEndpointMessageProperty endpointProperty = messageProperties[RemoteEndpointMessageProperty.Name] as RemoteEndpointMessageProperty;
                string LocalIpAddress = "";
                string clientPcName = "";
                try
                {
                    // clientPcName = Dns.GetHostByAddress(((RemoteEndpointMessageProperty)OperationContext.Current.IncomingMessageProperties[RemoteEndpointMessageProperty.Name]).Address).HostName;
                    //clientPcName = System.Net.Dns.GetHostEntry(endpointProperty.Address).HostName;
                    //LocalIpAddress = GetIPAddress(clientPcName);
                }
                catch (Exception ex) { ex.Data.Clear(); }
                return endpointProperty.Address;
            }
            catch (Exception ex)
            {
                return "Error";
            }
        }
        public static string GetIPAddress(string hostName)
        {
            Ping ping = new Ping();
            var replay = ping.Send(hostName);

            if (replay.Status == IPStatus.Success)
            {
                return replay.Address.ToString();
            }
            return null;
        }
        public string GetServerUrl()
        {
            string ServerUrl = string.Empty;
            try
            {
                ServerUrl = WebConfigurationManager.AppSettings["Service_Url"];
            }
            catch (Exception ex)
            {
                ServerUrl = ex.Message.ToString();
            }
            return ServerUrl;
        }   

        public string MailSend(ProMailContract data)
        {
            string strMailStsXml = "", strResult = "";
            try
            {
                strMailStsXml = "";
                strMailStsXml = strMailStsXml + "<root>";
                
                MailSender objMsndr = new MailSender();
                Dictionary<String, String> dicParamCol = new Dictionary<string, string>();
                String[] arrParams = new String[data.Params.Length];
                int iParamIndex = 0;
                foreach (string strParam in data.Params)
                {
                    arrParams[iParamIndex] = ProUtilMethods.IsStringJson(strParam) ? ProUtilMethods.ConvertJson(strParam) : strParam;
                    iParamIndex++;
                }
                DataSet dsDtlResult = fnExecuteProcedure("PrcWPMail", arrParams);
                if (dsDtlResult != null && dsDtlResult.Tables.Count > 0)
                {
                    objMsndr.fromAddress = dsDtlResult.Tables[0].Rows[0][0].ToString().Trim();
                    objMsndr.fromPassword = dsDtlResult.Tables[0].Rows[0][1].ToString().Trim();
                    objMsndr.Host = dsDtlResult.Tables[0].Rows[0][2].ToString().Trim();
                    objMsndr.Port = Convert.ToInt32(dsDtlResult.Tables[0].Rows[0][3].ToString());
                    for (int intItration = 0; intItration < dsDtlResult.Tables[1].Rows.Count; intItration++)
                    {
                        try
                        {
                            objMsndr._toAddress = dsDtlResult.Tables[1].Rows[intItration][0].ToString().Trim();
                            objMsndr._subject = "";
                            objMsndr._body = "";
                            objMsndr.altview = AlternateView.CreateAlternateViewFromString(dsDtlResult.Tables[1].Rows[intItration][2].ToString().Trim(), null, MediaTypeNames.Text.Html);
                            objMsndr.SendMail();
                            strResult = "Success:" + dsDtlResult.Tables[1].Rows[intItration][0].ToString().Trim();
                            strMailStsXml = strMailStsXml + "<item";
                            strMailStsXml = strMailStsXml + " UsrFk=" + "\"" + dsDtlResult.Tables[0].Rows[intItration][1] + "\"";
                            strMailStsXml = strMailStsXml + " Response=" + "\"" + "Success sending mail." + "\"";
                            strMailStsXml = strMailStsXml + " MStatus=" + "\"" + "1" + "\"";
                            strMailStsXml = strMailStsXml + " ExtStatus=" + "\"" + "1" + "\"";
                            strMailStsXml = strMailStsXml + " />";
                        }
                        catch (Exception ex)
                        {
                            strMailStsXml = strMailStsXml + "<item";
                            strMailStsXml = strMailStsXml + " UsrFk=" + "\"" + dsDtlResult.Tables[0].Rows[intItration][1] + "\"";
                            strMailStsXml = strMailStsXml + " Response=" + "\"" + ex.Message.ToString() + "\"";
                            strMailStsXml = strMailStsXml + " MStatus=" + "\"" + "2" + "\"";
                            strMailStsXml = strMailStsXml + " ExtStatus=" + "\"" + "0" + "\"";
                            strMailStsXml = strMailStsXml + " />";
                            strResult = "Error:" + ex.Message.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                strResult = "Error:" + ex.Message.ToString();
                ex.Data.Clear();
            }
            return strResult;
        }

        public string GetSoftCellData(SoftCell data)
        {
            string URL = System.Configuration.ConfigurationManager.AppSettings["SoftCellURL"];
            string Id = System.Configuration.ConfigurationManager.AppSettings["MEMBER_ID"];
            string Pwd = System.Configuration.ConfigurationManager.AppSettings["PASSWORD"];

            var request = (HttpWebRequest)WebRequest.Create(URL);
            var postData = "INSTITUTION_ID=4036";
            postData += "&AGGREGATOR_ID=567";
            postData += "&MEMBER_ID=" + Id + "";
            postData += "&PASSWORD=" + Pwd + "";
            postData += "&inputJson_=";
            /*
            String[] arrParams = new String[data.Param.Length];
            int iParamIndex = 0;
            foreach (string strParam in data.Param)
            {
                arrParams[iParamIndex] = ProUtilMethods.IsStringJson(strParam) ? ProUtilMethods.ConvertJson(strParam) : strParam;
                iParamIndex++;
            }
            DataSet dsDtlResult = fnExecuteProcedure("LOS_formsoftcelldata", arrParams);
             * string output = dsDtlResult.Tables[0].Rows[0][0].ToString();
             * */

            postData += data.InputString;
            var input = Encoding.ASCII.GetBytes(postData);

            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = input.Length;

            using (var stream = request.GetRequestStream())
            {
                stream.Write(input, 0, input.Length);
            }

            var response = (HttpWebResponse)request.GetResponse();

            var responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();
            response.Close();

            return responseString;
        }


        public string SoftCellAcknowledement(SoftCellAck data)
        {
            string URL = System.Configuration.ConfigurationManager.AppSettings["SoftCellURL"];
            string Id = System.Configuration.ConfigurationManager.AppSettings["MEMBER_ID"];
            string Pwd = System.Configuration.ConfigurationManager.AppSettings["PASSWORD"];
            FileStream Fs;

            var postData = "INSTITUTION_ID=4036";
            postData += "&AGGREGATOR_ID=567";
            postData += "&MEMBER_ID=" + Id + "";
            postData += "&PASSWORD=" + Pwd + "";
            postData += "&inputJson_={\"HEADER\": {\"SOURCE-SYSTEM\":\"DIRECT\",\"CUST-ID\": \"82274992\",\"APPLICATION-ID\": \"82274992\",\"REQUEST-TYPE\": \"ISSUE\",\"REQUEST-RECEIVED-TIME\":\"" + data.AckDateTime + "\"},	\"ACKNOWLEDGEMENT-ID\": " + data.AckNo + ",\"RESPONSE-FORMAT\": [\"05\"]}";
            var input = Encoding.ASCII.GetBytes(postData);
            var request = (HttpWebRequest)WebRequest.Create(URL);
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = input.Length;

            System.Threading.Thread.Sleep(10000);

            using (var stream = request.GetRequestStream())
            {
                stream.Write(input, 0, input.Length);
            }

            var response = (HttpWebResponse)request.GetResponse();

            var Outputval = new StreamReader(response.GetResponseStream()).ReadToEnd();

            //return Outputval;
            Outputval = Outputval.Replace("\\", "");
            int first = Outputval.IndexOf(">");
            int last = Outputval.LastIndexOf("<");
            Outputval = Outputval.Substring(first + 1, (Outputval.Length) - (first + (Outputval.Length - last) + 1));
            var PdfData = (JObject)JsonConvert.DeserializeObject(Outputval);
            string[] readarray = PdfData["FINISHED"][0].ToObject<string[]>();
            Fs = new System.IO.FileStream(ConfigurationSettings.AppSettings["ExportFilePath"] + "\\" + data.LeadNo + ".pdf", System.IO.FileMode.Create, System.IO.FileAccess.Write);
            byte[] unsign = (byte[])(Array)readarray.Select(sbyte.Parse).ToArray();
            Fs.Write(unsign, 0, unsign.Length);
            Fs.Close();
            return ConfigurationSettings.AppSettings["ExportFilePath"] + "\\"+data.LeadNo;
        }


        public string fnTiffImagePreview(TiffPrwContract TIFF)
        {
            string ReturnData = "";
            DataSet DS = new DataSet();
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                ResultDictionary.Add("status", true);
                ResultDictionary.Add("error", "");
                ResultDictionary.Add("ResultCount", 0);

                Serializer.MaxJsonLength = 500000000;
                int ReceivedCount = Convert.ToInt32(TIFF.receivedImages);
                FileManager FileMgr = new FileManager(TIFF);
                int pageCount = 0;
                string JsonString = FileMgr.TESTfnTiffImagePreview(ref ReceivedCount, ref pageCount);
                ResultDictionary["pageCount"] = pageCount;
                ResultDictionary["result"] = JsonString;
                if (ReceivedCount == -1)
                    ResultDictionary["isFinished"] = true;
                else
                    ResultDictionary["isFinished"] = false;
            }
            catch (Exception ex)
            {
                ResultDictionary["status"] = false;
                ResultDictionary["error"] = ex.Message;
            }
            finally
            {
                ReturnData = Serializer.Serialize(ResultDictionary);
            }

            return ReturnData;
        }


        public string fnExecDBQuery(ExecDBContract ExecDB)
        {
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string resultString = "";
            ResultDictionary.Add("status", true);
            ResultDictionary.Add("error", "");
            ResultDictionary.Add("ResultCount", 0);
            DataSet RetData = new DataSet();
            OleDbConnection conn = new OleDbConnection(ExecDB.ConString);
            try
            {
                OleDbDataAdapter DataAdapter;
                conn.Open();
                OleDbCommand cmd = new OleDbCommand();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = ExecDB.Query;
                DataAdapter = new OleDbDataAdapter(cmd);
                DataAdapter.Fill(RetData);
                int iTableIndex = 0;

                if (RetData.Tables.Count != 0)
                {
                    ResultDictionary["ResultCount"] = RetData.Tables.Count;
                }
                if (RetData.Tables.Count == 1)
                {
                    ResultDictionary["result"] = ConvertDataTableToJson(RetData.Tables[0]);
                }
                else if (RetData.Tables.Count > 1)
                {
                    foreach (DataTable dtResult in RetData.Tables)
                    {
                        ResultDictionary["result_" + (iTableIndex + 1).ToString()] = ConvertDataTableToJson(dtResult);
                        ++iTableIndex;
                    }
                }
                else if (RetData.Tables.Count == 0)
                {
                    ResultDictionary["result"] = null;
                }                
            }
            catch (Exception Ex)
            {
                ResultDictionary["status"] = false;
                ResultDictionary["error"] = "Error in executing your Query : " + Ex;
                ResultDictionary["ResultCount"] = 0;
                ResultDictionary["result"] = null;
            }
            finally
            {
                conn.Close();
                conn.Dispose();
                OleDbConnection.ReleaseObjectPool();
                GC.Collect();
                GC.WaitForPendingFinalizers();
                GC.Collect();
                resultString = Serializer.Serialize(ResultDictionary);
            }
            return resultString;
        }

        public string fnGetAppSettingsValue(ConfigData data)
        {
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            ResultDictionary["ConfigValue"] = ConfigurationSettings.AppSettings[data.ConfigKey];
            return Serializer.Serialize(ResultDictionary);
        }

        public string fnGetXMLData(ConfigData data)
        {
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            ResultDictionary["ConfigValue"] = File.ReadAllText(data.ConfigKey);
            return Serializer.Serialize(ResultDictionary);
        }
    }
}

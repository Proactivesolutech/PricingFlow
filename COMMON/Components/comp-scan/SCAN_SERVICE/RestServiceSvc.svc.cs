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
using System.Threading.Tasks;
using SCAN_RS.FileManagerClasses;
using System.IO;

namespace SCAN_RS
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
                if (Data.Type == "T") {
                    DS = fnExecuteProcedure(PrcParams[0]);
                }
                else if (Data.Type == "SP")
                {
                    DS = fnExecuteProcedure(Data.ProcedureName, PrcParams);
                }

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
        /// Method Executes procedure.
        /// 2 parameters - Procedure name and its parameters
        /// </summary>
        /// <param name="ProcedureName"> Name of the Procedure</param>
        /// <param name="Parameters"> parameters of procedure </param>
        /// <returns> Dataset </returns>
        public DataSet fnExecuteProcedure(string ProcedureName, string[] Parameters)
        {
            DataSet RetData = new DataSet();
            try
            {
                OleDbConnection conn = new OleDbConnection(ConnString);
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
            catch (Exception Ex) {
                IsError = true;
                ErrText = Ex.ToString();
                RetData = new DataSet();
            }
            return RetData;                        
        }

        /// <summary>
        /// Method Executes Query.
        /// </summary>
        /// <param name="Query"> Query to be Executed</param>
        /// <returns> Dataset </returns>
        public DataSet fnExecuteProcedure(string Query)
        {
            DataSet RetData = new DataSet();
            try
            {
                OleDbConnection conn = new OleDbConnection(ConnString);
                OleDbDataAdapter DataAdapter;
                conn.Open();
                OleDbCommand cmd = new OleDbCommand();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = Query;

                DataAdapter = new OleDbDataAdapter(cmd);
                DataAdapter.Fill(RetData);
                conn.Close();
            }
            catch (Exception Ex)
            {
                IsError = true;
                ErrText = Ex.ToString();
                RetData = new DataSet();
            }
            return RetData;
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


    }


}

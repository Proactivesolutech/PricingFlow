using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Configuration;

namespace SHFL_RS
{
    /// <summary>
    /// File Upload Handler
    /// </summary>
    public class FileUploadHandler : IHttpHandler
    {
        RestServiceSvc rs = new RestServiceSvc();
        public void ProcessRequest(HttpContext context)
        {
            string ResponseText = "";
            context.Response.ContentType = "text/plain";
            string savePath = context.Request.Form["savePath"];                        
            string RefKey = context.Request.Form["Action"];
            
            //added by Vijay S
            if (RefKey == "Attachment_UPLOAD")
            {                              
                try
                {
                    HttpFileCollection files = context.Request.Files;
                    int filecount = files.Count;                                        
                    if (filecount != 0)
                    {                                                                        
                        string RefKeyVal = context.Request.Form["RefKey"];
                        string ProcKeyVal = context.Request.Form["ProcKey"];
                        string Remarks = context.Request.Form["Remarks"];                                                           
                        string serverPath = context.Server.MapPath("~/" + savePath + "/");
                        
                        if (!Directory.Exists(serverPath))
                        {
                            Directory.CreateDirectory(serverPath);
                        }                        
                        for (int i = 0; i < filecount; i++)
                        {
                            string[] Params = new string[6];
                            string fname = context.Request.Form["filepath_" + i];
                            fname = fname.Substring(fname.LastIndexOf("/") + 1);                            
                            HttpPostedFile file = files[i];
                            file.SaveAs(serverPath + fname);                            
                            Params[0] = ProcKeyVal;
                            Params[1] = RefKeyVal;
                            Params[2] = file.FileName;
                            Params[3] = fname;
                            Params[4] = serverPath;
                            Params[5] = Remarks;           
                            rs.fnExecuteProcedure("PrcFileupldDetails", Params);                            
                        }                       
                    }
                    context.Response.Write("");
                }
                catch (Exception exp)
                {                    
                    context.Response.Write("File Upload.");
                }
                
                /*Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
                var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                string fileAttachmentPath = ConfigurationSettings.AppSettings["FileAttachmentPath"];
                string fileAttachmentPathMapServer = ConfigurationSettings.AppSettings["FileAttachmentPathMapServer"];
                if (savePath.Contains("FileAttachmentPath") == true) savePath = savePath.Replace("FileAttachmentPath", fileAttachmentPath);
                var serverPath = (fileAttachmentPathMapServer == "true") ? context.Server.MapPath("~/" + savePath + "/") : savePath;                
                try
                {
                    HttpFileCollection files = context.Request.Files;
                    int filecount = files.Count;                                               
                    if (filecount != 0)
                    {                        
                        Serializer.MaxJsonLength = 500000000;
                        string[] UploadedFiles = new string[filecount];
                        string RefKeyVal = context.Request.Form["RefKey"];
                        string ProcKeyVal = context.Request.Form["ProcKey"];                        
                        if (!Directory.Exists(serverPath)) Directory.CreateDirectory(serverPath);                        
                        for (int i = 0; i < filecount; i++)
                        {
                            string[] Params = new string[6];
                            string fname = "";
                            HttpPostedFile file = files[i];
                            string fileName = file.FileName;
                            fileName = fileName.Replace(" ", "");
                            fname = DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss-fff", CultureInfo.InvariantCulture) + "___" + fileName;
                            //file.SaveAs(serverPath + fname);
                            file.SaveAs(serverPath + context.Request.Form["files" + i]);                            
                            UploadedFiles[i] = "../RS/" + savePath + fname;
                            Params[0] = "yes";
                            Params[1] = ProcKeyVal;
                            Params[2] = RefKeyVal;
                            Params[3] = fileName;
                            Params[4] = fname;
                            Params[5] = serverPath;                            
                            rs.fnExecuteProcedure("PrcFileupldDetails", Params);
                        }
                        ResultDictionary["result"] = Serializer.Serialize(UploadedFiles);
                    }
                }
                catch (Exception exp)
                {
                    ResultDictionary["status"] = false;
                    ResultDictionary["error"] = exp.Message;
                    ResultDictionary["result"] = "[]";
                }
                finally
                {
                    ResponseText = Serializer.Serialize(ResultDictionary);
                    context.Response.Write(ResponseText);
                }*/

            } /* FOR FILE UPLOAD - MULTIPLE - NEW */
            else if (RefKey == "ReportUpload")
            {
                Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
                var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();

                ResultDictionary.Add("status", true);
                ResultDictionary.Add("error", "");
                ResultDictionary.Add("ResultCount", 0);
                ResultDictionary["result"] = "";
                Serializer.MaxJsonLength = 500000000;
                context.Response.ContentType = "text/plain";

                try
                {
                    HttpFileCollection files = context.Request.Files;
                    int filecount = files.Count;
                    string[] UploadedFiles = new string[filecount];
                    
                    var serverPath = context.Server.MapPath("~/" + savePath + "/");                                       
                    if (!Directory.Exists(serverPath))
                    {
                        Directory.CreateDirectory(serverPath);
                    }
                    if (filecount != 0)
                    {
                        for (int i = 0; i < filecount; i++)
                        {
                            string fname = "";
                            HttpPostedFile file = files[i];
                            string fileName = file.FileName;
                            fileName = fileName.Replace(" ", "");
                            fname = DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss-fff", CultureInfo.InvariantCulture) + "___" + fileName;
                            file.SaveAs(serverPath + fname);
                            UploadedFiles[i] = savePath + "/" + fname;
                        }
                        ResultDictionary["result"] = Serializer.Serialize(UploadedFiles);
                    }
                }
                catch (Exception exp)
                {
                    ResultDictionary["status"] = false;
                    ResultDictionary["error"] = exp.Message;
                    ResultDictionary["result"] = "[]";
                }
                finally {
                    ResponseText = Serializer.Serialize(ResultDictionary);
                    context.Response.Write(ResponseText);
                }

            }                
            else
            {
                try
                {
                    if (context.Request.Files.Count > 0)
                    {
                        string fname = "";
                        HttpFileCollection files = context.Request.Files;
                        int filecount = files.Count;
                        for (int i = 0; i < filecount; i++)
                        {
                            HttpPostedFile file = files[i];
                            string fileName = file.FileName;
                            fileName = fileName.Replace(" ", "");
                            var serverPath = context.Server.MapPath("~/" + savePath + "/");
                            if (!Directory.Exists(serverPath))
                            {
                                Directory.CreateDirectory(serverPath);
                            }
                            fname = DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss-fff", CultureInfo.InvariantCulture) + "~" + fileName;
                            file.SaveAs(serverPath + fname);
                        }
                        ResponseText = "SUCCESS: Uploaded successfully. ~$#" + savePath + "/" + fname;
                    }
                }
                catch (Exception ex)
                {
                    ResponseText = "ERROR: " + ex.ToString();
                }
                finally
                {
                    context.Response.Write(ResponseText);
                }
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
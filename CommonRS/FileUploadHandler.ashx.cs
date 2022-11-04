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
        
        public void ProcessRequest(HttpContext context)
        {
            string ResponseText = "";
            context.Response.ContentType = "text/plain";
            string savePath = context.Request.Form["savePath"];                                    
            string Action = context.Request.Form["Action"];
            /* FOR FILE UPLOAD - MULTIPLE - NEW */
            if (Action == "ReportUpload")
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
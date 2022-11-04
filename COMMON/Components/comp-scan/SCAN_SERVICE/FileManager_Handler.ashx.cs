using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using SCAN_RS.FileManagerClasses;
using System.IO;

namespace SCAN_RS
{
    /// <summary>
    /// Summary description for FileManager_Handler
    /// </summary>
    public class FileManager_Handler : IHttpHandler
    {
        HttpRequest GlobRequest;
        HttpContext GlobContext;
        public void ProcessRequest(HttpContext context)
        {
            Dictionary<string, object> ResultDictionary = new Dictionary<string, object>();
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();

            ResultDictionary.Add("status", true);
            ResultDictionary.Add("error", "");
            ResultDictionary.Add("ResultCount", 0);
            ResultDictionary["result"] = "";

            Serializer.MaxJsonLength = 500000000;
            string ResponseText = "";
            string Action = "";
            context.Response.ContentType = "text/plain";
            GlobRequest = context.Request;
            GlobContext = context;
            Action = GlobRequest.Form["Action"];
            try
            {
                if (Action == "UploadShowDoc")
                {
                    bool isUploaded = false;
                    FileManager FileMgr = new FileManager(context);
                    if (GlobRequest.Files.Count > 0)
                    {
                        string SaveFolder = GlobRequest.Form["savepath"];
                        
                        isUploaded = FileMgr.fnSaveUploadedFiles(SaveFolder);
                        if (isUploaded)
                        {
                            DataTable table = FileMgr.ShowAllDocs(true);
                            string JsonString = RestServiceSvc.ConvertDataTableToJson(table);
                            ResultDictionary["result"] = JsonString;
                        }
                        else
                        {
                            ResultDictionary["result"] = "[]";
                        }
                    }
                    else
                    {
                        DataTable dt = FileMgr.ShowAllDocs(true);
                        string JsonString = RestServiceSvc.ConvertDataTableToJson(dt);
                        ResultDictionary["result"] = JsonString;
                    }
                }
                else if (Action == "ShowTIFFPreview") {
                    FileManager FileMgr = new FileManager(context);
                    string JsonString = FileMgr.fnTiffImagePreview();
                    ResultDictionary["result"] = JsonString;
                }
                else if (Action == "SAVE_SELECTED") {
                    string isEnc = GlobRequest.Form["IsEncrypt"];
                    FileManager FileMgr = new FileManager(context);
                    bool isEncrypt = false;
                    if (isEnc == "true")
                        isEncrypt = true;
                    bool result = FileMgr.fnSaveSelectedImg(isEncrypt);
                    ResultDictionary["result"] = "[{result:" + result.ToString() + "}]";
                }
                else if (Action == "SAVE_SELECTED_PAGEWISE")
                {
                    string isEnc = GlobRequest.Form["IsEncrypt"];
                    string saveAsfile = GlobRequest.Form["saveAsfile"] == null ? "" : GlobRequest.Form["saveAsfile"];
                    FileManager FileMgr = new FileManager(context);
                    bool isEncrypt = false;
                    if (isEnc == "true")
                        isEncrypt = true;
                    //bool result = false;
                    string[] arr;
                    if (saveAsfile == "true")
                    {
                        arr = FileMgr.fnSaveSetOfImg(isEncrypt,true);
                        ResultDictionary["result"] = Serializer.Serialize(arr);
                        //ResultDictionary["result"] = "[{result:" + result.ToString() + "}]";                        
                    }
                    else
                    {
                        arr = FileMgr.fnSaveSetOfImg(isEncrypt,false);
                        ResultDictionary["result"] = Serializer.Serialize(arr);
                    }
                }
                else if (Action == "Folder_Preview" || Action == "ShowDeleted")
                {
                    string Path = GlobRequest.Form["PreviewPath"];
                    int Type = Convert.ToInt32(GlobRequest.Form["ViewType"]);
                    FileManager FileMgr = new FileManager(context);
                    Path = GlobContext.Server.MapPath("~/" + Path);

                    if (Directory.Exists(Path)) {
                        DataTable Dt = FileMgr.fnPreviewFiles(Path, 1);
                        string JsonString = RestServiceSvc.ConvertDataTableToJson(Dt);
                        ResultDictionary["result"] = JsonString;
                    }
                    else if (File.Exists(Path + ".txt") || File.Exists(Path + "_enc.txt") || Type == 1)
                    {
                        DataTable Dt = FileMgr.fnPreviewFiles(Path, Type);
                        string JsonString = RestServiceSvc.ConvertDataTableToJson(Dt);
                        ResultDictionary["result"] = JsonString;
                    }
                    else
                    {
                        ResultDictionary["result"] = "[{\"error\":\"Specified document not available.\"}]";
                    }
                }
                else if (Action == "DeleteFile")
                {
                    int type = Convert.ToInt32(GlobRequest.Form["DelType"]);
                    FileManager FileMgr = new FileManager(context);
                    FileMgr.fnDeleteFile(type);
                    ResultDictionary["result"] = "[{result:true}]";
                }
                else if (Action == "WORD_Preview")
                {
                    string filepath = GlobRequest.Form["previewFile"];
                    string FullPath = GlobContext.Server.MapPath("~") + "/" + filepath;
                    Word2Img WI = new Word2Img();
                    DataTable table = WI.fnConvertWord2Img(FullPath);
                    string JsonString = RestServiceSvc.ConvertDataTableToJson(table);
                    ResultDictionary["result"] = JsonString;
                }
            }
            catch (Exception ex)
            {
                ResultDictionary["status"] =  false;
                ResultDictionary["error"] = ex.Message;
            }
            finally
            {
                ResponseText = Serializer.Serialize(ResultDictionary);
            }
            context.Response.Write(ResponseText);
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
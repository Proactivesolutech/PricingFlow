using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace Masters
{
    /// <summary>
    /// Summary description for JsonFileEdit
    /// </summary>
    public class JsonFileEdit : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                context.Response.ContentType = "text/plain";
                string jsontext = context.Request["jsontext"];
                string fileName = context.Server.MapPath("~") + "/js/JSON/DbConnection.json";
                File.WriteAllText(fileName, jsontext);                
                context.Response.Write("success");
            }
            catch (Exception ex) {
                context.Response.Write(ex);
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
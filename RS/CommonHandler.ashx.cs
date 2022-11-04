using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SHFL_RS
{
    /// <summary>
    /// Summary description for CommonHandler
    /// </summary>
    public class CommonHandler : IHttpHandler
    {

        public void ProcessRequest(HttpContext Context)
        {
            string ClientIP = string.Empty;
            try
            {
                ClientIP = Context.Request.ServerVariables["REMOTE_ADDR"] == null ? Context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"] : Context.Request.ServerVariables["REMOTE_ADDR"];
            }
            catch (Exception ex)
            {
                ex.Data.Clear();
            }
            Context.Response.ContentType = "text/plain";
            Context.Response.Write(ClientIP);
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
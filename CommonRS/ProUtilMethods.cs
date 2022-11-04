using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script;
using System.Web.Script.Serialization;

namespace SHFL_RS
{
    public class ProUtilMethods
    {
        public static bool IsStringJson(string p_string)
        {
            p_string = p_string.Trim();
            
            return p_string.StartsWith("{") && p_string.EndsWith("}")
                    || p_string.StartsWith("[") && p_string.EndsWith("]"); 
            
        }
        public static string ConvertJsonArrayToXml(string p_jsonData, string elementTag = "item", string rootTag = "root")
        {
            StringBuilder xml = new StringBuilder();
            Dictionary<string, string>[] arrHtData = (new JavaScriptSerializer()).Deserialize<Dictionary<string, string>[]>(p_jsonData);
            xml.AppendFormat("<{0}>", rootTag);
            
            foreach (Dictionary<string, string> htData in arrHtData)
            {
                xml.AppendFormat("<{0} ", elementTag);

                foreach (string key in htData.Keys)
                {
                    if (htData[key] == null)
                    { { xml.AppendFormat("{0}=\"{1}\" ", key.Trim(), ""); } }
                    else
                    { xml.AppendFormat("{0}=\"{1}\" ", key.Trim(), System.Net.WebUtility.HtmlEncode(htData[key].Trim())); }

                   // xml.AppendFormat("{0}=\"{1}\" ", key.Trim(), System.Net.WebUtility.HtmlEncode(htData[key].Trim()));
                }
                xml.Append("/>");
            }
            xml.AppendFormat("</{0}>", rootTag);
            return xml.ToString();
        }



        /*Class to return JSON*/
        public static string ConvertJson(string p_jsonData, string elementTag = "item", string rootTag = "root")
        {
            return p_jsonData;
        }
        /*END*/
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
    }
}
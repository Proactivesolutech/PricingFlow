using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.ServiceModel.Web;
using System.IO;

namespace SCAN_RS
{
    /* Data contract Start */

    [DataContract]
    public class DataContract {
        [DataMember]
        public string ProcedureName { get; set; }
        
        [DataMember]
        public string Type { get; set; }
        
        [DataMember]
        public string[] Parameters { get; set; }
    }

    [DataContract]
    public class TiffPrwContract
    {
        [DataMember]
        public string receivedImages { get; set; }

        [DataMember]
        public string previewFile { get; set; }

        [DataMember]
        public string Imglimit { get; set; }    

    }
    [DataContract]
    public class FolderContract
    {
        [DataMember]
        public string userpk { get; set; }
    }
   

    /* Data contract End */

    /* Service contract Start */
    [ServiceContract]
    public interface IRestServiceSvc
    {      


        [WebInvoke(
            Method = "POST",
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.Bare,
            UriTemplate = "fnDataAccessService"
            )]
        [OperationContract]
        string fnDataAccessService(DataContract Data);


        [WebInvoke(RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
             BodyStyle = WebMessageBodyStyle.Bare, Method = "POST",
             UriTemplate = "fnTiffImagePreview")]
        [OperationContract]
        string fnTiffImagePreview(TiffPrwContract TIFF);

        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
        ResponseFormat = WebMessageFormat.Json,
        BodyStyle = WebMessageBodyStyle.Bare,
        UriTemplate = "fnCreateFolder")]
        [OperationContract]
        string fnCreateFolder(FolderContract folder);
    }
    /* Service contract End */
}

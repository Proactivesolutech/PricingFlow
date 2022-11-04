using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.ServiceModel.Web;
using System.IO;

namespace SHFL_RS
{
    /* Data contract Start */

    [DataContract]
    public class DataContract {
        [DataMember]
        public string ProcedureName { get; set; }

        [DataMember]
        public string QryTxt { get; set; }

        [DataMember]
        public string Type { get; set; }
        
        [DataMember]
        public string[] Parameters { get; set; }

         [DataMember]
        public string HtmlString { get; set; }
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

    [DataContract]
    public class AadharContract
    {
        [DataMember]
        public string AadharNum { get; set; }

        [DataMember]
        public string OTPGenerated { get; set; }

        [DataMember]
        public string BioString { get; set; }

        [DataMember]
        public string AuthType { get; set; }

        [DataMember]
        public string FingPrint { get; set; }
    }

    [DataContract]
    public class ExecDBContract
    {
        [DataMember]
        public string Query { get; set; }

        [DataMember]
        public string ConString { get; set; }
    }

    /* Data contract End */

    /* Service contract Start */
    [ServiceContract]
    public interface IRestServiceSvc
    {
        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
              ResponseFormat = WebMessageFormat.Json,
              BodyStyle = WebMessageBodyStyle.Bare,
              UriTemplate = "GetSoftCellData")]
        [OperationContract]
        string GetSoftCellData(SoftCell data);
        [OperationContract]
        string SoftCellAcknowledement(SoftCellAck data);


        [WebInvoke(
            Method = "POST",
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.Bare,
            UriTemplate = "fnDataAccessService"
            )]
        [OperationContract]
        string fnDataAccessService(DataContract Data);

        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
           ResponseFormat = WebMessageFormat.Json,
           BodyStyle = WebMessageBodyStyle.Bare,
           UriTemplate = "GetLocalIpAddress")]
        [OperationContract]
        string GetLocalIpAddress();

        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
         ResponseFormat = WebMessageFormat.Json,
         BodyStyle = WebMessageBodyStyle.Bare,
         UriTemplate = "GetServerUrl")]
        [OperationContract]
        string GetServerUrl();

        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
         ResponseFormat = WebMessageFormat.Json,
         BodyStyle = WebMessageBodyStyle.Bare,
         UriTemplate = "fnCreateFolder")]
        [OperationContract]
        string fnCreateFolder(FolderContract folder);

        [WebInvoke(
              Method = "POST",
              RequestFormat = WebMessageFormat.Json,
              ResponseFormat = WebMessageFormat.Json,
              BodyStyle = WebMessageBodyStyle.Bare,
              UriTemplate = "fnAadharGenerateOTP"
              )]
        [OperationContract]
        string fnAadharGenerateOTP(AadharContract AadharCt);

        [WebInvoke(
            Method = "POST",
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.Bare,
            UriTemplate = "fnGetAadharDetails"
            )]
        [OperationContract]
        string fnGetAadharDetails(AadharContract AadharCt);



        [WebInvoke(RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
             BodyStyle = WebMessageBodyStyle.Bare, Method = "POST",
             UriTemplate = "fnTiffImagePreview")]
        [OperationContract]
        string fnTiffImagePreview(TiffPrwContract TIFF);

        [WebInvoke(RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.Bare, Method = "POST",
            UriTemplate = "fnExecDBQuery")]
        [OperationContract]
        string fnExecDBQuery(ExecDBContract ExecDB);
       

    }
    /* Service contract End */

    [DataContract]
    public class ProMailContract
    {
        [DataMember]
        public string[] Params { get; set; }
    }

    [DataContract]
    public class SoftCell
    {
        [DataMember]
        public string InputString { get; set; }
    }
    [DataContract]
    public class SoftCellAck
    {
        [DataMember]
        public string AckNo { get; set; }
        [DataMember]
        public string AckDateTime { get; set; }
        [DataMember]
        public string LeadNo { get; set; }
    }
}

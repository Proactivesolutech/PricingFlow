using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;

namespace SHFL_RS
{
    public class MailSender
    {
        private static string _sConnectionString = "";
        private String toAddress;
        private String subject;
        private String body;

        public String _toAddress
        {
            set { toAddress = value; }
        }
        public String _subject
        {
            set { subject = value; }
        }
        public String _body
        {
            set { body = value; }
        }
        public AlternateView altview { set; get; }
        public String fromAddress
        {
            get;
            internal set;
        }
        public String fromPassword
        {
            get;
            internal set;
        }
        public String Host
        {
            get;
            internal set;
        }
        public int Port
        {
            get;
            internal set;
        }

        public void SendMail()
        {
            MailMessage objMailMessage = null;
            SmtpClient smtp = null;
            Attachment objAttach = null;
            try
            {
                smtp = new System.Net.Mail.SmtpClient();
                objMailMessage = new MailMessage(new MailAddress(fromAddress ?? ""), new MailAddress(toAddress ?? ""));
                objMailMessage.Subject = subject ?? "";
                objMailMessage.Body = body ?? "";
                objMailMessage.AlternateViews.Add(altview);
                //if (AttachmentPath != "")
                //{
                //    objAttach = new Attachment(AttachmentPath);
                //    objMailMessage.Attachments.Add(objAttach);
                //}
                smtp.Host = Host ?? "";
                smtp.Port = Port == null ? 0 : Port;
                smtp.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                smtp.Credentials = new NetworkCredential(fromAddress ?? "", fromPassword ?? "");
                smtp.Timeout = 100000;
                smtp.EnableSsl = true;
                smtp.Send(objMailMessage);
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                if (objMailMessage != null)
                {
                    objMailMessage.Dispose();
                }
                if (smtp != null)
                {
                    smtp.Dispose();
                }
                if (objAttach != null)
                {
                    objAttach.Dispose();
                }
            }
        }
    }
}
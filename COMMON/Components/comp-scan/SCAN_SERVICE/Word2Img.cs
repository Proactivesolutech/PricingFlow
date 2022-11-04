using word = Microsoft.Office.Interop.Word;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Reflection;
using System.ServiceModel.Dispatcher;
using System.Web;
using System.Data;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Office.Interop.Word;

namespace SCAN_RS
{
    public class Word2Img
    {

        public System.Data.DataTable fnConvertWord2Img(string startupPath)
        {
            System.Data.DataTable table = new System.Data.DataTable();
            DataRow row;
            table.Columns.Add("Base64", Type.GetType("System.String"));

            string file = startupPath;
            word.Application app = new word.Application();
            word.Document doc = app.Documents.Open(file);
            doc.ShowGrammaticalErrors = false;
            doc.ShowRevisions = false;
            doc.ShowSpellingErrors = false;


            Object paramDocPathSource = file;
            Object paramMissing = Type.Missing;
            doc = app.Documents.Add(ref paramDocPathSource, ref paramMissing, ref paramMissing, ref paramMissing);
            doc.Activate(); // Activate to get the word file image


            //Opens the word document and fetch each page and converts to image
            foreach (Window window in doc.Windows)
            {
                foreach (Pane pane in window.Panes)
                {
                    for (var i = 1; i <= pane.Pages.Count; i++)
                    {
                        Microsoft.Office.Interop.Word.Page page = null;
                        //bool populated = false;
                        try
                        {
                            page = pane.Pages[i];
                            //populated = true;
                        }
                        catch (COMException ex)
                        {
                            Thread.Sleep(1);
                        }
                        byte[] bytes = (byte[])page.EnhMetaFileBits; //(byte[])app.ActiveDocument.Content.EnhMetaFileBits;
                        if (bytes != null)
                        {
                            MemoryStream ms = new MemoryStream(bytes);
                            Image temp = Image.FromStream(ms);
                            string imgPath = Path.GetDirectoryName(file) + Path.DirectorySeparatorChar + Path.GetFileNameWithoutExtension(file) + i + ".png";
                            temp.Save(imgPath, ImageFormat.Png);
                            byte[] imageArray = System.IO.File.ReadAllBytes(imgPath);
                            string base64 = Convert.ToBase64String(imageArray);
                            File.Delete(imgPath);
                            row = table.NewRow();
                            row["Base64"] = base64;
                            table.Rows.Add(row);
                        }
                    }
                }
            }
            doc.Close(false);
            doc = null;
            app.Quit();
            GC.Collect();
            return table;
        }
    }
}
using ISQUARE_GenericControls;
//using Newtonsoft.Json;
//using Newtonsoft.Json;
using ServerControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using SHFL_RS;

namespace SHFL_RS.FileManagerClasses
{
    public class FileManager
    {
        HttpRequest GlobRequest;
        HttpContext GlobContext;
        public static DateTime DT = DateTime.Now;
        public string Year = DT.Year.ToString();
        public string Month = DT.Month.ToString();
        public string Day = DT.Day.ToString();
        public string Hour = DT.Hour.ToString();
        public string Minute = DT.Minute.ToString();
        public string Second = DT.Second.ToString();
        TiffPrwContract TIFF = new TiffPrwContract();


        public FileManager(HttpContext context) {
            GlobContext = context;
            GlobRequest = context.Request;            
        }

        public FileManager(TiffPrwContract TF)
        {
            TIFF = TF;                        
        }

        

        /// <summary>
        /// Function saves the uploaded file into specified path
        /// </summary>
        /// <param name="context"></param>
        /// <param name="SaveFolder"></param>
        /// <returns></returns>
        public bool fnSaveUploadedFiles(string SaveFolder)
        {
            bool result = false;
            try
            {                
                HttpFileCollection httpCollection = GlobRequest.Files;
                int FileCount = httpCollection.Count;
                string FolderPath = GlobContext.Server.MapPath("~/") + SaveFolder;
                if (!Directory.Exists(FolderPath)) {
                    Directory.CreateDirectory(FolderPath);
                }
                for (int i = 0; i < FileCount; i++)
                {
                    HttpPostedFile file = httpCollection[i];
                    string fileNm = file.FileName;
                    fileNm = "SHFL_" + Year + Month + Day + Hour + Minute + Second + "__X__" + fileNm;
                    string savePath = FolderPath + "/" + fileNm;
                    file.SaveAs(savePath);
                }
                result = true;
            }
            catch (Exception ex)
            {
                result = false;
            }
            return result;
        }



        public DataTable ShowAllDocs(bool isAllImg)
        {            
            DataTable table = new DataTable();
            DataColumn column;
            DataRow row;          

            // For Base 64 String
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "Base64";
            table.Columns.Add(column);

            // For Type of image
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "FileType";
            table.Columns.Add(column);

            // File - Physical Path
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "Filepath";
            table.Columns.Add(column);

            // For Error
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "Error";
            table.Columns.Add(column);

            string savePath = GlobRequest.Form["savePath"];
            var serverPath = GlobContext.Server.MapPath("~/" + savePath + "/");
            if (!Directory.Exists(serverPath))
            {
                row = table.NewRow();
                row["Base64"] = "";
                row["FileType"] = "";
                row["Filepath"] = "";
                row["Error"] = "Repository for this user is not created. contact admin to create a repository.";
                table.Rows.Add(row);
            }
            else
            {
                string[] Dir = Directory.GetFiles(serverPath);
                for (int i = 0; i < Dir.Length; i++)
                {
                    string Filetype = Path.GetExtension(Dir[i]).ToLower();
                    string FilePath = savePath + "/" + Path.GetFileName(Dir[i]);
                    if (Filetype == ".pdf" || Filetype == ".doc" || Filetype == ".docx")
                    {
                        isAllImg = false;
                        byte[] bytes = File.ReadAllBytes(Dir[i]);
                        string base64 = Convert.ToBase64String(bytes);

                        row = table.NewRow();
                        row["Base64"] = base64;
                        row["FileType"] = Filetype;
                        row["Filepath"] = FilePath;
                        row["Error"] = "";
                        table.Rows.Add(row);
                    }
                    else if (Filetype == ".tiff" || Filetype == ".tif")
                    {

                        row = table.NewRow();
                        row["Base64"] = "";
                        row["FileType"] = Filetype;
                        row["Filepath"] = FilePath;
                        row["Error"] = "";
                        table.Rows.Add(row);
                    }
                    else
                    {
                        Bitmap Images = (Bitmap)Image.FromFile(Dir[i]);
                        IS_ImageCompress imgCompress = IS_ImageCompress.GetImageCompressObject;
                        imgCompress.GetImage = Images;
                        imgCompress.Width = imgCompress.GetImage.Width;
                        imgCompress.Height = imgCompress.GetImage.Height;
                        byte[] imgArray = imgCompress.GetCompresedByte();
                        string base64 = Convert.ToBase64String(imgArray);
                        row = table.NewRow();
                        row["Base64"] = base64;
                        row["FileType"] = Filetype;
                        row["Filepath"] = FilePath;
                        row["Error"] = "";
                        table.Rows.Add(row);
                        Images.Dispose();
                    }
                }
            }
            return table;
        }


        public string fnTiffImagePreview() {
            DataTable table = new DataTable();
            DataColumn column;
            DataRow row;
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "DocBase64";
            table.Columns.Add(column);
            string[] str = TiffPreview();
            for (int i = 0; i < str.Length; i++)
            {
                row = table.NewRow();
                row["DocBase64"] = str[i];
                table.Rows.Add(row);
            }
            return RestServiceSvc.ConvertDataTableToJson(table);
        }


        public string TESTfnTiffImagePreview(ref int ReceivedCount, ref int pageCount)
        {
            DataTable table = new DataTable();
            DataColumn column;
            DataRow row;
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "DocBase64";
            table.Columns.Add(column);
            string[] str = TESTTiffPreview(ref ReceivedCount, ref pageCount);

            for (int i = 0; i < str.Length; i++)
            {
                row = table.NewRow();
                row["DocBase64"] = str[i];
                table.Rows.Add(row);
            }
            return RestServiceSvc.ConvertDataTableToJson(table);
        }

        public string[] TiffPreview()
        {
            string Imgpath = GlobRequest.Form["previewFile"];
            string filePath = GlobContext.Server.MapPath("~") + "/" + Imgpath;
            string[] arr64;
            using (FileStream stream = File.Open(filePath, FileMode.Open))
            {
                TiffManager tifmgr = new TiffManager(stream, filePath);
                arr64 = tifmgr.SplitTiffImageToBase64(EncoderValue.CompressionNone);
            }
            return arr64;
        }

        public string[] TESTTiffPreview(ref int count, ref int pageCount)
        {
            string Imgpath = TIFF.previewFile;
            int ImgLimit = Convert.ToInt32(TIFF.Imglimit);
            string filePath = HttpRuntime.AppDomainAppPath + "/" + Imgpath;
            string[] arr64;
            using (FileStream stream = File.Open(filePath, FileMode.Open))
            {
                TiffManager tifmgr = new TiffManager(stream, filePath);
                pageCount = tifmgr.PageNumber;
                arr64 = tifmgr.TESTSplitTiffImageToBase64(EncoderValue.CompressionNone, ref count, ImgLimit);
            }
            return arr64;
        }


        public bool fnSaveSelectedImg(bool IsEncrypt)
        {
            string outPath = "";
            int FileCount = Convert.ToInt32(GlobRequest.Form["FileLength"]);
            string Givenpath = GlobRequest.Form["savepath"];
            outPath = GlobContext.Server.MapPath("~/SHFL_DOCS/" + Givenpath);
            if (!Directory.Exists(outPath))
                Directory.CreateDirectory(outPath);
            int saveFile = Directory.GetFiles(outPath).Length + 1;
            for (int i = 0; i < FileCount; i++)
            {
                string fileSavePath = "";
                string base64Str = GlobRequest.Form["file_" + (i + 1)];
                var bytes = Convert.FromBase64String(base64Str);
                MemoryStream ms = new MemoryStream(bytes);
                Bitmap bmp = (Bitmap)Bitmap.FromStream(ms);
                string NumString = "";
                NumString = saveFile < 10 ? "00" + saveFile.ToString() : NumString = saveFile < 100 ? "0" + saveFile.ToString() : saveFile.ToString();
                fileSavePath = outPath + "/file_" + NumString + ".jpg";
                //while (fileSavePath.Contains("file_" + saveFile))
                while (File.Exists(fileSavePath))
                {
                    saveFile++;
                    NumString = saveFile < 10 ? "00" + saveFile.ToString() : NumString = saveFile < 100 ? "0" + saveFile.ToString() : saveFile.ToString();
                    fileSavePath = outPath + "/file_" + NumString + ".jpg";
                }
                bmp.Save(fileSavePath, ImageFormat.Jpeg);
                saveFile++;
                ms.Dispose();
                bmp.Dispose();
                if (IsEncrypt)
                {
                    string encSavePath = fileSavePath.Substring(0, fileSavePath.LastIndexOf("."));
                    string ext = Path.GetExtension(fileSavePath);
                    bool EncRet = this.Encrypt(fileSavePath, encSavePath + "_enc" + ext);
                    if (EncRet)
                        File.Delete(fileSavePath);
                }

            }

            return true;
        }

        public string[] fnSaveSetOfImg(bool IsEncrypt,bool isSaveAsImg) {
            string outPath = "";
            int FileCount = Convert.ToInt32(GlobRequest.Form["setLength"]);
            string ImageData = GlobRequest.Form["ImageData"];
            string Givenpath = GlobRequest.Form["savepath"];
            //int indxOfSlash = Givenpath.IndexOf("/") == -1 ? 1 : Givenpath.IndexOf("/");
            //string ID = Givenpath.Substring(0, indxOfSlash);
            string ID = Givenpath;
            string SavefileNm = Givenpath.Substring(Givenpath.IndexOf("/") + 1).Replace("/", "");
            string fileTempNm = "SHFL_DOCS\\" + ID;
            outPath = GlobContext.Server.MapPath("~/" + fileTempNm);
            if (!Directory.Exists(outPath))
                Directory.CreateDirectory(outPath);
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            Serializer.MaxJsonLength = 999999999;

            var ImagesetList = Serializer.Deserialize<List<ImageSet>>(ImageData).ToDictionary(x => x.DocNm, x => x.SrcList);
            string[] arrFile = new string[ImagesetList.Count];
            int i=0;
            
            foreach (var Imageset in ImagesetList)
            {
                if (isSaveAsImg) {
                    string[] arrImg = Imageset.Value;
                    string Filepath = Imageset.Key;                    
                    string saveFolder = outPath + "/" + Filepath;
                    if (!Directory.Exists(saveFolder))
                        Directory.CreateDirectory(saveFolder);
                    int saveFile = Directory.GetFiles(saveFolder).Length + 1;
                    string saveFolderDB = fileTempNm + "/" + Filepath;                    
                    for (int fileCnt = 0; fileCnt < arrImg.Length; fileCnt++)
                    {
                        string fileSavePath = "";
                        string base64Str =arrImg[fileCnt];
                        var bytes = Convert.FromBase64String(base64Str);
                        MemoryStream ms = new MemoryStream(bytes);
                        Bitmap bmp = (Bitmap)Bitmap.FromStream(ms);
                        string NumString = "";
                        NumString = saveFile < 10 ? "00" + saveFile.ToString() : NumString = saveFile < 100 ? "0" + saveFile.ToString() : saveFile.ToString();
                        fileSavePath = saveFolder + "/file_" + NumString + ".jpg";
                        //while (fileSavePath.Contains("file_" + saveFile))
                        while (File.Exists(fileSavePath))
                        {
                            saveFile++;
                            NumString = saveFile < 10 ? "00" + saveFile.ToString() : NumString = saveFile < 100 ? "0" + saveFile.ToString() : saveFile.ToString();
                            fileSavePath = saveFolder + "/file_" + NumString + ".jpg";
                        }
                        bmp.Save(fileSavePath, ImageFormat.Jpeg);
                        saveFile++;
                        ms.Dispose();
                        bmp.Dispose();
                        if (IsEncrypt)
                        {
                            string encSavePath = fileSavePath.Substring(0, fileSavePath.LastIndexOf("."));
                            string ext = Path.GetExtension(fileSavePath);
                            bool EncRet = this.Encrypt(fileSavePath, encSavePath + "_enc" + ext);
                            if (EncRet)
                                File.Delete(fileSavePath);
                        }
                    }
                    if (Array.IndexOf(arrFile, saveFolderDB) >= 0)
                        arrFile[i] = "null";
                    else
                        arrFile[i] = saveFolderDB;
                }
                else
                {
                    string fileName = Imageset.Key;
                    string temp = "";
                    temp = fileTempNm + "\\" + SavefileNm + "_" + fileName + ".txt";
                    fileName = outPath + "\\" + SavefileNm + "_" + fileName + ".txt"; ;
                    string fileNmWithoutExt = outPath + "\\" + Path.GetFileNameWithoutExtension(fileName);
                    string fileExt = Path.GetExtension(fileName);
                    File.WriteAllText(fileName, Serializer.Serialize(Imageset));
                    if (IsEncrypt)
                    {
                        bool EncRet = this.Encrypt(fileName, fileNmWithoutExt + "_enc" + fileExt);
                        if (EncRet)
                            File.Delete(fileName);
                    }
                    arrFile[i] = temp;                    
                }
                i++;
            }
            return arrFile;
        }

        public bool fnSaveSetOfImg()
        {
            string outPath = "";
            int FileCount = Convert.ToInt32(GlobRequest.Form["setLength"]);
            string ImageData = GlobRequest.Form["ImageData"];
            string Givenpath = GlobRequest.Form["savepath"];
            if (!Directory.Exists(GlobContext.Server.MapPath("~/" + Givenpath)))
                Directory.CreateDirectory(GlobContext.Server.MapPath("~/" + Givenpath));
            var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            Serializer.MaxJsonLength = 999999999;
            string[] arr = ImageData.Split(',');
            for (int i = 0; i < arr.Length; i++)
            {
                DT = DateTime.Now;
                Year = DT.Year.ToString();
                Month = DT.Month.ToString();
                Day = DT.Day.ToString();
                Hour = DT.Hour.ToString();
                Minute = DT.Minute.ToString();
                Second = DT.Second.ToString();
                string milliSec = DT.Millisecond.ToString();
                outPath = GlobContext.Server.MapPath("~/" + Givenpath + "/" + Year + Month + Day + Hour + Minute + Second + milliSec + ".jpg");
                string base64Str = arr[i];
                var bytes = Convert.FromBase64String(base64Str);
                MemoryStream ms = new MemoryStream(bytes);
                Bitmap bmp = (Bitmap)Bitmap.FromStream(ms);
                bmp.Save(outPath, ImageFormat.Jpeg);
                bmp.Dispose();
                ms.Dispose();
            }
            return true;
        }


        public DataTable fnPreviewFiles(string FolderPath, int type)
        {
            DataTable table = new DataTable();
            DataRow row;
            table.Columns.Add("Base64", Type.GetType("System.String"));
            table.Columns.Add("Filepath", Type.GetType("System.String"));

            string path = FolderPath;
            string isComp = GlobRequest.Form["iscomp"] == null ? "" : GlobRequest.Form["iscomp"];          
            if (type == 1)
            {
                string[] filePaths = Directory.GetFiles(path);
                foreach (string filePath in filePaths)
                {
                    string fileName = Path.GetFileNameWithoutExtension(filePath);
                    string fileNamewithExt = Path.GetFileName(filePath);
                    string base64ImageRepresentation = "";
                    if ((!fileName.Contains("___D")) && (!fileName.Contains("_R")))
                    {
                        string fileExtension = Path.GetExtension(filePath);
                        string fileWithoutExtension = Path.GetFileNameWithoutExtension(filePath);
                        if (fileWithoutExtension.IndexOf("_enc") == fileWithoutExtension.Length - 4)
                        {
                            string input = filePath;
                            string output = filePath + "_dec" + fileExtension;
                            this.Decrypt(input, output);
                            byte[] imageArray = System.IO.File.ReadAllBytes(output);
                            base64ImageRepresentation = Convert.ToBase64String(imageArray);
                            File.Delete(output);
                        }
                        else
                        {
                            byte[] imageArray = System.IO.File.ReadAllBytes(filePath);
                            base64ImageRepresentation = Convert.ToBase64String(imageArray);
                        }
                        row = table.NewRow();
                        row["Base64"] = base64ImageRepresentation;
                        row["Filepath"] = filePath.Substring(filePath.IndexOf("SHFL_DOCS"));
                        table.Rows.Add(row);
                    }
                }
            }
            else if (type == 2 || type == 3)
            {
                string fileStr = "";
                string txtFilepath = path + ".txt";
                if (!File.Exists(txtFilepath))
                    txtFilepath = path + "_enc.txt";
                string fileName = Path.GetFileNameWithoutExtension(txtFilepath);
                string fileNamewithExt = Path.GetFileName(txtFilepath);
                if ((!fileName.Contains("___D")) && (!fileName.Contains("_R")))
                {
                    string fileExtension = Path.GetExtension(txtFilepath);
                    string fileWithoutExtension = Path.GetFileNameWithoutExtension(txtFilepath);
                    if (fileWithoutExtension.IndexOf("_enc") == fileWithoutExtension.Length - 4)
                    {
                        string input = txtFilepath;
                        string output = txtFilepath + "_dec" + fileExtension;
                        this.Decrypt(input, output);
                        fileStr = File.ReadAllText(output);
                        File.Delete(output);
                    }
                    else
                    {
                        fileStr = File.ReadAllText(txtFilepath);
                    }

                    if (fileStr.IndexOf("[") != 0)
                        fileStr = "[" + fileStr;
                    if (fileStr.LastIndexOf("]") != fileStr.Length - 1)
                        fileStr = fileStr + "]";

                    var Serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                    Serializer.MaxJsonLength = 999999999;

                    var ImagesetList = Serializer.Deserialize<List<ReTImageSet>>(fileStr).ToDictionary(x => x.Key, x => x.Value);
                    foreach (var ImgSet in ImagesetList)
                    {
                        string key = ImgSet.Key;
                        string[] value = ImgSet.Value;
                        for (int i = 0; i < value.Length; i++)
                        {
                            if (type == 2)
                            {
                                if (!value[i].Contains("___D"))
                                {
                                    row = table.NewRow();
                                    row["Base64"] = value[i];
                                    row["Filepath"] = txtFilepath.Substring(txtFilepath.IndexOf("SHFL_DOCS")); ;
                                    table.Rows.Add(row);
                                }
                            }
                            else if (type == 3)
                            {
                                if (value[i].Contains("___D"))
                                {
                                    row = table.NewRow();
                                    row["Base64"] = value[i].Replace("___D", "");
                                    row["Filepath"] = txtFilepath.Substring(txtFilepath.IndexOf("SHFL_DOCS")); ;
                                    table.Rows.Add(row);
                                }
                            }
                        }
                    }

                }
            }
            return table;
        }

        public void fnDeleteFile(int type){
            int len = Convert.ToInt32(GlobRequest.Form["DelLength"]);
            if (type == 1)
            {
                for (int i = 0; i < len; i++)
                {
                    string filepath = GlobRequest.Form["DelFile_" + (i + 1)];
                    filepath = GlobContext.Server.MapPath("~") + "/" + filepath;
                    string fileExt = Path.GetExtension(filepath);
                    string outfile = filepath.Substring(0, filepath.LastIndexOf(".")) + "___D" + fileExt;
                    File.Move(filepath, outfile);
                }
            }
            else if (type == 2 || type ==3)
            {
                string filepath = GlobRequest.Form["DelFile_1"];
                filepath = GlobContext.Server.MapPath("~") + "/" + filepath;
                if (File.Exists(filepath))
                {
                    string FileStr = "";
                    string fileExtension = Path.GetExtension(filepath);
                    string fileWithoutExtension = Path.GetFileNameWithoutExtension(filepath);
                    if (fileWithoutExtension.IndexOf("_enc") == fileWithoutExtension.Length - 4)
                    {
                        string input = filepath;
                        string output = filepath + "_dec" + fileExtension;

                        this.Decrypt(input, output);
                        FileStr = File.ReadAllText(output);
                        File.Delete(output);
                        for (int i = 1; i <= len; i++)
                        {
                            string ReplceStr = GlobRequest.Form["DelFile_Base64_" + i];
                            if (type == 2)
                                FileStr = FileStr.Replace(ReplceStr, ReplceStr + "___D");
                            if (type == 3)
                                FileStr = FileStr.Replace(ReplceStr + "___D", ReplceStr);
                        }

                        File.Delete(filepath);
                        File.WriteAllText(filepath, FileStr);
                        this.Encrypt(filepath, filepath + "_1.txt");
                        File.Delete(filepath);
                        File.Move(filepath + "_1.txt", filepath);
                    }
                    else
                    {
                        FileStr = File.ReadAllText(filepath);
                        for (int i = 0; i < len; i++)
                        {
                            string ReplceStr = GlobRequest.Form["DelFile_Base64" + (i + 1)];
                            FileStr = FileStr.Replace(ReplceStr, ReplceStr + "___D");
                        }
                        File.WriteAllText(filepath, FileStr);
                    }

                }
            }
        
        }

        public bool Encrypt(string inputFilePath, string outputfilePath)
        {
            string EncryptionKey = "MAKV2SPBNI99212";
            using (Aes encryptor = Aes.Create())
            {
                Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);
                using (FileStream fs = new FileStream(outputfilePath, FileMode.Create))
                {
                    using (CryptoStream cs = new CryptoStream(fs, encryptor.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        using (FileStream fsIn = new FileStream(inputFilePath, FileMode.Open))
                        {
                            int data;
                            while ((data = fsIn.ReadByte()) != -1)
                            {
                                cs.WriteByte((byte)data);
                            }
                        }
                    }

                }
            }
            return true;
        }

        public void Decrypt(string inputFilePath, string outputfilePath)
        {
            string EncryptionKey = "MAKV2SPBNI99212";
            using (Aes encryptor = Aes.Create())
            {
                Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);
                using (FileStream fs = new FileStream(inputFilePath, FileMode.Open))
                {
                    using (CryptoStream cs = new CryptoStream(fs, encryptor.CreateDecryptor(), CryptoStreamMode.Read))
                    {
                        using (FileStream fsOut = new FileStream(outputfilePath, FileMode.Create))
                        {
                            int data;
                            while ((data = cs.ReadByte()) != -1)
                            {
                                fsOut.WriteByte((byte)data);
                            }
                        }
                    }
                }
            }
        }

        private string getArrayString(string[] array)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < array.Length; i++)
            {
                sb.Append("'" + array[i] + "'" + ",");
            }
            string arrayStr = string.Format("[{0}]", sb.ToString().TrimEnd(','));
            return arrayStr;
        }

        private static bool ISValidFileType(string fileName)
        {
            bool isValidExt = false;
            string fileExt = Path.GetExtension(fileName);
            switch (fileExt.ToLower())
            {
                case ".jpeg":
                case ".btm":
                case ".jpg":
                case ".png":
                case ".tiff":
                case ".tif":
                    isValidExt = true;
                    break;
            }
            return isValidExt;
        }

    }
    // Class Ends

    public  class ArrImageSet
    {
        public ImageSet[] imgset { get; set; }
    }

    public class ImageSet{
        public string DocNm { get; set; }
        public string[] SrcList { get; set; }
    }
    public class ReTImageSet
    {
        public string Key { get; set; }
        public string[] Value { get; set; }
    }

    public class ImageAnnotation
    {
        public string ImageId { get; set; }
        public string[] Annotation { get; set; }
    }

}

// Namespace Ends
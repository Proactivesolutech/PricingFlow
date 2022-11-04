using System;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;		 
using System.Collections;
using ServerControls;
using System.Windows.Media.Imaging;
using System.Windows.Media;
using System.Configuration;

namespace SCAN_RS
{
	/// <summary>
	/// Summary description for TiffManager.
	/// </summary>
	public class TiffManager : IDisposable
	{
		private string _ImageFileName;
		private int _PageNumber;
		public Image image;
		private string _TempWorkingDir;
        private Stream GlobStream;

		public TiffManager(string imageFileName)
		{
			this._ImageFileName=imageFileName;
			image=Image.FromFile(_ImageFileName);
			GetPageNumber();
		}

        public TiffManager(Stream ImageStream, string imageFileName)
        {
            this._ImageFileName = imageFileName;
            //image = Image.FromFile(_ImageFileName);
            GlobStream = ImageStream;
            image = Image.FromStream(ImageStream);
            GetPageNumber();
        }
		
		public TiffManager(){
		}

		/// <summary>
		/// Read the image file for the page number.
		/// </summary>
		private void GetPageNumber(){
			Guid objGuid=image.FrameDimensionsList[0];
			FrameDimension objDimension=new FrameDimension(objGuid);

			//Gets the total number of frames in the .tiff file
			_PageNumber=image.GetFrameCount(objDimension);
			
			return;
		}

		/// <summary>
		/// Read the image base string,
		/// Assert(GetFileNameStartString(@"c:\test\abc.tif"),"abc")
		/// </summary>
		/// <param name="strFullName"></param>
		/// <returns></returns>
		private string GetFileNameStartString(string strFullName){
			int posDot=_ImageFileName.LastIndexOf(".");
			int posSlash=_ImageFileName.LastIndexOf(@"\");
			return _ImageFileName.Substring(posSlash+1,posDot-posSlash-1);
		}

		/// <summary>
		/// This function will output the image to a TIFF file with specific compression format
		/// </summary>
		/// <param name="outPutDirectory">The splited images' directory</param>
		/// <param name="format">The codec for compressing</param>
		/// <returns>splited file name array list</returns>
		public ArrayList SplitTiffImage(string outPutDirectory,EncoderValue format)
		{
			string fileStartString=outPutDirectory+"\\"+GetFileNameStartString(_ImageFileName);
			ArrayList splitedFileNames=new ArrayList();
			try{
				Guid objGuid=image.FrameDimensionsList[0];
				FrameDimension objDimension=new FrameDimension(objGuid);

				//Saves every frame as a separate file.
				Encoder enc=Encoder.Compression;
				int curFrame=0;
				for (int i=0;i<_PageNumber;i++)
				{
					image.SelectActiveFrame(objDimension,curFrame);
					EncoderParameters ep=new EncoderParameters(1);
					ep.Param[0]=new EncoderParameter(enc,(long)format);
					ImageCodecInfo info=GetEncoderInfo("image/tiff");
					
					//Save the master bitmap
					string fileName=string.Format("{0}{1}.TIF",fileStartString,i.ToString());
					image.Save(fileName,info,ep);
					splitedFileNames.Add(fileName);

					curFrame++;
				}	
			}catch (Exception){
				throw;
			}
			
			return splitedFileNames;
		}



        /// <summary>
        /// This function will output the TIFF image to a base64 String array
        /// </summary>
        /// <param name="outPutDirectory"></param>
        /// <param name="format"></param>
        /// <returns></returns>

        public string[] SplitTiffImageToBase64(EncoderValue format)
        {
            string[] splitedFileBase64 = new string[_PageNumber];
            try
            {
                Guid objGuid = image.FrameDimensionsList[0];
                FrameDimension objDimension = new FrameDimension(objGuid);
                int curFrame = 0;
                for (int i = 0; i < _PageNumber; i++)
                {
                    image.SelectActiveFrame(objDimension, curFrame);
                    System.Drawing.Bitmap bmpPostedImage = new System.Drawing.Bitmap(image);
                    IS_ImageCompress imgCompress = IS_ImageCompress.GetImageCompressObject;
                    imgCompress.GetImage = bmpPostedImage;
                    imgCompress.Width = imgCompress.GetImage.Width;
                    imgCompress.Height = imgCompress.GetImage.Height;
                    byte[] imgArray = imgCompress.GetCompresedByte();
                    string base64ImageRepresentation = Convert.ToBase64String(imgArray);                    
                    //Save the master bitmap
                    splitedFileBase64[i] = base64ImageRepresentation;                    
                    curFrame++;
                }
            }
            catch (Exception)
            {
                throw;
            }

            return splitedFileBase64;
        }


        public string[] TESTSplitTiffImageToBase64(EncoderValue format, ref int count, int ImgLimit)
        {
            int imageLimit = ImgLimit > 0 ? ImgLimit : _PageNumber;
            string[] splitedFileBase64 = new string[imageLimit];
            int curFrame = count;
            if (count == _PageNumber)
                count = -1;
            try
            {
                image = Image.FromStream(GlobStream);
                FrameDimension objDimension = new FrameDimension(image.FrameDimensionsList[0]);
                int arrCount = 0;                
                for (int i = count; i < _PageNumber && arrCount < imageLimit && i >= curFrame; i++)
                {
                    image = Image.FromStream(GlobStream);
                    objDimension = new FrameDimension(image.FrameDimensionsList[0]);

                    image.SelectActiveFrame(objDimension, curFrame);
                    System.Drawing.Bitmap bmpPostedImage = new System.Drawing.Bitmap(image);
                    IS_ImageCompress imgCompress = IS_ImageCompress.GetImageCompressObject;
                    imgCompress.GetImage = bmpPostedImage;
                    imgCompress.Width = imgCompress.GetImage.Width;
                    imgCompress.Height = imgCompress.GetImage.Height;
                    byte[] imgArray = imgCompress.GetCompresedByte();
                    string base64ImageRepresentation = Convert.ToBase64String(imgArray);
                    splitedFileBase64[arrCount] = base64ImageRepresentation;
                    arrCount++;
                    curFrame++;
                }
                if (arrCount < imageLimit)
                {
                    splitedFileBase64 = splitedFileBase64.Where(val => val != null).ToArray();
                }
            }
            catch (Exception)
            {
                throw;
            }

            return splitedFileBase64;
        }



		/// <summary>
		/// This function will join the TIFF file with a specific compression format
		/// </summary>
		/// <param name="imageFiles">string array with source image files</param>
		/// <param name="outFile">target TIFF file to be produced</param>
		/// <param name="compressEncoder">compression codec enum</param>
		public void JoinTiffImages(string[] imageFiles,string outFile,EncoderValue compressEncoder)
		{
			try{
				//If only one page in the collection, copy it directly to the target file.
				if (imageFiles.Length==1)
				{
					File.Copy(imageFiles[0],outFile,true);
					return;
				}

				//use the save encoder
				Encoder enc=Encoder.SaveFlag;

				EncoderParameters ep=new EncoderParameters(2);
				ep.Param[0]=new EncoderParameter(enc,(long)EncoderValue.MultiFrame); 
				ep.Param[1] = new EncoderParameter(Encoder.Compression,(long)compressEncoder); 

				Bitmap pages=null;
				int frame=0;
				ImageCodecInfo info=GetEncoderInfo("image/tiff");


				foreach(string strImageFile in imageFiles)
				{
					if(frame==0)
					{
						pages=(Bitmap)Image.FromFile(strImageFile);

						//save the first frame
						pages.Save(outFile,info,ep);
					}
					else
					{
						//save the intermediate frames
						ep.Param[0]=new EncoderParameter(enc,(long)EncoderValue.FrameDimensionPage);

						Bitmap bm=(Bitmap)Image.FromFile(strImageFile);
						pages.SaveAdd(bm,ep);
					}        

					if(frame==imageFiles.Length-1)
					{
						//flush and close.
						ep.Param[0]=new EncoderParameter(enc,(long)EncoderValue.Flush);
						pages.SaveAdd(ep);
					} 

					frame++;
				}
			}catch (Exception){
				throw;
			}
			
			return;
		}

        Bitmap[] Base64ToImage(string[] base64)
        {
            //BitmapFrame[] bmFrm = new BitmapFrame[base64.Length];
            Bitmap[] bitmap = null;            
            MemoryStream stream = null;
            for (int i = 0; i < base64.Length; i++)
            {
                byte[] bytes = Convert.FromBase64String(base64[i]);
                stream = new MemoryStream(bytes);
                //bmFrm[i] = BitmapFrame.Create(stream);
                bitmap[i] = (Bitmap) Bitmap.FromStream(stream);
            }
            return bitmap;
        }

        /// <summary>
        /// This function will join the TIFF file with a specific compression format
        /// </summary>
        /// <param name="imageBase64"> in Base64 format </param>
        /// <param name="outFile"></param>
        /// <param name="compressEncoder"></param>

        public bool JoinTiffImages(string[] imageBase64, string outFile, EncoderValue compressEncoder,bool isBase64)
        {
            try
            {
/*
                int width = 128;
                int height = width;
                int stride = width / 8;
                byte[] pixels = new byte[height * stride];

                // Define the image palette
                //BitmapPalette myPalette = BitmapPalettes.WebPalette;

                // Creates a new empty image with the pre-defined palette                
                TiffBitmapEncoder encodertif = new TiffBitmapEncoder();                
                //encodertif.Compression = TiffCompressOption.Zip;
                Bitmap[] BMFrm = Base64ToImage(imageBase64);
                for (int i = 0; i < BMFrm.Length; i++)
                {                    
                    encodertif.Frames.Add((BitmapFrame)BMFrm[i]);
                }
                if (File.Exists(outFile))
                    File.Delete(outFile);
                FileStream stream = new FileStream(outFile, FileMode.Create);
                encodertif.Save(stream);
                if (outFile.Length > 0)
                    return true;

                */

                Encoder encoder = Encoder.SaveFlag;
                ImageCodecInfo encoderInfo = ImageCodecInfo.GetImageEncoders().First(i => i.MimeType == "image/tiff");
                EncoderParameters encoderParameters = new EncoderParameters(2);
                encoderParameters.Param[0] = new EncoderParameter(encoder, (long)EncoderValue.MultiFrame);
                encoderParameters.Param[1] = new EncoderParameter(Encoder.Quality, (long)compressEncoder);
                Bitmap firstImage = null;
                // Save the first frame of the multi page tiff
                byte[] bytes = Convert.FromBase64String(imageBase64[0]);

                if (imageBase64.Length == 0) {                    
                    System.Drawing.Image image__1 = default(System.Drawing.Image);
                    using (MemoryStream ms = new MemoryStream(bytes))
                    {
                        image__1 = System.Drawing.Image.FromStream(ms);
                        image__1.Save(outFile);
                    }
                    return true;
                }


                using(Stream ms = new MemoryStream(bytes)){
                    firstImage = (Bitmap) Image.FromStream(ms);

                    IS_ImageCompress imgCompress = IS_ImageCompress.GetImageCompressObject;
                    imgCompress.GetImage = firstImage;


                    imgCompress.Width = imgCompress.GetImage.Width;
                    imgCompress.Height = imgCompress.GetImage.Height;
                    byte[] imgArray = imgCompress.GetCompresedByte();
                    /*
                    string base64ImageRepresentation = Convert.ToBase64String(imgArray);
                    string compBase64String = LZString.compressToUTF16(base64ImageRepresentation);
                    string deCompBase64String = LZString.decompressFromUTF16(compBase64String);
                    var bytes1 = Convert.FromBase64String(deCompBase64String);
                    */
                    using (Stream ms1 = new MemoryStream(imgArray))
                    {
                        firstImage = (Bitmap)Image.FromStream(ms1);
                        firstImage.Save(outFile, encoderInfo, encoderParameters);
                    }                                        
                }
                encoderParameters.Param[0] = new EncoderParameter(encoder, (long)EncoderValue.FrameDimensionPage);
                encoderParameters.Param[1] = new EncoderParameter(Encoder.Quality, (long)compressEncoder);

                // Add the remining images to the tiff
                for (int i = 1; i < imageBase64.Length; i++)
                {                      
                    var bytes1 = Convert.FromBase64String(imageBase64[i]);
                    using(Stream ms = new MemoryStream(bytes1)){
                        Bitmap img = (Bitmap)Image.FromStream(ms);
                        IS_ImageCompress imgCompress = IS_ImageCompress.GetImageCompressObject;
                        imgCompress.GetImage = img;


                        imgCompress.Width = imgCompress.GetImage.Width;
                        imgCompress.Height = imgCompress.GetImage.Height;
                        byte[] imgArray = imgCompress.GetCompresedByte();
                        /*
                        string base64ImageRepresentation = Convert.ToBase64String(imgArray);
                        string compBase64String = LZString.compressToUTF16(base64ImageRepresentation);
                        string deCompBase64String = LZString.decompressFromUTF16(compBase64String);
                        var bytes2 = Convert.FromBase64String(deCompBase64String);                        
                         */
                        using (Stream ms2 = new MemoryStream(imgArray))
                        {
                            img = (Bitmap)Image.FromStream(ms2);
                            firstImage.SaveAdd(img, encoderParameters);
                        }                           
                    }
                }

                // Close out the file
                encoderParameters.Param[0] = new EncoderParameter(encoder, (long)EncoderValue.Flush);
                firstImage.SaveAdd(encoderParameters);




            }
            catch (Exception Ex)
            {
                return false;
            }

            return true;
        }



		/// <summary>
		/// This function will join the TIFF file with a specific compression format
		/// </summary>
		/// <param name="imageFiles">array list with source image files</param>
		/// <param name="outFile">target TIFF file to be produced</param>
		/// <param name="compressEncoder">compression codec enum</param>
		public void JoinTiffImages(ArrayList imageFiles,string outFile,EncoderValue compressEncoder)
		{
			try
			{
				//If only one page in the collection, copy it directly to the target file.
				if (imageFiles.Count==1){
					File.Copy((string)imageFiles[0],outFile,true);
					return;
				}

				//use the save encoder
				Encoder enc=Encoder.SaveFlag;

				EncoderParameters ep=new EncoderParameters(2);
				ep.Param[0]=new EncoderParameter(enc,(long)EncoderValue.MultiFrame); 
				ep.Param[1] = new EncoderParameter(Encoder.Compression,(long)compressEncoder); 

				Bitmap pages=null;
				int frame=0;
				ImageCodecInfo info=GetEncoderInfo("image/tiff");


				foreach(string strImageFile in imageFiles)
				{
					if(frame==0)
					{
						pages=(Bitmap)Image.FromFile(strImageFile);

						//save the first frame
						pages.Save(outFile,info,ep);
					}
					else
					{
						//save the intermediate frames
						ep.Param[0]=new EncoderParameter(enc,(long)EncoderValue.FrameDimensionPage);

						Bitmap bm=(Bitmap)Image.FromFile(strImageFile);
						pages.SaveAdd(bm,ep);
						bm.Dispose();
					}        

					if(frame==imageFiles.Count-1)
					{
						//flush and close.
						ep.Param[0]=new EncoderParameter(enc,(long)EncoderValue.Flush);
						pages.SaveAdd(ep);
					} 

					frame++;
				}
			}
			catch (Exception ex)
			{
#if DEBUG
				Console.WriteLine(ex.Message);
#endif
				throw;
			}
			
			return;
		}

		/// <summary>
		/// Remove a specific page within the image object and save the result to an output image file.
		/// </summary>
		/// <param name="pageNumber">page number to be removed</param>
		/// <param name="compressEncoder">compress encoder after operation</param>
		/// <param name="strFileName">filename to be outputed</param>
		/// <returns></</returns>
		public void RemoveAPage(int pageNumber,EncoderValue compressEncoder,string strFileName){
			try
			{
				//Split the image files to single pages.
				ArrayList arrSplited=SplitTiffImage(this._TempWorkingDir,compressEncoder);
				
				//Remove the specific page from the collection
				string strPageRemove=string.Format("{0}\\{1}{2}.TIF",_TempWorkingDir,GetFileNameStartString(this._ImageFileName),pageNumber);
				arrSplited.Remove(strPageRemove);

				JoinTiffImages(arrSplited,strFileName,compressEncoder);
			}
			catch(Exception)
			{
				throw;
			}

			return;
		}

		/// <summary>
		/// Getting the supported codec info.
		/// </summary>
		/// <param name="mimeType">description of mime type</param>
		/// <returns>image codec info</returns>
		public ImageCodecInfo GetEncoderInfo(string mimeType){
			ImageCodecInfo[] encoders=ImageCodecInfo.GetImageEncoders();
			for (int j=0;j<encoders.Length;j++){
				if (encoders[j].MimeType==mimeType)
					return encoders[j];
			}
			
			throw new Exception( mimeType + " mime type not found in ImageCodecInfo" );
		}

		/// <summary>
		/// Return the memory steam of a specific page
		/// </summary>
		/// <param name="pageNumber">page number to be extracted</param>
		/// <returns>image object</returns>
		public Image GetSpecificPage(int pageNumber)
		{
			MemoryStream ms=null;
			Image retImage=null;
			try
			{
                ms=new MemoryStream();
				Guid objGuid=image.FrameDimensionsList[0];
				FrameDimension objDimension=new FrameDimension(objGuid);

				image.SelectActiveFrame(objDimension,pageNumber);
				image.Save(ms,ImageFormat.Bmp);
				
				retImage=Image.FromStream(ms);

				return retImage;
			}
			catch (Exception)
			{
				ms.Close();
				retImage.Dispose();
				throw;
			}
		}

		/// <summary>
		/// Convert the existing TIFF to a different codec format
		/// </summary>
		/// <param name="compressEncoder"></param>
		/// <returns></returns>
		public void ConvertTiffFormat(string strNewImageFileName,EncoderValue compressEncoder)
		{
			//Split the image files to single pages.
			ArrayList arrSplited=SplitTiffImage(this._TempWorkingDir,compressEncoder);
			JoinTiffImages(arrSplited,strNewImageFileName,compressEncoder);

			return;
		}

		/// <summary>
		/// Image file to operate
		/// </summary>
		public string ImageFileName
		{
			get
			{
				return _ImageFileName;
			}
			set{
				_ImageFileName=value;
			}
		}

		/// <summary>
		/// Buffering directory
		/// </summary>
		public string TempWorkingDir
		{
			get
			{
				return _TempWorkingDir;
			}
			set{
				_TempWorkingDir=value;
			}
		}

		/// <summary>
		/// Image page number
		/// </summary>
		public int PageNumber
		{
			get
			{
				return _PageNumber;
			}
		}

	
		#region IDisposable Members

		public void Dispose()
		{
			image.Dispose();
			System.GC.SuppressFinalize(this);
		}

		#endregion

        public void TiffTest()
        {
            //converting from tiff to base64
            string tiff = @"D:\Workings\BPM\BPM_RS\SHFL_DOCS\ADA\Co-Applicant\tif.tif";
            FileStream fstream = new FileStream(tiff, FileMode.Open);
            byte[] original = new byte[fstream.Length];
            fstream.Read(original, 0, (int)fstream.Length);
            int fstreamLength = (int)fstream.Length;

            string tiffBase64 = Convert.ToBase64String(original);
            StreamWriter writer = new StreamWriter(@"D:\Workings\BPM\BPM_RS\SHFL_DOCS\ADA\Co-Applicant\SampleBase64.txt");
            writer.Write(tiffBase64);
            writer.Close();
            fstream.Close();

            //converting back to tiff
            StreamReader reader = new StreamReader(@"D:\Workings\BPM\BPM_RS\SHFL_DOCS\ADA\Co-Applicant\SampleBase64.txt");
            byte[] base64Convert = new byte[fstreamLength];
            base64Convert = Convert.FromBase64String(reader.ReadToEnd());

            FileStream streamWriter = new FileStream(@"D:\Workings\BPM\BPM_RS\SHFL_DOCS\ADA\Co-Applicant\tif_new.tif", FileMode.Create);
            streamWriter.Write(base64Convert, 0, fstreamLength);
            streamWriter.Close();            
        }
        private ImageCodecInfo GetImageCoeInfo(string mimeType)
        {
            ImageCodecInfo[] codes = ImageCodecInfo.GetImageEncoders();
            for (int i = 0; i < codes.Length; i++)
            {
                if (codes[i].MimeType == mimeType)
                {
                    return codes[i];
                }
            }
            return null;
        }
	}
}

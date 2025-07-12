# RNG Capitalist v2.0 - AI-Powered Sunk Cost Tracker

## 🚀 Production Release

**Real AI-Powered Financial Document Analysis**

### 🎯 What's New in v2.0
- **Google Gemini AI Integration**: Real AI that understands document context
- **Enhanced Amount Detection**: Correctly parses complex amounts like $1,124.22
- **Intelligent Categorization**: AI categorizes expenses based on content understanding
- **Smart Description Generation**: Meaningful transaction names instead of generic "Payment"
- **Confidence Scoring**: AI provides confidence levels for each detection
- **Advanced OCR**: Supports PDFs, images, screenshots, and camera captures

### 🔧 System Requirements
- **OS**: Windows 10 (version 1903 or later) / Windows 11
- **Architecture**: x64 (64-bit)
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 500MB free space
- **Network**: Internet connection required for AI analysis
- **API Key**: Free Google Gemini API key (see setup below)

### 📦 Installation

#### Option 1: Standalone Executable
1. Download `RNG-Capitalist-v2.0-Windows-x64.zip`
2. Extract to your desired location
3. **Set up API key** (required for AI features):
   - Run `setup_api_key.bat` for guided setup
   - OR manually edit `.env` file with your Google Gemini API key
   - Get free API key: https://aistudio.google.com/app/apikey
4. Run `rng_capitalist.exe`
5. Allow Windows Defender/antivirus if prompted

#### Option 2: Microsoft Store (Coming Soon)
- Search "RNG Capitalist" in Microsoft Store
- Click Install
- App will auto-update

### 🔑 **API Key Setup (Required for AI Features)**

#### **Quick Setup:**
1. Run `setup_api_key.bat` in the app folder
2. Follow the guided setup process
3. Get your free API key from Google AI Studio
4. The script will configure everything automatically

#### **Manual Setup:**
1. Visit: https://aistudio.google.com/app/apikey
2. Create a free Google account if needed
3. Click "Create API Key"
4. Copy the generated key
5. Open `.env` file in the app folder
6. Replace `your_api_key_here` with your actual key
7. Save the file

#### **Verification:**
- Run the app and check console for "✅ Google Gemini AI initialized successfully"
- Try uploading a document to test AI features
- The setup is working if you see intelligent categorization and descriptions

**Note**: The API key is free and includes 1,500 requests per day - plenty for personal use!

### 🤖 AI Features

#### Google Gemini AI Analysis
- **Real AI Understanding**: Not just regex - actual AI reads and understands documents
- **Context Awareness**: AI understands what transactions are for
- **Multi-format Support**: PDFs, images, bank statements, receipts

#### Smart Detection
- **Complex Amounts**: Handles $1,124.22, 1,124.22, $1124.22 formats
- **Category Intelligence**: Education, Gaming Equipment, Entertainment, Shopping, etc.
- **Meaningful Names**: "UNC Tuition Payment" instead of "Transaction"

### 🎮 Gaming Focus
Perfect for D&D players and gamers:
- **Gaming Equipment**: Dice, rulebooks, miniatures
- **Entertainment**: Games, subscriptions, events
- **Smart Recognition**: AI understands gaming-related purchases

### 🏫 Educational Expenses
Ideal for students:
- **Tuition Tracking**: University payments, fees
- **Educational Materials**: Books, supplies, software
- **Automatic Recognition**: AI identifies educational expenses

### 🔒 Privacy & Security
- **Local Processing**: OCR happens on your device
- **Secure AI**: Only text sent to Google Gemini (no images)
- **No Data Storage**: AI provider doesn't store your data
- **Firebase Backend**: Secure cloud sync (optional)

### 📊 Features
- **AI Document Upload**: Camera, gallery, PDF, file browser
- **Smart Categorization**: 10+ intelligent categories
- **Amount Parsing**: Complex number format support
- **Confidence Scoring**: AI confidence levels
- **Deduplication**: Prevents duplicate entries
- **Cloud Sync**: Firebase integration
- **Modern UI**: Beautiful, responsive design

### 🛠️ Technical Details
- **Framework**: Flutter 3.x
- **AI Engine**: Google Gemini 1.5 Flash
- **OCR**: Google ML Kit Text Recognition
- **PDF Processing**: Syncfusion Flutter PDF
- **Backend**: Firebase Firestore
- **Platform**: Windows native

### 🐛 Troubleshooting

#### App Won't Start
- Ensure Windows is up to date
- Install Visual C++ Redistributable if needed
- Run as administrator if permission issues

#### AI Analysis Not Working
- Check internet connection
- Verify firewall isn't blocking the app
- Try again - AI services occasionally have brief outages

#### PDF Not Reading Correctly
- Ensure PDF contains selectable text (not just images)
- Try converting image-based PDFs to text-based
- Use camera capture for image-based documents

### 🔄 Updates
- **Auto-update**: Microsoft Store version updates automatically
- **Manual update**: Download latest release for standalone version
- **Release Notes**: Check GitHub releases for changelog

### 💡 Tips for Best Results
1. **High Quality Images**: Clear, well-lit photos work best
2. **Text-based PDFs**: Native text PDFs parse better than scanned images
3. **Context Matters**: Include surrounding text for better AI understanding
4. **Review Results**: Always verify AI-detected amounts and categories

### 🆘 Support
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Check README.md for detailed setup
- **AI Issues**: Verify API key configuration if self-building

### 📈 Performance
- **File Size**: ~50MB installed
- **Startup Time**: 2-3 seconds typical
- **AI Analysis**: 3-5 seconds per document
- **Memory Usage**: 100-200MB typical

### 🔮 Roadmap
- **Mobile Apps**: iOS/Android versions planned
- **More AI Providers**: OpenAI, Claude integration
- **Enhanced Categories**: Custom category creation
- **Batch Processing**: Multiple document upload
- **Receipt Templates**: Common receipt format recognition
- **Export Features**: PDF/Excel report generation

---

**Built with ❤️ using Flutter and powered by Google Gemini AI**

*Transform your financial tracking with the power of artificial intelligence!*

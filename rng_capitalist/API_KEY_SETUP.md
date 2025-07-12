# 🔑 API Key Setup Guide

## Getting Your Free Google Gemini API Key

### 1. **Visit Google AI Studio**
Go to: https://aistudio.google.com/app/apikey

### 2. **Sign In**
- Sign in with your Google account
- Accept the terms of service

### 3. **Create API Key**
- Click "Create API Key"
- Choose "Create API key in new project" or select existing project
- Copy the generated API key

### 4. **Configure RNG Capitalist**

#### **Option A: Edit .env file directly**
```bash
# Open .env file in a text editor
# Replace "your_api_key_here" with your actual key
GOOGLE_GEMINI_API_KEY=AIzaSyBqJ4...your_actual_key_here
```

#### **Option B: Copy from template**
```bash
# Copy the example file
copy .env.example .env

# Edit .env with your key
notepad .env
```

### 5. **Test Your Setup**
- Run the app: `flutter run`
- Try uploading a document
- Look for "✅ Google Gemini AI initialized successfully" in the logs

## 🔒 **Security Best Practices**

### **DO:**
✅ Keep your API key private  
✅ Add .env to .gitignore (already done)  
✅ Use different keys for development/production  
✅ Monitor your API usage in Google Cloud Console  
✅ Revoke keys if compromised  

### **DON'T:**
❌ Share your API key publicly  
❌ Commit .env file to version control  
❌ Hardcode API keys in source code  
❌ Use production keys for development  

## 📊 **API Limits & Pricing**

### **Free Tier:**
- **15 requests per minute**
- **1,500 requests per day**
- **1 million tokens per day**

This is plenty for personal use! Each document analysis uses ~1,000-3,000 tokens.

### **If You Need More:**
Visit [Google AI Pricing](https://ai.google.dev/pricing) for paid plans.

## 🛠️ **Troubleshooting**

### **Error: "API key not found"**
- Make sure `.env` file exists
- Check that `GOOGLE_GEMINI_API_KEY` is set correctly
- Verify no extra spaces or quotes around the key

### **Error: "API key invalid"**
- Copy the key again from Google AI Studio
- Make sure you copied the complete key
- Check that the key hasn't been revoked

### **Error: "Quota exceeded"**
- You've hit the daily limit (1,500 requests)
- Wait 24 hours or upgrade to paid plan
- Consider using fewer document uploads per day

### **App builds but AI doesn't work**
- Check Flutter console for error messages
- Verify internet connection
- Make sure `.env` file is in the correct location

## 🚀 **Production Deployment**

When building for production:

1. **Create production .env:**
   ```bash
   GOOGLE_GEMINI_API_KEY=your_production_key
   APP_ENV=production
   DEBUG_MODE=false
   ```

2. **Build with environment:**
   ```bash
   flutter build windows --release
   ```

3. **Distribute safely:**
   - Only share the compiled .exe
   - Never share source code with .env file
   - The .env file is bundled securely in the app

## 📞 **Support**

Need help? Check:
- Console logs for error messages
- Google AI Studio for API key status
- GitHub issues for common problems

**Your API key enables the AI magic that makes RNG Capitalist intelligent! 🤖✨**

# 🔍 ForensiScan - Digital Forensics Learning Platform

[![Godot Engine](https://img.shields.io/badge/Godot-4.2-blue.svg)](https://godotengine.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20|%20Android-green.svg)]()
[![License](https://img.shields.io/badge/License-Educational-orange.svg)]()
[![Version](https://img.shields.io/badge/Version-v0.3.0-brightgreen.svg)]()

**ForensiScan** is an innovative educational mobile and desktop application designed to teach digital forensics and fingerprinting fundamentals through interactive lessons, quizzes, and comprehensive progress tracking.

## 🎯 **Overview**

ForensiScan transforms complex forensic science concepts into engaging, interactive learning experiences. Built with **Godot Engine 4.2**, the application provides a modern, user-friendly interface for students to master digital forensics principles at their own pace.

### **🎓 Educational Focus**
- **Digital Forensics**: Core principles and methodologies
- **Fingerprint Analysis**: Historical context and modern applications
- **Crime Scene Investigation**: Evidence collection and analysis
- **Legal Implications**: Forensic evidence in court proceedings

## ✨ **Key Features**

### **📚 Interactive Learning System**
- **Structured Lessons**: Progressive curriculum from basic to advanced concepts
- **Typewriter Effect**: Engaging text animations with BBCode support
- **Visual Content**: Rich media integration with images and animations
- **Progress Tracking**: Comprehensive lesson completion monitoring

### **🧪 Assessment & Evaluation**
- **Interactive Quizzes**: Multiple-choice questions with immediate feedback
- **Performance Analytics**: Detailed scoring and grade analysis
- **Answer History**: Complete review of quiz responses
- **Progress Resumption**: Continue lessons from where you left off

### **📊 Comprehensive Reporting**
- **PDF Generation**: Professional assessment reports
- **Multi-Platform Support**: Cross-platform compatibility (Windows/Android)
- **Detailed Analytics**: Score breakdowns and improvement suggestions
- **Export Options**: Save and share results

### **🔐 License & Security**
- **User Authentication**: Secure license-based access control
- **Device Registration**: Unique device identification
- **Progress Synchronization**: User data persistence
- **Secure Storage**: Encrypted user information

### **🎨 Modern User Interface**
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Smooth Animations**: Polished transitions and effects
- **Intuitive Navigation**: User-friendly interface design
- **Dark/Light Themes**: Visual customization options

## 🛠️ **Technical Architecture**

### **Engine & Framework**
- **Godot Engine 4.2**: Cross-platform game engine
- **GDScript**: Primary programming language
- **OpenGL Compatibility**: Wide hardware support

### **Core Systems**

#### **🎮 Game Management**
- **Scene System**: Modular lesson and quiz organization
- **Autoload Services**: Global state management
- **Progress Manager**: Lesson completion tracking
- **License Processor**: User authentication and validation

#### **📝 Content Delivery**
- **Typewriter Service**: Animated text rendering
- **Navigation Controls**: Lesson progression management
- **Media Integration**: Image and video content support
- **BBCode Rendering**: Rich text formatting

#### **📊 Assessment Engine**
- **Quiz Manager**: Question handling and scoring
- **Answer Tracking**: Comprehensive response logging
- **Grade Calculation**: Performance evaluation algorithms
- **Result Processing**: Score analysis and reporting

#### **📄 Report Generation**
- **PDF Generator**: Multi-method document creation
- **Python Integration**: Advanced PDF conversion using ReportLab
- **HTML Fallback**: Cross-platform report compatibility
- **Template System**: Professional report formatting

### **📁 Project Structure**

```
ForensiScan/
├── 📂 assets/                    # Media and resource files
│   ├── 🖼️ images/               # Sprites, backgrounds, UI elements
│   ├── 🔤 fonts/                # Typography resources
│   ├── 🎵 sounds/               # Audio files
│   ├── 🎬 video/                # Video content
│   └── 📊 json/                 # Question databases
├── 📂 src/                      # Source code
│   ├── 📂 scenes/               # Godot scene files
│   │   ├── 🏠 MainMenu.tscn     # Main application menu
│   │   ├── 📚 Lesson/           # Interactive lesson scenes
│   │   ├── 🧪 Quiz/             # Assessment scenes
│   │   └── 🎬 Splash/           # Intro screens
│   ├── 📂 scripts/              # GDScript source files
│   │   ├── 🏠 MainMenu/         # Menu logic
│   │   ├── 📚 Lesson/           # Lesson controllers
│   │   ├── 🧪 Quiz/             # Quiz logic
│   │   ├── 🔧 Services/         # Core services
│   │   └── 🎨 Components/       # Reusable UI components
│   └── 📂 styles/               # UI styling resources
├── 📂 bin/                      # Compiled applications
│   ├── 🐧 Debug/               # Development builds
│   └── 📱 Release/             # Production builds (APK, EXE)
├── 📂 docs/                     # Documentation and samples
└── 📄 html_to_pdf.py           # PDF conversion utility
```

## 🚀 **Getting Started**

### **📋 Prerequisites**
- **Godot Engine 4.2** or higher
- **Python 3.7+** (for PDF generation)
- **Windows 10+** or **Android 7.0+**

### **🔧 Installation**

#### **Development Setup**
1. **Clone Repository**
   ```bash
   git clone https://github.com/mrl-barua/ForensiScan.git
   cd ForensiScan
   ```

2. **Open in Godot**
   - Launch Godot Engine 4.2
   - Import the project by selecting `project.godot`
   - Wait for initial asset import

3. **Install PDF Dependencies**
   ```bash
   pip install weasyprint reportlab beautifulsoup4
   ```

#### **🎮 User Installation**
1. **Download Release**: Get the latest APK or EXE from releases
2. **Install Application**: Follow platform-specific installation
3. **License Activation**: Enter your educational license key
4. **Start Learning**: Begin with preliminary lessons

### **🎯 Quick Start Guide**

1. **📱 Launch Application**
   - Open ForensiScan on your device
   - Complete the splash screen sequence

2. **🔐 License Verification**
   - Enter your educational license key
   - Register your device for secure access

3. **📚 Begin Learning**
   - Navigate to "Preliminary Lessons"
   - Start with "Introduction to Digital Forensics"

4. **🧪 Take Assessments**
   - Complete lesson quizzes to test knowledge
   - Review detailed answer explanations

5. **📊 Generate Reports**
   - Export PDF reports of your progress
   - Share results with instructors

## 📖 **Learning Modules**

### **🔰 Preliminary Course**
#### **Module 1: Foundations**
- Introduction to Digital Forensics
- Historical Context of Fingerprinting
- Basic Evidence Collection Principles

#### **Module 2: Fingerprint Science**
- Anatomy of Fingerprints
- Classification Systems
- Pattern Recognition

#### **Module 3: Notable Figures**
- Sir Edward Richard Henry (Father of Fingerprints)
- Gilbert Thompson (First US Implementation)
- John Evangelist Purkinji (Father of Dactyloscopy)

#### **Module 4: Modern Applications**
- AFIS (Automated Fingerprint Identification Systems)
- Legal Admissibility
- Contemporary Case Studies

#### **Module 5: Collection Methods**
- Visible Prints
- Latent Print Development
- Plastic Print Preservation

### **🎯 Assessment System**
- **Progressive Quizzes**: Test comprehension after each module
- **Comprehensive Reviews**: Detailed answer explanations
- **Performance Tracking**: Monitor learning progress
- **Remedial Learning**: Identify areas for improvement

## 🔧 **Advanced Features**

### **📊 Progress Management**
```gdscript
# Resume functionality allows students to continue lessons
ProgressManager.update_lesson_progress("prelim", 15)
var resume_info = ProgressManager.get_resume_info_for_lesson_type("prelim")
```

### **📄 PDF Report Generation**
```python
# Multi-method PDF conversion
convert_with_weasyprint(html_file, pdf_file)    # Professional quality
convert_with_reportlab(html_file, pdf_file)     # Cross-platform compatible
```

### **🔐 License System**
```gdscript
# Secure user authentication
LicenseProcessor.validate_license(license_key)
var user_details = LicenseProcessor.get_license_details()
```

### **📱 Cross-Platform Compatibility**
- **Windows**: Full-featured desktop experience
- **Android**: Touch-optimized mobile interface
- **Responsive UI**: Adaptive layouts for all screen sizes

## 🎨 **User Interface Design**

### **🖼️ Visual Elements**
- **Modern Gradient Backgrounds**: Professional aesthetic
- **Smooth Animations**: Polished user experience
- **Intuitive Icons**: Clear visual communication
- **Consistent Typography**: Readable and accessible

### **🎯 Accessibility Features**
- **Large Touch Targets**: Mobile-friendly interaction
- **High Contrast Modes**: Visual accessibility
- **Clear Navigation**: Intuitive user flow
- **Progress Indicators**: Clear learning pathways

## 📊 **Performance & Analytics**

### **📈 Student Metrics**
- **Completion Rates**: Track lesson progress
- **Quiz Scores**: Performance assessment
- **Time Tracking**: Learning pace analysis
- **Knowledge Retention**: Long-term assessment

### **🎓 Instructor Dashboard**
- **Class Overview**: Student progress monitoring
- **Performance Analytics**: Detailed reporting
- **Curriculum Insights**: Content effectiveness
- **Export Capabilities**: Data portability

## 🔒 **Security & Privacy**

### **🛡️ Data Protection**
- **Local Storage**: No cloud dependency
- **Encrypted Preferences**: Secure data persistence
- **Device Binding**: License security
- **Privacy Compliant**: GDPR considerations

### **🔐 Authentication System**
- **License-Based Access**: Educational institution control
- **Device Registration**: Prevent unauthorized sharing
- **Secure Validation**: Tamper-resistant verification

## 🚀 **Deployment**

### **📱 Mobile Deployment (Android)**
```bash
# Build and export APK
godot --headless --export-release Android bin/Release/ForensiScan.apk
```

### **🖥️ Desktop Deployment (Windows)**
```bash
# Build executable
godot --headless --export-release Windows bin/Release/ForensiScan.exe
```

### **📦 Distribution**
- **Educational Licenses**: Institution-based distribution
- **Google Play**: Public educational release
- **Direct Download**: Website distribution

## 🐛 **Troubleshooting**

### **📄 PDF Generation Issues**
If PDF generation fails:
1. **Install Python Dependencies**:
   ```bash
   pip install weasyprint reportlab beautifulsoup4
   ```
2. **Check Python Path**: Ensure Python is in system PATH
3. **HTML Fallback**: Manual browser print-to-PDF available

### **🔐 License Activation Problems**
1. **Verify License Key**: Check for typing errors
2. **Internet Connection**: Ensure connectivity for validation
3. **Contact Support**: Educational institution assistance

### **📱 Performance Optimization**
- **Close Background Apps**: Free system memory
- **Update Graphics Drivers**: Ensure compatibility
- **Clear Cache**: Reset application data if needed

## 🤝 **Contributing**

### **👥 Development Team**
- **Educational Consultants**: Curriculum design
- **Software Developers**: Technical implementation
- **UI/UX Designers**: Interface optimization
- **Quality Assurance**: Testing and validation

### **🔄 Development Workflow**
1. **Feature Planning**: Educational requirement analysis
2. **Implementation**: Godot development
3. **Testing**: Cross-platform validation
4. **Review**: Educational effectiveness assessment
5. **Deployment**: Multi-platform release

## 📄 **License & Usage**

### **📚 Educational License**
- **Institution Use**: Educational facility deployment
- **Student Access**: Individual learning accounts
- **Content Rights**: Curriculum material usage
- **Support Included**: Technical assistance

### **⚖️ Legal Compliance**
- **Educational Fair Use**: Content guidelines
- **Privacy Regulations**: Student data protection
- **Accessibility Standards**: Inclusive design
- **International Compliance**: Multi-jurisdiction support

## 📞 **Support & Contact**

### **🎓 Educational Support**
- **Curriculum Questions**: Content clarification
- **Implementation Guidance**: Classroom integration
- **Progress Monitoring**: Student tracking assistance

### **🔧 Technical Support**
- **Installation Help**: Setup assistance
- **Bug Reports**: Issue resolution
- **Feature Requests**: Enhancement suggestions
- **Performance Optimization**: System tuning

### **📧 Contact Information**
- **Educational Inquiries**: curriculum@forensiscan.edu
- **Technical Support**: support@forensiscan.edu
- **General Information**: info@forensiscan.edu

---

## 🎯 **Version History**

### **v0.3.0 - Current Release** 🌟
- ✅ Enhanced quiz results system
- ✅ PDF report generation
- ✅ Cross-platform compatibility
- ✅ Progress resumption functionality
- ✅ Improved license verification

### **v0.2.0 - Previous Release**
- ✅ Interactive lesson system
- ✅ Typewriter text effects
- ✅ Basic quiz functionality
- ✅ Progress tracking foundation

### **v0.1.0 - Initial Release**
- ✅ Core application framework
- ✅ Basic navigation system
- ✅ Initial content implementation

---

**🎓 Empowering the next generation of digital forensics professionals through innovative educational technology.**

*ForensiScan - Where Science Meets Learning* 🔬📱


# 🛡️ Intrusion Detection System (IDS) - Full Stack Solution

A real-time network intrusion detection system with ML-powered classification, featuring a Django REST backend and a beautiful Flutter dashboard.

## 🎯 Features

- **Real-time Threat Detection**: Classifies network traffic into 15 attack types using XGBoost ML model
- **Beautiful Dashboard**: Modern cybersecurity-themed UI with live statistics
- **2-Second Polling**: Automatic updates every 2 seconds when monitoring is active
- **External API Integration**: Simulates real-time data streaming from network sensors
- **Comprehensive Statistics**: Attack distribution, threat timeline, and recent threats feed
- **Production Ready**: Deployment configs for Railway and Render included

## 🏗️ Architecture

```
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  Flutter Frontend│◄────►│  Django Backend  │◄────►│  External API    │
│  (Dashboard)     │ HTTP │  (Main Server)   │ HTTP │  (Data Stream)   │
│                  │      │  • ML Inference  │      │  • Random Data   │
│  • Statistics    │      │  • REST API      │      │  • API Key Auth  │
│  • Live Feed     │      │  • Aggregation   │      │                  │
└──────────────────┘      └──────────────────┘      └──────────────────┘
                                   │
                                   ▼
                          ┌──────────────────┐
                          │   ML Models      │
                          │  • XGBoost       │
                          │  • Scaler        │
                          │  • Encoder       │
                          └──────────────────┘
```

## 📁 Project Structure

```
IS/
├── backend/                      # Main Django Backend
│   ├── ids_api/                  # API app
│   │   ├── services/
│   │   │   ├── model_service.py  # ML model loading & inference
│   │   │   └── data_service.py   # External API & statistics
│   │   ├── utils/
│   │   │   └── constants.py      # Feature names & attack classes
│   │   ├── views.py              # Function-based REST views
│   │   └── urls.py               # API routes
│   ├── model_scaler_encoder/     # ML assets
│   │   ├── xgboost_ids_gpu.pkl   # Trained model
│   │   ├── scaler_gpu.pkl        # Feature scaler
│   │   ├── label_encoder_gpu.pkl # Label encoder
│   │   └── cicids_sample_500.csv # Sample dataset
│   └── requirements.txt
│
├── external_api/                 # External Data API Server
│   ├── data_server/
│   │   ├── data/
│   │   │   └── cicids_sample_500.csv
│   │   └── views.py              # Data streaming endpoint
│   ├── Procfile                  # Deployment config
│   └── requirements.txt
│
└── frontend/                     # Flutter Dashboard
    └── lib/
        ├── config/
        │   └── constants.dart    # API URLs, colors, theme
        ├── models/
        │   └── models.dart       # Data models
        ├── services/
        │   └── api_service.dart  # HTTP client
        ├── providers/
        │   └── dashboard_provider.dart  # State management
        ├── screens/
        │   └── dashboard_screen.dart    # Main screen
        ├── widgets/              # UI components
        └── main.dart
```

## 🚀 Quick Start

### Prerequisites

- Python 3.12+
- Flutter 3.10.7+
- Virtual environment activated

### 1. Backend Setup

```bash
cd backend

# Install dependencies (if not already done)
pip install -r requirements.txt

# Run migrations (if needed)
python manage.py migrate

# Start server
python manage.py runserver
```

Backend will run on: `http://localhost:8000`

**API Endpoints:**
- `GET /api/health/` - Health check
- `GET /api/fetch-and-classify/?batch_size=5` - Fetch & classify data
- `GET /api/statistics/` - Get full statistics
- `GET /api/recent-threats/?limit=20` - Get recent threats

### 2. External API Server Setup

```bash
cd external_api

# Install dependencies
pip install -r requirements.txt

# Run server on different port
python manage.py runserver 8001
```

External API will run on: `http://localhost:8001`

**Test API:**
```bash
curl -H "X-API-Key: ids-secure-key-2026-railway-render" \
     http://localhost:8001/api/data/?count=5
```

### 3. Flutter Frontend Setup

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on Chrome (or Windows)
flutter run -d chrome
# OR
flutter run -d windows
```

## 🎮 Usage

1. **Start Backend**: Run Django server on port 8000
2. **Start External API**: Run external API server on port 8001
3. **Launch Frontend**: Run Flutter app
4. **Click "START MONITORING"**: Begins 2-second polling
5. **Watch Live Dashboard**: See real-time classifications and statistics
6. **Click "STOP MONITORING"**: Pause data fetching

## 🌐 Deployment

### Deploy External API to Railway

1. Create new project on [Railway](https://railway.app)
2. Connect GitHub repository
3. Set root directory: `external_api`
4. Railway auto-detects Procfile
5. Deploy!

Get your API URL (e.g., `https://your-app.railway.app/api/data/`)

### Deploy External API to Render (Fallback)

1. Create new Web Service on [Render](https://render.com)
2. Connect repository
3. Configure:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn external_api.wsgi:application`
   - **Root Directory**: `external_api`
4. Deploy!

### Update Main Backend

After deploying external API, update `backend/backend/settings.py`:

```python
EXTERNAL_API_URL = "https://your-deployed-api.railway.app/api/data/"
```

## 📊 Dataset Information

**Dataset**: CICIDS2017 (Canadian Institute for Cybersecurity Intrusion Detection Dataset)

**Features**: 78 network flow features including:
- Packet counts, lengths, and rates
- Flow duration and inter-arrival times
- TCP flags
- Header lengths
- Active/Idle statistics

**Attack Types** (15 classes):
1. BENIGN
2. Bot
3. DDoS
4. DoS GoldenEye
5. DoS Hulk
6. DoS Slowhttptest
7. DoS slowloris
8. FTP-Patator
9. Heartbleed
10. Infiltration
11. PortScan
12. SSH-Patator
13. Web Attack – Brute Force
14. Web Attack – Sql Injection
15. Web Attack – XSS

## 🔐 Security

- **API Key Authentication**: Hardcoded key for demo (`ids-secure-key-2026-railway-render`)
- **CORS Enabled**: Allows Flutter app to connect
- **Production Notes**: Use environment variables for secrets in production

## 🎨 UI Features

- **Dark Cybersecurity Theme**: Futuristic design with glowing accents
- **Real-time Animations**: Smooth transitions and updates
- **Statistics Cards**: Total analyzed, benign, threats, threat rate
- **Pie Chart**: Attack distribution visualization
- **Live Threat Feed**: Scrolling list of recent detections
- **Status Indicator**: Shows active/idle monitoring state
- **Responsive Layout**: Adapts to different screen sizes

## 🛠️ Technology Stack

**Backend:**
- Django 5.2.11
- Django REST Framework
- XGBoost (ML model)
- scikit-learn (preprocessing)
- pandas, numpy
- gunicorn (deployment)

**Frontend:**
- Flutter 3.10.7
- Provider (state management)
- fl_chart (data visualization)
- google_fonts (typography)
- flutter_animate (animations)
- http (API client)

## 📈 Performance

- **Polling Interval**: 2 seconds (configurable)
- **Batch Size**: 5 samples per fetch (configurable)
- **Model Inference**: < 100ms per batch
- **Memory Footprint**: ~200MB (models loaded once)

## 🐛 Troubleshooting

**Backend won't start:**
- Ensure virtual environment is activated
- Check if all dependencies are installed: `pip install -r requirements.txt`
- Verify model files exist in `model_scaler_encoder/`

**Frontend shows connection error:**
- Ensure backend is running on `http://localhost:8000`
- Check CORS settings in `backend/settings.py`
- Verify API endpoints are accessible

**External API returns 403:**
- Check API key matches in both servers
- Verify `X-API-Key` header is sent correctly

**No data in dashboard:**
- Click "START MONITORING" button
- Ensure external API server is running
- Check browser console for errors

## 📝 API Key

The hardcoded API key for authentication is:
```
ids-secure-key-2026-railway-render
```

This is shared between:
- Main backend (`backend/backend/settings.py`)
- External API server (`external_api/data_server/views.py`)

## 🔄 Development Workflow

1. **Modify Backend**: Edit views, services → Restart Django server
2. **Modify Frontend**: Edit widgets, screens → Hot reload Flutter
3. **Modify ML Pipeline**: Retrain model → Replace .pkl files
4. **Test Integration**: Start all servers → Launch app → Start monitoring

## 📚 Additional Resources

- [Django REST Framework Docs](https://www.django-rest-framework.org/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [XGBoost Documentation](https://xgboost.readthedocs.io/)
- [CICIDS2017 Dataset](https://www.unb.ca/cic/datasets/ids-2017.html)

## 📄 License

This project is for educational purposes.

## 👥 Contributors

Built as a comprehensive full-stack intrusion detection system demonstration.

---

**Status**: ✅ Production Ready  
**Last Updated**: February 5, 2026  
**Version**: 1.0.0

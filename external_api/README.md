# External API Server - Deployment Guide

## Deployment on Railway

1. Create a new project on [Railway](https://railway.app)
2. Connect your GitHub repository or deploy via CLI
3. Set the root directory to `external_api`
4. Railway will automatically detect the Procfile
5. Set environment variable: `DJANGO_SETTINGS_MODULE=external_api.settings`
6. Deploy!

Your API URL will be something like: `https://your-app.railway.app/api/data/`

## Deployment on Render

1. Create a new Web Service on [Render](https://render.com)
2. Connect your repository
3. Set:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn external_api.wsgi:application`
   - **Root Directory**: `external_api`
4. Add environment variable: `PYTHON_VERSION=3.12.0`
5. Deploy!

Your API URL will be: `https://your-service.onrender.com/api/data/`

## Testing Locally

```bash
cd external_api
pip install -r requirements.txt
python manage.py runserver 8001
```

Test endpoint:
```bash
curl -H "X-API-Key: ids-secure-key-2026-railway-render" http://localhost:8001/api/data/?count=5
```

## After Deployment

Update the main backend's `settings.py`:
```python
EXTERNAL_API_URL = "https://your-deployed-api.railway.app/api/data/"
```

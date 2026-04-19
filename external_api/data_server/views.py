"""
Data server views - Streams random samples from CICIDS2017 dataset
"""
import random
import pandas as pd
from datetime import datetime
from pathlib import Path
from rest_framework.decorators import api_view
from rest_framework.response import Response

# Hardcoded API Key for authentication
VALID_API_KEY = "ids-secure-key-2026-railway-render"

# Load sample data at startup
DATA_PATH = Path(__file__).parent / 'data' / 'cicids_sample_500.csv'
try:
    SAMPLE_DATA = pd.read_csv(DATA_PATH)
    # Clean column names
    SAMPLE_DATA.columns = SAMPLE_DATA.columns.str.strip()
    # Get feature columns (all except Label)
    FEATURE_COLUMNS = [col for col in SAMPLE_DATA.columns if col != 'Label']
    print(f"✓ Loaded {len(SAMPLE_DATA)} samples with {len(FEATURE_COLUMNS)} features")
except Exception as e:
    print(f"✗ Error loading sample data: {e}")
    SAMPLE_DATA = None
    FEATURE_COLUMNS = []


def generate_fake_ip():
    """Generate a random IP address"""
    return f"{random.randint(1,255)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"


@api_view(['GET'])
def get_random_samples(request):
    """
    Return random samples from the CICIDS2017 dataset
    
    Headers:
        X-API-Key: Authentication key
        
    Query params:
        count: Number of samples to return (default: 5, max: 50)
    """
    # Validate API Key
    api_key = request.headers.get('X-API-Key', '')
    if api_key != VALID_API_KEY:
        return Response({
            'error': 'Invalid or missing API key',
            'message': 'Please provide a valid X-API-Key header'
        }, status=403)
    
    # Check if data is loaded
    if SAMPLE_DATA is None or SAMPLE_DATA.empty:
        return Response({
            'error': 'Sample data not available'
        }, status=503)
    
    # Get count parameter
    try:
        count = int(request.query_params.get('count', 5))
        count = max(1, min(count, 50))  # Limit between 1-50
    except ValueError:
        count = 5
    
    # Sample random rows (with replacement for infinite sampling)
    if len(SAMPLE_DATA) < count:
        samples = SAMPLE_DATA
    else:
        samples = SAMPLE_DATA.sample(n=count, replace=True)
    
    # Build response
    results = []
    for _, row in samples.iterrows():
        results.append({
            'timestamp': datetime.now().isoformat(),
            'source_ip': generate_fake_ip(),
            'destination_port': int(row['Destination Port']) if 'Destination Port' in row else 80,
            'features': [float(row[col]) for col in FEATURE_COLUMNS],
            'actual_label': str(row['Label']) if 'Label' in row else 'Unknown'
        })
    
    return Response({
        'success': True,
        'count': len(results),
        'samples': results,
        'timestamp': datetime.now().isoformat()
    })


@api_view(['GET'])
def health_check(request):
    """Health check endpoint"""
    return Response({
        'status': 'healthy',
        'data_loaded': SAMPLE_DATA is not None,
        'sample_count': len(SAMPLE_DATA) if SAMPLE_DATA is not None else 0,
        'feature_count': len(FEATURE_COLUMNS)
    })

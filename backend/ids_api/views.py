"""
Function-based views for IDS API
"""
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .services.model_service import ModelService
from .services.data_service import data_service
from .utils.constants import FEATURE_NAMES


# Initialize model service (singleton)
model_service = ModelService()


@api_view(['GET'])
def health_check(request):
    """Health check endpoint"""
    return Response({
        'status': 'healthy',
        'model_loaded': model_service.is_loaded(),
        'total_analyzed': data_service.total_analyzed
    })


@api_view(['GET'])
def get_statistics(request):
    """Get aggregated statistics from classified data"""
    stats = data_service.get_statistics()
    return Response(stats)


@api_view(['POST'])
def predict(request):
    """
    Classify a single network flow
    Expected input: {"features": [78 floats]}
    """
    features = request.data.get('features', [])
    
    if len(features) != 78:
        return Response(
            {'error': f'Expected 78 features, got {len(features)}'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        prediction = model_service.predict(features)
        return Response(prediction)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
def fetch_and_classify(request):
    """
    Fetch random data from external API and classify it
    Query params: batch_size (default: 5)
    """
    batch_size = int(request.query_params.get('batch_size', 5))
    batch_size = min(max(batch_size, 1), 50)  # Limit between 1-50
    
    try:
        # Fetch from external API
        print(f"Fetching {batch_size} samples from external API...")
        raw_data = data_service.fetch_from_external_api(batch_size)
        
        if not raw_data:
            return Response(
                {'error': 'No data received from external API'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        
        print(f"Received {len(raw_data)} samples, starting classification...")
        
        # Classify each sample
        results = []
        for i, sample in enumerate(raw_data):
            try:
                print(f"Classifying sample {i+1}/{len(raw_data)}...")
                prediction = model_service.predict(sample['features'])
                
                results.append({
                    'timestamp': sample['timestamp'],
                    'source_ip': sample['source_ip'],
                    'destination_port': sample['destination_port'],
                    'prediction': prediction['class'],
                    'confidence': prediction['confidence'],
                    'is_threat': prediction['class'] != 'BENIGN',
                    'security_impact': prediction['security_impact'],
                    'top_predictions': prediction['top_predictions']
                })
            except Exception as sample_error:
                print(f"Error classifying sample {i+1}: {sample_error}")
                import traceback
                traceback.print_exc()
                raise
        
        # Update statistics
        data_service.update_statistics(results)
        
        return Response({
            'success': True,
            'count': len(results),
            'results': results,
            'summary': data_service.get_quick_summary()
        })
        
    except Exception as e:
        print(f"Fetch and classify error: {e}")
        import traceback
        traceback.print_exc()
        return Response(
            {'error': f'Failed to fetch and classify: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
def get_attack_classes(request):
    """Get all possible attack classifications"""
    classes = model_service.get_classes()
    return Response({
        'classes': classes,
        'total': len(classes)
    })


@api_view(['GET'])
def get_recent_threats(request):
    """Get most recent detected threats"""
    limit = int(request.query_params.get('limit', 20))
    limit = min(max(limit, 1), 100)  # Limit between 1-100
    
    threats = data_service.get_recent_threats(limit)
    return Response({
        'threats': threats,
        'count': len(threats)
    })


@api_view(['POST'])
def reset_statistics(request):
    """Reset all statistics (for testing)"""
    data_service.reset_statistics()
    return Response({
        'success': True,
        'message': 'Statistics reset successfully'
    })


@api_view(['GET'])
def get_feature_names(request):
    """Get the list of feature names"""
    return Response({
        'features': FEATURE_NAMES,
        'count': len(FEATURE_NAMES)
    })

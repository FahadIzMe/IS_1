"""
Model Service - Singleton for loading and using ML models
"""
import joblib
import numpy as np
import pandas as pd
from pathlib import Path
from django.conf import settings
from ..utils.constants import FEATURE_NAMES, get_security_impact


class ModelService:
    """Singleton service for ML model inference"""
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialize()
        return cls._instance
    
    def _initialize(self):
        """Load ML model, scaler, and encoder"""
        self._loaded = False
        try:
            model_dir = Path(settings.BASE_DIR) / 'model_scaler_encoder'
            
            print(f"Loading models from: {model_dir}")
            self.model = joblib.load(model_dir / 'xgboost_ids_gpu.pkl')
            self.scaler = joblib.load(model_dir / 'scaler_gpu.pkl')
            self.encoder = joblib.load(model_dir / 'label_encoder_gpu.pkl')
            
            self._loaded = True
            print("✓ Models loaded successfully")
            print(f"✓ Model classes: {list(self.encoder.classes_)}")
        except Exception as e:
            print(f"✗ Error loading models: {e}")
            self._loaded = False
    
    def is_loaded(self):
        """Check if models are loaded"""
        return self._loaded
    
    def predict(self, features):
        """
        Make prediction on input features
        
        Args:
            features: List or array of 78 features
            
        Returns:
            dict with prediction, confidence, and probabilities
        """
        if not self._loaded:
            raise Exception("Models not loaded")
        
        # Convert to pandas DataFrame with feature names (fixes sklearn warning)
        features_df = pd.DataFrame([features], columns=FEATURE_NAMES)
        
        # Scale features
        scaled_features = self.scaler.transform(features_df)
        
        # Predict
        prediction = self.model.predict(scaled_features)
        probabilities = self.model.predict_proba(scaled_features)[0]
        
        # Decode prediction
        predicted_class = self.encoder.inverse_transform(prediction)[0]
        confidence = float(max(probabilities))
        
        # Get security impact (CIA+A)
        security_impact = get_security_impact(predicted_class)
        
        # Get top 3 predictions
        top_indices = np.argsort(probabilities)[-3:][::-1]
        top_predictions = [
            {
                'class': self.encoder.inverse_transform([idx])[0],
                'confidence': float(probabilities[idx])
            }
            for idx in top_indices
        ]
        
        return {
            'class': predicted_class,
            'confidence': round(confidence, 4),
            'security_impact': security_impact,
            'top_predictions': top_predictions,
            'all_probabilities': {
                cls: round(float(prob), 4) 
                for cls, prob in zip(self.encoder.classes_, probabilities)
            }
        }
    
    def get_classes(self):
        """Get all attack classes"""
        if not self._loaded:
            return []
        return list(self.encoder.classes_)

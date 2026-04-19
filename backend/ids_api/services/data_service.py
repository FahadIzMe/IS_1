"""
Data Service - Handles external API communication and statistics
"""
import requests
from datetime import datetime
from collections import defaultdict
from django.conf import settings


class DataService:
    """Service for managing statistics and external API communication"""
    
    def __init__(self):
        self.statistics = defaultdict(int)
        self.recent_threats = []
        self.total_analyzed = 0
        self.timeline_data = []  # For timeline visualization
    
    def fetch_from_external_api(self, batch_size=5):
        """
        Fetch random samples from external API
        
        Args:
            batch_size: Number of samples to fetch
            
        Returns:
            list of samples with features
        """
        try:
            external_api_url = getattr(settings, 'EXTERNAL_API_URL', None)
            external_api_key = getattr(settings, 'EXTERNAL_API_KEY', None)
            
            if not external_api_url:
                raise Exception("EXTERNAL_API_URL not configured")
            
            headers = {'X-API-Key': external_api_key}
            params = {'count': min(batch_size, 50)}
            
            response = requests.get(
                external_api_url,
                headers=headers,
                params=params,
                timeout=15
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get('samples', [])
            else:
                raise Exception(f"External API returned {response.status_code}")
                
        except Exception as e:
            print(f"Error fetching from external API: {e}")
            raise
    
    def update_statistics(self, results):
        """
        Update running statistics with new results
        
        Args:
            results: List of prediction results
        """
        timestamp = datetime.now().isoformat()
        threat_count_batch = 0
        
        for result in results:
            prediction_class = result['prediction']
            self.statistics[prediction_class] += 1
            self.total_analyzed += 1
            
            # Track threats
            if result['is_threat']:
                threat_count_batch += 1
                self.recent_threats.insert(0, {
                    'type': result['prediction'],
                    'timestamp': result['timestamp'],
                    'confidence': result['confidence'],
                    'source_ip': result.get('source_ip', 'N/A'),
                    'destination_port': result.get('destination_port', 0),
                    'security_impact': result.get('security_impact', {})
                })
        
        # Keep only last 100 threats
        self.recent_threats = self.recent_threats[:100]
        
        # Add to timeline
        self.timeline_data.append({
            'timestamp': timestamp,
            'threat_count': threat_count_batch,
            'benign_count': len(results) - threat_count_batch
        })
        
        # Keep last 50 timeline points
        self.timeline_data = self.timeline_data[-50:]
    
    def get_statistics(self):
        """Get comprehensive statistics"""
        total = sum(self.statistics.values()) or 1
        
        # Calculate threat vs benign
        benign_count = self.statistics.get('BENIGN', 0)
        threat_count = sum(
            count for attack_type, count in self.statistics.items() 
            if attack_type != 'BENIGN'
        )
        
        # Get top attacks
        sorted_attacks = sorted(
            [(k, v) for k, v in self.statistics.items() if k != 'BENIGN'],
            key=lambda x: x[1],
            reverse=True
        )
        
        return {
            'total_analyzed': self.total_analyzed,
            'benign_count': benign_count,
            'threat_count': threat_count,
            'threat_percentage': round((threat_count / total) * 100, 2),
            'by_class': dict(self.statistics),
            'percentages': {
                k: round((v / total) * 100, 2) 
                for k, v in self.statistics.items()
            },
            'top_attacks': [
                {'type': attack, 'count': count} 
                for attack, count in sorted_attacks[:5]
            ],
            'timeline': self.timeline_data
        }
    
    def get_quick_summary(self):
        """Get quick summary for response"""
        threat_count = sum(
            count for attack_type, count in self.statistics.items() 
            if attack_type != 'BENIGN'
        )
        return {
            'total': self.total_analyzed,
            'threats': threat_count,
            'benign': self.statistics.get('BENIGN', 0)
        }
    
    def get_recent_threats(self, limit=20):
        """Get most recent threats"""
        return self.recent_threats[:limit]
    
    def reset_statistics(self):
        """Reset all statistics"""
        self.statistics.clear()
        self.recent_threats.clear()
        self.total_analyzed = 0
        self.timeline_data.clear()


# Global instance
data_service = DataService()

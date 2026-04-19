"""
Feature names and attack classes for CICIDS2017 dataset
"""

# 78 feature names (all columns except Label - must match exact spacing from training)
FEATURE_NAMES = [
    ' Destination Port',
    ' Flow Duration',
    ' Total Fwd Packets',
    ' Total Backward Packets',
    'Total Length of Fwd Packets',
    ' Total Length of Bwd Packets',
    ' Fwd Packet Length Max',
    ' Fwd Packet Length Min',
    ' Fwd Packet Length Mean',
    ' Fwd Packet Length Std',
    'Bwd Packet Length Max',
    ' Bwd Packet Length Min',
    ' Bwd Packet Length Mean',
    ' Bwd Packet Length Std',
    'Flow Bytes/s',
    ' Flow Packets/s',
    ' Flow IAT Mean',
    ' Flow IAT Std',
    ' Flow IAT Max',
    ' Flow IAT Min',
    'Fwd IAT Total',
    ' Fwd IAT Mean',
    ' Fwd IAT Std',
    ' Fwd IAT Max',
    ' Fwd IAT Min',
    'Bwd IAT Total',
    ' Bwd IAT Mean',
    ' Bwd IAT Std',
    ' Bwd IAT Max',
    ' Bwd IAT Min',
    'Fwd PSH Flags',
    ' Bwd PSH Flags',
    ' Fwd URG Flags',
    ' Bwd URG Flags',
    ' Fwd Header Length',
    ' Bwd Header Length',
    'Fwd Packets/s',
    ' Bwd Packets/s',
    ' Min Packet Length',
    ' Max Packet Length',
    ' Packet Length Mean',
    ' Packet Length Std',
    ' Packet Length Variance',
    'FIN Flag Count',
    ' SYN Flag Count',
    ' RST Flag Count',
    ' PSH Flag Count',
    ' ACK Flag Count',
    ' URG Flag Count',
    ' CWE Flag Count',
    ' ECE Flag Count',
    ' Down/Up Ratio',
    ' Average Packet Size',
    ' Avg Fwd Segment Size',
    ' Avg Bwd Segment Size',
    ' Fwd Header Length.1',
    'Fwd Avg Bytes/Bulk',
    ' Fwd Avg Packets/Bulk',
    ' Fwd Avg Bulk Rate',
    ' Bwd Avg Bytes/Bulk',
    ' Bwd Avg Packets/Bulk',
    'Bwd Avg Bulk Rate',
    'Subflow Fwd Packets',
    ' Subflow Fwd Bytes',
    ' Subflow Bwd Packets',
    ' Subflow Bwd Bytes',
    'Init_Win_bytes_forward',
    ' Init_Win_bytes_backward',
    ' act_data_pkt_fwd',
    ' min_seg_size_forward',
    'Active Mean',
    ' Active Std',
    ' Active Max',
    ' Active Min',
    'Idle Mean',
    ' Idle Std',
    ' Idle Max',
    ' Idle Min',
]

# 15 attack classes
ATTACK_CLASSES = [
    'BENIGN',
    'Bot',
    'DDoS',
    'DoS GoldenEye',
    'DoS Hulk',
    'DoS Slowhttptest',
    'DoS slowloris',
    'FTP-Patator',
    'Heartbleed',
    'Infiltration',
    'PortScan',
    'SSH-Patator',
    'Web Attack – Brute Force',
    'Web Attack – Sql Injection',
    'Web Attack – XSS'
]

# External API configuration
EXTERNAL_API_KEY = "ids-secure-key-2026-railway-render"


def get_security_impact(attack_type):
    """
    Get security impact (CIA+A) for each attack type
    C = Confidentiality, I = Integrity, A = Availability, Au = Authenticity
    """
    impact_map = {
        'BENIGN': {
            'confidentiality': False,
            'integrity': False,
            'availability': False,
            'authenticity': False,
            'description': 'Normal traffic'
        },
        'DDoS': {
            'confidentiality': False,
            'integrity': False,
            'availability': True,
            'authenticity': False,
            'description': 'Overwhelms system resources, prevents legitimate access'
        },
        'DoS Hulk': {
            'confidentiality': False,
            'integrity': False,
            'availability': True,
            'authenticity': False,
            'description': 'Floods server with excessive requests, denies service'
        },
        'DoS GoldenEye': {
            'confidentiality': False,
            'integrity': False,
            'availability': True,
            'authenticity': False,
            'description': 'HTTP flood attack, exhausts server resources'
        },
        'DoS Slowhttptest': {
            'confidentiality': False,
            'integrity': False,
            'availability': True,
            'authenticity': False,
            'description': 'Slow HTTP attack, keeps connections open'
        },
        'DoS slowloris': {
            'confidentiality': False,
            'integrity': False,
            'availability': True,
            'authenticity': False,
            'description': 'Slow connection attack, exhausts concurrent connections'
        },
        'PortScan': {
            'confidentiality': True,
            'integrity': False,
            'availability': False,
            'authenticity': False,
            'description': 'Reconnaissance to discover open ports and services'
        },
        'FTP-Patator': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': True,
            'description': 'Brute force attack on FTP credentials'
        },
        'SSH-Patator': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': True,
            'description': 'Brute force attack on SSH credentials'
        },
        'Web Attack – Brute Force': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': True,
            'description': 'Attempts to guess credentials for web applications'
        },
        'Web Attack – XSS': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': False,
            'description': 'Cross-site scripting, injects malicious scripts'
        },
        'Web Attack – Sql Injection': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': False,
            'description': 'Database attack, manipulates SQL queries'
        },
        # Alternate encodings (� character instead of –)
        'Web Attack � Brute Force': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': True,
            'description': 'Attempts to guess credentials for web applications'
        },
        'Web Attack � XSS': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': False,
            'description': 'Cross-site scripting, injects malicious scripts'
        },
        'Web Attack � Sql Injection': {
            'confidentiality': True,
            'integrity': True,
            'availability': False,
            'authenticity': False,
            'description': 'Database attack, manipulates SQL queries'
        },
        'Bot': {
            'confidentiality': True,
            'integrity': True,
            'availability': True,
            'authenticity': True,
            'description': 'Automated malicious software, full system compromise'
        },
        'Infiltration': {
            'confidentiality': True,
            'integrity': True,
            'availability': True,
            'authenticity': True,
            'description': 'Advanced persistent threat, complete network compromise'
        },
        'Heartbleed': {
            'confidentiality': True,
            'integrity': False,
            'availability': False,
            'authenticity': False,
            'description': 'SSL/TLS bug, leaks memory contents including credentials'
        },
    }
    
    return impact_map.get(attack_type, {
        'confidentiality': False,
        'integrity': False,
        'availability': False,
        'authenticity': False,
        'description': 'Unknown attack type'
    })

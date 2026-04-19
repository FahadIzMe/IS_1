"""
Extract 500 stratified samples from CICIDS2017 dataset
"""
import pandas as pd
import os
from pathlib import Path

# Dataset directory
dataset_dir = Path(__file__).parent / 'Datasets'
csv_files = list(dataset_dir.glob('*.csv'))

print(f"Found {len(csv_files)} CSV files")

# Load all CSV files
dfs = []
for file in csv_files:
    print(f"Loading {file.name}...")
    df = pd.read_csv(file, encoding='utf-8')
    dfs.append(df)

# Combine all datasets
df_combined = pd.concat(dfs, ignore_index=True)
print(f"\nTotal combined dataset: {df_combined.shape}")

# Clean up column names (remove leading/trailing spaces)
df_combined.columns = df_combined.columns.str.strip()

# Find label column
label_col = 'Label' if 'Label' in df_combined.columns else None
if not label_col:
    print("ERROR: Label column not found!")
    exit(1)

print(f"\nLabel distribution:")
print(df_combined[label_col].value_counts())

# Replace infinite values with NaN
df_combined.replace([float('inf'), float('-inf')], pd.NA, inplace=True)

# Drop rows with NaN
df_combined.dropna(inplace=True)

print(f"\nAfter cleaning: {df_combined.shape}")

# Stratified sampling - 500 total rows
# Try to keep proportions but ensure at least 1 sample per class
sample_per_class = {}
class_counts = df_combined[label_col].value_counts()
total_samples = 500

# Calculate proportional samples
for attack_class, count in class_counts.items():
    proportion = count / len(df_combined)
    samples_needed = max(1, int(proportion * total_samples))
    sample_per_class[attack_class] = min(samples_needed, count)

# Adjust to exactly 500
current_total = sum(sample_per_class.values())
if current_total != total_samples:
    # Adjust the largest class
    largest_class = class_counts.index[0]
    sample_per_class[largest_class] += (total_samples - current_total)

print(f"\nSampling strategy:")
for cls, n in sample_per_class.items():
    print(f"  {cls}: {n} samples")

# Sample each class
sampled_dfs = []
for attack_class, n_samples in sample_per_class.items():
    class_data = df_combined[df_combined[label_col] == attack_class]
    sampled = class_data.sample(n=n_samples, random_state=42)
    sampled_dfs.append(sampled)

# Combine samples
df_sample = pd.concat(sampled_dfs, ignore_index=True)

# Shuffle
df_sample = df_sample.sample(frac=1, random_state=42).reset_index(drop=True)

print(f"\nFinal sample size: {df_sample.shape}")
print(f"Sample label distribution:")
print(df_sample[label_col].value_counts())

# Save
output_path = Path(__file__).parent / 'cicids_sample_500.csv'
df_sample.to_csv(output_path, index=False)
print(f"\n✓ Saved to: {output_path}")

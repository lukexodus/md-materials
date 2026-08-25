## Domain-Specific Feature Creation


Domain-specific features leverage expert knowledge to create meaningful representations for particular industries or problem types.

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.preprocessing import FunctionTransformer
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import re

# 1. Time Series Feature Engineering
class TimeSeriesFeatureExtractor(BaseEstimator, TransformerMixin):
    def __init__(self, datetime_column='timestamp', extract_features=None):
        self.datetime_column = datetime_column
        self.extract_features = extract_features or [
            'hour', 'day_of_week', 'month', 'quarter', 'year',
            'is_weekend', 'is_month_end', 'is_quarter_end',
            'hour_sin', 'hour_cos', 'day_sin', 'day_cos',
            'month_sin', 'month_cos'
        ]
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        X = X.copy()
        if isinstance(X, pd.DataFrame) and self.datetime_column in X.columns:
            dt_series = pd.to_datetime(X[self.datetime_column])
        else:
            # Assume first column is datetime if DataFrame not provided
            dt_series = pd.to_datetime(X.iloc[:, 0] if hasattr(X, 'iloc') else X[:, 0])
        
        features = pd.DataFrame()
        
        if 'hour' in self.extract_features:
            features['hour'] = dt_series.dt.hour
        if 'day_of_week' in self.extract_features:
            features['day_of_week'] = dt_series.dt.dayofweek
        if 'month' in self.extract_features:
            features['month'] = dt_series.dt.month
        if 'quarter' in self.extract_features:
            features['quarter'] = dt_series.dt.quarter
        if 'year' in self.extract_features:
            features['year'] = dt_series.dt.year
        if 'is_weekend' in self.extract_features:
            features['is_weekend'] = (dt_series.dt.dayofweek >= 5).astype(int)
        if 'is_month_end' in self.extract_features:
            features['is_month_end'] = dt_series.dt.is_month_end.astype(int)
        if 'is_quarter_end' in self.extract_features:
            features['is_quarter_end'] = dt_series.dt.is_quarter_end.astype(int)
        
        # Cyclical encoding
        if 'hour_sin' in self.extract_features:
            features['hour_sin'] = np.sin(2 * np.pi * dt_series.dt.hour / 24)
        if 'hour_cos' in self.extract_features:
            features['hour_cos'] = np.cos(2 * np.pi * dt_series.dt.hour / 24)
        if 'day_sin' in self.extract_features:
            features['day_sin'] = np.sin(2 * np.pi * dt_series.dt.dayofweek / 7)
        if 'day_cos' in self.extract_features:
            features['day_cos'] = np.cos(2 * np.pi * dt_series.dt.dayofweek / 7)
        if 'month_sin' in self.extract_features:
            features['month_sin'] = np.sin(2 * np.pi * dt_series.dt.month / 12)
        if 'month_cos' in self.extract_features:
            features['month_cos'] = np.cos(2 * np.pi * dt_series.dt.month / 12)
        
        return features.values

# 2. Financial Feature Engineering
class FinancialFeatureExtractor(BaseEstimator, TransformerMixin):
    def __init__(self, price_columns=None, volume_column=None, periods=[5, 10, 20, 50]):
        self.price_columns = price_columns or ['open', 'high', 'low', 'close']
        self.volume_column = volume_column or 'volume'
        self.periods = periods
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        X = X.copy()
        features = pd.DataFrame(index=X.index)
        
        # Basic price features
        if all(col in X.columns for col in self.price_columns):
            features['price_range'] = X['high'] - X['low']
            features['price_change'] = X['close'] - X['open']
            features['price_change_pct'] = features['price_change'] / X['open']
            features['upper_shadow'] = X['high'] - np.maximum(X['open'], X['close'])
            features['lower_shadow'] = np.minimum(X['open'], X['close']) - X['low']
            features['body_size'] = np.abs(X['close'] - X['open'])
            features['is_bullish'] = (X['close'] > X['open']).astype(int)
        
        # Technical indicators
        for period in self.periods:
            if 'close' in X.columns:
                features[f'sma_{period}'] = X['close'].rolling(period).mean()
                features[f'price_to_sma_{period}'] = X['close'] / features[f'sma_{period}']
                features[f'volatility_{period}'] = X['close'].rolling(period).std()
                features[f'rsi_{period}'] = self._calculate_rsi(X['close'], period)
                
                # Bollinger Bands
                sma = X['close'].rolling(period).mean()
                std = X['close'].rolling(period).std()
                features[f'bb_upper_{period}'] = sma + (2 * std)
                features[f'bb_lower_{period}'] = sma - (2 * std)
                features[f'bb_position_{period}'] = (X['close'] - features[f'bb_lower_{period}']) / (features[f'bb_upper_{period}'] - features[f'bb_lower_{period}'])
        
        # Volume features
        if self.volume_column in X.columns:
            for period in self.periods:
                features[f'volume_sma_{period}'] = X[self.volume_column].rolling(period).mean()
                features[f'volume_ratio_{period}'] = X[self.volume_column] / features[f'volume_sma_{period}']
            
            features['price_volume'] = X['close'] * X[self.volume_column]
            features['vwap'] = (features['price_volume'].rolling(20).sum() / 
                               X[self.volume_column].rolling(20).sum())
        
        return features.fillna(method='ffill').fillna(0).values
    
    def _calculate_rsi(self, prices, period=14):
        delta = prices.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
        rs = gain / loss
        return 100 - (100 / (1 + rs))

# 3. Text Feature Engineering
class TextFeatureExtractor(BaseEstimator, TransformerMixin):
    def __init__(self, text_column='text'):
        self.text_column = text_column
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        if isinstance(X, pd.DataFrame):
            text_series = X[self.text_column]
        else:
            text_series = pd.Series(X)
        
        features = pd.DataFrame()
        
        # Basic text statistics
        features['char_count'] = text_series.str.len()
        features['word_count'] = text_series.str.split().str.len()
        features['sentence_count'] = text_series.str.count(r'[.!?]+')
        features['avg_word_length'] = features['char_count'] / features['word_count']
        features['avg_sentence_length'] = features['word_count'] / features['sentence_count']
        
        # Punctuation and formatting
        features['exclamation_count'] = text_series.str.count('!')
        features['question_count'] = text_series.str.count(r'\?')
        features['capital_ratio'] = text_series.str.count(r'[A-Z]') / features['char_count']
        features['digit_ratio'] = text_series.str.count(r'\d') / features['char_count']
        features['special_char_ratio'] = text_series.str.count(r'[^a-zA-Z0-9\s]') / features['char_count']
        
        # Linguistic features
        features['unique_word_ratio'] = text_series.apply(
            lambda x: len(set(x.split())) / len(x.split()) if len(x.split()) > 0 else 0
        )
        features['stopword_ratio'] = text_series.apply(self._count_stopwords) / features['word_count']
        
        # Readability features
        features['flesch_reading_ease'] = text_series.apply(self._flesch_reading_ease)
        
        return features.fillna(0).values
    
    def _count_stopwords(self, text):
        stopwords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should'}
        words = text.lower().split()
        return sum(1 for word in words if word in stopwords)
    
    def _flesch_reading_ease(self, text):
        words = text.split()
        sentences = len(re.findall(r'[.!?]+', text))
        syllables = sum(self._count_syllables(word) for word in words)
        
        if len(words) == 0 or sentences == 0:
            return 0
        
        return 206.835 - (1.015 * len(words) / sentences) - (84.6 * syllables / len(words))
    
    def _count_syllables(self, word):
        vowels = 'aeiouyAEIOUY'
        syllable_count = 0
        previous_char_was_vowel = False
        
        for char in word:
            is_vowel = char in vowels
            if is_vowel and not previous_char_was_vowel:
                syllable_count += 1
            previous_char_was_vowel = is_vowel
        
        if word.endswith('e'):
            syllable_count -= 1
        
        return max(1, syllable_count)

# 4. Geospatial Feature Engineering
class GeospatialFeatureExtractor(BaseEstimator, TransformerMixin):
    def __init__(self, lat_column='latitude', lon_column='longitude', reference_points=None):
        self.lat_column = lat_column
        self.lon_column = lon_column
        self.reference_points = reference_points or {}
    
    def fit(self, X, y=None):
        if isinstance(X, pd.DataFrame):
            self.center_lat = X[self.lat_column].mean()
            self.center_lon = X[self.lon_column].mean()
        return self
    
    def transform(self, X):
        features = pd.DataFrame()
        
        if isinstance(X, pd.DataFrame):
            lat = X[self.lat_column]
            lon = X[self.lon_column]
        else:
            lat = X[:, 0]
            lon = X[:, 1]
        
        # Distance from center
        features['distance_from_center'] = self._haversine_distance(
            lat, lon, self.center_lat, self.center_lon
        )
        
        # Distance from reference points
        for name, (ref_lat, ref_lon) in self.reference_points.items():
            features[f'distance_from_{name}'] = self._haversine_distance(
                lat, lon, ref_lat, ref_lon
            )
        
        # Spatial clustering features
        features['lat_rounded_1'] = np.round(lat, 1)
        features['lon_rounded_1'] = np.round(lon, 1)
        features['lat_rounded_01'] = np.round(lat, 2)
        features['lon_rounded_01'] = np.round(lon, 2)
        
        # Geographic regions (simplified)
        features['hemisphere'] = (lat >= 0).astype(int)
        features['longitude_band'] = pd.cut(lon, bins=[-180, -120, -60, 0, 60, 120, 180], labels=False)
        features['latitude_band'] = pd.cut(lat, bins=[-90, -60, -30, 0, 30, 60, 90], labels=False)
        
        return features.values
    
    def _haversine_distance(self, lat1, lon1, lat2, lon2):
        R = 6371  # Earth's radius in kilometers
        
        lat1_rad = np.radians(lat1)
        lon1_rad = np.radians(lon1)
        lat2_rad = np.radians(lat2)
        lon2_rad = np.radians(lon2)
        
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = np.sin(dlat/2)**2 + np.cos(lat1_rad) * np.cos(lat2_rad) * np.sin(dlon/2)**2
        c = 2 * np.arcsin(np.sqrt(a))
        
        return R * c

# 5. E-commerce Feature Engineering
class EcommerceFeatureExtractor(BaseEstimator, TransformerMixin):
    def __init__(self, user_id='user_id', product_id='product_id', timestamp='timestamp', 
                 price='price', category='category'):
        self.user_id = user_id
        self.product_id = product_id
        self.timestamp = timestamp
        self.price = price
        self.category = category
    
    def fit(self, X, y=None):
        self.user_stats = {}
        self.product_stats = {}
        self.category_stats = {}
        
        if isinstance(X, pd.DataFrame):
            # User statistics
            self.user_stats = X.groupby(self.user_id).agg({
                self.price: ['mean', 'std', 'count'],
                self.category: 'nunique'
            }).round(2)
            
            # Product statistics
            self.product_stats = X.groupby(self.product_id).agg({
                self.price: ['mean', 'std', 'count'],
                self.user_id: 'nunique'
            }).round(2)
            
            # Category statistics
            self.category_stats = X.groupby(self.category).agg({
                self.price: ['mean', 'std', 'count'],
                self.user_id: 'nunique'
            }).round(2)
        
        return self
    
    def transform(self, X):
        features = pd.DataFrame(index=X.index)
        
        # Price features
        features['price_log'] = np.log1p(X[self.price])
        features['is_premium'] = (X[self.price] > X[self.price].quantile(0.8)).astype(int)
        features['is_discount'] = (X[self.price] < X[self.price].quantile(0.2)).astype(int)
        
        # User behavior features
        for user_id in X[self.user_id].unique():
            user_mask = X[self.user_id] == user_id
            if user_id in self.user_stats.index:
                features.loc[user_mask, 'user_avg_price'] = self.user_stats.loc[user_id, (self.price, 'mean')]
                features.loc[user_mask, 'user_price_std'] = self.user_stats.loc[user_id, (self.price, 'std')]
                features.loc[user_mask, 'user_purchase_count'] = self.user_stats.loc[user_id, (self.price, 'count')]
                features.loc[user_mask, 'user_category_diversity'] = self.user_stats.loc[user_id, (self.category, 'nunique')]
        
        # Product features
        for product_id in X[self.product_id].unique():
            product_mask = X[self.product_id] == product_id
            if product_id in self.product_stats.index:
                features.loc[product_mask, 'product_avg_price'] = self.product_stats.loc[product_id, (self.price, 'mean')]
                features.loc[product_mask, 'product_popularity'] = self.product_stats.loc[product_id, (self.user_id, 'nunique')]
        
        # Relative features
        features['price_vs_user_avg'] = X[self.price] / features['user_avg_price']
        features['price_vs_product_avg'] = X[self.price] / features['product_avg_price']
        
        # Time-based features (if timestamp available)
        if self.timestamp in X.columns:
            dt = pd.to_datetime(X[self.timestamp])
            features['hour'] = dt.dt.hour
            features['is_weekend'] = (dt.dt.dayofweek >= 5).astype(int)
            features['is_holiday_season'] = ((dt.dt.month == 11) | (dt.dt.month == 12)).astype(int)
        
        return features.fillna(0).values

# 6. Healthcare Feature Engineering
class HealthcareFeatureExtractor(BaseEstimator, TransformerMixin):
    def __init__(self, age_column='age', gender_column='gender', vital_columns=None):
        self.age_column = age_column
        self.gender_column = gender_column
        self.vital_columns = vital_columns or ['heart_rate', 'blood_pressure_sys', 'blood_pressure_dia', 'temperature']
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        features = pd.DataFrame()
        
        # Age-based features
        if self.age_column in X.columns:
            features['age'] = X[self.age_column]
            features['age_group'] = pd.cut(X[self.age_column], 
                                         bins=[0, 18, 35, 50, 65, 100], 
                                         labels=[0, 1, 2, 3, 4])
            features['is_senior'] = (X[self.age_column] >= 65).astype(int)
            features['is_child'] = (X[self.age_column] < 18).astype(int)
        
        # Vital signs features
        for vital in self.vital_columns:
            if vital in X.columns:
                features[f'{vital}_normalized'] = self._normalize_vital(X[vital], vital)
                features[f'{vital}_abnormal'] = self._detect_abnormal_vital(X[vital], vital)
        
        # BMI calculation
        if 'height' in X.columns and 'weight' in X.columns:
            features['bmi'] = X['weight'] / (X['height'] / 100) ** 2
            features['bmi_category'] = pd.cut(features['bmi'], 
                                            bins=[0, 18.5, 25, 30, float('inf')], 
                                            labels=[0, 1, 2, 3])
        
        # Risk scores
        if all(col in X.columns for col in ['age', 'cholesterol', 'blood_pressure_sys']):
            features['cardiovascular_risk'] = (
                (X['age'] > 45).astype(int) +
                (X['cholesterol'] > 200).astype(int) +
                (X['blood_pressure_sys'] > 140).astype(int)
            )
        
        return features.fillna(0).values
    
    def _normalize_vital(self, values, vital_type):
        # Normal ranges (simplified)
        ranges = {
            'heart_rate': (60, 100),
            'blood_pressure_sys': (90, 140),
            'blood_pressure_dia': (60, 90),
            'temperature': (36.1, 37.2)
        }
        
        if vital_type in ranges:
            min_val, max_val = ranges[vital_type]
            return (values - min_val) / (max_val - min_val)
        return values
    
    def _detect_abnormal_vital(self, values, vital_type):
        ranges = {
            'heart_rate': (60, 100),
            'blood_pressure_sys': (90, 140),
            'blood_pressure_dia': (60, 90),
            'temperature': (36.1, 37.2)
        }
        
        if vital_type in ranges:
            min_val, max_val = ranges[vital_type]
            return ((values < min_val) | (values > max_val)).astype(int)
        return np.zeros_like(values)

# Example usage and testing
if __name__ == "__main__":
    # Generate sample data for testing
    np.random.seed(42)
    
    # Time series data
    dates = pd.date_range('2023-01-01', periods=100, freq='D')
    ts_data = pd.DataFrame({
        'timestamp': dates,
        'value': np.random.randn(100)
    })
    
    # Financial data
    financial_data = pd.DataFrame({
        'open': np.random.uniform(100, 200, 100),
        'high': np.random.uniform(150, 250, 100),
        'low': np.random.uniform(50, 150, 100),
        'close': np.random.uniform(100, 200, 100),
        'volume': np.random.randint(1000, 10000, 100)
    })
    
    # Test time series features
    ts_extractor = TimeSeriesFeatureExtractor()
    ts_features = ts_extractor.fit_transform(ts_data)
    print("Time series features shape:", ts_features.shape)
    
    # Test financial features
    fin_extractor = FinancialFeatureExtractor()
    fin_features = fin_extractor.fit_transform(financial_data)
    print("Financial features shape:", fin_features.shape)
    
    print("\nDomain-specific feature engineering completed successfully!")
```

**Key points:**

- Time series features extract temporal patterns, cyclical encodings, and calendar effects
- Financial features create technical indicators like RSI, Bollinger Bands, and moving averages
- Text features quantify linguistic properties, readability, and stylistic characteristics
- Geospatial features calculate distances, spatial clustering, and geographic regions
- E-commerce features capture user behavior, product popularity, and purchasing patterns
- Healthcare features normalize vital signs, calculate risk scores, and detect abnormalities

**Example:** In financial data, RSI > 70 indicates overbought conditions, while Bollinger Band position shows price relative to volatility bands


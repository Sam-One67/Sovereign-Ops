import numpy as np
from sklearn.linear_model import LinearRegression

class SovereignAI:
    def __init__(self):
        self.model = LinearRegression()
        self.history_x = [] # Time intervals
        self.history_y = [] # CPU/RAM values

    def predict_future_load(self, current_value):
        # Naya data point add karo
        self.history_x.append([len(self.history_x) + 1])
        self.history_y.append(float(current_value))

        # Prediction ke liye kam se kam 5 readings chahiye
        if len(self.history_x) >= 5:
            X = np.array(self.history_x)
            y = np.array(self.history_y)
            self.model.fit(X, y)
            
            # Predict load for next 5 minutes
            future_step = len(self.history_x) + 5
            prediction = self.model.predict([[future_step]])
            return round(prediction[0], 2)
        return None

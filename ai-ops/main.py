import time
import requests
from engine import SovereignAI
from scaler import scale_pods

# --- CONFIGURATION ---
# Target Prometheus API endpoint
PROM_URL = "http://3.6.36.5:9090/api/v1/query"

# Query to calculate total CPU usage across the node
CPU_QUERY = '100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'

ai_brain = SovereignAI()

print("Sovereign-Ops AI-Ops Engine Started...")
print(f"Targeting Prometheus at: {PROM_URL}")

while True:
    try:
        # 1. Fetch real-time metrics from Prometheus
        response = requests.get(PROM_URL, params={'query': CPU_QUERY}, timeout=5)
        results = response.json()['data']['result']
        
        if results:
            # Extract CPU value from metric result
            current_cpu = float(results[0]['value'][1])
            print(f"Current CPU Usage: {current_cpu:.2f}%")
            
            # 2. Feed data to AI Engine for load prediction
            prediction = ai_brain.predict_future_load(current_cpu)
            
            if prediction:
                print(f"AI Predicted Load (for next 5 mins): {prediction}%")
                
                # 3. Scaling Logic based on AI Prediction
                if prediction > 70.0:
                    print("ALERT: High load predicted. Scaling up pods...")
                    scale_pods(5)
                elif prediction < 20.0:
                    print("INFO: Low load predicted. Scaling down to save resources.")
                    scale_pods(2)
            else:
                print("Gathering more data points... (5 points required to start AI prediction)")
        else:
            print("Warning: No metrics found. Please verify if Node Exporter is active.")

    except Exception as e:
        print(f"Error connecting to Prometheus: {e}")
        
    # Wait for 10 seconds before next iteration
    time.sleep(10)

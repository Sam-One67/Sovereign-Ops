from kubernetes import client, config

def scale_pods(replica_count):
    try:
        # K3s config load karo
        config.load_kube_config(config_file="/etc/rancher/k3s/k3s.yaml")
        apps_v1 = client.AppsV1Api()
        
        # Deployment ko update karo
        deployment_name = "sovereign-app"
        namespace = "default"
        
        body = {"spec": {"replicas": replica_count}}
        apps_v1.patch_namespaced_deployment_scale(name=deployment_name, namespace=namespace, body=body)
        print(f" AI ACTION: Scaled pods to {replica_count} successfully!")
    except Exception as e:
        print(f" Scaling Error: {e}")

param([string]$EnvironmentPath = "infrastructure/environments/dev")
$endpoint = terraform -chdir=$EnvironmentPath output -raw iot_endpoint
py -m pip install -r simulator/requirements.txt
py simulator/simulator.py --endpoint $endpoint --certificate certificates/device.pem.crt --private-key certificates/private.key --root-ca certificates/AmazonRootCA1.pem

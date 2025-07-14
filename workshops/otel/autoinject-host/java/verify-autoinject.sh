PID=$(systemctl show -p MainPID --value java-app.service)
sudo lsof -p $PID | grep opentelemetry
sudo journalctl -u java-app.service --since "today"
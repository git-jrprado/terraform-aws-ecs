<powershell>
echo "### SETUP AGENT"
Initialize-ECSAgent -Cluster ${tf_cluster_name} -EnableTaskIAMRole -LoggingDrivers '["json-file","awslogs"]'

echo "### EXTRA USERDATA"
${userdata_extra}
</powershell>
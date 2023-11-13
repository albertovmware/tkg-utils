#Desde cluster supervisor ejecutamos
total_cpus=0
# Obtener el número de CPUs de las máquinas virtuales de tanzu
kubectl get virtualmachine -o -A custom-columns=NAME:.metadata.name,VMCLASS:.spec.className --no-headers | \
while read -r name vmclass; do
  cpu=$(kubectl get virtualmachineclass $vmclass -o json | jq -r '.spec.hardware.cpus')
  total_cpus=$((total_cpus + cpu))
  echo "VM: $name, VMClass: $vmclass, vCPUs: $cpu"
done

# Obtener el número de CPUs del Supervisor
control_plane_cpus=$(kubectl get nodes -l node-role.kubernetes.io/control-plane= --no-headers -o custom-columns=CPUS:.status.capacity.cpu | awk '{sum+=$1} END {print sum}')
total_cpus=$((total_cpus + control_plane_cpus))

echo "Total vCPUs (incluyendo supervisor): $total_cpus"

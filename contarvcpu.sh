#Desde cluster supervisor ejecutamos

#!/bin/bash

total_cpus=0

# Obtenemos las maquinas 
vm_info=$(kubectl get virtualmachine -A -o custom-columns=NAME:.metadata.name,VMCLASS:.spec.className,NS:.metadata.namespace --no-headers)

# leemos tipo de maquina
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    vmclass=$(echo "$line" | awk '{print $2}')
    namespace=$(echo "$line" | awk '{print $3}')
    cpu=$(kubectl get virtualmachineclass "$vmclass" -n "$namespace" -o json | jq -r '.spec.hardware.cpus')
    total_cpus=$((total_cpus + cpu))
    echo "VM: $name, VMClass: $vmclass, vCPUs: $cpu"
done <<< "$vm_info"

# Sumamos cluster superbisot
control_plane_cpus=$(kubectl get nodes -l node-role.kubernetes.io/control-plane= --no-headers -o custom-columns=CPUS:.status.capacity.cpu | awk '{sum+=$1} END {print sum}')
echo "CPUs del Supervisor: $control_plane_cpus"

# Total de cpus
total_cpus=$((total_cpus + control_plane_cpus))
echo "Total vCPUs (incluyendo supervisor): $total_cpus"

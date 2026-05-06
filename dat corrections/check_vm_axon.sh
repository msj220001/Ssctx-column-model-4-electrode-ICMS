#!/bin/bash

for file in Vm_axon_6_44*.dat; do
	if [[ -f "$file" ]]; then
		echo "File: $file"
		echo "$(awk '{print NF}' "$file" | uniq -c)" 
	fi
	#sleep 0.1
done

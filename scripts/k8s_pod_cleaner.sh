#!/usr/bin/env bash
// This shell script is designed to iterate through all namespaces in a Kubernetes cluster, identify
// pods that are not in a 'Running' state within each namespace, and delete those pods.
NAME_SPACES=$(kubectl get namespaces --no-headers -o custom-columns=NAME:metadata.name)
for EACH_NAMESPACE in $NAME_SPACES;do
	echo "Working on $EACH_NAMESPACE"
	kubectl get pods -n ${EACH_NAMESPACE} | grep -v 'Running' | grep -v ^NAME  | awk {'print $1'} | xargs kubectl -n ${EACH_NAMESPACE} delete pod

done
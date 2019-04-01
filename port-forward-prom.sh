#!/bin/bash

nohup kubectl port-forward -n monitoring prometheus-prometheus-operator-prometheus-0 9090 >/dev/null 2>&1 &

KIALI_POD=$(kubectl get pod -n istio-system -l app=kiali -o go-template="{{ range .items }}{{ .metadata.name }}{{end}}")
nohup kubectl port-forward -n istio-system $KIALI_POD 8001:20001 >/dev/null 2>&1 &

#!/bin/bash
kubectl exec -it dse-2 dse cassandra-stop
kubectl exec -it dse-1 dse cassandra-stop
kubectl exec -it dse-0 dse cassandra-stop

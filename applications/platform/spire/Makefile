CLUSTER := happylittlecloud
TRUST_DOMAIN := happylittlecloud.ca

register-node:
	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-socketPath /run/spire/sockets/api.sock \
		-spiffeID spiffe://$(TRUST_DOMAIN)/ns/spire/sa/spire-agent \
		-selector k8s_sat:cluster:$(CLUSTER) \
		-selector k8s_sat:agent_ns:spire \
		-selector k8s_sat:agent_sa:spire-agent \
		-node

register-workload:
	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-socketPath /run/spire/sockets/api.sock \
		-spiffeID spiffe://$(TRUST_DOMAIN)/ns/spire/sa/default \
		-parentID spiffe://$(TRUST_DOMAIN)/ns/spire/sa/spire-agent \
		-selector k8s:ns:spire \
		-selector k8s:sa:default

test-client:
	POD=$$(kubectl get pod -n spire -o custom-columns=":metadata.name" | grep client); \
	kubectl exec -n spire $$POD -- /opt/spire/bin/spire-agent api fetch jwt \
		-socketPath /run/spire/sockets/agent.sock \
		-audience TESTING | grep -A 1 '^token(' \
	| sed 1d | jq -R 'split(".") | .[1] | @base64d | fromjson'

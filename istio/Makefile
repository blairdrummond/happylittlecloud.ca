ISTIO_VERSION := 1.9.2

istio-charts: istio-$(ISTIO_VERSION)
	ln -s $^/manifests/charts $@

istio-$(ISTIO_VERSION):
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) sh -
	echo "*" > $@/.gitignore
	echo "!manifests" >> $@/.gitignore

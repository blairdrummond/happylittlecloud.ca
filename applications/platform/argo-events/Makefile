FILES := install.yaml install-validating-webhook.yaml

all: $(FILES)

clean:
	rm -f $(FILES)

install.yaml:
	wget -O $@ 'https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml'

install-validating-webhook.yaml:
	wget -O $@ 'https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml'


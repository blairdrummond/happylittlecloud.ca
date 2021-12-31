FILES := event-bus.yaml install.yaml install-validating-webhook.yaml

all: $(FILES)

clean:
	rm -f $(FILES)

event-bus.yaml:
	wget -O $@ 'https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml'

install.yaml:
	wget -O $@ 'https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml'

install-validating-webhook.yaml:
	wget -O $@ 'https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml'


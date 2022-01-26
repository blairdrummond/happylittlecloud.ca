serve:
	rm -rf .site
	cp -r . /tmp/.site
	mv /tmp/.site .
	sed -i 's~https://s3.happylittlecloud.ca/bdrummond/~~' .site/index.html
	cd .site && python3 -m http.server 8005

images/cluster.svg: files/cluster.dot
	dot -Tsvg $^ > $@

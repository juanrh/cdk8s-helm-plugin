install:
	helm plugin uninstall cdk8s || true
	helm plugin install $$(pwd)
	echo
	helm plugin list
	echo
	echo "Plugin installed to $$(helm env HELM_PLUGINS)"

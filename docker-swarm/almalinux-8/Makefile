# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

VESPANODE_HOSTS_ACTIVE_OTHER:=$(shell me=$$(hostname); docker node ls --filter "node.label=enable-$$USER-vespanode=true" --format '{{.Hostname}}' | while read name; do test $$name != $$me && echo $$name; done)
VESPANODE_HOSTS_ALL:=$(shell docker node ls --format '{{.Hostname}}')

VESPANODE_IMAGE_SUFFIX:=$(shell . ./vespanode-common.sh; echo $$VESPANODE_IMAGE_SUFFIX)
VESPANODE_BASELINEBASE_IMAGE=$$USER-vespanode-baselinebase-$(VESPANODE_IMAGE_SUFFIX)
VESPANODE_BASELINE_IMAGE=$$USER-vespanode-baseline-$(VESPANODE_IMAGE_SUFFIX)
VESPANODE_IMAGE=$$USER-vespanode-$(VESPANODE_IMAGE_SUFFIX)
SELFRELDIR=git/docker-image-dev/docker-swarm/almalinux-8

.PHONY: default
default:
	echo "No default"

.PHONY: upload-vespanode-baselinebase
upload-vespanode-baselinebase:
	./upload-vespanode.sh ${VESPANODE_BASELINEBASE_IMAGE}

.PHONY: upload-vespanode-baseline
upload-vespanode-baseline:
	./upload-vespanode.sh ${VESPANODE_BASELINE_IMAGE}

.PHONY: upload-vespanode
upload-vespanode:
	./upload-vespanode.sh ${VESPANODE_IMAGE}

.PHONY: distribute-vespanode-baselinebase distribute-vespanode-baselinebase-pre
distribute-vespanode-baselinebase: distribute-vespanode-baselinebase-pre
	echo "Distribute vespanode baselinebase done"

distribute-vespanode-baselinebase-pre:

.PHONY: distribute-vespanode-baseline distribute-vespanode-baseline-pre
distribute-vespanode-baseline: distribute-vespanode-baseline-pre
	echo "Distribute vespanode baseline done"

distribute-vespanode-baseline-pre:

.PHONY: distribute-vespanode distribute-vespanode-pre
distribute-vespanode: distribute-vespanode-pre
	echo "Distribute vespanode done"

distribute-vespanode-pre:

remove-vespanode-baselinebase: remove-vespanode-baselinebase-pre
	echo "Remove vespanode baselinebase done"

remove-vespanode-baselinebase-pre: remove-vespanode-baseline remove-vespanode

remove-vespanode-baseline: remove-vespanode-baseline-pre
	echo "Remove vespanode baseline done"

remove-vespanode-baseline-pre: remove-vespanode

remove-vespanode: remove-vespanode-pre
	echo "Remove vespanode done"

remove-vespanode-pre:

define distribute_template =
.PHONY: distribute-vespanode-baselinebase-$(1)
distribute-vespanode-baselinebase-$(1): upload-vespanode-baselinebase
	./distribute-vespanode.sh $(1) $$${VESPANODE_BASELINEBASE_IMAGE}

distribute-vespanode-baselinebase-pre: distribute-vespanode-baselinebase-$(1)

.PHONY: distribute-vespanode-baseline-$(1)
distribute-vespanode-baseline-$(1): upload-vespanode-baseline
	./distribute-vespanode.sh $(1) $$${VESPANODE_BASELINE_IMAGE}

distribute-vespanode-baseline-pre: distribute-vespanode-baseline-$(1)

.PHONY: distribute-vespanode-$(1)
distribute-vespanode-$(1): upload-vespanode
	./distribute-vespanode.sh $(1) $$${VESPANODE_IMAGE}

distribute-vespanode-pre: distribute-vespanode-$(1)
endef

define remove_template =
.PHONY: remove-vespanode-baseline-$(1)
remove-vespanode-baselinebase-$(1): remove-vespanode-baseline-$(1) remove-vespanode-$(1)
	ssh -a $(1) bash -lc "'cd $(SELFRELDIR) && ./remove-vespanode.sh $$${VESPANODE_BASELINEBASE_IMAGE}'"

remove-vespanode-baselinebase-pre: remove-vespanode-baselinebase-$(1)

remove-vespanode-baseline-$(1): remove-vespanode-$(1)
	ssh -a $(1) bash -lc "'cd $(SELFRELDIR) && ./remove-vespanode.sh $$${VESPANODE_BASELINE_IMAGE}'"

remove-vespanode-baseline-pre: remove-vespanode-baseline-$(1)

.PHONY: remove-vespanode-$(1)
remove-vespanode-$(1):
	ssh -a $(1) bash -lc "'cd $(SELFRELDIR) && ./remove-vespanode.sh $$${VESPANODE_IMAGE}'"

remove-vespanode-pre: remove-vespanode-$(1)
endef

$(foreach host,$(VESPANODE_HOSTS_ACTIVE_OTHER),$(eval $(call distribute_template,$(host))))
$(foreach host,$(VESPANODE_HOSTS_ALL),$(eval $(call remove_template,$(host))))

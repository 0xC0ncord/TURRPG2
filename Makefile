NO_COLOR = \033[0m
O1_COLOR = \033[0;01m
O2_COLOR = \033[32;01m

PREFIX = "$(O2_COLOR)==>$(O1_COLOR)"
SUFFIX = "$(NO_COLOR)"

CURRENT_DIR = $(shell pwd)
BASENAME = $(shell basename $(CURRENT_DIR))
SYSTEM_DIR = $(CURRENT_DIR)/../System
UCC = "$(SYSTEM_DIR)/ucc.exe"

BUILD_INFO = $(shell git rev-parse --short HEAD)$(shell [ -z "$(shell git diff --shortstat 2>/dev/null | tail -n1)" ] || echo '-dirty')
BUILD_DATE = $(shell date +"%a %d %b %Y %H:%M:%S %Z")

default: compile
.PHONY: compile clean

compile:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	@$(CURRENT_DIR)/build.sh

clean:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	@-rm -vrf $(SYSTEM_DIR)/$(BASENAME).u $(SYSTEM_DIR)/$(BASENAME).u.bak $(CURRENT_DIR)/Classes.sha1sum
	@if [[ -d $(CURRENT_DIR)/.Classes ]]; then \
		rm -rf $(CURRENT_DIR)/Classes &&\
		mv -vf $(CURRENT_DIR)/.Classes $(CURRENT_DIR)/Classes;\
	fi

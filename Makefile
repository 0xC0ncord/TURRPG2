NO_COLOR = \033[0m
O1_COLOR = \033[0;01m
O2_COLOR = \033[32;01m

PREFIX = "$(O2_COLOR)==>$(O1_COLOR)"
SUFFIX = "$(NO_COLOR)"

CURRENT_DIR = $(shell pwd)
BASENAME = $(shell basename $(CURRENT_DIR))
SYSTEM_DIR = $(CURRENT_DIR)/../System
UCC = "$(SYSTEM_DIR)/ucc.exe"

default: compile

compile:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	if [ -f $(SYSTEM_DIR)/$(BASENAME).u ]; then mv -vf $(SYSTEM_DIR)/$(BASENAME).u $(SYSTEM_DIR)/$(BASENAME).u.bak ; fi
	wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 1 $(BASENAME)
	wine $(UCC) make
	wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 0 $(BASENAME)

clean:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	@-rm -vrf $(SYSTEM_DIR)/$(BASENAME).u $(SYSTEM_DIR)/$(BASENAME).u.bak

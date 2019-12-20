NO_COLOR = \033[0m
O1_COLOR = \033[0;01m
O2_COLOR = \033[32;01m

PREFIX = "$(O2_COLOR)==>$(O1_COLOR)"
SUFFIX = "$(NO_COLOR)"

CURRENT_DIR = $(shell pwd)
SYSTEM_DIR = $(CURRENT_DIR)/../System
UCC = "$(SYSTEM_DIR)/ucc.exe"

default: compile

compile:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	if [ -f $(SYSTEM_DIR)/TURRPG2.u ]; then mv -vf $(SYSTEM_DIR)/TURRPG2.u $(SYSTEM_DIR)/TURRPG2.u.bak ; fi
	wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 1 OnslaughtBP
	wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 1 TURRPG2
	wine $(UCC) make
	wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 0 TURRPG2

clean:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	@-rm -vrf $(SYSTEM_DIR)/TURRPG2.u $(SYSTEM_DIR)/TURRPG2.u.bak

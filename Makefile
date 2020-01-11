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
.PHONY: compile clean

compile:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	$(eval SHA1SUM := $(shell find $(CURRENT_DIR)/Classes -type f -iname '*.uc' -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $$1}'))
	$(eval SHA1SUM_OLD := $(shell cat $(SYSTEM_DIR)/$(BASENAME)_src.sha1sum))
	@if [[ -f $(SYSTEM_DIR)/$(BASENAME)_src.sha1sum && "$(SHA1SUM_OLD)" = "$(SHA1SUM)" ]]; then echo Source directory unchanged since last build. Nothing to do. Exiting. && false; fi
	@if [[ -f $(SYSTEM_DIR)/$(BASENAME).u ]]; then mv -vf $(SYSTEM_DIR)/$(BASENAME).u $(SYSTEM_DIR)/$(BASENAME).u.bak; fi; \
	wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 1 $(BASENAME) 2>/dev/null; \
	wine $(UCC) make 2>/dev/null && echo $(SHA1SUM) > $(SYSTEM_DIR)/$(BASENAME)_src.sha1sum
	@wine $(UCC) MakeCommandletUtils.EditPackagesCommandlet 0 $(BASENAME) 2>/dev/null

clean:
	@echo -e $(PREFIX) $@ $(SUFFIX)
	@-rm -vrf $(SYSTEM_DIR)/$(BASENAME).u $(SYSTEM_DIR)/$(BASENAME).u.bak $(SYSTEM_DIR)/$(BASENAME)_src.sha1sum

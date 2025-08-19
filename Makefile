PYTHON = python3

VENV   = $(CURDIR)/.venv
PIP    = $(VENV)/bin/pip
TRIADE = $(VENV)/bin/triade

PAGER = less -FR

XDG_DATA_HOME ?= $(HOME)/.local/share

MODS_DIR   = $(XDG_DATA_HOME)/Steam/steamapps/common/Xenonauts/assets/mods
OUTPUT_DIR = $(MODS_DIR)/CustomConfigs

DIST_DIR    = $(CURDIR)/dist
OUTPUT_FILE = $(DIST_DIR)/gameconfig.xml
MODINFO     = $(DIST_DIR)/modinfo.xml

DEFAULT_DIR = data/defaultconfig
CUSTOM_DIR  = data/gameconfig

P       = .
PATTERN = $P

GAME_CONFIGS != sh get_config_files.sh $(CUSTOM_DIR) $(MAKECMDGOALS)
ifeq (NO_YAML,$(GAME_CONFIGS))
    $(error No YAML files found at "$(CUSTOM_DIR)")
else ifeq (NO_DIR,$(GAME_CONFIGS))
    $(warning Usage: sh get_config_files.sh <directory> [<target>]...)
    $(error Input configurations directory not provided)
endif

all: $(OUTPUT_FILE) $(MODINFO) link

link: $(OUTPUT_DIR)

unlink:
	if test -L "$(OUTPUT_DIR)"; then unlink "$(OUTPUT_DIR)"; fi

diff:
	@if test -t 1; then tty=y; fi; \
	for file in $(DEFAULT_DIR)/*.yml; do \
		copy="$(CUSTOM_DIR)/$$(basename $$file)"; \
		if [ -r "$$copy" ] && ! diff "$$file" "$$copy" >/dev/null 2>&1; then \
			if test "$$tty" = y; then \
				printf '\n'; \
				diff -u "$$file" "$$copy" \
				| sed -e 's/^-.[^-].*/\x1b[31m&\x1b[39m/' \
				      -e 's/^+.[^+].*/\x1b[32m&\x1b[39m/' \
				      -E -e 's/^\+++ ([^\t ]+)/+++ \x1b[94m\1\x1b[39m /'; \
			else \
				printf '\n'; diff -u "$$file" "$$copy" || true; \
			fi; \
		fi; \
	done | $(PAGER)

edit:
	@if ls $(CUSTOM_DIR)/*.yml >/dev/null 2>&1; then \
		"$${EDITOR:-vi}" $(CUSTOM_DIR)/*.yml; \
	else \
		printf 'There are no configuration files at %s\n' "$(CUSTOM_DIR)"; \
	fi

configs:
	ls $(DEFAULT_DIR) | sed -n -e '/$(PATTERN)/p' | xargs $(MAKE) --no-print-directory

$(VENV): requirements.txt
	if test ! -d "$@"; then $(PYTHON) -m venv "$@"; fi
	$(VENV)/bin/$(PYTHON) -m ensurepip
	$(PIP) install --upgrade pip -r $<
	touch "$@"

$(OUTPUT_FILE): $(GAME_CONFIGS) | $(VENV) $(DIST_DIR)
	cat $^ | $(TRIADE) -I yaml -o "$@"
	if test -t 1; then \
		printf 'Game configuration file \033[4m%s\033[0m was created successfully!\n' "$@"; \
	else \
		printf 'Game configuration file %s was created successfully!\n' "$@"; \
	fi

$(MODINFO): modinfo.xml | $(DIST_DIR)
	@cp "$<" "$@"

$(OUTPUT_DIR): | $(DIST_DIR)
	@if test ! -e "$@"; then ln -s "$(DIST_DIR)" "$@"; fi

$(DIST_DIR):
	@mkdir -p "$@"

$(CUSTOM_DIR):
	@mkdir -p "$@"

$(CUSTOM_DIR)/%.yml: $(DEFAULT_DIR)/%.yml | $(CUSTOM_DIR)
	cp "$<" "$@"
	@chmod 644 "$@"

%.yml:
	@$(MAKE) --no-print-directory "$(CUSTOM_DIR)/$@"

$(CUSTOM_DIR)/00_header.yml: $(DEFAULT_DIR)/00_header.yml
	@:

clean:
	rm -f dist/*

clean-config:
	rm -f data/gameconfig/*.yml

clean-all: clean clean-config

.PHONY: all link unlink diff edit configs clean clean-config clean-all

.SILENT: $(VENV) $(OUTPUT_FILE)

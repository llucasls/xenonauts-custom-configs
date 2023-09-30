PYTHON = python3

VENV   = $(CURDIR)/.venv
PIP    = $(VENV)/bin/pip
TRIADE = $(VENV)/bin/triade
CREATE = cat $1 | $(TRIADE) -I yaml -o $2

DEFAULT_DIR = data/defaultconfig
CUSTOM_DIR  = data/gameconfig

ifdef USE_DEFAULT
DEFAULT_CONFIGS = $(wildcard $(DEFAULT_DIR)/*.yml)
GAME_CONFIGS    = $(foreach FILE,$(DEFAULT_CONFIGS),\
                  $(if $(wildcard $(FILE:$(DEFAULT_DIR)%=$(CUSTOM_DIR)%)),\
                  $(FILE:$(DEFAULT_DIR)%=$(CUSTOM_DIR)%),$(FILE)))
else
HEADER_FILE  = $(if $(wildcard $(CUSTOM_DIR)/00_header.yml),,\
               $(DEFAULT_DIR)/00_header.yml)
GAME_CONFIGS = $(HEADER_FILE) $(wildcard $(CUSTOM_DIR)/*.yml)
endif

all: gameconfig.xml

$(VENV): requirements.txt
	if test ! -d "$@"; then $(PYTHON) -m venv "$@"; fi
	$(PIP) install --upgrade pip -r $<
	touch "$@"

gameconfig.xml: $(GAME_CONFIGS) | $(VENV)
	$(call CREATE,$^,$@)
	if test -t 1; \
		then printf 'Game configuration file \033[4m%s\033[0m was created successfully!\n' "$@"; \
		else printf 'Game configuration file %s was created successfully!\n' "$@"; \
	fi

.PHONY: all

.SILENT: $(VENV) gameconfig.xml

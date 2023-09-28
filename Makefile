PYTHON = python3

VENV   = $(CURDIR)/.venv
PIP    = $(VENV)/bin/pip
TRIADE = $(VENV)/bin/triade
CREATE = cat $1 | $(TRIADE) -I yaml -O xml > $2

DEFAULT_DIR = data/gameconfig
CUSTOM_DIR  = data/gameconfig

DEFAULT_CONFIGS = $(wildcard $(DEFAULT_DIR)/*.yml)
GAME_CONFIGS    = $(foreach FILE,$(DEFAULT_CONFIGS),\
                  $(if $(wildcard $(FILE:$(DEFAULT_DIR)%=$(CUSTOM_DIR)%)),\
                  $(FILE:$(DEFAULT_DIR)%=$(CUSTOM_DIR)%),$(FILE)))

all: gameconfig.xml

$(VENV): requirements.txt
	if test ! -d "$@"; then $(PYTHON) -m venv "$@"; fi
	$(PIP) install --upgrade pip -r $<
	touch "$@"

gameconfig.xml: $(GAME_CONFIGS) | $(VENV)
	$(call CREATE,$^,$@)

.PHONY: all

.SILENT: $(VENV) gameconfig.xml

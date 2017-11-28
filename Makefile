#!/usr/bin/make -f
#
# Copyright (c) 2017 Samsung CNCT
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DOCS_SRC_DIR   := ./sphinx
DOCS_DIR       := ./docs
DOCS_BK_DIR    := ./docs_bk
DOCS_BUILD_DIR := ./build

.PHONY: help
default: help
help: ## Show the defined tasks
	@grep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: bootstrap
bootstrap: ## Get build dependencies (assumes python and pip are installed)
	pip install sphinx sphinx-jsonschema

.PHONY: docs
docs: ## Build gh-pages documentation, manual push required
	mkdir -p $(DOCS_BUILD_DIR)
	cp -r $(DOCS_DIR) $(DOCS_BK_DIR)
	sphinx-build -a $(DOCS_SRC_DIR) $(DOCS_BUILD_DIR)
	rm -rf $(DOCS_DIR)
	@mv $(DOCS_BUILD_DIR) $(DOCS_DIR)

.PHONY: clean
clean: ## Remove items creted by make docs
	-rm -rf $(DOCS_BUILD_DIR) $(DOCS_BK_DIR)

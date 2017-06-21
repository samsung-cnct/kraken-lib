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

SPHINX_SOURCE_DIR = ./sphinx
SPHINX_BUILD_DIR  = ./docs

# Put it first so that "make" without argument is like "make help".
help:
	@grep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: help Makefile

gh-pages: ## Build gh-pages documentation, manual push required
	@mv $(SPHINX_BUILD_DIR) ./html
	$(MAKE) -C $(SPHINX_SOURCE_DIR) html
	@mv ./html $(SPHINX_BUILD_DIR)

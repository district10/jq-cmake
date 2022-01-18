PROJECT_SOURCE_DIR ?= $(abspath ./)
BUILD_DIR ?= $(PROJECT_SOURCE_DIR)/build
INSTALL_DIR ?= $(BUILD_DIR)/install
NUM_JOB ?= 8

all:
	@echo nothing special
clean:
	rm -rf $(BUILD_DIR)

CMAKE_ARGS := \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
	-DBUILD_SHARED_LIBS=OFF
build:
	mkdir -p $(BUILD_DIR) && cd $(BUILD_DIR) && \
	cmake $(CMAKE_ARGS) $(PROJECT_SOURCE_DIR) && \
	make -j $(NUM_JOB) && make install
.PHONY: build

.PHONY: project build run clean archive open lint icon zip dmg dist

PROJECT := Kikey.xcodeproj
SCHEME  := Kikey
CONFIG  := Release
BUILD_DIR := build
APP := $(BUILD_DIR)/Build/Products/$(CONFIG)/Kikey.app

project:
	xcodegen generate

build: project
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
		build | xcpretty || true

run: build
	open $(APP)

archive: project
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) \
		-archivePath $(BUILD_DIR)/Kikey.xcarchive archive

clean:
	rm -rf $(BUILD_DIR) $(PROJECT)

open: project
	open $(PROJECT)

icon:
	swift scripts/gen-icon.swift

dist:
	./scripts/package.sh

zip: dist
dmg: dist

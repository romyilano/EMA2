# setup pods
setup:
	@echo installing cocoapods...
	sudo /usr/bin/gem install cocoapods
	@pod setup

# update pods
pods:
	@echo [sudo] gem install cocoapods
	@echo
	@echo updating pods...
	@-rm Podfile.lock
	@-rm -rf Pods
	@pod install

cleanpods:
	@echo removing local pod caches...
	@echo /Users/$$USER/.cocoapods/*
	@echo ! be sure to run make setup !
	@-rm -rf /Users/$$USER/.cocoapods/*

test:
	xctool -workspace SplitApp.xcworkspace/ -scheme "Debug" -sdk iphonesimulator build analyze test

# generate en.lproj localization file
localize:
	find . -name \*.m | xargs genstrings -o Dote/en.lproj

.PHONY: setup pods cleanpods test localize

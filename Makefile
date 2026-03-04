.PHONY: setup

## Creates the log/ and answer/ runtime directories required by the Azure RBAC Advisor agent.
## Run once after cloning: make setup
setup:
	mkdir -p log answer
	touch log/.gitkeep answer/.gitkeep
	@echo "✅ log/ and answer/ directories ready."

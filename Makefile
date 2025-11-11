.PHONY: unit integration reports

reports:
	mkdir -p reports

unit:	reports
	pytest -q tests/unit -m "unit" \
	--disable-warnings \
	--maxfail=1 \
	--junitxml=reports/unit_results.xml \
	--cov=app \
	--cov-report=xml:reports/coverage_unit.xml

integration: reports
	pytest -q tests/integration -m "integration" \
	--disable-warnings \
	--maxfail=1 \
	--junitxml=reports/integration_result.xml \
	--cov=app \
	--cov-report=xml:reports/coverage_integration.xml
package:
	@docker build --build-arg XGBOOST_REF=$(git ls-remote -h https://github.com/dmlc/xgboost | cut -f 1) -t xgboost4j-builder-container .

test: package
	@docker run -v `pwd`:/xgboost4j-builder-repo \
	--entrypoint "/bin/bash" xgboost4j-builder-container \
	-c "cd /xgboost4j-builder-repo && sbt --error test"

publish-local: test
	@docker run -v `pwd`:/xgboost4j-builder-repo \
	--entrypoint "/bin/bash" xgboost4j-builder-container \
	-c "cd /xgboost4j-builder-repo && mkdir -p ./target/jvm-packages && cp -R /root/xgboost/jvm-packages ./target"

assembly: package
	@docker run -v `pwd`:/xgboost4j-builder-repo \
	--entrypoint "/bin/bash" xgboost4j-builder-container \
	-c "cd /xgboost4j-builder-repo && sbt assembly"

publish-nexus: test
	@docker run -v ${HOME}/.m2/:/root/.m2/ -v ${HOME}:/publisher \
	--entrypoint "/bin/bash" xgboost4j-builder-container "/publisher/publish.sh"
clstumpy:
	rm -rf .build
	docker buildx build --platform linux/amd64,linux/arm64 --push -t pirateguillermo/clstumpy:dev .
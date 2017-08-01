all: fetch

fetch:
	$(MAKE) -j do_fetch
CDN = 'http://download.tensorflow.org/models/'
do_fetch: $(shell curl -s 'https://raw.githubusercontent.com/tensorflow/models/master/slim/README.md' | sed 's%](%\n%g;s%.tar.gz)%.tar.gz\n%g' | grep -E '^http[^|]+tar.gz$$' | sed 's%$(CDN)%%g')
%.tar.gz: xzf
	curl -s -O $(CDN)$@
	mkdir $^/$*
	tar xzf $@ -C $^/$*
xzf:
	mkdir $@

quantize:
	bazel build tensorflow/tools/quantization:quantize_graph
	bazel-bin/tensorflow/tools/quantization/quantize_graph \
	  --input=/tmp/classify_image_graph_def.pb \
	  --output_node_names='softmax' --output=/tmp/quantized_graph.pb \
	  --mode='eightbit'

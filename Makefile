run: gen
	hexo server --debug

gen:
	hexo clean && hexo generate

PHONY: run gen

# vars

PAGE  ?= 'A4'
WIDTH ?= 1200
FILES ?= json md txt html pdf

# functions

make_and_print     = make --quiet out/resume.$(1) > /dev/null && printf "." $(2)
make_and_print_map = $(foreach X,$(1),$(call make_and_print,$(X),&&))
make_and_print_all = $(call make_and_print_map,$(FILES))

# dir tasks

out: node_modules
	@test -d $@ || mkdir $@

node_modules:
	@npm install

# build tasks

build: node_modules index.html resume.pdf Michael_Vanasse_resume.pdf
	@printf "  `date -u +'%Y-%m-%d %H:%M:%S'` - building " \
	&& $(make_and_print_all) \
	printf ' done\n'

watch: node_modules
	@clear \
	&& echo \
	&& ./node_modules/.bin/chokidar \
		src/** \
		bin/** \
		Makefile \
		--silent \
		--initial \
		--command "make build"

# resume formats

out/resume.png: out/resume.html out
	@./node_modules/.bin/electroshot \
	--quality 100 \
	--filename $(@F) \
	--out $(@D) \
	--format png \
	./$< $(WIDTH)x

out/resume.pdf: out/resume.html out
	@wkhtmltopdf \
	--quiet \
	--print-media-type \
	--orientation Portrait \
	--page-size $(PAGE) \
	--page-width $(WIDTH) \
	--title 'Ryan Andersen' \
	--dpi 300 \
	--margin-top 2cm  --margin-bottom 1cm \
	--margin-left 1cm --margin-right 1cm \
	./$< $@

out/resume.html: src/resume.pug src/resume.styl src/resume.js out/resume.json out
	@./node_modules/.bin/pug \
	--path $(PWD)/$< \
	--obj out/resume.json \
	< $< \
	| ./node_modules/.bin/js-beautify \
		--type html \
		--indent-size 2 \
		--indent-level 0 \
		--good-stuff \
	> $@

out/resume.json: src/resume.yml bin/process_json.js out
	@./node_modules/.bin/js-yaml \
	< $< \
	| ./bin/process_json.js \
	> $@

out/%: out/resume.json
	@./node_modules/.bin/hackmyresume build \
	$< to $@

index.html: out/resume.html
	@./node_modules/.bin/minify --html < $< > $@

resume.pdf: out/resume.pdf
	@cp -f $< $@

Michael_Vanasse_resume.pdf: out/resume.pdf
	@cp -f $< $@

# utility tasks

clean:
	rm -rf out node_modules

# misc

.DEFAULT_GOAL = build
.PHONY: watch build clean

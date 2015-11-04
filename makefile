COMPRESS_OPT:=dead_code,drop_console,join_vars,warnings,unused,sequences,drop_debugger,conditionals,comparisons,evaluate,booleans,loops,if_return
UGLIFY:=uglifyjs -o underboss.js --lint --screw-ie8 -c ${COMPRESS_OPT}  -m --reserve-domprops --stats --
JSL:=jsl-0.3.0/src/Linux_All_DBG.OBJ/jsl -conf jsl.conf -nosummary -nologo -process

FILES+=$(shell ls res/*.js)
FILES+=$(shell ls bot/*.js)
FILES+=$(shell ls gui/*.js)
FILES+=$(shell ls util/*.js)
FILES+=main.js

.PHONY: clean lint release all dropbox

all: Underboss-dev.user.js

release: Underboss.user.js

Underboss-dev.user.js: makefile res/underboss.css.js Underboss.meta.js $(FILES)
	make lint
	cat Underboss.meta.js $(FILES) > Underboss-dev.user.js

res/underboss.css.js: res/underboss.css
	@echo "Convert CSS to JS"
	@echo -n 'var css = "' > res/underboss.css.js
	@uglifycss res/underboss.css | tr -d '\n' >> res/underboss.css.js
	@echo -n '";' >> res/underboss.css.js

lint:
	@for f in $(FILES); do \
		${JSL} $$f; \
	done

Underboss.user.js: Underboss-dev.user.js
	${UGLIFY} Underboss-dev.user.js
	cat Underboss.meta.js underboss.js > Underboss.user.js
	rm underboss.js

dropbox: all
	cp Underboss-dev.user.js ~/Dropbox/Godfather_Bot/

clean:
	rm -fr *~
	rm -fr bot/*~
	rm -fr util/*~
	rm -fr res/*~

setup: install_jsl install_uglify

install_jsl:
	wget http://www.javascriptlint.com/download/jsl-0.3.0-src.tar.gz
	tar -zxvf jsl-0.3.0-src.tar.gz
	rm jsl-0.3.0-src.tar.gz
	cd jsl-0.3.0/src && make -f Makefile.ref

install_uglify:
	sudo apt-get install npm
	sudo npm install uglify-js -g
	sudo npm install uglifycss -g
	sudo ln -s /usr/bin/nodejs /usr/bin/node

install_dropbox_64:
	cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
	~/.dropbox-dist/dropboxd

install_dropbox_32:
	cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
	~/.dropbox-dist/dropboxd

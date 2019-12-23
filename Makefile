.PHONY: package

files = $(shell hg files)
docfiles = $(shell hg files site)

package: ~/Desktop/splice.zip

~/Desktop/splice.zip: $(files)
	hg archive ~/Desktop/splice.zip -I 'doc' -I 'plugin' -I 'autoload' -I 'syntax' -I 'LICENSE.markdown' -I 'README.markdown'


docs: site/build/index.html

site/build/index.html: $(docfiles)
	cd site && ~/.virtualenvs/d/bin/d

pubdocs: site/build/index.html
	hg -R ~/src/docs.stevelosh.com pull -u
	rsync --delete -az site/build/ ~/src/docs.stevelosh.com/splice.vim
	hg -R ~/src/docs.stevelosh.com commit -Am 'splice.vim: Update site.'
	hg -R ~/src/docs.stevelosh.com push

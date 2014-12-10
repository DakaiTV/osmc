# (c) 2014 Sam Nazarko
# email@samnazarko.co.uk

#!/bin/bash

. ../common.sh

pull_source "https://github.com/Sky-git/afpfs-ng-fork" "$(pwd)/src"
if [ $? != 0 ]; then echo -e "Error downloading" && exit 1; fi
# Build in native environment
build_in_env "${1}" $(pwd) "libafpclient-osmc"
if [ $? == 0 ]
then
	echo -e "Building libafpclient"
	out=$(pwd)/files
	make clean
	sed '/Package/d' -i files/DEBIAN/control
	sed '/Package/d' -i files-dev/DEBIAN/control
	sed '/Depends/d' -i files-dev/DEBIAN/control
	update_sources
	handle_dep "libfuse-dev"
	handle_dep "libreadline-dev"
	handle_dep "libncurses5-dev"
	test "$1" == gen && echo "Package: libafpclient-osmc" >> files/DEBIAN/control && echo "Package: libafpclient-dev-osmc" >> files-dev/DEBIAN/control && echo "Depends: libafpclient-osmc" >> files-dev/DEBIAN/control
	test "$1" == rbp && echo "Package: rbp-libafpclient-osmc" >> files/DEBIAN/control && echo "Package: rbp-libafpclient-dev-osmc" >> files-dev/DEBIAN/control && echo "Depends: rbp-libafpclient-osmc" >> files-dev/DEBIAN/control
	pushd src/afpfs-ng
	chmod +x configure
	./configure --prefix=/usr
	$BUILD
	make install DESTDIR=${out}
	# We always error
	if [ $? != 0 ]; then echo "Error occured during build" && exit 1; fi
	strip_files "${out}"
	popd
	mkdir -p files-dev/usr/include
	cp src/afpfs-ng/include/* files-dev/usr/include
	fix_arch_ctl "files/DEBIAN/control"
	fix_arch_ctl "files-dev/DEBIAN/control"
	dpkg -b files/ libafpclient-osmc.deb
	dpkg -b files-dev libafpclient-dev-osmc.deb
fi
teardown_env "${1}"

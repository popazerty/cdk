#
# host_python
#
$(D)/host_python: @DEPENDS_host_python@
	@PREPARE_host_python@ && \
	( cd @DIR_host_python@ && \
		autoconf && \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure \
			--without-cxx-main \
			--without-threads && \
		$(MAKE) python Parser/pgen && \
		mv python ./hostpython && \
		mv Parser/pgen ./hostpgen && \
		\
		$(MAKE) distclean && \
		./configure \
			--prefix=$(hostprefix) \
			--sysconfdir=$(hostprefix)/etc \
			--without-cxx-main \
			--without-threads && \
		$(MAKE) \
			TARGET_OS=$(build) \
			PYTHON_MODULES_INCLUDE="$(hostprefix)/include" \
			PYTHON_MODULES_LIB="$(hostprefix)/lib" \
			HOSTPYTHON=./hostpython \
			HOSTPGEN=./hostpgen \
			all install && \
		cp ./hostpgen $(hostprefix)/bin/pgen ) && \
	@CLEANUP_host_python@
	touch $@

#
# libxmlccwrap
#
$(D)/libxmlccwrap: $(D)/bootstrap $(D)/libxml2_e2 $(D)/libxslt @DEPENDS_libxmlccwrap@
	@PREPARE_libxmlccwrap@
	cd @DIR_libxmlccwrap@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libxmlccwrap@
	@CLEANUP_libxmlccwrap@
	touch $@

#
# lxml
#
$(D)/lxml: $(D)/bootstrap $(D)/python @DEPENDS_lxml@
	@PREPARE_lxml@
	cd @DIR_lxml@ && \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py build \
			--with-xml2-config=$(hostprefix)/bin/xml2-config \
			--with-xslt-config=$(hostprefix)/bin/xslt-config && \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_lxml@
	touch $@

#
# setuptools
#
$(D)/setuptools: $(D)/bootstrap $(D)/python @DEPENDS_setuptools@
	@PREPARE_setuptools@
	cd @DIR_setuptools@ && \
		$(hostprefix)/bin/python ./setup.py build install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_setuptools@
	touch $@

#
# twisted
#
$(D)/twisted: $(D)/bootstrap $(D)/setuptools @DEPENDS_twisted@
	@PREPARE_twisted@
	cd @DIR_twisted@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_twisted@
	touch $@

#
# pilimaging
#
$(D)/pilimaging: $(D)/bootstrap $(D)/libjpeg $(D)/libfreetype $(D)/python $(D)/setuptools @DEPENDS_pilimaging@
	@PREPARE_pilimaging@
	cd @DIR_pilimaging@ && \
		sed -ie "s|"darwin"|"darwinNot"|g" "setup.py"; \
		sed -ie "s|ZLIB_ROOT = None|ZLIB_ROOT = libinclude(\"${targetprefix}/usr\")|" "setup.py"; \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pilimaging@
	touch $@

#
# pycrypto
#
$(D)/pycrypto: $(D)/bootstrap $(D)/setuptools @DEPENDS_pycrypto@
	@PREPARE_pycrypto@
	cd @DIR_pycrypto@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pycrypto@
	touch $@

#
# python
#
$(D)/python: $(D)/bootstrap $(D)/host_python $(D)/libncurses $(D)/openssl $(D)/sqlite $(D)/libreadline $(D)/bzip2 @DEPENDS_python@
	@PREPARE_python@
	( cd @DIR_python@ && \
		CONFIG_SITE= \
		autoreconf --verbose --install --force Modules/_ctypes/libffi && \
		autoconf && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--sysconfdir=/etc \
			--enable-shared \
			--enable-ipv6 \
			--without-cxx-main \
			--with-threads \
			--with-pymalloc \
			--with-signal-module \
			--with-wctype-functions \
			HOSTPYTHON=$(hostprefix)/bin/python \
			OPT="$(TARGET_CFLAGS)" \
		&& \
		$(MAKE) $(MAKE_ARGS) \
			TARGET_OS=$(target) \
			PYTHON_MODULES_INCLUDE="$(prefix)/$*cdkroot/usr/include" \
			PYTHON_MODULES_LIB="$(prefix)/$*cdkroot/usr/lib" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(target) \
			HOSTARCH=sh4-linux \
			CFLAGS="$(TARGET_CFLAGS) -fno-inline" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(target)-gcc" \
			HOSTPYTHON=$(hostprefix)/bin/python \
			HOSTPGEN=$(hostprefix)/bin/pgen \
			all install DESTDIR=$(prefix)/$*cdkroot ) \
		&& \
		@INSTALL_python@
	$(LN_SF) ../../libpython$(PYTHON_VERSION).so.1.0 $(prefix)/$*cdkroot$(PYTHON_DIR)/config/libpython$(PYTHON_VERSION).so && \
	$(LN_SF) $(prefix)/$*cdkroot$(PYTHON_INCLUDE_DIR) $(prefix)/$*cdkroot/usr/include/python
	@CLEANUP_python@
	touch $@

#
# pyusb
#
$(D)/pyusb: $(D)/bootstrap $(D)/setuptools @DEPENDS_pyusb@
	@PREPARE_pyusb@
	cd @DIR_pyusb@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pyusb@
	touch $@

#
# pyopenssl
#
$(D)/pyopenssl: $(D)/bootstrap $(D)/setuptools @DEPENDS_pyopenssl@
	@PREPARE_pyopenssl@
	cd @DIR_pyopenssl@ && \
		$(BUILDENV) CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pyopenssl@
	touch $@

#
# elementtree
#
$(D)/elementtree: $(D)/bootstrap @DEPENDS_elementtree@
	@PREPARE_elementtree@
	cd @DIR_elementtree@ && \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_elementtree@
	touch $@

#
# pythonwifi
#
$(D)/pythonwifi: $(D)/bootstrap $(D)/setuptools @DEPENDS_pythonwifi@
	@PREPARE_pythonwifi@
	cd @DIR_pythonwifi@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pythonwifi@
	touch $@

#
# pythoncheetah
#
$(D)/pythoncheetah: $(D)/bootstrap $(D)/setuptools @DEPENDS_pythoncheetah@
	@PREPARE_pythoncheetah@
	cd @DIR_pythoncheetah@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pythoncheetah@
	touch $@

#
# pythonmechanize
#
$(D)/pythonmechanize: $(D)/bootstrap $(D)/setuptools @DEPENDS_pythonmechanize@
	@PREPARE_pythonmechanize@
	cd @DIR_pythonmechanize@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pythonmechanize@
	touch $@

#
# gdata
#
$(D)/gdata: $(D)/bootstrap $(D)/setuptools @DEPENDS_gdata@
	@PREPARE_gdata@
	cd @DIR_gdata@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_gdata@
	touch $@

#
# zope_interface
#
$(D)/zope_interface: bootstrap python setuptools @DEPENDS_zope_interface@
	@PREPARE_zope_interface@
	cd @DIR_zope_interface@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_zope_interface@
	touch $@

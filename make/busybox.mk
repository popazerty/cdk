#
# busybox
#
$(D)/busybox: $(D)/bootstrap @DEPENDS_busybox@ $(buildprefix)/Patches/busybox.config$(if $(UFS912)$(UFS913)$(SPARK)$(SPARK7162),_nandwrite)
	$(START_BUILD)
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
		for i in \
			busybox-1.25.1-nandwrite.patch \
			busybox-1.25.1-unicode.patch \
			busybox-1.25.1-extra.patch \
		; do \
			echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
			$(PATCH)/$$i; \
		done; \
		$(INSTALL) -m644 $(lastword $^) .config && \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(targetprefix)"#' .config
	cd @DIR_busybox@ && \
		export CROSS_COMPILE=$(target)- && \
		$(MAKE) all \
			CROSS_COMPILE=$(target)- \
			CONFIG_EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		&& \
		@INSTALL_busybox@
#	@CLEANUP_busybox@
	$(TOUCH)


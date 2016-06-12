#
# driver
#
$(D)/driver: $(driverdir)/Makefile $(D)/bootstrap $(D)/linux-kernel
	cp $(driverdir)/stgfb/stmfb/linux/drivers/video/stmfb.h $(targetprefix)/usr/include/linux
	cp $(driverdir)/player2/linux/include/linux/dvb/stm_ioctls.h $(targetprefix)/usr/include/linux/dvb
	 $(MAKE) -j$(MAKE_JOBS) -C $(driverdir) ARCH=sh \
		CONFIG_MODULES_PATH=$(crossprefix)/target \
		KERNEL_LOCATION=$(buildprefix)/$(KERNEL_DIR) \
		DRIVER_TOPDIR=$(driverdir) \
		$(DRIVER_PLATFORM) \
		CROSS_COMPILE=$(target)-
	 $(MAKE) -j$(MAKE_JOBS) -C $(driverdir) ARCH=sh \
		CONFIG_MODULES_PATH=$(crossprefix)/target \
		KERNEL_LOCATION=$(buildprefix)/$(KERNEL_DIR) \
		DRIVER_TOPDIR=$(driverdir) \
		$(DRIVER_PLATFORM) \
		CROSS_COMPILE=$(target)- \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) \
		install
	$(DEPMOD) -ae -b $(targetprefix) -F $(buildprefix)/$(KERNEL_DIR)/System.map -r $(KERNELVERSION)
	touch $@

driver-clean:
	rm -f $(D)/driver
	 $(MAKE) -j$(MAKE_JOBS) -C $(driverdir) ARCH=sh \
		KERNEL_LOCATION=$(buildprefix)/$(KERNEL_DIR) \
		distclean

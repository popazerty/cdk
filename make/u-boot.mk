#
# HOST-U-BOOT-TOOLS SMALL
#
HOST_U_BOOT_TOOLS := host_u_boot_tools
$(D)/host_u_boot_tools: @DEPENDS_host_u_boot_tools@
	@PREPARE_host_u_boot_tools@
	cp -Ppr @DIR_host_u_boot_tools@/opt/STM/STLinux-2.4/host/bin/* $(hostprefix)/bin
	@CLEANUP_host_u_boot_tools@
	touch $@

#
# TF7700 installer
#
TFINSTALLER_DIR := tfinstaller

tfinstaller:
	$(MAKE) -j$(MAKE_JOBS) $(MAKE_OPTS) -C tfinstaller

$(TFINSTALLER_DIR)/u-boot.ftfd: @DIR_uboot_tf7700@/u-boot.bin $(TFINSTALLER_DIR)/tfpacker
	$(TFINSTALLER_DIR)/tfpacker $< $@
	$(TFINSTALLER_DIR)/tfpacker -t $< $(@D)/Enigma_Installer.tfd
	@CLEANUP_uboot_tf7700@

$(TFINSTALLER_DIR)/tfpacker:
	$(MAKE) -j$(MAKE_JOBS) -C $(TFINSTALLER_DIR) tfpacker

$(D)/uboot_tf7700: bootstrap @DEPENDS_uboot_tf7700@
	@PREPARE_uboot_tf7700@
	cd @DIR_uboot_tf7700@ && \
		$(MAKE) -j$(MAKE_JOBS) tf7700_config && \
		$(MAKE) -j$(MAKE_JOBS)
#	@CLEANUP_uboot_tf7700@
	touch $@





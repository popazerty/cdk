#
# diff helper
#
enigma2-nightly-patch \
neutrino-mp-next-patch \
neutrino-mp-tangos-patch \
neutrino-mp-cst-next-patch \
neutrino-mp-martii-github-patch \
libstb-hal-next-patch \
libstb-hal-cst-next-patch \
libstb-hal-github-old-patch :
	cd $(sourcedir) && diff -Nur --exclude-from=$(buildprefix)/scripts/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(cvsdir)/$@ ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# STB-HAL from github
NEUTRINO_MP_LIBSTB_GH_OLD_PATCHES += $(PATCHES)/libstb-hal.patch

# Neutrino MP Next from github
NEUTRINO_MP_LIBSTB_NEXT_PATCHES += $(PATCHES)/libstb-hal-next.patch
NEUTRINO_MP_NEXT_PATCHES += $(PATCHES)/neutrino-mp-next.patch

# Neutrino MP Next CST from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES += $(PATCHES)/libstb-hal-cst-next.patch
NEUTRINO_MP_CST_NEXT_PATCHES += $(PATCHES)/neutrino-mp-cst-next.patch

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/neutrino-hd2-exp.diff $(PATCHES)/nhd2-exp.patch
NEUTRINO_HD2_PLUGINS_PATCHES += 

# Neutrino MP from martii
NEUTRINO_MP_MARTII_GH_PATCHES += $(PATCHES)/neutrino-mp-martii-github.patch

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES += $(PATCHES)/neutrino-mp-tangos.patch

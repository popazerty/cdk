#
# diff helper
#
enigma2-nightly-diff \
neutrino-mp-next-diff \
neutrino-mp-tangos-diff \
neutrino-mp-cst-next-diff \
neutrino-mp-martii-github-diff \
libstb-hal-next-diff \
libstb-hal-cst-next-diff \
libstb-hal-github-old-diff :
	cd $(sourcedir) && diff -NEbur --exclude-from=$(buildprefix)/scripts/diff-exclude $(subst -diff,,$@).org $(subst -diff,,$@) > $(cvsdir)/$@ ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# STB-HAL from github
NEUTRINO_MP_LIBSTB_GH_OLD_PATCHES += 

# Neutrino MP from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES += 
NEUTRINO_MP_CST_NEXT_PATCHES += 

# Neutrino MP Next from github
NEUTRINO_MP_LIBSTB_NEXT_PATCHES += $(PATCHES)/libstb-hal-next.patch
NEUTRINO_MP_NEXT_PATCHES += $(PATCHES)/neutrino-mp-next.patch

# Neutrino MP from martii
NEUTRINO_MP_MARTII_GH_PATCHES += $(PATCHES)/neutrino-mp-martii-github.patch

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES += $(PATCHES)/neutrino-mp-tangos.patch

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/neutrino-hd2-exp.diff $(PATCHES)/nhd2-exp.patch
NEUTRINO_HD2_PLUGINS_PATCHES += 


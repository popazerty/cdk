#
# diff helper
#
enigma2-nightly-patch \
neutrino-mp-next-patch \
neutrino-mp-tangos-patch \
neutrino-mp-cst-next-patch \
neutrino-mp-cst-next-max-patch \
neutrino-mp-martii-github-patch \
libstb-hal-next-patch \
libstb-hal-cst-next-patch \
libstb-hal-github-old-patch :
	cd $(sourcedir) && diff -Nur --exclude-from=$(buildprefix)/scripts/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(cvsdir)/$@ ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# STB-HAL from github
NEUTRINO_MP_LIBSTB_GH_OLD_PATCHES += 

# Neutrino MP from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES += 
NEUTRINO_MP_CST_NEXT_PATCHES += 

# Neutrino MP Next from github
NEUTRINO_MP_LIBSTB_NEXT_PATCHES += 
NEUTRINO_MP_NEXT_PATCHES += 

# Neutrino MP from martii
NEUTRINO_MP_MARTII_GH_PATCHES += 

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES += 

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/neutrino-hd2-exp.diff
NEUTRINO_HD2_PLUGINS_PATCHES += 


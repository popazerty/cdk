# keeping all patches together in one file
# uncomment if needed
#

# Neutrino MP
NEUTRINO_MP_LIBSTB_HAL_PATCHES = $(PATCHES)/libstb-hal.patch
NEUTRINO_MP_PATCHES = $(PATCHES)/neutrino-mp.patch

# Neutrino MP from github
NEUTRINO_MP_GH_LIBSTB_HAL_GH_PATCHES += $(PATCHES)/libstb-hal-github.patch
NEUTRINO_MP_GH_PATCHES += $(PATCHES)/neutrino-mp-github.patch

# Neutrino MP from martii
NEUTRINO_MP_MARTII_GH_PATCHES += $(PATCHES)/neutrino-mp-martii-github.patch

# Neutrino MP Next from gitorious
NEUTRINO_LIBSTB_NEXT_PATCHES += $(PATCHES)/libstb-hal-next.patch
NEUTRINO_MP_NEXT_PATCHES += $(PATCHES)/neutrino-mp-next.patch

# Neutrino MP Tango 
NEUTRINO_MP_TANGOS_PATCHES += $(PATCHES)/neutrino-mp-tangos.patch

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/neutrino-hd2-exp.diff $(PATCHES)/nhd2-exp.patch

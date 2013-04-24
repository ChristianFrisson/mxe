# This file is part of MXE.
# See index.html for further information.

PKG             := openscenegraph
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := e1b80206572d681fe624b4c8076674aa5efd6b29
$(PKG)_SUBDIR   := OpenSceneGraph-$($(PKG)_VERSION)
$(PKG)_FILE     := OpenSceneGraph-$($(PKG)_VERSION).zip
$(PKG)_URL      := http://www.openscenegraph.org/downloads/developer_releases/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc boost curl dcmtk ffmpeg freetype giflib gta jasper jpeg libpng openal openexr poppler qt tiff xine-lib zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.openscenegraph.org/downloads/developer_releases/?C=M;O=D' | \
    $(SED) -n 's,.*OpenSceneGraph-\([0-9][^<]*\)\.zip.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && cmake . \
        -DCMAKE_TOOLCHAIN_FILE='$(CMAKE_TOOLCHAIN_FILE)' \
        -DCMAKE_CXX_FLAGS=-D__STDC_CONSTANT_MACROS \
        -DCMAKE_HAVE_PTHREAD_H=OFF \
        -DPKG_CONFIG_EXECUTABLE='$(PREFIX)/bin/$(TARGET)-pkg-config' \
        -DDYNAMIC_OPENTHREADS=OFF \
        -DDYNAMIC_OPENSCENEGRAPH=OFF \
        -DBUILD_OSG_APPLICATIONS=OFF \
        -DPOPPLER_HAS_CAIRO_EXITCODE=0 \
        -D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=1
    $(MAKE) -C '$(1)' -j '$(JOBS)' install VERBOSE=1
    # Test that all plugins link
    '$(TARGET)-g++' \
        -W -Wall \
        '$(2).cpp' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `$(TARGET)-pkg-config --cflags openscenegraph-osgPlugin-all` \
	`$(TARGET)-pkg-config --libs openscenegraph-osgPlugin-all` \
	-lglu32 -lopengl32
endef

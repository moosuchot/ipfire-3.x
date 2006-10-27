#############################################################
#
# uClibc (the C library)
#
#############################################################
ifeq ($(USE_UCLIBC_SNAPSHOT),true)
# Be aware that this changes daily....
UCLIBC_DIR=$(TOOL_BUILD_DIR)/uClibc
UCLIBC_SOURCE=uClibc-snapshot.tar.gz
UCLIBC_SITE:=http://www.uclibc.org/downloads/snapshots
else
UCLIBC_DIR:=$(TOOL_BUILD_DIR)/uClibc-0.9.28
UCLIBC_SOURCE:=uClibc-0.9.28.tar.bz2
UCLIBC_SITE:=http://www.uclibc.org/downloads
endif
LINUX_DIR:=/usr/src/linux

UCLIBC_TARGET_ARCH:=$(shell echo $(ARCH) | sed -e s'/-.*//' \
                -e 's/i.86/i386/' \
		-e 's/sparc.*/sparc/' \
		-e 's/arm.*/arm/g' \
		-e 's/m68k.*/m68k/' \
		-e 's/ppc/powerpc/g' \
		-e 's/v850.*/v850/g' \
		-e 's/sh64/sh/' \
		-e 's/sh[234]/sh/' \
		-e 's/mips.*/mips/' \
		-e 's/mipsel.*/mips/' \
		-e 's/cris.*/cris/' \
)


$(DL_DIR)/$(UCLIBC_SOURCE):
#	$(WGET) -P $(DL_DIR) $(UCLIBC_SITE)/$(UCLIBC_SOURCE)

$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE)
	bzip2 -dc $(DL_DIR)/$(UCLIBC_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xf -
	sed -i -e 's/include <sys\/types.h>/include <sys\/types.h>\n#include <pthread.h>/' $(UCLIBC_DIR)/librt/kernel-posix-timers.h
	touch $(UCLIBC_DIR)/.unpacked

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.unpacked 
	$(MAKE) -C $(UCLIBC_DIR) defconfig;
	cp $(SOURCE_DIR)/uClibc.config-$(MACHINE) $(UCLIBC_DIR)/.config
	cp $(SOURCE_DIR)/locales.txt $(UCLIBC_DIR)/extra/locale
	cp $(SOURCE_DIR)/codesets.txt $(UCLIBC_DIR)/extra/locale
	$(MAKE) -C $(UCLIBC_DIR) PREFIX=$(STAGING_DIR) headers;
	(cd $(UCLIBC_DIR)/extra/locale; \
               patch -Np0 < /usr/src/src/patches/uClibc-gen_wctype-segfault.patch; \
		$(MAKE); \
	)
	$(MAKE) -C $(UCLIBC_DIR) PREFIX=$(STAGING_DIR) install_dev;
	rm -rf $(STAGING_DIR)/include
	ln -s $(STAGING_DIR)/usr/include $(STAGING_DIR)/include
	touch $(UCLIBC_DIR)/.configured

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured $(LIBFLOAT_TARGET)
	$(SED) 's,^CROSS=.*,CROSS=$(TARGET_CROSS),g' $(UCLIBC_DIR)/Rules.mak
	$(MAKE) -C $(UCLIBC_DIR) oldconfig
	$(MAKE) -C $(UCLIBC_DIR) headers
	-$(MAKE) -C $(UCLIBC_DIR) pregen
	(cd $(UCLIBC_DIR)/extra/locale; \
               patch -Np0 < /usr/src/src/patches/uClibc-gen_wctype-segfault.patch; \
		$(MAKE); \
	)
	$(MAKE) -C $(UCLIBC_DIR)

$(STAGING_DIR)/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	$(MAKE) -C $(UCLIBC_DIR) PREFIX=$(STAGING_DIR) install_dev install_runtime
	$(MAKE) -C $(UCLIBC_DIR) PREFIX=$(STAGING_DIR) utils install_utils
	# Clean up the host compiled utils...
	$(MAKE) -C $(UCLIBC_DIR)/utils clean
	(cd $(STAGING_DIR)/lib; \
		ln -fs libc.so.0 libc.so; \
		ln -fs libdl.so.0 libdl.so; \
		ln -fs libcrypt.so.0 libcrypt.so; \
		ln -fs libresolv.so.0 libresolv.so; \
		ln -fs libutil.so.0 libutil.so; \
		ln -fs libm.so.0 libm.so; \
		ln -fs libpthread.so.0 libpthread.so; \
		ln -fs libnsl.so.0 libnsl.so; \
		ln -fs libthread_db.so.1 libthread_db.so; \
	)

ifneq ($(TARGET_DIR),)
$(TARGET_DIR)/lib/libc.so.0: $(STAGING_DIR)/lib/libc.a
	$(MAKE) -C $(UCLIBC_DIR) PREFIX=$(TARGET_DIR) install_runtime

$(TARGET_DIR)/usr/bin/ldd: $(TARGET_DIR)/lib/libc.so.0
	$(MAKE) -C $(UCLIBC_DIR) $(TARGET_CONFIGURE_OPTS) \
		PREFIX=$(TARGET_DIR) utils install_utils

UCLIBC_TARGETS=$(TARGET_DIR)/lib/libc.so.0 $(TARGET_DIR)/usr/bin/ldd
endif

uclibc-configured: $(UCLIBC_DIR)/.configured

uclibc: $(STAGING_DIR)/bin/$(ARCH)-linux-uclibc-gcc $(STAGING_DIR)/lib/libc.a \
	$(UCLIBC_TARGETS)

uclibc-source: $(DL_DIR)/$(UCLIBC_SOURCE)

uclibc-configured-source: uclibc-source

uclibc-clean:
	-$(MAKE) -C $(UCLIBC_DIR) clean
	rm -f $(UCLIBC_DIR)/.config

uclibc-dirclean:
	rm -rf $(UCLIBC_DIR)




#############################################################
#
# uClibc for the target just needs its header files
# and whatnot installed.
#
#############################################################

$(TARGET_DIR)/usr/lib/libc.a: $(STAGING_DIR)/lib/libc.a
	$(MAKE) -C $(UCLIBC_DIR) $(TARGET_CONFIGURE_OPTS) \
		PREFIX=$(TARGET_DIR) install_dev
	(cd $(TARGET_DIR)/usr/lib; \
		ln -fs /lib/libc.so.0 libc.so; \
		ln -fs /lib/libdl.so.0 libdl.so; \
		ln -fs /lib/libcrypt.so.0 libcrypt.so; \
		ln -fs /lib/libresolv.so.0 libresolv.so; \
		ln -fs /lib/libutil.so.0 libutil.so; \
		ln -fs /lib/libm.so.0 libm.so; \
		ln -fs /lib/libpthread.so.0 libpthread.so; \
		ln -fs /lib/libnsl.so.0 libnsl.so; \
		ln -fs /lib/libthread_db.so.1 libthread_db.so; \
	)

ifeq ($(GCC_2_95_TOOLCHAIN),true)
uclibc_target: gcc2_95 uclibc $(TARGET_DIR)/usr/lib/libc.a
else
uclibc_target: gcc3_3 uclibc $(TARGET_DIR)/usr/lib/libc.a
endif

uclibc_target-clean:
	rm -f $(TARGET_DIR)/include

uclibc_target-dirclean:
	rm -f $(TARGET_DIR)/include


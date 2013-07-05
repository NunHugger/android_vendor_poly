PRODUCT_BRAND ?= polycule

-include vendor/poly-priv/keys.mk
SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.cyanogenmod.superuser

# To deal with CM9 specifications
# TODO: remove once all devices have been switched
ifneq ($(TARGET_BOOTANIMATION_NAME),)
TARGET_SCREEN_DIMENSIONS := $(subst -, $(space), $(subst x, $(space), $(TARGET_BOOTANIMATION_NAME)))
ifeq ($(TARGET_SCREEN_WIDTH),)
TARGET_SCREEN_WIDTH := $(word 2, $(TARGET_SCREEN_DIMENSIONS))
endif
ifeq ($(TARGET_SCREEN_HEIGHT),)
TARGET_SCREEN_HEIGHT := $(word 3, $(TARGET_SCREEN_DIMENSIONS))
endif
endif

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# clear TARGET_BOOTANIMATION_NAME in case it was set for CM9 purposes
TARGET_BOOTANIMATION_NAME :=

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/poly/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif


PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.google.clientidbase=android-google \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/poly/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/poly/prebuilt/common/bin/50-poly.sh:system/addon.d/50-poly.sh \
    vendor/poly/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# init.d support
PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/poly/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/etc/init.local.rc:root/init.poly.rc

# Compcache/Zram support
PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/bin/compcache:system/bin/compcache \
    vendor/poly/prebuilt/common/bin/handle_compcache:system/bin/handle_compcache

# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/poly/proprietary/Term.apk:system/app/Term.apk \
    vendor/poly/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/poly/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/poly/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/poly/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/poly/prebuilt/common/etc/mkshrc:system/etc/mkshrc

# T-Mobile theme engine
include vendor/poly/config/themes_common.mk

# packages
PRODUCT_PACKAGES += \
    Camera \
    Development \
    LatinIME \
    Superuser \
    su

# Optional CM packages
PRODUCT_PACKAGES += \
    VideoEditor \
    VoiceDialer \
    SoundRecorder \
    Basic

# Custom CM packages
PRODUCT_PACKAGES += \
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    CMWallpapers \
    Apollo \
    CMUpdater \
    CMFileManager \
    LockClock
	
# Custom Poly packages
PRODUCT_PACKAGES += \
	PolyPapers

PRODUCT_PACKAGES += \
    CellBroadcastReceiver

# Extra tools in CM
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    vim \
    nano \
    htop \
    powertop \
    lsof

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

PRODUCT_PACKAGE_OVERLAYS += vendor/poly/overlay/dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/poly/overlay/common

# version
RELEASE = false
POLY_VERSION_MAJOR = 1
POLY_VERSION_MINOR = 8

#Set POLY_BUILDTYPE 
ifdef POLY_NIGHTLY
    POLY_BUILDTYPE := NIGHTLY
endif
ifdef POLY_EXPERIMENTAL
    POLY_BUILDTYPE := EXPERIMENTAL
endif
ifdef POLY_RELEASE
    POLY_BUILDTYPE := RELEASE
endif
#Set Unofficial if no buildtype set (Buildtype should ONLY be set by Poly Devs!)
ifdef POLY_BUILDTYPE
else
    POLY_BUILDTYPE := UNOFFICIAL
    POLY_VERSION_MAJOR :=
    POLY_VERSION_MINOR :=
endif

#Set Poly version
ifdef POLY_RELEASE
    POLY_VERSION := "POLYCULER-v"$(POLY_VERSION_MAJOR).$(POLY_VERSION_MINOR)
else
    POLY_VERSION := "POLY--$(POLY_BUILD)-$(POLY_BUILDTYPE)"-$(shell date +%Y%m%d-%H%M)
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.poly.version=$(POLY_VERSION)

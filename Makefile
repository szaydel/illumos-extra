#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2022, Joyent, Inc.
#

#
# To build everything just run 'gmake' in this directory.
#

include $(CURDIR)/../../build.env

BASE =		$(CURDIR)
DESTDIR =	$(BASE)/proto

#
# This contains items that we only build during the strap build itself.
#
STRAP_ONLY = \
	idnkit

ifeq ($(STRAP),strap)

STRAPPROTO =	$(DESTDIR)

COMMA=,
EXTRA_COMPILERS = $(subst $(COMMA), , $(SHADOW_COMPILERS))

SUBDIRS = \
	cpp \
	bzip2 \
	libexpat \
	libidn \
	libxml \
	libz \
	node.js \
	nss-nspr \
	openssl1x \
	openssl3 \
	perl \
	$(EXTRA_COMPILERS) \
	$(STRAP_ONLY)

STRAPFIX +=	$(PRIMARY_COMPILER) $(EXTRA_COMPILERS)
STRAPFIX_SUBDIRS=$(STRAPFIX:%=%.strapfix)

else

STRAPPROTO =	$(DESTDIR:proto=proto.strap)

SUBDIRS = \
	bash \
	bind \
	bzip2 \
	coreutils \
	cpp \
	curl \
	dialog \
	gnupg \
	gtar \
	gzip \
	ipmitool \
	less \
	libexpat \
	libidn \
	libidn2 \
	libxml \
	libz \
	mdb_v8 \
	ncurses \
	node.js \
	nss-nspr \
	ntp \
	openldap \
	openlldp \
	openssl1x \
	openssl3 \
	openssh \
	pbzip2 \
	perl \
	rsync \
	rsyslog \
	screen \
	socat \
	tun \
	uuid \
	vim \
	wget \
	xz

STRAPFIX_SUBDIRS =

endif

PATH =		$(STRAPPROTO)/usr/bin:/usr/bin:/usr/sbin:/sbin:/opt/local/bin

NAME =	illumos-extra

AWK =		$(shell (which gawk 2>/dev/null | grep -v "^no ") || which awk)
BRANCH =	$(shell git symbolic-ref HEAD | $(AWK) -F/ '{print $$3}')

ifeq ($(TIMESTAMP),)
  TIMESTAMP =	$(shell date -u "+%Y%m%dT%H%M%SZ")
endif

GITDESCRIBE = \
	g$(shell git describe --all --long | $(AWK) -F'-g' '{print $$NF}')

TARBALL =	$(NAME)-$(BRANCH)-$(TIMESTAMP)-$(GITDESCRIBE).tgz

LIBSTDCXXVER_4 = 6.0.13
LIBSTDCXXVER_6 = 6.0.22
LIBSTDCXXVER_7 = 6.0.24
LIBSTDCXXVER_9 = 6.0.28
LIBSTDCXXVER_10 = 6.0.28
LIBSTDCXXVER_14 = 6.0.33

all: $(SUBDIRS)

strap: $(SUBDIRS)

curl: libz openssl3 libidn2
gzip: libz
node.js: libz openssl1x
dialog: ncurses
socat: openssl3
wget: openssl3 libidn
openldap: openssl3
ntp: perl openssl3
openssh: openssl3

#
# pkg-config may be installed. This will actually only hurt us rather than help
# us. pkg-config is based as a part of the pkgsrc packages and will pull in
# versions of libraries that we have in /opt/local rather than using the ones in
# /usr that we want. PKG_CONFIG_LIBDIR controls the actual path. This
# environment variable nulls out the search path. Other vars just control what
# gets appended.
#


$(DESTDIR)/usr/gnu/bin/gas: FRC
	(cd binutils && \
	    PKG_CONFIG_LIBDIR="" \
	    STRAP=$(STRAP) \
	    $(MAKE) DESTDIR=$(DESTDIR) install)

#
# gcc lives in a different prefix when building the bootstrap, but not
# gas.
#
ifeq ($(STRAP),strap)

$(DESTDIR)/usr/gcc/$(PRIMARY_COMPILER_VER)/bin/gcc: $(DESTDIR)/usr/gnu/bin/gas
	@echo "========== building $@ =========="
	(cd $(PRIMARY_COMPILER) && \
	    PKG_CONFIG_LIBDIR="" \
	    STRAP=$(STRAP) \
	    $(MAKE) DESTDIR=$(DESTDIR) install strapfix)

$(SUBDIRS): $(DESTDIR)/usr/gcc/$(PRIMARY_COMPILER_VER)/bin/gcc
	@echo "========== strap building $@ =========="
	(cd $@ && \
	    PKG_CONFIG_LIBDIR="" \
	    STRAP=$(STRAP) \
	    CTFMERGE=$(CTFMERGE) \
	    CTFCONVERT=$(CTFCONVERT) \
	    $(MAKE) DESTDIR=$(DESTDIR) install)

$(STRAPFIX_SUBDIRS): $(SUBDIRS)
	@echo "========== strapfix building $@ =========="
	(cd $$(basename $@ .strapfix) && \
	    PKG_CONFIG_LIBDIR="" \
	    STRAP=$(STRAP) \
	    PRIMARY_COMPILER=$(PRIMARY_COMPILER) \
	    $(MAKE) DESTDIR=$(DESTDIR) strapfix)

fixup_strap: $(STRAPFIX_SUBDIRS)

install_strap: binutils $(PRIMARY_COMPILER) $(SUBDIRS) fixup_strap

else

#
# For the non-strap build, we just need the runtime libraries to be in place in
# the proto dir.
#
$(PRIMARY_COMPILER):
	@echo "========== building $@ =========="
	(cd $(PRIMARY_COMPILER) && \
	    PKG_CONFIG_LIBDIR="" \
	    STRAP=$(STRAP) \
	    $(MAKE) DESTDIR=$(DESTDIR) fixup)

$(SUBDIRS): $(PRIMARY_COMPILER)
	@echo "========== building $@ =========="
	(cd $@ && \
	    PKG_CONFIG_LIBDIR="" \
	    STRAP=$(STRAP) \
	    CTFMERGE=$(CTFMERGE) \
	    CTFCONVERT=$(CTFCONVERT) \
	    $(MAKE) DESTDIR=$(DESTDIR) install)

install: $(PRIMARY_COMPILER) $(SUBDIRS)

endif

clean:
	-for dir in $(PRIMARY_COMPILER) $(SUBDIRS) $(STRAP_ONLY) binutils; \
	    do (cd $$dir; $(MAKE) DESTDIR=$(DESTDIR) clean); done
	-rm -rf proto

manifest:
	sed 's/$$LIBSTDCXXVER/$(LIBSTDCXXVER_$(PRIMARY_COMPILER_VER))/g' \
	    manifest >$(DESTDIR)/$(DESTNAME)

mancheck_conf:
	cp mancheck.conf $(DESTDIR)/$(DESTNAME)

tarball:
	tar -zcf $(TARBALL) manifest proto

FRC:

.PHONY: $(PRIMARY_COMPILER) $(SUBDIRS) binutils manifest mancheck_conf

#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at COPYING
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at COPYING.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
# Copyright (c) 2015 Joyent, Inc.  All rights reserved.
#

VER =	bind-9.10.1-P1

include ../Makefile.defs

AUTOCONF_OPTS += \
	--with-libxml2=no \
	--with-libjson=no \
	--without-openssl

CFLAGS +=	-g $(CPPFLAGS)
PARALLEL =

PATCHES += Patches/*

AUTOCONF_ENV += \
	INSTALL="/usr/ucb/install -c" \

OVERRIDES += \
	INSTALL="/usr/ucb/install -c"

include ../Makefile.targ

all: all_autoconf

install: all
	DESTDIR=$(DESTDIR) VERS=$(VER.32) /bin/bash ./install-joyent

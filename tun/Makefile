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
# Copyright 2019 Joyent, Inc.
#

VER = tun-1.3

include ../Makefile.defs

PATCHES = Patches/*

BUILD32 =
BUILD64 = yes

include ../Makefile.targ

all: all_autoconf

install: all
	mkdir -p $(DESTDIR)/usr/include/net
	mkdir -p $(DESTDIR)/usr/kernel/drv/amd64
	cp $(BASE)/$(VER.64)/if_tun.h $(DESTDIR)/usr/include/net
	cp $(BASE)/$(VER.64)/tap.conf $(DESTDIR)/usr/kernel/drv
	cp $(BASE)/$(VER.64)/tun.conf $(DESTDIR)/usr/kernel/drv
	cp $(BASE)/$(VER.64)/tap $(DESTDIR)/usr/kernel/drv/amd64
	cp $(BASE)/$(VER.64)/tun $(DESTDIR)/usr/kernel/drv/amd64

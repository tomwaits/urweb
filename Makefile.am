ACLOCAL_AMFLAGS = -I m4

BIN       = @BIN@
SRCLIB    = @SRCLIB@
INCLUDE   = @INCLUDE@
SITELISP  = @SITELISP@
VERSION   = @VERSION@
MLTON     = @MLTON@
MLLEX     = @MLLEX@
MLYACC    = @MLYACC@
MLTONARGS = @MLTONARGS@

LIB_UR   = $(SRCLIB)/ur
LIB_C    = $(SRCLIB)/c
LIB_JS   = $(SRCLIB)/js

all-local: smlnj mlton

SUBDIRS = src/c

.PHONY: smlnj mlton mlton-tc test check-local

smlnj: src/urweb.cm xml/entities.sml
mlton: bin/urweb
mlton-tc: bin/urwebtc

clean-local:
	rm -f bin/urweb bin/urwebtc compiler.du src/urweb.mlton.* \
		src/urweb.cm src/urweb.mlb xml/parse xml/entities.sml \
		mlb-path-map
	rm -f demo/demo.exe demo/demo.sql
	rm -f tests/dce.exe tests/dce.out tests/cookiehttponly.exe tests/jsonsurrogate.exe tests/respstatus.exe tests/notfound.exe tests/hdrtok.exe tests/hdrbad.exe tests/pkeyorder.exe tests/pkeyorder.sql tests/pgtest.exe tests/pgtest.sql
	rm -rf .cm src/.cm

src/urweb.cm: src/prefix.cm src/sources
	cat $^ | sed -e 's/$$(SRC)\///g' > $@

src/urweb.mlb: src/prefix.mlb src/sources src/suffix.mlb
	sed -e 's/^\(.*\).grm$$/$$(BUILD)\/\1.mlton.grm.sig:\1.mlton.grm.sml/' -e 'y/:/\n/' \
		-e 's/^\(.*\).lex$$/$$(BUILD)\/\1.mlton.lex.sml/' \
	$^ > $@

src/urweb.mlton.lex: src/urweb.lex
	cp $< $@
src/urweb.mlton.grm: src/urweb.grm
	cp $< $@

src/urweb.mlton.lex.sml: src/urweb.mlton.lex
	$(MLLEX) $<

src/urweb.mlton.grm.sig src/urweb.mlton.grm.sml: src/urweb.mlton.grm
	$(MLYACC) $<

#ifdef DEBUG
#	MLTON += -const 'Exn.keepHistory true'
#endif

#ifdef PROFILE
#	MLTON += -profile $(PROFILE)
#endif

mlb-path-map: Makefile
	echo SRC $(abs_srcdir)/src > $@
	echo BUILD $(abs_builddir)/src >> $@

bin/urweb: src/compiler.mlb xml/entities.sml \
		src/urweb.mlb $(srcdir)/src/*.sig $(srcdir)/src/*.sml src/config.sml \
		src/urweb.mlton.lex.sml \
		src/urweb.mlton.grm.sig src/urweb.mlton.grm.sml \
		mlb-path-map
	mkdir -p bin
	$(MLTON) $(MLTONARGS) -mlb-path-map mlb-path-map -output $@ $<

bin/urwebtc: src/compiler.mlb xml/entities.sml \
		src/urweb.mlb $(srcdir)/src/*.sig $(srcdir)/src/*.sml src/config.sml \
		src/urweb.mlton.lex.sml \
		src/urweb.mlton.grm.sig src/urweb.mlton.grm.sml \
		mlb-path-map
	mkdir -p bin
	$(MLTON) $(MLTONARGS) -prefer-abs-paths true -show-def-use compiler.du -stop tc -mlb-path-map mlb-path-map -output $@ $<

xml/entities.sml: xml/parse xml/xhtml-lat1.ent xml/xhtml-special.ent xml/xhtml-symbol.ent
	$^ > $@

xml/parse: xml/parse.sml
	mkdir -p xml
	$(MLTON) $(MLTONARGS) -output $@ $<

install-exec-emacs:
if USE_EMACS
	mkdir -p $(DESTDIR)$(SITELISP)
	cp $(srcdir)/src/elisp/*.el $(DESTDIR)$(SITELISP)/
endif

install-exec-local-main:
	mkdir -p $(DESTDIR)$(BIN)
	install bin/urweb $(DESTDIR)$(BIN)/
	mkdir -p $(DESTDIR)$(LIB_UR)
	cp $(srcdir)/lib/ur/*.urs $(DESTDIR)$(LIB_UR)/
	cp $(srcdir)/lib/ur/*.ur $(DESTDIR)$(LIB_UR)/
	mkdir -p $(DESTDIR)$(LIB_JS)
	cp $(srcdir)/lib/js/*.js $(DESTDIR)$(LIB_JS)/
	mkdir -p $(DESTDIR)$(INCLUDE)
	cp $(srcdir)/include/urweb/*.h $(DESTDIR)$(INCLUDE)/

install-exec-local: install-exec-local-main install-exec-emacs
	-ldconfig

uninstall-emacs:
if USE_EMACS
	rm -f $(DESTDIR)$(SITELISP)/urweb-compat.el $(DESTDIR)$(SITELISP)/urweb-mode.el $(DESTDIR)$(SITELISP)/urweb-move.el \
		$(DESTDIR)$(SITELISP)/urweb-defs.el $(DESTDIR)$(SITELISP)/urweb-mode-startup.el $(DESTDIR)$(SITELISP)/urweb-util.el
endif

uninstall-local-main:
	rm -f $(DESTDIR)$(BIN)/urweb $(DESTDIR)$(LIB_UR)/basis.urs $(DESTDIR)$(LIB_UR)/char.urs $(DESTDIR)$(LIB_UR)/datetime.urs		\
		$(DESTDIR)$(LIB_UR)/listPair.urs $(DESTDIR)$(LIB_UR)/list.urs $(DESTDIR)$(LIB_UR)/monad.urs					\
		$(DESTDIR)$(LIB_UR)/option.urs $(DESTDIR)$(LIB_UR)/string.urs $(DESTDIR)$(LIB_UR)/top.urs $(DESTDIR)$(LIB_UR)/char.ur		\
		$(DESTDIR)$(LIB_UR)/datetime.ur $(DESTDIR)$(LIB_UR)/listPair.ur $(DESTDIR)$(LIB_UR)/list.ur $(DESTDIR)$(LIB_UR)/monad.ur	\
		$(DESTDIR)$(LIB_UR)/option.ur $(DESTDIR)$(LIB_UR)/string.ur $(DESTDIR)$(LIB_UR)/top.ur $(DESTDIR)$(LIB_JS)/urweb.js		\
		$(DESTDIR)$(INCLUDE)/config.h $(DESTDIR)$(INCLUDE)/queue.h $(DESTDIR)$(INCLUDE)/request.h $(DESTDIR)$(INCLUDE)/types.h		\
		$(DESTDIR)$(INCLUDE)/urweb.h $(DESTDIR)$(INCLUDE)/types_cpp.h $(DESTDIR)$(INCLUDE)/urweb_cpp.h

uninstall-local: uninstall-local-main uninstall-emacs

EXTRA_DIST = demo/prose demo/*.urs demo/*.ur demo/*.urp demo/more/prose demo/more/*.urs demo/more/*.ur demo/more/*.urp \
	doc/Makefile doc/*.tex doc/*.ur doc/LICENSE lib/js \
	lib/ur/*.urs lib/ur/*.ur xml/parse.sml xml/*.ent \
	src/coq src/*.sig src/*.sml src/*.mlb src/config.sml.in src/elisp src/*.cm src/sources src/*.grm src/*.lex \
	CHANGELOG LICENSE urweb.ebuild include/urweb/*.h tests/*.html tests/*.ur tests/*.urp

dist-hook:
	cd src; rm -f urweb.mlton.lex urweb.mlton.grm *.lex.* *.grm.*
	cd demo; rm -f demo.ur*
	cd demo/more; rm -f demo.ur*

TESTDB = /tmp/urweb.db
TESTPID = /tmp/urweb.pid

# demo/demo.exe is produced by compiling the bundled demo with the
# freshly built compiler. It genuinely depends on bin/urweb and, because
# -boot makes the demo link against the in-tree C runtime, on the
# src/c libraries. The original rule declared neither, so `make test`
# from a clean tree failed and parallel builds were racy. bin/urweb is a
# real target here; the src/c sub-make orders this after the SUBDIRS
# libraries (a no-op when they are already current).
demo/demo.exe: bin/urweb
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -dbms sqlite -db $(TESTDB) -demo /Demo demo

tests/dce.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs tests/dce

tests/cookiehttponly.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs tests/cookiehttponly

tests/jsonsurrogate.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs tests/jsonsurrogate

tests/respstatus.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs tests/respstatus

tests/notfound.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs tests/notfound

# Wire the custom test target into automake's standard `make check`.
check-local: test

QUERY_FIXTURES = qguard agg

test: demo/demo.exe tests/dce.exe tests/cookiehttponly.exe tests/jsonsurrogate.exe tests/respstatus.exe tests/notfound.exe
	@echo ""
	@echo "=== make test: fixtures built; running checks (each announced below; the slow part was the full demo compile above) ==="
	@echo "==> [tc 1/6] sigfk        (signature-level FK disjointness, #267)"
	bin/urweb -tc -boot -noEmacs tests/sigfk || (echo "Test 'sigfk' failed: a PK table and an FK table referencing it, both in an ascribed signature, did not typecheck (urweb/urweb#267)"; false)
	@echo "==> [tc 2/6] blockquote   (the blockquote HTML tag, #259)"
	bin/urweb -tc -boot -noEmacs tests/blockquote || (echo "Test 'blockquote' failed: the blockquote tag did not typecheck (urweb/urweb#259)"; false)
	@echo "==> [tc 3/6] inputattrs   (input validation attributes, #275)"
	bin/urweb -tc -boot -noEmacs tests/inputattrs || (echo "Test 'inputattrs' failed: input validation attributes (Pattern/Minlength/Maxlength/Autocomplete/Readonly/Disabled) did not typecheck (urweb/urweb#275)"; false)
	@echo "==> [tc 4/6] arrowguard   (-> accepted in guarded types, #197)"
	bin/urweb -tc -boot -noEmacs tests/arrowguard || (echo "Test 'arrowguard' failed: a guarded type written with -> instead of => did not typecheck (urweb/urweb#197)"; false)
	@# PR#279: a cookie set with HttpOnly = True must emit `httponly` in the
	@# Set-Cookie response header.
	@echo "==> [http 1/4] cookiehttponly (Set-Cookie HttpOnly flag, PR#279) — serving on :8083"
	tests/cookiehttponly.exe -q -a 127.0.0.1 -p 8083 & echo $$! > $(TESTPID)
	sleep 1
	(curl -si 'http://localhost:8083/Cookiehttponly/main' | grep -i '^set-cookie:' | grep -qi 'httponly') || (kill `cat $(TESTPID)`; echo "Test 'cookiehttponly' failed: Set-Cookie header missing 'httponly' (PR#279)"; false)
	kill `cat $(TESTPID)`
	@# urweb/urweb#211: a UTF-16 surrogate PAIR (😀 = U+1F600) must decode to
	@# ONE scalar value / 4 UTF-8 bytes (F0 9F 98 80). Before the fix the pair
	@# was decoded as two lone surrogates, which the runtime drops (U8_LENGTH is
	@# 0 for surrogate code points) -> an empty string. The fixture decodes a
	@# RUNTIME-built JSON string on purpose (a compile-time literal would hit a
	@# separate constant-folding bug for astral chars); its strlen/strlenUtf8
	@# self-check emits SURROGATE_PAIR_OK, and we also byte-check for F0 9F 98 80.
	@echo "==> [http 2/4] jsonsurrogate (UTF-16 surrogate-pair decode, #211) — serving on :8084"
	tests/jsonsurrogate.exe -q -a 127.0.0.1 -p 8084 & echo $$! > $(TESTPID)
	sleep 2
	(curl -s 'http://localhost:8084/Jsonsurrogate/main' | grep -q 'SURROGATE_PAIR_OK') || (kill `cat $(TESTPID)`; echo "Test 'jsonsurrogate' failed: surrogate pair did not decode to one U+1F600 scalar value (strlen/strlenUtf8 self-check) -- urweb/urweb#211"; false)
	(curl -s 'http://localhost:8084/Jsonsurrogate/main' | od -An -tx1 | tr -d ' \n' | grep -q 'f09f9880') || (kill `cat $(TESTPID)`; echo "Test 'jsonsurrogate' failed: response missing U+1F600 UTF-8 bytes F0 9F 98 80 -- urweb/urweb#211"; false)
	kill `cat $(TESTPID)`
	@# urweb/urweb#222: Basis.setResponseStatus must set the HTTP status line.
	@# The standalone server writes a real status line (uw_supports_direct_status
	@# = 1), so curl -si shows it verbatim. Two handlers set two different codes
	@# (404, 429) so the check proves the emitted status tracks the argument, not
	@# a hardcoded value. -i so the status line is in curl's output.
	@echo "==> [http 3/4] respstatus (setResponseStatus 404/429, #222) — serving on :8085"
	tests/respstatus.exe -q -a 127.0.0.1 -p 8085 & echo $$! > $(TESTPID)
	sleep 1
	(curl -si 'http://localhost:8085/Respstatus/notFound' | grep -qiE '^HTTP/[0-9.]+ 404( |$$)') || (kill `cat $(TESTPID)`; echo "Test 'respstatus' failed: setResponseStatus 404 did not set the status line to 404 (urweb/urweb#222)"; false)
	(curl -si 'http://localhost:8085/Respstatus/tooMany' | grep -qiE '^HTTP/[0-9.]+ 429( |$$)') || (kill `cat $(TESTPID)`; echo "Test 'respstatus' failed: setResponseStatus 429 did not set the status line to 429 (urweb/urweb#222)"; false)
	kill `cat $(TESTPID)`
	@# urweb/urweb#39: the `notFoundPage` .urp directive names a FILE whose HTML
	@# is served for URLs that match no page. A request to a nonexistent path
	@# must return 404 with that custom HTML (NOTFOUND_CUSTOM_BODY) as text/html,
	@# not the default plain "Not Found". Reading from a file (not the .urp line)
	@# also preserves '#' (colors/anchors) that the .urp comment stripper would
	@# truncate -- asserted via the '#top' anchor. /Notfound/main exists;
	@# /Notfound/nope does not.
	@echo "==> [http 4/4] notfound (custom 404 notFoundPage, #39) — serving on :8086"
	tests/notfound.exe -q -a 127.0.0.1 -p 8086 & echo $$! > $(TESTPID)
	sleep 1
	(curl -si 'http://localhost:8086/Notfound/nope' | grep -qiE '^HTTP/[0-9.]+ 404( |$$)') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: an unmatched URL did not return a 404 status line (urweb/urweb#39)"; false)
	(curl -s 'http://localhost:8086/Notfound/nope' | grep -q 'NOTFOUND_CUSTOM_BODY') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: the custom notFoundPage body was not served on a 404 (urweb/urweb#39)"; false)
	(curl -si 'http://localhost:8086/Notfound/nope' | grep -qi '^content-type:.*text/html') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: custom 404 not served as text/html (urweb/urweb#39)"; false)
	(curl -s 'http://localhost:8086/Notfound/nope' | grep -qF '#top') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: '#' in the custom page was lost (notFoundPage must read from a file, not the .urp line) (urweb/urweb#39)"; false)
	kill `cat $(TESTPID)`
	@# Query-DSL regression guard: typecheck fixtures exercising the SQL type
	@# layer (sql_query / sql_order_by / aggregates), which no CI step covered
	@# before. qguard spans plain SELECT + WHERE + ORDER BY (multiple, ASC/DESC,
	@# by AS-alias), aggregates, GROUP BY (+ ORDER BY a grouped column), comma
	@# join, UNION and LIMIT/OFFSET; agg adds the aggregate functions. -tc
	@# suffices: the layer's main regression risk is type-level. (This net is a
	@# prerequisite for the #269 fix.)
	@for t in $(QUERY_FIXTURES); do \
	  echo "==> typecheck query fixture: tests/$$t"; \
	  bin/urweb -tc -boot -noEmacs tests/$$t \
	    || { echo "Query fixture '$$t' failed to typecheck -- SQL-DSL regression guard"; exit 1; }; \
	done
	@# Composite-key column-order guard (urweb/urweb#228/#261): a multi-column
	@# PRIMARY KEY / UNIQUE must emit its columns in DECLARED order. pkeyorder's
	@# key orders (Bb,Aa)/(Cc,Aa)/(Cc,Bb,Aa) differ from any alphabetical
	@# reordering, so the order is observable in the generated Postgres DDL. All
	@# whitespace is squeezed to single spaces so the column-order check is
	@# layout-independent (the pretty-printer may break a wide clause across
	@# lines). NB: #261's other half -- MySQL's `(255)` length prefix using each
	@# column's own type -- is fixed in code but NOT exercised here (the nix
	@# build has no mysql backend; textKeysNeedLengths is false for postgres).
	@echo "==> [sql] pkeyorder      (composite-key column order in emitted DDL, #228/#261)"
	@rm -f tests/pkeyorder.sql
	bin/urweb -boot -noEmacs -dbms postgres -sql tests/pkeyorder.sql tests/pkeyorder \
	  || { echo "Test 'pkeyorder' failed to compile"; false; }
	@echo "--- emitted key DDL (pkeyorder) ---"; grep -iE 'PRIMARY KEY|UNIQUE' tests/pkeyorder.sql || true
	@flat=`tr -s '[:space:]' ' ' < tests/pkeyorder.sql`; \
	echo "$$flat" | grep -iqE 'PRIMARY KEY[^)]*bb[^)]*aa' \
	  || { echo "Test 'pkeyorder' failed: PRIMARY KEY columns not in declared order (Bb, Aa) -- urweb/urweb#228"; false; }; \
	echo "$$flat" | grep -iqE 'UNIQUE[^)]*cc[^)]*aa' \
	  || { echo "Test 'pkeyorder' failed: UNIQUE columns not in declared order (Cc, Aa) -- urweb/urweb#228"; false; }; \
	echo "$$flat" | grep -iqE 'UNIQUE[^)]*cc[^)]*bb[^)]*aa' \
	  || { echo "Test 'pkeyorder' failed: 3-column UNIQUE not in declared order (Cc, Bb, Aa) -- urweb/urweb#228 (source order not preserved for 3+ columns)"; false; }
	@# The header-name charset check runs in mono_opt, which a full -boot
	@# compile reaches. For hdrbad (a name that must be REJECTED) the verdict is
	@# whether the charset error ("Invalid string ... passed to 'bless*Header'")
	@# appears, NOT the exit code -- the rejected compile never links. For
	@# hdrtok (a name that must be ACCEPTED) we require BOTH the absence of that
	@# error AND a produced executable, so an unrelated compile failure can't
	@# make it pass vacuously. The wildcard allow-rules in the .urp files make
	@# the rule-list half of the check always pass, isolating the character
	@# check as the only possible source of that error. See urweb/urweb#271.
	@echo "==> [charset] hdrbad/hdrtok (RFC 7230 header-name charset, #271)"
	@out=`bin/urweb -boot -noEmacs tests/hdrbad 2>&1`; \
	echo "$$out" | grep -q "Invalid string" \
	  || { echo "Test 'hdrbad' failed: blessRequestHeader accepted a name containing '/' (urweb/urweb#271). Compiler output:"; echo "$$out"; false; }
	@rm -f tests/hdrtok.exe; out=`bin/urweb -boot -noEmacs tests/hdrtok 2>&1`; \
	if echo "$$out" | grep -q "Invalid string"; then \
	  echo "Test 'hdrtok' failed: a valid RFC 7230 header-name character ('_') was rejected (urweb/urweb#271). Compiler output:"; echo "$$out"; false; \
	elif test ! -x tests/hdrtok.exe; then \
	  echo "Test 'hdrtok' failed: did not compile to an executable, so '_' acceptance was not exercised (urweb/urweb#271). Compiler output:"; echo "$$out"; false; \
	fi
	@echo "==> [demo] golden-output pages (Hello + Crud1 vs recorded HTML)"
	rm -f $(TESTDB)
	sqlite3 $(TESTDB) < demo/demo.sql
	demo/demo.exe -q -a 127.0.0.1 & echo $$! > $(TESTPID)
	sleep 1
	(curl -s 'http://localhost:8080/Demo/Hello/main' | diff tests/hello.html -) || (kill `cat $(TESTPID)`; echo "Test 'Hello' failed"; /bin/false)
	(curl -s 'http://localhost:8080/Demo/Crud1/create?A=1&B=2&C=3&D=4' | diff tests/crud1.html -) || (kill `cat $(TESTPID)`; echo "Test 'Crud1' failed"; /bin/false)
	kill `cat $(TESTPID)`
	@echo "==> [dce] dead-abort-call elimination guard (#221) — serving on :8081"
	tests/dce.exe -q -a 127.0.0.1 -p 8081 & echo $$! > $(TESTPID)
	sleep 1
	(curl -s 'http://localhost:8081/Dce/main' > tests/dce.out && grep -q 'Do not eliminate me' tests/dce.out && ! grep -q 'Hello, DCE!' tests/dce.out) || (kill `cat $(TESTPID)`; echo "Test 'dce' failed: branch-selected error call was eliminated (urweb/urweb#221)"; false)
	kill `cat $(TESTPID)`
	if (ifconfig lo | grep -q inet6); \
	then \
		echo "Running IPv6 tests."; \
		rm -f $(TESTDB); \
		sqlite3 $(TESTDB) < demo/demo.sql; \
		demo/demo.exe -q -A ::1 & echo $$! > $(TESTPID); \
		sleep 1; \
		(curl -g -6 -s 'http://[::1]:8080/Demo/Hello/main' | diff tests/hello.html -) || (kill `cat $(TESTPID)`; echo "Test 'Hello' failed"; /bin/false); \
		(curl -g -6 -s 'http://[::1]:8080/Demo/Crud1/create?A=1&B=2&C=3&D=4' | diff tests/crud1.html -) || (kill `cat $(TESTPID)`; echo "Test 'Crud1' failed"; /bin/false); \
		kill `cat $(TESTPID)`; \
	else \
		echo "Skipped IPv6 tests."; \
	fi
	@echo ""
	@echo "=== make test: ALL CHECKS PASSED ==="

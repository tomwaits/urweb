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
	rm -f tests/dce.exe tests/dce.out tests/cookiehttponly.exe tests/jsonsurrogate.exe tests/respstatus.exe tests/notfound.exe tests/daemon.exe tests/svgtag.exe tests/jsesc.exe tests/postcommit.exe tests/postcommitffi.o tests/postcommit.sql $(TESTPCDB) $(TESTDLOG) $(TESTDOUT) tests/hdrtok.exe tests/hdrbad.exe tests/pkeyorder.exe tests/pkeyorder.sql tests/pgtest.exe tests/pgtest.sql
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
TESTDLOG = /tmp/urweb.daemon.log
TESTDOUT = /tmp/urweb.daemon.out
TESTPCDB = /tmp/urweb.pc.db

# demo/demo.exe is produced by compiling the bundled demo with the
# freshly built compiler. It genuinely depends on bin/urweb and, because
# -boot makes the demo link against the in-tree C runtime, on the
# src/c libraries. The original rule declared neither, so `make test`
# from a clean tree failed and parallel builds were racy. bin/urweb is a
# real target here; the src/c sub-make orders this after the SUBDIRS
# libraries (a no-op when they are already current).
# Test binaries are compiled with -ccopt -O1: they exist only to answer a single
# request in the checks below, so gcc -O3 (which dominates each compile -- see the
# compile-speed measurement) is pure waste here, and -O1 is far cheaper. NB: -O0
# is NOT usable -- glibc's _FORTIFY_SOURCE (set by hardened build envs) emits a
# "requires compiling with optimization" #warning at -O0, which urweb's -Werror
# turns into an error; -O1 is the minimum that satisfies it. Behavioral
# correctness is optimization-level-independent.
demo/demo.exe: bin/urweb
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 -dbms sqlite -db $(TESTDB) -demo /Demo demo

tests/dce.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/dce

tests/cookiehttponly.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/cookiehttponly

tests/jsonsurrogate.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/jsonsurrogate

tests/respstatus.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/respstatus

tests/notfound.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/notfound

tests/daemon.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/daemon

tests/svgtag.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/svgtag

tests/jsesc.exe: bin/urweb | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 tests/jsesc

tests/postcommitffi.o: tests/postcommitffi.c tests/postcommitffi.h
	$(CC) -pthread -Wall -Werror -I $(srcdir)/include/urweb -c -o $@ $<

tests/postcommit.exe: bin/urweb tests/postcommitffi.o | demo/demo.exe
	cd src/c && $(MAKE) $(AM_MAKEFLAGS)
	bin/urweb -boot -noEmacs -ccopt -O1 -dbms sqlite -db $(TESTPCDB) -sql tests/postcommit.sql tests/postcommit

# Wire the custom test target into automake's standard `make check`.
check-local: test

QUERY_FIXTURES = qguard agg

test: demo/demo.exe tests/dce.exe tests/cookiehttponly.exe tests/jsonsurrogate.exe tests/respstatus.exe tests/notfound.exe tests/daemon.exe tests/svgtag.exe tests/jsesc.exe tests/postcommit.exe
	@echo ""
	@echo "=== make test: fixtures built; running checks (each announced below; the slow part was the full demo compile above) ==="
	@echo "==> [tc 1/8] sigfk        (signature-level FK disjointness, #267)"
	bin/urweb -tc -boot -noEmacs tests/sigfk || (echo "Test 'sigfk' failed: a PK table and an FK table referencing it, both in an ascribed signature, did not typecheck (urweb/urweb#267)"; false)
	@echo "==> [tc 2/8] blockquote   (the blockquote HTML tag, #259)"
	bin/urweb -tc -boot -noEmacs tests/blockquote || (echo "Test 'blockquote' failed: the blockquote tag did not typecheck (urweb/urweb#259)"; false)
	@echo "==> [tc 3/8] inputattrs   (input validation attributes, #275)"
	bin/urweb -tc -boot -noEmacs tests/inputattrs || (echo "Test 'inputattrs' failed: input validation attributes (Pattern/Minlength/Maxlength/Autocomplete/Readonly/Disabled) did not typecheck (urweb/urweb#275)"; false)
	@echo "==> [tc 4/8] arrowguard   (-> accepted in guarded types, #197)"
	bin/urweb -tc -boot -noEmacs tests/arrowguard || (echo "Test 'arrowguard' failed: a guarded type written with -> instead of => did not typecheck (urweb/urweb#197)"; false)
	@echo "==> [tc 5/8] deepunif     (#266 workarounds keep typechecking)"
	bin/urweb -tc -boot -noEmacs tests/deepunif || (echo "Test 'deepunif' failed: a documented #266 workaround (implicit recursive call / monomorphic inner helper) no longer typechecks (urweb/urweb#266)"; false)
	@# The verbatim #266 shape must KEEP failing with the too-deep error: if this
	@# starts passing, the elaborator's depth guard changed (e.g. PR#226) -- that
	@# must be a conscious, reviewed decision, not silent drift.
	@echo "==> [tc 6/8] deepunif_red (#266 limitation still pinned red)"
	(bin/urweb -tc -boot -noEmacs tests/deepunif_red 2>&1 | grep -q 'too-deep unification variable') || (echo "Test 'deepunif_red' failed: the verbatim urweb/urweb#266 shape no longer fails with the too-deep-unification-variable error -- the elaborator depth guard changed; review deliberately (fork issue #20)"; false)
	@echo "==> [tc 7/8] obgroup      (#269: grouped/aggregate ORDER BY typecheck)"
	bin/urweb -tc -boot -noEmacs tests/obgroup || (echo "Test 'obgroup' failed: a VALID ORDER BY (grouped column / aggregate / ungrouped query) no longer typechecks (urweb/urweb#269)"; false)
	@echo "==> [tc 8/8] obgroup_red  (#269: ungrouped ORDER BY column rejected)"
	(! bin/urweb -tc -boot -noEmacs tests/obgroup_red >/dev/null 2>&1) || (echo "Test 'obgroup_red' failed: ORDER BY on a NON-grouped bare column typechecked -- the #269 fix regressed (Postgres rejects this SQL at runtime)"; false)
	@# PR#279: a cookie set with HttpOnly = True must emit `httponly` in the
	@# Set-Cookie response header.
	@echo "==> [http 1/8] cookiehttponly (Set-Cookie HttpOnly flag, PR#279) — serving on :8083"
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
	@echo "==> [http 2/8] jsonsurrogate (UTF-16 surrogate-pair decode, #211) — serving on :8084"
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
	@echo "==> [http 3/8] respstatus (setResponseStatus 404/429, #222) — serving on :8085"
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
	@echo "==> [http 4/8] notfound (custom 404 notFoundPage, #39) — serving on :8086"
	tests/notfound.exe -q -a 127.0.0.1 -p 8086 & echo $$! > $(TESTPID)
	sleep 1
	(curl -si 'http://localhost:8086/Notfound/nope' | grep -qiE '^HTTP/[0-9.]+ 404( |$$)') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: an unmatched URL did not return a 404 status line (urweb/urweb#39)"; false)
	(curl -s 'http://localhost:8086/Notfound/nope' | grep -q 'NOTFOUND_CUSTOM_BODY') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: the custom notFoundPage body was not served on a 404 (urweb/urweb#39)"; false)
	(curl -si 'http://localhost:8086/Notfound/nope' | grep -qi '^content-type:.*text/html') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: custom 404 not served as text/html (urweb/urweb#39)"; false)
	(curl -s 'http://localhost:8086/Notfound/nope' | grep -qF '#top') || (kill `cat $(TESTPID)`; echo "Test 'notfound' failed: '#' in the custom page was lost (notFoundPage must read from a file, not the .urp line) (urweb/urweb#39)"; false)
	kill `cat $(TESTPID)`
	@# Standalone-server daemon flag: `-d <logfile>` forks BEFORE spawning any
	@# worker/pruner thread (forking a multi-threaded process would strand the
	@# other threads), the child setsid()s to detach and redirects stdout/stderr
	@# to <logfile>, and the PARENT prints "Daemonized: pid <n>" and exits 0. We
	@# run it in the FOREGROUND (no `&`): under -d a blocking invocation that
	@# returns is itself proof the server detached. Then we curl the backgrounded
	@# child (it must still serve), confirm the log file was written and that the
	@# app's background `task periodic` still fires in the child, and stop it via
	@# the reported pid.
	@echo "==> [http 5/8] daemon (-d detaches, logs, serves + keeps its 'task periodic', in background) — serving on :8087"
	@rm -f $(TESTDLOG) $(TESTDOUT)
	tests/daemon.exe -a 127.0.0.1 -p 8087 -d $(TESTDLOG) > $(TESTDOUT) || (echo "Test 'daemon' failed: the server exited nonzero under -d instead of daemonizing"; false)
	@sed -n 's/.*Daemonized: pid \([0-9][0-9]*\).*/\1/p' $(TESTDOUT) > $(TESTPID)
	(test -s $(TESTPID)) || (echo "Test 'daemon' failed: parent did not report a parseable 'Daemonized: pid <n>' on stdout under -d"; false)
	sleep 1
	(curl -sf 'http://localhost:8087/Daemon/main' | grep -q 'DAEMON_ALIVE') || (kill `cat $(TESTPID)` 2>/dev/null; echo "Test 'daemon' failed: the detached daemon did not serve /Daemon/main in the background"; false)
	(test -s $(TESTDLOG)) || (kill `cat $(TESTPID)` 2>/dev/null; echo "Test 'daemon' failed: -d log file $(TESTDLOG) was not written (stdout/stderr not redirected)"; false)
	@# The app declares `task periodic` -> uw_request_init spawns a periodic thread
	@# whose marker reaches the CHILD's redirected log ONLY if that thread lives in
	@# the daemon child, i.e. only if the fork happens before uw_request_init runs.
	@# This is the regression guard for the fork-must-precede-all-app-threads rule.
	(grep -q 'PERIODIC_FIRED' $(TESTDLOG)) || (kill `cat $(TESTPID)` 2>/dev/null; echo "Test 'daemon' failed: the app's 'task periodic' did not run in the daemon child -- fork() stranded the periodic thread (uw_request_init must run AFTER the fork)"; false)
	kill `cat $(TESTPID)`
	@# urweb/urweb#259 (svg/path half): inline SVG must render with the CORRECT
	@# SVG attribute spellings -- interior capitals kept (ViewBox -> viewBox) and
	@# '_' rendered as '-' (Fill_rule -> fill-rule). Greps the served HTML for the
	@# exact names, so a regression in attribute-name rendering fails, not just a
	@# missing declaration.
	@echo "==> [http 6/8] svgtag (inline svg/path render with viewBox + fill-rule, #259) — serving on :8088"
	tests/svgtag.exe -q -a 127.0.0.1 -p 8088 & echo $$! > $(TESTPID)
	sleep 1
	@# Liveness gate: if the fresh server died (e.g. bind failure against a stale
	@# survivor from an aborted run), fail HERE rather than letting the greps pass
	@# against whatever old process still answers on the port.
	kill -0 `cat $(TESTPID)` || (echo "Test 'svgtag' failed: the freshly started server is not running (stale process on :8088?)"; false)
	(curl -s 'http://localhost:8088/Svgtag/main' | grep -q 'viewBox="0 0 24 24"') || (kill `cat $(TESTPID)`; echo "Test 'svgtag' failed: viewBox attribute not rendered with its interior capital (urweb/urweb#259)"; false)
	(curl -s 'http://localhost:8088/Svgtag/main' | grep -q 'fill-rule="evenodd"') || (kill `cat $(TESTPID)`; echo "Test 'svgtag' failed: Fill_rule did not render as fill-rule (urweb/urweb#259)"; false)
	(curl -s 'http://localhost:8088/Svgtag/main' | grep -q 'stroke-width="2"') || (kill `cat $(TESTPID)`; echo "Test 'svgtag' failed: Stroke_width did not render as stroke-width (urweb/urweb#259)"; false)
	(curl -s 'http://localhost:8088/Svgtag/main' | grep -q 'xmlns="http://www.w3.org/2000/svg"') || (kill `cat $(TESTPID)`; echo "Test 'svgtag' failed: xmlns attribute missing from the svg tag (urweb/urweb#259)"; false)
	(curl -s 'http://localhost:8088/Svgtag/main' | grep -q 'd="M9 12l2 2 4-4"') || (kill `cat $(TESTPID)`; echo "Test 'svgtag' failed: single-letter D field did not render as the d attribute (urweb/urweb#259)"; false)
	(curl -s 'http://localhost:8088/Svgtag/main' | grep -q 'width="24"') || (kill `cat $(TESTPID)`; echo "Test 'svgtag' failed: string-typed Width did not render on svg (urweb/urweb#259)"; false)
	kill `cat $(TESTPID)`
	@# urweb/urweb#121 (verify-then-close): control characters in client-side
	@# string literals must never reach the emitted JavaScript raw. A REAL 0x08
	@# (via \x08 -- the lexer has no \b escape) plus \n and \t are compiled into
	@# app.js; jscomp's jsChar octal-escapes non-printables (0x08 -> \010) and the
	@# closure-serialization layer doubles backslashes, so the pinned wire form is
	@# A\\010B\\nC\\ttail. Assert (a) the exact encoding is present (anti-vacuity)
	@# and (b) NO raw 0x08 byte exists anywhere in the fetched app.js.
	@echo "==> [http 7/8] jsesc (control chars octal-escaped into app.js, #121) — serving on :8089"
	tests/jsesc.exe -q -a 127.0.0.1 -p 8089 & echo $$! > $(TESTPID)
	sleep 1
	kill -0 `cat $(TESTPID)` || (echo "Test 'jsesc' failed: the freshly started server is not running (stale process on :8089?)"; false)
	(curl -s "http://localhost:8089$$(curl -s 'http://localhost:8089/Jsesc/main' | grep -oE 'src="[^"]*"' | sed 's/src="//;s/"$$//')" -o /tmp/urweb.jsesc.js) || (kill `cat $(TESTPID)`; echo "Test 'jsesc' failed: could not fetch the served app.js (urweb/urweb#121)"; false)
	(grep -qF 'A\\010B\\nC\\ttail' /tmp/urweb.jsesc.js) || (kill `cat $(TESTPID)`; echo "Test 'jsesc' failed: the pinned octal wire encoding of the control-char literal is missing from app.js (urweb/urweb#121)"; false)
	(! grep -qP '\x08' /tmp/urweb.jsesc.js) || (kill `cat $(TESTPID)`; echo "Test 'jsesc' failed: a RAW 0x08 byte reached the emitted JavaScript (urweb/urweb#121)"; false)
	kill `cat $(TESTPID)`
	@# urweb/urweb#273 (+ the urweb/mail mechanism behind #110): a NULL-rollback
	@# transactional's commit callback runs AFTER the SQL COMMIT. /ok arms one
	@# that records it ran; /fail arms one that FAILS there. The failing request
	@# must return the callback's error (body unrendered) WITHOUT a bogus SQL
	@# ROLLBACK -- so /check must still see BOTH rows durable, the ok callback
	@# ran, and the server alive after the post-COMMIT failure.
	@echo "==> [http 8/8] postcommit (post-COMMIT transactional contract, #273/#110) — serving on :8090"
	rm -f $(TESTPCDB)
	sqlite3 $(TESTPCDB) < tests/postcommit.sql
	tests/postcommit.exe -q -a 127.0.0.1 -p 8090 & echo $$! > $(TESTPID)
	sleep 1
	kill -0 `cat $(TESTPID)` || (echo "Test 'postcommit' failed: the freshly started server is not running (stale process on :8090?)"; false)
	(curl -s 'http://localhost:8090/Postcommit/ok' | grep -q 'OK_ARMED') || (kill `cat $(TESTPID)`; echo "Test 'postcommit' failed: the successful post-COMMIT transactional request did not serve (urweb/urweb#273)"; false)
	(curl -s 'http://localhost:8090/Postcommit/fail' | grep -q 'POSTCOMMIT_FAILURE_MARKER') || (kill `cat $(TESTPID)`; echo "Test 'postcommit' failed: a failing post-COMMIT commit callback did not surface its error message (urweb/urweb#273)"; false)
	(! (curl -s 'http://localhost:8090/Postcommit/fail' | grep -q 'FAIL_BODY_MUST_NOT_RENDER')) || (kill `cat $(TESTPID)`; echo "Test 'postcommit' failed: the page body rendered despite the post-COMMIT callback failure (urweb/urweb#273)"; false)
	(curl -s 'http://localhost:8090/Postcommit/check' | grep -q 'CHECK:r1=okrow,r2=failrow,cb=True') || (kill `cat $(TESTPID)`; echo "Test 'postcommit' failed: post-COMMIT contract broken -- expected both rows durable (no bogus ROLLBACK), the ok callback run, and a live server (urweb/urweb#273 / #110)"; false)
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
	@out=`bin/urweb -boot -noEmacs -ccopt -O1 tests/hdrbad 2>&1`; \
	echo "$$out" | grep -q "Invalid string" \
	  || { echo "Test 'hdrbad' failed: blessRequestHeader accepted a name containing '/' (urweb/urweb#271). Compiler output:"; echo "$$out"; false; }
	@rm -f tests/hdrtok.exe; out=`bin/urweb -boot -noEmacs -ccopt -O1 tests/hdrtok 2>&1`; \
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

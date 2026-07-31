{
  autoconf,
  automake,
  curl,
  gcc,
  icu,
  lib,
  libtool,
  linkFarm,
  makeBinaryWrapper,
  mlton,
  openssl,
  pkg-config,
  postgresql,
  runCommand,
  sqlite,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "urweb";
  version = "20200209-unstable-2026-07-28";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.intersection (lib.fileset.gitTracked ./.) (
      lib.fileset.unions [
        ./autogen.sh
        ./configure.ac
        ./demo
        ./doc
        ./include
        ./lib
        ./m4
        ./Makefile.am
        ./src
        ./tests
        ./xml
      ]
    );
  };

  # build-time dependencies
  nativeBuildInputs = [
    autoconf
    automake
    libtool
    mlton
    pkg-config
  ];

  # link/runtime dependencies
  buildInputs = [
    icu
    openssl
    postgresql
    sqlite
  ];

  # test dependencies
  nativeCheckInputs = [
    curl
  ];

  configureFlags = [ "--with-openssl=${openssl.dev}" ];

  preConfigure = ''
    export SQHEADER="${sqlite.dev}/include/sqlite3.h"
    export PGHEADER="${postgresql.dev}/include/libpq-fe.h"
    export ICU_INCLUDES="-I${icu.dev}/include"
    export CC="${gcc}/bin/gcc"
    export CCARGS="-I$out/include \
      -L${lib.getLib openssl}/lib \
      -L${sqlite.out}/lib \
      -L${postgresql.lib}/lib \
      -Wno-error=int-conversion"
    ./autogen.sh
  '';

  # The urweb compiler links generated applications against the static
  # archives, so keep the .a files in the output.
  dontDisableStatic = true;

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    # REQUIRE_IPV6=1 turns "IPv6 unavailable" from a skip into a hard failure.
    # This is the ONLY place it can be armed for CI: the nix sandbox does not
    # inherit the environment, so setting it in ci.yml would do nothing -- and an
    # unarmed knob is exactly how the IPv6 checks came to be skipped on every CI
    # run while the suite still printed ALL CHECKS PASSED.  The sandbox
    # demonstrably has ::1 (proven by the first CI run that actually executed
    # them), so this is not speculative.  The cost is that `nix-build` on a
    # genuinely IPv6-less machine now fails loudly rather than skipping quietly,
    # which is the trade this whole change argues for.
    make test REQUIRE_IPV6=1
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    make install
    runHook postInstall
  '';

  /*
    withLibraries accepts urweb libraries:

      urweb-with-libs = urweb.withLibraries {
        foo = someLib;
      };

    Use it by calling the default executable:

      ${lib.getExe urweb-with-libs} ...

    This will allow importing the libraries in .urp files using

      library $NIX_LIBS/foo
  */
  passthru.withLibraries =
    libs:
    let
      libPath = linkFarm "urweb-libs" (lib.mapAttrsToList (name: path: { inherit name path; }) libs);
    in
    runCommand "urweb-with-libs"
      {
        nativeBuildInputs = [ makeBinaryWrapper ];
        meta.mainProgram = "urweb-with-libs";
      }
      ''
        makeWrapper ${finalAttrs.finalPackage}/bin/urweb $out/bin/urweb \
          --add-flags "-path NIX_LIBS ${libPath}"
      '';

  meta = {
    description = "Advanced purely-functional web programming language";
    mainProgram = "urweb";
    homepage = "http://www.impredicative.com/ur/";
    license = lib.licenses.bsd3;
    # CC is pinned to gcc in preConfigure and CI covers linux only; restore
    # darwin here once a darwin build is actually exercised.
    platforms = lib.platforms.linux;
    maintainers = [
      lib.maintainers.thoughtpolice
      lib.maintainers.sheganinans
    ];
  };
})

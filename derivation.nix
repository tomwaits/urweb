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
  mlton20210117,
  openssl,
  postgresql,
  runCommand,
  sqlite,
  stdenv,
  urweb,
}:

stdenv.mkDerivation {
  pname = "urweb";
  version = "20200209";

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
    mlton20210117
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
    make test
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
        makeWrapper ${urweb}/bin/urweb $out/bin/urweb \
          --add-flags "-path NIX_LIBS ${libPath}"
      '';

  meta = {
    description = "Advanced purely-functional web programming language";
    mainProgram = "urweb";
    homepage = "http://www.impredicative.com/ur/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [
      lib.maintainers.thoughtpolice
      lib.maintainers.sheganinans
    ];
  };
}

{ stdenv, lib, fetchurl, dpkg, pcsclite, libassuan, libgpgerror, nssTools }:
let
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    pcsclite
    libassuan
    libgpgerror
  ];
in stdenv.mkDerivation rec {
  name = "libpkcs-dnie-${version}";
  version = "1.6.6";
  src = fetchurl {
    url = "https://www.dnielectronico.es/descargas/distribuciones_linux/libpkcs11-dnie_${version}_amd64.deb";
    sha256 = "1qi3rsazp5g0qihqmfy9r9bmxm6kgh9pg4g29qcq3cq65jigcajn";
  };
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  buildInputs = [dpkg nssTools];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp -p usr/lib/* $out/lib
    echo '#!${stdenv.shell}' >> $out/bin/install-dnie
    echo "${nssTools}/bin/modutil -dbdir sql:\$HOME/.pki/nssdb -add "DNI-e" -libfile $out/lib/libpkcs11-dnie.so" >> $out/bin/install-dnie
    chmod a+x $out/bin/install-dnie
  '';

  fixupPhase = ''
    for lib in $out/lib/*so; do
      patchelf --set-rpath ${libPath}:$out/lib   $lib
    done
  '';

  meta = with lib; {
    description = "Libpkcs for DNI-e";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

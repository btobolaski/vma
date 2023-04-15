let
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  nixpkgs = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "2b1bba76a13ed39c7abc0a6e8f74f9e168cf3c7c";
    sha256 = "148rixn22aa1ayacx0nwpy53bhva1xw6adzr7lmydhnjdgciqagl";
  };
  pkgs = import nixpkgs {};

  nixpkgs_uring = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b54b679c90d143b6443d35c3900bdb981667b933";
    sha256 = "15gkjpslpm670lyqph5ady4aj2qc8z6pk5ikp40f46i8mjnazgy6";
  };
  pkgs_uring = import nixpkgs_uring {};

  liburing = pkgs_uring.liburing;

  stdenv = pkgs.stdenv;

  libproxmox-backup = stdenv.mkDerivation rec {
    pname = "libproxmox-backup";
    version = "1.3.1-1";

    src = pkgs.fetchurl {
      url = "http://download.proxmox.com/debian/dists/bullseye/pve-no-subscription/binary-amd64/libproxmox-backup-qemu0_${version}_amd64.deb";
      sha256 = "sha256-+kerPykquEK6cJ+DntJXYphse+pTJKvtxjaeasLBC24=";
    };

    nativeBuildInputs = [pkgs.dpkg];

    unpackPhase = ''
      dpkg -x $src .
    '';

    installPhase = ''
      mkdir -p $out/lib

      ls -lah usr/lib

      cp -ar usr/lib $out
    '';
  };

    vma = stdenv.mkDerivation rec {
      pname = "vma";
      version = "7.2.0-8";


      src = pkgs.fetchurl {
        url = "http://download.proxmox.com/debian/dists/bullseye/pve-no-subscription/binary-amd64/pve-qemu-kvm_${version}_amd64.deb";
        sha256 = "sha256-U4sN2UOn99bt3dgARtW9ujzBpYoyh7WC+MPQH0Tn/b8=";
      };

      nativeBuildInputs = [pkgs.dpkg];
      buildInputs = [pkgs.libiscsi];

      unpackPhase = ''
        dpkg -x $src .
      '';

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/lib

        cp -ar usr/bin $out
      '';

    postFixup = ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --replace-needed libiscsi.so.7 ${pkgs.libiscsi}/lib/libiscsi.so.9 \
        $out/bin/vma
    '';
        #--replace-needed liburing.so.1 ${liburing_0_2}/lib/liburing.so.2 \
  };
in (pkgs.buildFHSUserEnv {
  name = "vma";
  targetPkgs = pkgs: [
    libproxmox-backup
    vma
    pkgs.ceph.lib
    pkgs.curlWithGnuTls.out
    pkgs.glusterfs
    pkgs.libaio
    #pkgs.libiscsi
    pkgs.libuuid.out
    liburing
    pkgs.numactl
    pkgs.openssl_1_1.out
    pkgs.glib
    pkgs.glibc
    pkgs.gnutls.out
    pkgs.zstd.out
    pkgs.zlib.out
    pkgs.bash
  ];

  runScript = "bash";
}).env

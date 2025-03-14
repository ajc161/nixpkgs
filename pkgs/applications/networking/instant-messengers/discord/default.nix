{ branch ? "stable", callPackage, fetchurl, lib, stdenv, withOpenASAR ? false }:
let
  versions = if stdenv.isLinux then {
    stable = "0.0.18";
    ptb = "0.0.29";
    canary = "0.0.135";
  } else {
    stable = "0.0.264";
    ptb = "0.0.59";
    canary = "0.0.283";
  };
  version = versions.${branch};
  srcs = let
    darwin-ptb = fetchurl {
      url = "https://dl-ptb.discordapp.net/apps/osx/${version}/DiscordPTB.dmg";
      sha256 = "sha256-LS7KExVXkOv8O/GrisPMbBxg/pwoDXIOo1dK9wk1yB8=";
    };
  in {
    x86_64-linux = {
      stable = fetchurl {
        url =
          "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "1hl01rf3l6kblx5v7rwnwms30iz8zw6dwlkjsx2f1iipljgkh5q4";
      };
      ptb = fetchurl {
        url =
          "https://dl-ptb.discordapp.net/apps/linux/${version}/discord-ptb-${version}.tar.gz";
        sha256 = "d78NnQZ3MkLje8mHrI6noH2iD2oEvSJ3cDnsmzQsUYc=";
      };
      canary = fetchurl {
        url =
          "https://dl-canary.discordapp.net/apps/linux/${version}/discord-canary-${version}.tar.gz";
        sha256 = "sha256-dmG+3BWS1BMHHQAv4fsXuObVeAJBeD+TqnyQz69AMac=";
      };
    };
    x86_64-darwin = {
      stable = fetchurl {
        url = "https://dl.discordapp.net/apps/osx/${version}/Discord.dmg";
        sha256 = "1jvlxmbfqhslsr16prsgbki77kq7i3ipbkbn67pnwlnis40y9s7p";
      };
      ptb = darwin-ptb;
      canary = fetchurl {
        url =
          "https://dl-canary.discordapp.net/apps/osx/${version}/DiscordCanary.dmg";
        sha256 = "0mqpk1szp46mih95x42ld32rrspc6jx1j7qdaxf01whzb3d4pi9l";
      };
    };
    # Only PTB bundles a MachO Universal binary with ARM support.
    aarch64-darwin = { ptb = darwin-ptb; };
  };
  src = srcs.${stdenv.hostPlatform.system}.${branch};

  meta = with lib; {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    downloadPage = "https://discordapp.com/download";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ldesgoui MP2E devins2518 ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ]
      ++ lib.optionals (branch == "ptb") [ "aarch64-darwin" ];
  };
  package = if stdenv.isLinux then ./linux.nix else ./darwin.nix;

  openasar = if withOpenASAR then callPackage ./openasar.nix { } else null;

  packages = (builtins.mapAttrs
    (_: value: callPackage package (value // { inherit src version openasar; meta = meta // { mainProgram = value.binaryName; }; }))
    {
      stable = rec {
        pname = "discord";
        binaryName = "Discord";
        desktopName = "Discord";
      };
      ptb = rec {
        pname = "discord-ptb";
        binaryName = "DiscordPTB";
        desktopName = "Discord PTB";
      };
      canary = rec {
        pname = "discord-canary";
        binaryName = "DiscordCanary";
        desktopName = "Discord Canary";
      };
    }
  );
in packages.${branch}

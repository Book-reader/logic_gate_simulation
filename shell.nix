{ pkgs ? import <nixpkgs> {} }:
let
	c3c = pkgs.callPackage ((pkgs.fetchFromGitHub {
		owner = "c3lang";
		repo = "c3c";
		rev = "b6f5938eda9109c8777cf451503580e47ed08dd9";
		sha256 = "sha256-HztgRZNYr/3VYPGwHTP/v2BnTIlApKdxCx+Ir44IWuU=";
	} + "/nix")) {};
in
pkgs.mkShellNoCC {
	packages = with pkgs; [ gcc c3c ];
	LD_LIBRARY_PATH = with pkgs; ''$LD_LIBRARY_PATH:${
		lib.makeLibraryPath [
			libGL
			xorg.libX11
		]
	}'';
}

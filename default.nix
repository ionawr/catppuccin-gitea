{inputs, ...}: {
  perSystem = {
    pkgs,
    inputs',
    self',
    system,
    ...
  }: {
    formatter = pkgs.alejandra;

    packages = {
      default = self'.packages.css;

      css = pkgs.stdenv.mkDerivation {
        pname = "catppuccin-gitea";
        version = "1.0.0";
        src = inputs.self;

        nativeBuildInputs = with pkgs; [
          deno
          nodejs
          cacert
        ];

        buildPhase = ''
          export HOME=$TMPDIR
          export DENO_DIR=$TMPDIR/deno
          export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export NODE_EXTRA_CA_CERTS=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

          deno cache --node-modules-dir build.ts || true
          mkdir -p node_modules/@catppuccin
          rm -rf node_modules/@catppuccin/palette
          cp -r ${inputs.palette.packages.${system}.npm} node_modules/@catppuccin/palette

          deno task build
        '';

        installPhase = ''
          cp -r dist/ $out
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-bfzIxIwwmPBMox0v3KDK7xXQiwraaGoLi+STulKGX70=";
      };
    };
  };
}

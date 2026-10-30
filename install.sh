#!/bin/sh
# Actario installer for macOS and Linux:
#
#   curl -fsSL https://actario.app/install.sh | sh
#
# Downloads Actario with its own Node (nothing to install first) into
# ~/.actario-app/runtime, checks it against the release's SHA256SUMS.txt, then
# installs the plugin into Claude Code and Codex if they are on this computer.
# Run it again to update.
#
#   ACTARIO_VERSION=v0.2.13   a specific release instead of the latest
#   ACTARIO_APP_DIR=<dir>     install somewhere other than ~/.actario-app
#   ACTARIO_DOWNLOAD_BASE=<url>  fetch the release files from there (a mirror, a test server)
#   sh -s -- --no-codex       flags after `--` go to the setup step
#
# Everything is inside main(), called on the last line: `curl | sh` runs
# nothing until the whole script has arrived.

set -eu

main() {
  repo="${ACTARIO_REPO:-actario/actario-plugin}"
  version="${ACTARIO_VERSION:-latest}"
  app="${ACTARIO_APP_DIR:-$HOME/.actario-app}"

  case "$(uname -s)" in
    Darwin) os=mac ;;
    Linux) os=linux ;;
    *) fail "This installer is for macOS and Linux. On Windows, in PowerShell: irm https://actario.app/install.ps1 | iex" ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64) arch=x64 ;;
    arm64 | aarch64) arch=arm64 ;;
    *) fail "Unsupported processor: $(uname -m)" ;;
  esac
  # A Terminal running under Rosetta reports x86_64 on an Apple-silicon Mac.
  if [ "$os" = mac ] && [ "$arch" = x64 ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
    arch=arm64
  fi

  asset="actario-runtime-$os-$arch.tar.gz"
  if [ -n "${ACTARIO_DOWNLOAD_BASE:-}" ]; then
    base="$ACTARIO_DOWNLOAD_BASE"
  elif [ "$version" = latest ]; then
    base="https://github.com/$repo/releases/latest/download"
  else
    base="https://github.com/$repo/releases/download/$version"
  fi

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT INT TERM

  echo "Downloading Actario for $os-$arch …"
  fetch "$base/SHA256SUMS.txt" "$tmp/SHA256SUMS.txt"
  fetch "$base/$asset" "$tmp/$asset"

  want="$(awk -v f="$asset" '$2 == f { print $1 }' "$tmp/SHA256SUMS.txt")"
  [ -n "$want" ] || fail "SHA256SUMS.txt does not list $asset"
  if command -v sha256sum >/dev/null 2>&1; then
    got="$(sha256sum "$tmp/$asset" | awk '{ print $1 }')"
  else
    got="$(shasum -a 256 "$tmp/$asset" | awk '{ print $1 }')"
  fi
  [ "$got" = "$want" ] || fail "Checksum mismatch for $asset (got $got, expected $want). Nothing was installed."

  mkdir -p "$app"
  rm -rf "$app/runtime.new"
  mkdir "$app/runtime.new"
  tar -xzf "$tmp/$asset" -C "$app/runtime.new"
  chmod +x "$app/runtime.new/node/node"
  rm -rf "$app/runtime"
  mv "$app/runtime.new" "$app/runtime"

  # The setup step may open a browser to sign in (Codex); give it the
  # terminal rather than the pipe this script arrived on.
  if [ -r /dev/tty ] && (: </dev/tty) 2>/dev/null; then
    "$app/runtime/node/node" "$app/runtime/setup.mjs" "$@" </dev/tty
  else
    "$app/runtime/node/node" "$app/runtime/setup.mjs" "$@" </dev/null
  fi

  case ":$PATH:" in
    *":$app/bin:"*) ;;
    *)
      echo
      echo "To use the actario command in a terminal, add this to your shell profile:"
      echo "  export PATH=\"$app/bin:\$PATH\""
      ;;
  esac
}

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 2 -o "$2" "$1" || fail "Could not download $1"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$2" "$1" || fail "Could not download $1"
  else
    fail "Needs curl or wget."
  fi
}

fail() {
  echo "actario install: $1" >&2
  exit 1
}

main "$@"

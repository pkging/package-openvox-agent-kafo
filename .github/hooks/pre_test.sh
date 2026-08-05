#!/usr/bin/env bash
set -euo pipefail

source /workspace/.ci-workflows/hooks/lib/distro.sh
source /workspace/.ci-workflows/hooks/lib/common.sh || true

log "Project pre-test hook – distro: $ID ($ID_LIKE)"

echo "[DEBUG] /etc/os-release content:"
cat /etc/os-release || true
echo "[DEBUG] Detected ID=$ID, ID_LIKE=$ID_LIKE, RELEASE=${RELEASE:-unknown}"

fail_unsupported() {
  echo "[ERROR] $*" >&2
  exit 1
}

if is_el || is_fedora; then
  log "RPM-basierte Distro erkannt – installiere OpenVox..."

  if is_el; then
    case "${RELEASE}" in
      8|9|10) ;;
      *)
        fail_unsupported "OpenVox 8 Release-Paket fuer EL ${RELEASE} ist nicht in der Allowlist. Unterstuetzte EL-Versionen: 8, 9, 10."
        ;;
    esac
    release_url="https://yum.voxpupuli.org/openvox8-release-el-${RELEASE}.noarch.rpm"
    packages_url="https://packages.private.prefork.de/epel/${RELEASE}/Packages/p/prefork-packages-1.0.0-1.el${RELEASE}.noarch.rpm"
  elif is_fedora; then
    case "${RELEASE}" in
      43|44) ;;
      *)
        fail_unsupported "OpenVox 8 Release-Paket fuer Fedora ${RELEASE} ist nicht in der Allowlist. Unterstuetzte Fedora-Versionen: 43, 44."
        ;;
    esac
    release_url="https://yum.voxpupuli.org/openvox8-release-fedora-${RELEASE}.noarch.rpm"
    packages_url="https://packages.private.prefork.de/fedora/${RELEASE}/Packages/p/prefork-packages-1.0.0-1.fc${RELEASE}.noarch.rpm"
  else
    fail_unsupported "Konnte RPM-Distribution nicht klassifizieren (ID=${ID}, ID_LIKE=${ID_LIKE}, RELEASE=${RELEASE})."
  fi

  dnf install -y --allowerasing ca-certificates curl
  if ! curl -fsSI "${release_url}" >/dev/null; then
    fail_unsupported "Release-Paket nicht erreichbar: ${release_url}."
  fi

  dnf install -y --allowerasing "${release_url}" "${packages_url}"
  dnf makecache
elif is_debian || is_ubuntu; then
  log "Debian/Ubuntu erkannt - installiere OpenVox 8 APT Repository..."

  if is_debian; then
    case "${RELEASE}" in
      10|11|12|13) ;;
      *)
        fail_unsupported "OpenVox 8 Release-Paket fuer Debian ${RELEASE} ist nicht in der Allowlist. Unterstuetzte Debian-Versionen: 10, 11, 12, 13."
        ;;
    esac
    release_pkg="openvox8-release-debian${RELEASE}.deb"
    packages_pkg="prefork-packages_1.0.0-1+debian${RELEASE}_all.deb"
  else
    case "${VERSION_ID}" in
      18.04|20.04|22.04|24.04|25.04|26.04) ;;
      *)
        fail_unsupported "OpenVox 8 Release-Paket fuer Ubuntu ${VERSION_ID} ist nicht in der Allowlist. Unterstuetzte Ubuntu-Versionen: 18.04, 20.04, 22.04, 24.04, 25.04, 26.04."
        ;;
    esac
    release_pkg="openvox8-release-ubuntu${VERSION_ID}.deb"
    packages_pkg="prefork-packages_1.0.0-1+ubuntu${VERSION_ID//./}_all.deb"
  fi

  release_url="https://apt.voxpupuli.org/${release_pkg}"
  log "Installing release package: ${release_url}"

  apt-get update -y
  apt-get install -y --no-install-recommends ca-certificates curl

  if ! curl -fsSI "${release_url}" >/dev/null; then
    fail_unsupported "Release-Paket nicht erreichbar: ${release_url}."
  fi

  curl -fL --retry 3 -o "/tmp/${release_pkg}" "${release_url}"
  apt-get install -y "/tmp/${release_pkg}"

  packages_url="https://packages.private.prefork.de/${ID}/pool/main/p/prefork-packages/${packages_pkg}"
  log "Installing release package: ${packages_url}"

  if ! curl -fsSI "${packages_url}" >/dev/null; then
    fail_unsupported "Release-Paket nicht erreichbar: ${packages_url}."
  fi

  curl -fL --retry 3 -o "/tmp/${packages_pkg}" "${packages_url}"
  apt-get install -y "/tmp/${packages_pkg}"

  apt-get update -y
else
  log "Nicht-RHEL-kompatible Distribution – epel-release wird übersprungen."
fi

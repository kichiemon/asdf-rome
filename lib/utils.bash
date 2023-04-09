#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/rome/tools"
TOOL_NAME="rome"
TOOL_TEST="rome help"

fail() {
	# Output an error message and exit with a non-zero status
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if rome is not hosted on GitHub releases.
# Use an authorization token for accessing GitHub API
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -r -H "Authorization: token $GITHUB_API_TOKEN")
fi

# Sort versions in a format compatible with the version of the tool
sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/\./&000/3; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# List all tags associated with the repository
list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/cli/.*' | cut -d/ -f3- |
		sed 's/^cli\/v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

# List all available versions of the tool
list_all_versions() {
	list_github_tags
}

# Get the machine architecture, converting it to lowercase
get_machine_arch() {
	local ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

	# Map the machine architecture to the appropriate value
	case "${ARCH}" in
	i?86) echo "386" ;;
	x86_64) echo "amd64" ;;
	aarch64) echo "arm64" ;;
	armv8l) echo "arm64" ;;
	arm64) echo "arm64" ;;
	*) fail "Architecture not supported: $ARCH" ;;
	esac
}

# Get the machine operating system, converting it to lowercase
get_machine_os() {
	local OS=$(uname -s | tr '[:upper:]' '[:lower:]')

	# Map the machine operating system to the appropriate value
	case "${OS}" in
	darwin*) echo "darwin" ;;
	linux*) echo "linux" ;;
	*) fail "OS not supported: ${OS}" ;;
	esac
}

# judge download url for platform - see https://docs.rome.tools/standalone-executable/
download_url_for_platform() {
	local v="$1"
	local machine_os=$(get_machine_os)
	local machine_arch=$(get_machine_arch)
	# Determine the appropriate download URL based on the machine OS and architecture
	if [ $machine_os == "darwin" ]; then
		case "$machine_arch" in
		amd64) echo "https://github.com/rome/tools/releases/download/cli%2Fv$v/rome-darwin-x64" ;;
		arm64) echo "https://github.com/rome/tools/releases/download/cli%2Fv$v/rome-darwin-arm64" ;;
		*) fail "not supported" ;;
		esac
	else
		case "$machine_arch" in
		amd64) echo "https://github.com/rome/tools/releases/download/cli%2Fv$v/rome-linux-x64" ;;
		arm64) echo "https://github.com/rome/tools/releases/download/cli%2Fv$v/rome-linux-arm64" ;;
		*) fail "not supported" ;;
		esac
	fi
}
# This function downloads the release of the tool.
download_release() {
	local version filename url
	version="$1"
	filename="$2"

	# Generate the download URL.
	url=$(download_url_for_platform "$version")

	# Download the release using curl.
	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o $filename -C - "$url" || fail "Could not download $url"
}

# This function installs the tool.
install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	# Check if the installation type is correct.
	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	# Install the tool.
	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$install_path"
		chmod +x $install_path/$TOOL_NAME

		# Test the installation.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		# Rollback the installation in case of errors.
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}

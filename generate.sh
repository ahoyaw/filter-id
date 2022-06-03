echo "::group::Init"

set -e

log () {
    echo `date +"%m/%d/%Y %H:%M:%S"` "$@"
}

cleanup() {
    rm -f filter-id >> /dev/null 2>&1
}

cleanup

# Make sure all dependencies are installed
sudo apt-get install -y unzip wget || true

echo "::endgroup::"

echo "::group::Build executable"
log "Building"
go build -v -o filter-id
echo "::endgroup::"

echo "::group::Downloading latest ruleset_converter build"

install_bromite_ruleset_converter() {
    log "Downloading from latest Bromite release"
    rm -rf deps || true
    mkdir -p deps
    wget -O "deps/ruleset_converter" "https://github.com/bromite/bromite/releases/latest/download/ruleset_converter"
}

install_selfbuilt_ruleset_converter() {
    log "Downloading from latest self-built release"
    rm -rf deps || true
    mkdir -p deps
    
    wget -O "subresource_filter_tools_linux.zip" "https://github.com/xarantolus/subresource_filter_tools/releases/latest/download/subresource_filter_tools_linux-x64.zip"

    unzip -ou "subresource_filter_tools_linux.zip" -d deps

    rm "subresource_filter_tools_linux.zip"
}

# If the latest official Bromite release contains the ruleset_converter tool, we fetch it from there.
# If not, we just download from another build and unzip it from there
install_bromite_ruleset_converter || install_selfbuilt_ruleset_converter

echo "::endgroup::"

echo "::group::Other setup steps"
chmod +x filter-id
chmod +x deps/ruleset_converter
mkdir -p dist
mkdir -p logs
echo "::endgroup::"

# Now that everything is set up, we can start actually generating filter lists
./filter-id 

echo "::group::Cleanup"
cleanup

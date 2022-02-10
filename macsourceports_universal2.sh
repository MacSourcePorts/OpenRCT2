# game/app specific values
export APP_VERSION="1.2.0"
export ICONSDIR="resources/mac/"
export ICONSFILENAME="openrct2"
export PRODUCT_NAME="OpenRCT2"
export EXECUTABLE_NAME="OpenRCT2"
export PKGINFO="APPLERCT2"
export COPYRIGHT_TEXT="RollerCoaster Tycoon Copyright © 2002 Chris Sawyer. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=./install -DARCH=x86_64 ..
make -j$NCPU install

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_INSTALL_PREFIX=./install ..
make -j$NCPU install

cd ..

# create the app bundle
"../MSPScripts/build_app_bundle.sh" "skiplipo"

# this is similar to what their create-macos-universal thing does

rsync -ah ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
rsync -ah ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create

# we only do one Frameworks folder since the ones OpenRCT2 supplies are Universal 2 already
echo mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;
rsync -ah --exclude 'libopenrct2.dylib' ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

#sign and notarize
export ENTITLEMENTS_FILE="OpenRCT2.entitlements"
"../MSPScripts/sign_and_notarize.sh" "$1" entitlements
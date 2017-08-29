#!/usr/bin/env bash

PROJECT_PATH=$1

echo "$PROJECT_PATH"

MAJOR=`grep "set(OCTASPIRE_CORE_CONFIG_VERSION_MAJOR" "$PROJECT_PATH/CMakeLists.txt" | awk '{ print $2 }' | sed s/\)//`
MINOR=`grep "set(OCTASPIRE_CORE_CONFIG_VERSION_MINOR" "$PROJECT_PATH/CMakeLists.txt" | awk '{ print $2 }' | sed s/\)//`
PATCH=`grep "set(OCTASPIRE_CORE_CONFIG_VERSION_PATCH" "$PROJECT_PATH/CMakeLists.txt" | awk '{ print $2 }' | sed s/\)//`

echo    ""
echo    "-------------- New release for Octaspire Core --------------"
echo    ""
echo    "Current version is $MAJOR.$MINOR.$PATCH"
echo -n "Is this release major, minor or patch? [major/minor/patch]: "

create_new_version() {
    MAJOR=$1
    MINOR=$2
    PATCH=$3
    NEW_MAJOR=$4
    NEW_MINOR=$5
    NEW_PATCH=$6

    echo "New version is $NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"

    echo "Updating CMakeLists.txt..."
    sed -i "s/set(OCTASPIRE_CORE_CONFIG_VERSION_MAJOR $MAJOR)/set(OCTASPIRE_CORE_CONFIG_VERSION_MAJOR $NEW_MAJOR)/" "$PROJECT_PATH/CMakeLists.txt"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    sed -i "s/set(OCTASPIRE_CORE_CONFIG_VERSION_MINOR $MINOR)/set(OCTASPIRE_CORE_CONFIG_VERSION_MINOR $NEW_MINOR)/" "$PROJECT_PATH/CMakeLists.txt"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    sed -i "s/set(OCTASPIRE_CORE_CONFIG_VERSION_PATCH $PATCH)/set(OCTASPIRE_CORE_CONFIG_VERSION_PATCH $NEW_PATCH)/" "$PROJECT_PATH/CMakeLists.txt"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    sed -i "s/Documentation for Octaspire Core library version $MAJOR.$MINOR.$PATCH/Documentation for Octaspire Core library version $NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/" "$PROJECT_PATH/doc/book/Octaspire_Core_Manual.adoc"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Running make..."
    make
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Testing..."
    make test
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Building book..."
    make book-core
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Generating amalgamation..."
    "$PROJECT_PATH/etc/amalgamate.sh" "$PROJECT_PATH/etc"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Compiling amalgamation..."
    gcc -std=c99 -Wall -Wextra -pedantic -Werror -DOCTASPIRE_CORE_AMALGAMATED_UNIT_TEST_IMPLEMENTATION -DGREATEST_ENABLE_ANSI_COLORS "$PROJECT_PATH/etc/octaspire_core_amalgamated.c" -lm -o "$PROJECT_PATH/build/octaspire_core_amalgamated_test_runner"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Testing amalgamation..."
    "$PROJECT_PATH/build/octaspire_core_amalgamated_test_runner"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Removing old release directory, archive and signature..."
    rm -rf "$PROJECT_PATH/etc/release.tar.bz2"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    rm -rf "$PROJECT_PATH/etc/release.tar.bz2.sig"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    rm -rf "$PROJECT_PATH/etc/release"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Creating a directories for the source release..."
    mkdir -p "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    mkdir -p "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/documentation"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    mkdir -p "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/examples"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Create a README file..."
    cat << EOFEOF > "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/README"

This is amalgamated single file source release for Octaspire Core library
version $NEW_MAJOR.$NEW_MINOR.$NEW_PATCH. File 'octaspire-core-amalgamated.c'
is all that is needed; it has no other dependencies than a C compiler and
standard library supporting C99.

SHA-512 checksums for this and older releases can be found from:
https://octaspire.github.io/core/
If you want to check this release, download checksums for version $NEW_MAJOR.$NEW_MINOR.$NEW_PATCH from:
https://octaspire.github.io/core/checksums-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH

Building instructions for all supported platforms (and scripts for building
automatically) can be found in directory 'how-to-build'. Look for a file that
has your platform's name in the file's name. If instructions for your
platform are not yet added, looking instructions for a similar system will
probably help. The amalgamation contains only one source file and should be
straightforward to use. By using few compiler defines, the single file can
be used for different purposes:

    (1) to build stand-alone unit test runner for the file.
    (2) to use the file as a single file header+library in C/C++ programs
        wanting to use the Octaspire Core library.

Octaspire Core is work in progress. The most recent version
of this amalgamated source release can be downloaded from:

    * octaspire.com/core/release.tar.bz2
    * https://octaspire.io/core/release.tar.bz2
    * https://octaspire.github.io/core/release.tar.bz2

Directory 'documentation' contains the book 'Octaspire Core Manual'
and directory 'examples' has some short examples.

More information about Core can be found from the homepage:
octaspire.com/core
https://octaspire.io/core
EOFEOF
RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Copying amalgamation..."
    cp "$PROJECT_PATH/etc/octaspire_core_amalgamated.c" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/octaspire-core-amalgamated.c"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Copying LICENSE file..."
    cp "$PROJECT_PATH/LICENSE" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/LICENSE"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Copying book to the release directory..."
    cp "$PROJECT_PATH/doc/book/Octaspire_Core_Manual.html" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/documentation/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    cp "$PROJECT_PATH/doc/book/Octaspire_Core_Manual.pdf" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/documentation/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Copying examples..."
    cp "$PROJECT_PATH/doc/examples/hash-map-example.c" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/examples/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    cp "$PROJECT_PATH/doc/examples/string-example.c" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/examples/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    cp "$PROJECT_PATH/doc/examples/vector-example.c" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/examples/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Copying build scripts to the release directory..."
    cp -r "$PROJECT_PATH/etc/how-to-build/" "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Compressing release directory into tar.bz2..."
    cd "$PROJECT_PATH/etc/"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    tar --bzip2 -cf "release.tar.bz2" release
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Signing release.tar.bz2..."
    gpg -u 9bd2ccd560e9e29c --output "release.tar.bz2.sig" --detach-sig release.tar.bz2
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Removing $PROJECT_PATH/release/ and creating it again with updates"
    rm -rf "$PROJECT_PATH/release"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    cp -r "$PROJECT_PATH/etc/release/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH" "$PROJECT_PATH"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi
    mv "$PROJECT_PATH/version-$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH" "$PROJECT_PATH/release"
    RETVAL=$?; if [ $RETVAL != 0 ]; then exit $RETVAL; fi

    echo "Release $NEW_MAJOR.$NEW_MINOR.$NEW_PATCH created."
}

read RELTYPE

if [ $RELTYPE = major ]; then
    echo "MAJOR RELEASE"
    NEW_MAJOR=$((MAJOR + 1))
    NEW_MINOR=0
    NEW_PATCH=0

    create_new_version $MAJOR $MINOR $PATCH $NEW_MAJOR $NEW_MINOR $NEW_PATCH

elif [ $RELTYPE = minor ]; then
    echo "MINOR RELEASE"
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$((MINOR + 1))
    NEW_PATCH=0

    create_new_version $MAJOR $MINOR $PATCH $NEW_MAJOR $NEW_MINOR $NEW_PATCH

elif [ $RELTYPE = patch ]; then
    echo "PATCH RELEASE"
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$MINOR
    NEW_PATCH=$((PATCH + 1))

    create_new_version $MAJOR $MINOR $PATCH $NEW_MAJOR $NEW_MINOR $NEW_PATCH

else
    echo "========================================================="
    echo "= major, minor or patch was expected. Going to quit now ="
    echo "========================================================="
    exit 1
fi

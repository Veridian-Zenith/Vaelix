#!/usr/bin/env fish
# Detect logical CPU cores and update android/gradle.properties org.gradle.workers.max value

set file android/gradle.properties
if not test -f $file
    echo "No $file found"
    exit 1
end

# Detect logical processors
set cores (nproc)
if test -z "$cores"
    # fallback
    set cores 2
end

# Use cores as worker count, but keep a reasonable cap
set workers $cores
if test $workers -gt 8
    set workers 8
end

echo "Detected $cores logical CPUs."

echo "Done."
